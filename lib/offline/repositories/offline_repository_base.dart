import '../local_database.dart';
import '../offline_status.dart';

abstract class OfflineRepositoryBase {
  OfflineRepositoryBase(this.localDb);

  final LocalDatabase localDb;

  bool isOnline = true;

  void updateConnectivity(bool online) {
    isOnline = online;
  }

  Future<void> cacheEntity({
    required String table,
    required String id,
    required Map<String, dynamic> data,
    SyncStatus status = SyncStatus.pending,
  }) {
    return localDb.upsertEntity(
      table: table,
      id: id,
      data: data,
      status: status,
    );
  }

  Stream<List<Map<String, dynamic>>> watchEntities(String table) {
    return localDb.watchEntities(table);
  }

  Future<void> queueOperation({
    required String entityType,
    required String action,
    required Map<String, dynamic> payload,
  }) {
    return localDb.queueOperation(
      entityType: entityType,
      action: action,
      payload: payload,
    );
  }
}
