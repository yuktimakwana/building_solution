import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../model/record_model.dart';
import '../utils/functions.dart';
import '../utils/text_constant.dart';
import 'connectivity_notifier.dart';
import 'local_database.dart';
import 'offline_status.dart';
import 'pending_operation.dart';

class OfflineSyncService {
  OfflineSyncService._();

  static final OfflineSyncService instance = OfflineSyncService._();

  final LocalDatabase _localDb = LocalDatabase.instance;
  final ConnectivityNotifier _connectivity = ConnectivityNotifier.instance;
  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  bool _initialized = false;
  bool _isSyncing = false;
  SyncStatus _currentSyncStatus = SyncStatus.synced;

  Future<void> initialize() async {
    if (_initialized) return;

    await _localDb.initialize();
    await _connectivity.initialize();
    _connectivity.addListener(() {
      if (_connectivity.value) {
        unawaited(_processQueue());
      }
    });
    if (_connectivity.value) {
      unawaited(_processQueue());
    }
    _initialized = true;
  }

  bool get isOnline => _connectivity.value;
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  SyncStatus get currentSyncStatus => _currentSyncStatus;

  Future<void> upsertParty({
    required String partyName,
    required Map<String, dynamic> data,
  }) {
    return _executeOrQueue(
      table: 'parties',
      id: partyName,
      entityType: 'party',
      action: 'upsert',
      payload: {'partyName': partyName, 'data': data},
      onlineAction: () => FirebaseRef.partyUserDoc.doc(partyName).set(data),
    );
  }

  Future<void> markPartyDeleted({
    required String partyName,
    required bool deleted,
  }) async {
    final current =
        await _localDb.getEntity('parties', partyName) ?? <String, dynamic>{};
    final merged = Map<String, dynamic>.from(current)
      ..['party_deleted'] = deleted ? 'yes' : 'no';

    return _executeOrQueue(
      table: 'parties',
      id: partyName,
      entityType: 'party',
      action: 'update',
      payload: {
        'partyName': partyName,
        'fields': {'party_deleted': deleted ? 'yes' : 'no'},
      },
      cacheData: merged,
      onlineAction: () => FirebaseRef.partyUserDoc.doc(partyName).update({
        'party_deleted': deleted ? 'yes' : 'no',
      }),
    );
  }

  Future<void> upsertProject({
    required String partyName,
    required String projectName,
    required Map<String, dynamic> data,
  }) {
    return _executeOrQueue(
      table: 'projects',
      id: '$partyName::$projectName',
      entityType: 'project',
      action: 'upsert',
      payload: {
        'partyName': partyName,
        'projectName': projectName,
        'data': data,
      },
      onlineAction: () => FirebaseRef.partyUserDoc
          .doc(partyName)
          .collection(TextConstant.projectCollection)
          .doc(projectName)
          .set(data),
    );
  }

  Future<void> markProjectDeleted({
    required String partyName,
    required String projectName,
    required bool deleted,
  }) async {
    final cacheId = '$partyName::$projectName';
    final current =
        await _localDb.getEntity('projects', cacheId) ?? <String, dynamic>{};
    final merged = Map<String, dynamic>.from(current)
      ..['project_deleted'] = deleted ? 'yes' : 'no';

    return _executeOrQueue(
      table: 'projects',
      id: cacheId,
      entityType: 'project',
      action: 'update',
      payload: {
        'partyName': partyName,
        'projectName': projectName,
        'fields': {'project_deleted': deleted ? 'yes' : 'no'},
      },
      cacheData: merged,
      onlineAction: () => FirebaseRef.partyUserDoc
          .doc(partyName)
          .collection(TextConstant.projectCollection)
          .doc(projectName)
          .update({'project_deleted': deleted ? 'yes' : 'no'}),
    );
  }

  Future<void> upsertFile({
    required String partyName,
    required String projectName,
    required String fileName,
    required Map<String, dynamic> data,
  }) {
    return _executeOrQueue(
      table: 'files',
      id: '$partyName::$projectName::$fileName',
      entityType: 'file',
      action: 'upsert',
      payload: {
        'partyName': partyName,
        'projectName': projectName,
        'fileName': fileName,
        'data': data,
      },
      onlineAction: () => FirebaseRef.partyUserDoc
          .doc(partyName)
          .collection(TextConstant.projectCollection)
          .doc(projectName)
          .collection(TextConstant.fileCollection)
          .doc(fileName)
          .set(data),
    );
  }

