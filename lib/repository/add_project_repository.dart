import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:flutter/foundation.dart';

class AddProjectRepository {
  Future<void> addProject({
    required String projectName,
    required String partyName,
    required String projectDescription,
    required String projectDeleted,
    required String projectNameLower,
  }) async {
    try {
      final fireCloud = FirebaseRef.partyUserDoc
          .doc(partyName)
          .collection("project")
          .doc(projectName);

      final body = {
        'project_name': projectName,
        'project_name_lower': projectNameLower,
        'project_description': projectDescription,
        'project_deleted': projectDeleted,
        'project_add_on': Timestamp.now(),
      };

      await fireCloud.set(body);
    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("Failed with error '${e.code}' : ${e.message}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
