import 'dart:convert';

import 'offline_status.dart';
import 'json_codec.dart';

class PendingOperation {
  final int id;
  final String entityType;
  final String action;
  final Map<String, dynamic> payload;
  final SyncStatus status;
  final int retryCount;

  PendingOperation({
    required this.id,
    required this.entityType,
    required this.action,
    required this.payload,
    required this.status,
    required this.retryCount,
  });

  factory PendingOperation.fromRow(Map<String, dynamic> row) {
    return PendingOperation(
      id: row['id'] as int,
      entityType: row['entity_type'] as String,
      action: row['action'] as String,
      payload: decodeFromStorage(
        Map<String, dynamic>.from(jsonDecode(row['payload'] as String) as Map),
      ),
      status: SyncStatusX.fromValue(row['status'] as String),
      retryCount: row['retry_count'] as int? ?? 0,
    );
  }
}