  Future<void> markFileDeleted({
    required String partyName,
    required String projectName,
    required String fileName,
    required bool deleted,
  }) async {
    final cacheId = '$partyName::$projectName::$fileName';
    final current =
        await _localDb.getEntity('files', cacheId) ?? <String, dynamic>{};
    final merged = Map<String, dynamic>.from(current)
      ..['file_deleted'] = deleted ? 'yes' : 'no';

    return _executeOrQueue(
      table: 'files',
      id: cacheId,
      entityType: 'file',
      action: 'update',
      payload: {
        'partyName': partyName,
        'projectName': projectName,
        'fileName': fileName,
        'fields': {'file_deleted': deleted ? 'yes' : 'no'},
      },
      cacheData: merged,
      onlineAction: () => FirebaseRef.partyUserDoc
          .doc(partyName)
          .collection(TextConstant.projectCollection)
          .doc(projectName)
          .collection(TextConstant.fileCollection)
          .doc(fileName)
          .update({'file_deleted': deleted ? 'yes' : 'no'}),
    );
  }

  Future<void> addRecord({
    required String partyName,
    required String projectName,
    required String fileName,
    required RecordModel record,
  }) {
    final docId = DateTime.now().millisecondsSinceEpoch.toString();
    final id = '$partyName::$projectName::$fileName::$docId';
    return _executeOrQueue(
      table: 'records',
      id: id,
      entityType: 'record',
      action: 'upsert',
      payload: {
        'partyName': partyName,
        'projectName': projectName,
        'fileName': fileName,
        'docId': docId,
        'data': record.toMap(),
      },
      onlineAction: () => FirebaseRef.partyUserDoc
          .doc(partyName)
          .collection(TextConstant.projectCollection)
          .doc(projectName)
          .collection(TextConstant.fileCollection)
          .doc(fileName)
          .collection(TextConstant.recordsCollection)
          .doc(docId)
          .set(record.toMap()),
    );
  }

  Future<void> updateRecord({
    required String partyName,
    required String projectName,
    required String fileName,
    required String docId,
    required RecordModel record,
  }) {
    final id = '$partyName::$projectName::$fileName::$docId';
    return _executeOrQueue(
      table: 'records',
      id: id,
      entityType: 'record',
      action: 'update',
      payload: {
        'partyName': partyName,
        'projectName': projectName,
        'fileName': fileName,
        'docId': docId,
        'data': record.toMap(),
      },
      onlineAction: () => FirebaseRef.partyUserDoc
          .doc(partyName)
          .collection(TextConstant.projectCollection)
          .doc(projectName)
          .collection(TextConstant.fileCollection)
          .doc(fileName)
          .collection(TextConstant.recordsCollection)
          .doc(docId)
          .update(record.toMap()),
    );
  }

  Future<void> cacheSnapshotBatch({
    required String table,
    required QuerySnapshot<Map<String, dynamic>> snapshot,
    required String Function(DocumentSnapshot<Map<String, dynamic>>) idBuilder,
  }) async {
    if (snapshot.docChanges.isEmpty) {
      for (final doc in snapshot.docs) {
        final id = idBuilder(doc);
        await _localDb.upsertEntity(
          table: table,
          id: id,
          data: doc.data(),
          status: SyncStatus.synced,
        );
      }
      return;
    }

    for (final change in snapshot.docChanges) {
      final id = idBuilder(change.doc);
      if (change.type == DocumentChangeType.removed) {
        await _localDb.deleteEntity(table: table, id: id);
      } else {
        final data = change.doc.data();
        if (data == null) continue;
        await _localDb.upsertEntity(
          table: table,
          id: id,
          data: data,
          status: SyncStatus.synced,
        );
      }
    }
  }

  Stream<List<Map<String, dynamic>>> watchCachedParties() =>
      _localDb.watchEntities('parties');

  Stream<List<Map<String, dynamic>>> watchCachedProjects() =>
      _localDb.watchEntities('projects');

  Stream<List<Map<String, dynamic>>> watchCachedFiles() =>
      _localDb.watchEntities('files');

  Stream<List<Map<String, dynamic>>> watchCachedRecords() =>
      _localDb.watchEntities('records');

