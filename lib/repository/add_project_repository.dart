import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/offline/offline_sync_service.dart';
import 'package:flutter/foundation.dart';

class AddProjectRepository {
  final OfflineSyncService _syncService = OfflineSyncService.instance;

  Future<void> addProject({
    required String projectName,
    required String partyName,
    required String projectDescription,
    required String projectDeleted,
    required String projectNameLower,
  }) async {
    try {
      final body = {
        'project_name': projectName,
        'project_name_lower': projectNameLower,
        'project_description': projectDescription,
        'project_deleted': projectDeleted,
        'project_add_on': Timestamp.now(),
      };

      await _syncService.upsertProject(
        partyName: partyName,
        projectName: projectName,
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
