import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/offline/offline_sync_service.dart';
import 'package:flutter/foundation.dart';

class AddFileRepository {
  final OfflineSyncService _syncService = OfflineSyncService.instance;

  Future<void> addFile({
    required String fileName,
    required String partyName,
    required String projectName,
    required String fileDescription,
    required String fileDeleted,
    required String fileNameLower,
  }) async {
    try {
      final body = {
        'file_name': fileName,
        'file_deleted': fileDeleted,
        'file_description': fileDescription,
        'file_name_lower': fileNameLower,
        'file_add_on': Timestamp.now(),
      };
      await _syncService.upsertFile(
        partyName: partyName,
        projectName: projectName,
        fileName: fileName,
        data: body,
      );
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("Failed with error '${e.code}' : ${e.message}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