  Future<void> deleteCache({required String table, required String id}) {
    return _localDb.deleteEntity(table: table, id: id);
  }

  Future<void> deleteCacheByPrefix({
    required String table,
    required String prefix,
  }) {
    return _localDb.deleteEntitiesByPrefix(table: table, prefix: prefix);
  }

  Future<void> clearAllLocalData() async {
    await _localDb.clearAllData();
  }

  Future<void> removePendingOperations({
    required String entityType,
    required bool Function(Map<String, dynamic> payload) matcher,
  }) {
    return _localDb.removePendingOperations(
      entityType: entityType,
      matcher: matcher,
    );
  }

  Future<void> deletePartyPermanently(String partyName) async {
    await deleteCache(table: 'parties', id: partyName);
    await deleteCacheByPrefix(table: 'projects', prefix: '$partyName::');
    await deleteCacheByPrefix(table: 'files', prefix: '$partyName::');
    await deleteCacheByPrefix(table: 'records', prefix: '$partyName::');

    await removePendingOperations(
      entityType: 'party',
      matcher: (payload) => payload['partyName'] == partyName,
    );
    await removePendingOperations(
      entityType: 'project',
      matcher: (payload) => payload['partyName'] == partyName,
    );
    await removePendingOperations(
      entityType: 'file',
      matcher: (payload) => payload['partyName'] == partyName,
    );
    await removePendingOperations(
      entityType: 'record',
      matcher: (payload) => payload['partyName'] == partyName,
    );

    await _runDeleteOrQueue(
      entityType: 'party',
      payload: {'partyName': partyName},
      deleteAction: () async {
        final ref = FirebaseRef.partyUserDoc.doc(partyName);
        final doc = await ref.get();
        if (doc.exists) {
          await ref.delete();
        }
      },
    );
  }

  Future<void> deleteProjectPermanently({
    required String partyName,
    required String projectName,
  }) async {
    final cacheId = '$partyName::$projectName';
    await deleteCache(table: 'projects', id: cacheId);
    await deleteCacheByPrefix(
      table: 'files',
      prefix: '$partyName::$projectName::',
    );
    await deleteCacheByPrefix(
      table: 'records',
      prefix: '$partyName::$projectName::',
    );

    await removePendingOperations(
      entityType: 'project',
      matcher: (payload) =>
          payload['partyName'] == partyName &&
          payload['projectName'] == projectName,
    );
    await removePendingOperations(
      entityType: 'file',
      matcher: (payload) =>
          payload['partyName'] == partyName &&
          payload['projectName'] == projectName,
    );
    await removePendingOperations(
      entityType: 'record',
      matcher: (payload) =>
          payload['partyName'] == partyName &&
          payload['projectName'] == projectName,
    );

    await _runDeleteOrQueue(
      entityType: 'project',
      payload: {'partyName': partyName, 'projectName': projectName},
      deleteAction: () async {
        final ref = FirebaseRef.partyUserDoc
            .doc(partyName)
            .collection(TextConstant.projectCollection)
            .doc(projectName);
        final doc = await ref.get();
        if (doc.exists) {
          await ref.delete();
        }
      },
    );
  }

  Future<void> deleteFilePermanently({
    required String partyName,
    required String projectName,
    required String fileName,
  }) async {
    final cacheId = '$partyName::$projectName::$fileName';
    await deleteCache(table: 'files', id: cacheId);
    await deleteCacheByPrefix(
      table: 'records',
      prefix: '$partyName::$projectName::$fileName::',
    );

    await removePendingOperations(
      entityType: 'file',
      matcher: (payload) =>
          payload['partyName'] == partyName &&
          payload['projectName'] == projectName &&
          payload['fileName'] == fileName,
    );
    await removePendingOperations(
      entityType: 'record',
      matcher: (payload) =>
          payload['partyName'] == partyName &&
          payload['projectName'] == projectName &&
          payload['fileName'] == fileName,
    );

    await _runDeleteOrQueue(
      entityType: 'file',
      payload: {
        'partyName': partyName,
        'projectName': projectName,
        'fileName': fileName,
      },
      deleteAction: () async {
        final ref = FirebaseRef.partyUserDoc
            .doc(partyName)
            .collection(TextConstant.projectCollection)
            .doc(projectName)
            .collection(TextConstant.fileCollection)
            .doc(fileName);
        final doc = await ref.get();
        if (doc.exists) {
          await ref.delete();
        }
      },
    );
  }

