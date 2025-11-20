import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'offline_status.dart';
import 'json_codec.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  Database? _db;
  bool _initialized = false;

  final Map<String, StreamController<List<Map<String, dynamic>>>>
      _tableControllers = {};
  final Map<String, List<Map<String, dynamic>>> _latestCache = {};

  Future<void> initialize() async {
    if (_initialized) return;

    final Directory appDocDir = await getApplicationDocumentsDirectory();
    final dbPath = p.join(appDocDir.path, 'offline_cache.db');

    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await _createTables(db);
      },
      onOpen: (db) async {
        await _createTables(db);
      },
    );

    // Seed controllers for already created watchers.
    for (final table in _tableControllers.keys) {
      final data = await _getCachedEntities(table);
      _tableControllers[table]!.add(data);
    }

    _initialized = true;
  }

  Future<Map<String, dynamic>?> getEntity(String table, String id) async {
    final rows = await _db!.query(
      'cache_entities',
      where: 'table_name = ? AND entity_id = ?',
      whereArgs: [table, id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return _decodeCacheRow(rows.first);
  }

  Future<void> upsertEntity({
    required String table,
    required String id,
    required Map<String, dynamic> data,
    SyncStatus status = SyncStatus.pending,
  }) async {
    final encoded = jsonEncode(encodeForStorage(data));
    final now = DateTime.now().millisecondsSinceEpoch;
    await _db!.insert('cache_entities', {
      'table_name': table,
      'entity_id': id,
      'data': encoded,
      'status': status.value,
      'updated_at': now,
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await _notifyWatchers(table);
  }

  Future<void> markEntityStatus({
    required String table,
    required String id,
    required SyncStatus status,
  }) async {
    await _db!.update(
      'cache_entities',
      {
        'status': status.value,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      },
      where: 'table_name = ? AND entity_id = ?',
      whereArgs: [table, id],
    );
    await _notifyWatchers(table);
  }

  Future<void> deleteEntity({required String table, required String id}) async {
    await _db!.delete(
      'cache_entities',
      where: 'table_name = ? AND entity_id = ?',
      whereArgs: [table, id],
    );
    await _notifyWatchers(table);
  }

  Future<void> deleteEntitiesByPrefix({
    required String table,
    required String prefix,
  }) async {
    await _db!.delete(
      'cache_entities',
      where: 'table_name = ? AND entity_id LIKE ?',
      whereArgs: [table, '$prefix%'],
    );
    await _notifyWatchers(table);
  }

  Stream<List<Map<String, dynamic>>> watchEntities(String table) {
    final baseController = _tableControllers.putIfAbsent(
      table,
      () => StreamController<List<Map<String, dynamic>>>.broadcast(),
    );

    late final StreamController<List<Map<String, dynamic>>> controller;
    StreamSubscription<List<Map<String, dynamic>>>? subscription;

    controller = StreamController<List<Map<String, dynamic>>>.broadcast(
      onListen: () async {
        final latest = await _getLatestSnapshot(table);
        controller.add(latest);
        subscription = baseController.stream.listen(
          controller.add,
          onError: controller.addError,
        );
      },
      onCancel: () {
        subscription?.cancel();
        controller.close();
      },
    );

    return controller.stream;
  }

  Future<void> queueOperation({
    required String entityType,
    required String action,
    required Map<String, dynamic> payload,
  }) async {
    await _db!.insert('pending_operations', {
      'entity_type': entityType,
      'action': action,
      'payload': jsonEncode(encodeForStorage(payload)),
      'status': SyncStatus.pending.value,
      'retry_count': 0,
      'created_at': DateTime.now().millisecondsSinceEpoch,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingOperations() async {
    return _db!.query('pending_operations', orderBy: 'created_at ASC');
  }

  Future<void> updateOperationStatus({
    required int id,
    required SyncStatus status,
    int? retryCount,
  }) async {
    final values = <String, Object?>{'status': status.value};
    if (retryCount != null) {
      values['retry_count'] = retryCount;
    }
    await _db!.update(
      'pending_operations',
      values,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> _getCachedEntities(String table) async {
    final rows = await _db!.query(
      'cache_entities',
      where: 'table_name = ?',
      whereArgs: [table],
      orderBy: 'updated_at DESC',
    );
    final data = rows.map(_decodeCacheRow).toList();
    _latestCache[table] = data;
    return data;
  }

  Map<String, dynamic> _decodeCacheRow(Map<String, Object?> row) {
    final data = decodeFromStorage(
      Map<String, dynamic>.from(jsonDecode(row['data'] as String) as Map),
    );
    data['__entity_id'] = row['entity_id'];
    data['__sync_status'] = row['status'];
    data['__updated_at'] = row['updated_at'];
    return data;
  }

  Future<void> _notifyWatchers(String table) async {
    if (!_tableControllers.containsKey(table)) return;
    final data = await _getCachedEntities(table);
    _tableControllers[table]!.add(data);
  }

  Future<List<Map<String, dynamic>>> _getLatestSnapshot(String table) async {
    final cached = _latestCache[table];
    if (cached != null) {
      return cached.map((row) => Map<String, dynamic>.from(row)).toList();
    }
    return _getCachedEntities(table);
  }

  Future<void> removePendingOperations({
    required String entityType,
    required bool Function(Map<String, dynamic> payload) matcher,
  }) async {
    final rows = await _db!.query(
      'pending_operations',
      where: 'entity_type = ?',
      whereArgs: [entityType],
    );
    if (rows.isEmpty) return;
    final idsToDelete = <int>[];
    for (final row in rows) {
      final payload = decodeFromStorage(
        Map<String, dynamic>.from(jsonDecode(row['payload'] as String) as Map),
      );
      if (matcher(payload)) {
        idsToDelete.add(row['id'] as int);
      }
    }
    if (idsToDelete.isEmpty) return;
    final placeholders = List.filled(idsToDelete.length, '?').join(',');
    await _db!.delete(
      'pending_operations',
      where: 'id IN ($placeholders)',
      whereArgs: idsToDelete,
    );
  }

  Future<void> _createTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS cache_entities (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT NOT NULL,
        entity_id TEXT NOT NULL,
        data TEXT NOT NULL,
        status TEXT NOT NULL,
        updated_at INTEGER NOT NULL,
        UNIQUE(table_name, entity_id)
      );
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS cache_entities_table_idx ON cache_entities(table_name);',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS cache_entities_entity_idx ON cache_entities(entity_id);',
    );
    await db.execute('''
      CREATE TABLE IF NOT EXISTS pending_operations (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        action TEXT NOT NULL,
        payload TEXT NOT NULL,
        status TEXT NOT NULL,
        retry_count INTEGER NOT NULL DEFAULT 0,
        created_at INTEGER NOT NULL
      );
    ''');
    await db.execute(
      'CREATE INDEX IF NOT EXISTS pending_operations_status_idx ON pending_operations(status);',
    );
  }
}
