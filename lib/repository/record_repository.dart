import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/model/record_model.dart';
import 'package:duplicate_building_solution/offline/offline_sync_service.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';

class RecordsRepository {
  RecordsRepository({
    required this.partyName,
    required this.projectName,
    required this.fileName,
  });

  final String partyName;
  final String projectName;
  final String fileName;

  final OfflineSyncService _syncService = OfflineSyncService.instance;
  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _onlineSubscription;
  bool _listening = false;

  CollectionReference<Map<String, dynamic>> get _col => FirebaseRef.partyUserDoc
      .doc(partyName)
      .collection(TextConstant.projectCollection)
      .doc(projectName)
      .collection(TextConstant.fileCollection)
      .doc(fileName)
      .collection(TextConstant.recordsCollection);

  Stream<List<RecordModel>> watchAll() {
    _startOnlineListener();
    return _syncService.watchCachedRecords().map(_mapCachedRecords);
  }

  Future<void> addRecord(RecordModel r) async {
    await _syncService.addRecord(
      partyName: partyName,
      projectName: projectName,
      fileName: fileName,
      record: r,
    );
  }

  Future<void> updateRecord(String docId, RecordModel r) async {
    await _syncService.updateRecord(
      partyName: partyName,
      projectName: projectName,
      fileName: fileName,
      docId: docId,
      record: r,
    );
  }

  void dispose() {
    _onlineSubscription?.cancel();
  }

  void _startOnlineListener() {
    if (_listening) return;
    _onlineSubscription = _col
        .orderBy('id_column', descending: true)
        .limit(100)
        .snapshots()
        .listen((snapshot) async {
          await _syncService.cacheSnapshotBatch(
            table: 'records',
            snapshot: snapshot,
            idBuilder: (doc) =>
                '$partyName::$projectName::$fileName::${doc.id}',
          );
        });
    _listening = true;
  }

  List<RecordModel> _mapCachedRecords(List<Map<String, dynamic>> data) {
    final prefix = '$partyName::$projectName::$fileName::';
    final filtered =
        data
            .where((row) {
              final entityId = (row['__entity_id'] ?? '') as String;
              return entityId.startsWith(prefix);
            })
            .map((row) {
              final entityId = (row['__entity_id'] ?? '') as String;
              final docId = entityId.substring(prefix.length);
              final cleaned = Map<String, dynamic>.from(row)
                ..removeWhere((key, _) => key.toString().startsWith('__'));
              return RecordModel.fromMapData(cleaned, docId: docId);
            })
            .toList()
          ..sort((a, b) => b.idColumn.compareTo(a.idColumn));
    return filtered;
  }
}