  Future<void> _executeOrQueue({
    required String table,
    required String id,
    required String entityType,
    required String action,
    required Map<String, dynamic> payload,
    required Future<void> Function() onlineAction,
    Map<String, dynamic>? cacheData,
  }) async {
    await _localDb.upsertEntity(
      table: table,
      id: id,
      data:
          cacheData ??
          (payload['data'] as Map<String, dynamic>? ??
              Map<String, dynamic>.from(
                payload['fields'] as Map? ?? <String, dynamic>{},
              )),
      status: isOnline ? SyncStatus.synced : SyncStatus.pending,
    );

    if (isOnline) {
      try {
        await onlineAction();
      } catch (err) {
        await _localDb.markEntityStatus(
          table: table,
          id: id,
          status: SyncStatus.pending,
        );
        await _localDb.queueOperation(
          entityType: entityType,
          action: action,
          payload: payload,
        );
        rethrow;
      }
    } else {
      _updateSyncStatus(SyncStatus.pending);
      await _localDb.queueOperation(
        entityType: entityType,
        action: action,
        payload: payload,
      );
    }
  }

  Future<void> _runDeleteOrQueue({
    required String entityType,
    required Map<String, dynamic> payload,
    required Future<void> Function() deleteAction,
  }) async {
    if (isOnline) {
      try {
        await deleteAction();
      } on FirebaseException catch (err) {
        if (err.code == 'not-found') {
          return;
        }
        await _queueDeleteOperation(entityType, payload);
        rethrow;
      } catch (err) {
        await _queueDeleteOperation(entityType, payload);
        rethrow;
      }
    } else {
      _updateSyncStatus(SyncStatus.pending);
      await _queueDeleteOperation(entityType, payload);
    }
  }

  Future<void> _queueDeleteOperation(
    String entityType,
    Map<String, dynamic> payload,
  ) {
    return _localDb.queueOperation(
      entityType: entityType,
      action: 'delete',
      payload: payload,
    );
  }

  Future<void> _processQueue() async {
    if (_isSyncing) return;
    _isSyncing = true;
    var encounteredFailure = false;
    var stillPending = false;
    try {
      final rows = await _localDb.getPendingOperations();
      if (rows.isEmpty) {
        _updateSyncStatus(SyncStatus.synced);
        return;
      }
      _updateSyncStatus(SyncStatus.syncing);
      for (final row in rows) {
        final op = PendingOperation.fromRow(row);
        try {
          await _executePendingOperation(op);
          await _localDb.updateOperationStatus(
            id: op.id,
            status: SyncStatus.synced,
          );
          await _markCachedEntitySynced(op);
        } catch (err) {
          debugPrint('Sync failed for op ${op.id}: $err');
          final retry = op.retryCount + 1;
          final status = retry >= 5 ? SyncStatus.failed : SyncStatus.pending;
          await _localDb.updateOperationStatus(
            id: op.id,
            status: status,
            retryCount: retry,
          );
          if (status == SyncStatus.failed) {
            debugPrint('Operation ${op.id} marked as failed.');
            encounteredFailure = true;
            _updateSyncStatus(SyncStatus.failed);
          } else {
            stillPending = true;
            _updateSyncStatus(SyncStatus.pending);
          }
        }
      }
      if (encounteredFailure) {
        _updateSyncStatus(SyncStatus.failed);
      } else if (stillPending) {
        _updateSyncStatus(SyncStatus.pending);
      } else {
        _updateSyncStatus(SyncStatus.synced);
      }
    } finally {
      _isSyncing = false;
    }
  }

  Future<void> _executePendingOperation(PendingOperation op) {
    switch (op.entityType) {
      case 'party':
        return _handlePartyOperation(op);
      case 'project':
        return _handleProjectOperation(op);
      case 'file':
        return _handleFileOperation(op);
      case 'record':
        return _handleRecordOperation(op);
      default:
        throw UnsupportedError('Unknown entity ${op.entityType}');
    }
  }

