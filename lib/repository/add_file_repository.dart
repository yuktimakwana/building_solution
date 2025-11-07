import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:flutter/foundation.dart';

class AddFileRepository {
  Future<void> addFile({
    required String fileName,
    required String partyName,
    required String projectName,
    required String fileDescription,
    required String fileDeleted,
    required String fileNameLower,
  }) async {
    try {
      final fireCloud = FirebaseRef.partyUserDoc
          .doc(partyName)
          .collection(TextConstant.projectCollection)
          .doc(projectName)
          .collection(TextConstant.fileCollection)
          .doc(fileName);

      final body = {
        'file_name': fileName,
        'file_deleted': fileDeleted,
        'file_description': fileDescription,
        'file_name_lower': fileNameLower,
        'file_add_on': Timestamp.now(),
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
