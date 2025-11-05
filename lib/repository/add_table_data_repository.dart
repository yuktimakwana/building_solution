import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AddTableDataRepository {
  Future<void> addTableData({
    required String note,
    required String feet,
    required String inch,
    required String rft,
    required String qty,
    required num id,
    required String total,
    required String partyName,
    required String projectName,
    required String fileName,
    required bool less,
  }) async {
    try {
      var timeStamp = Timestamp.now().microsecondsSinceEpoch;
      String documentId = '';
      String finalLess = '';
      String finalNote = '';

      var querySnapshots = await FirebaseFirestore.instance
          .collection(Globals.partyCollection)
          .doc(partyName)
          .collection(Globals.projectCollection)
          .doc(projectName)
          .collection(Globals.fileCollection)
          .doc(fileName)
          .collection(Globals.recordsCollection)
          .where(Globals.idColumn, isEqualTo: Globals.tableId)
          .get();

      for (var snapshot in querySnapshots.docs) {
        documentId = snapshot.id;
        String note = snapshot[Globals.noteColumn];
        String checkLess = note.split('').reversed.join();
        finalLess = checkLess.split(' ')[0].split('').reversed.join();
      }

      if (less) {
        if (finalLess.contains('Less')) {
          finalNote = note;
        } else {
          finalNote = '$note${TextConstant.lessWord}';
        }
      } else {
        if (finalLess.contains('Less')) {
          String newNote = Globals.txtNoteController.text.split(' L')[0];
          finalNote = newNote;
        } else {
          finalNote = note;
        }
      }

      final body = {
        Globals.noteColumn: finalNote.trimRight(),
        Globals.lessColumn: less,
        Globals.feetColumn: feet == '0' ? '' : feet,
        Globals.inchColumn: inch == '0' ? '' : inch,
        Globals.rftColumn: rft == '0.00' ? '' : rft,
        Globals.qtyColumn: qty,
        Globals.totalColumn: total == '0.00' ? '' : total,
        Globals.dataAddOnColumn: Timestamp.now()
      };
      if (!Globals.isUpdate) {
        body[Globals.idColumn] = id;
      }

      if (Globals.isUpdate) {
        await FirebaseFirestore.instance
            .collection(Globals.partyCollection)
            .doc(partyName)
            .collection(Globals.projectCollection)
            .doc(projectName)
            .collection(Globals.fileCollection)
            .doc(fileName)
            .collection(Globals.recordsCollection)
            .doc(documentId)
            .update(body);
      } else {
        await FirebaseFirestore.instance
            .collection(Globals.partyCollection)
            .doc(partyName)
            .collection(Globals.projectCollection)
            .doc(projectName)
            .collection(Globals.fileCollection)
            .doc(fileName)
            .collection(Globals.recordsCollection)
            .doc('$timeStamp')
            .set(body);
      }

    } on FirebaseException catch (e) {
      if (kDebugMode) {
        print("Failed with error '${e.code}' : ${e.message}");
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }
}