  Future<void> _handlePartyOperation(PendingOperation op) async {
    final payload = op.payload;
    final partyName = payload['partyName'] as String;
    if (op.action == 'upsert') {
      await FirebaseRef.partyUserDoc
          .doc(partyName)
          .set(Map<String, dynamic>.from(payload['data'] as Map));
    } else if (op.action == 'update') {
      await FirebaseRef.partyUserDoc
          .doc(partyName)
          .update(Map<String, dynamic>.from(payload['fields'] as Map));
    } else if (op.action == 'delete') {
      final ref = FirebaseRef.partyUserDoc.doc(partyName);
      final doc = await ref.get();
      if (doc.exists) {
        await ref.delete();
      }
    }
  }

  Future<void> _handleProjectOperation(PendingOperation op) async {
    final payload = op.payload;
    final partyName = payload['partyName'] as String;
    final projectName = payload['projectName'] as String;
    final doc = FirebaseRef.partyUserDoc
        .doc(partyName)
        .collection(TextConstant.projectCollection)
        .doc(projectName);
    if (op.action == 'upsert') {
      await doc.set(Map<String, dynamic>.from(payload['data'] as Map));
    } else if (op.action == 'update') {
      await doc.update(Map<String, dynamic>.from(payload['fields'] as Map));
    } else if (op.action == 'delete') {
      final snapshot = await doc.get();
      if (snapshot.exists) {
        await doc.delete();
      }
    }
  }

  Future<void> _handleFileOperation(PendingOperation op) async {
    final payload = op.payload;
    final partyName = payload['partyName'] as String;
    final projectName = payload['projectName'] as String;
    final fileName = payload['fileName'] as String;
    final doc = FirebaseRef.partyUserDoc
        .doc(partyName)
        .collection(TextConstant.projectCollection)
        .doc(projectName)
        .collection(TextConstant.fileCollection)
        .doc(fileName);
    if (op.action == 'upsert') {
      await doc.set(Map<String, dynamic>.from(payload['data'] as Map));
    } else if (op.action == 'update') {
      await doc.update(Map<String, dynamic>.from(payload['fields'] as Map));
    } else if (op.action == 'delete') {
      final snapshot = await doc.get();
      if (snapshot.exists) {
        await doc.delete();
      }
    }
  }

  Future<void> _handleRecordOperation(PendingOperation op) async {
    final payload = op.payload;
    final partyName = payload['partyName'] as String;
    final projectName = payload['projectName'] as String;
    final fileName = payload['fileName'] as String;
    final docId = payload['docId'] as String;
    final doc = FirebaseRef.partyUserDoc
        .doc(partyName)
        .collection(TextConstant.projectCollection)
        .doc(projectName)
        .collection(TextConstant.fileCollection)
        .doc(fileName)
        .collection(TextConstant.recordsCollection)
        .doc(docId);
    if (op.action == 'upsert') {
      await doc.set(Map<String, dynamic>.from(payload['data'] as Map));
    } else if (op.action == 'update') {
      await doc.update(Map<String, dynamic>.from(payload['data'] as Map));
    } else if (op.action == 'delete') {
      final snapshot = await doc.get();
      if (snapshot.exists) {
        await doc.delete();
      }
    }
  }

  Future<void> _markCachedEntitySynced(PendingOperation op) async {
    if (op.action == 'delete') return;
    final target = _cacheTargetForOperation(op);
    if (target == null) return;
    await _localDb.markEntityStatus(
      table: target.$1,
      id: target.$2,
      status: SyncStatus.synced,
    );
  }

  (String, String)? _cacheTargetForOperation(PendingOperation op) {
    switch (op.entityType) {
      case 'party':
        return ('parties', op.payload['partyName'] as String);
      case 'project':
        final party = op.payload['partyName'] as String;
        final project = op.payload['projectName'] as String;
        return ('projects', '$party::$project');
      case 'file':
        final party = op.payload['partyName'] as String;
        final project = op.payload['projectName'] as String;
        final file = op.payload['fileName'] as String;
        return ('files', '$party::$project::$file');
      case 'record':
        final party = op.payload['partyName'] as String;
        final project = op.payload['projectName'] as String;
        final file = op.payload['fileName'] as String;
        final docId = op.payload['docId'] as String;
        return ('records', '$party::$project::$file::$docId');
      default:
        return null;
    }
  }

  void _updateSyncStatus(SyncStatus status) {
    if (_currentSyncStatus == status) return;
    _currentSyncStatus = status;
    _syncStatusController.add(status);
  }
}
