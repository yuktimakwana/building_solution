import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/model/record_model.dart';
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

  CollectionReference get _col => FirebaseRef.partyUserDoc
      .doc(partyName)
      .collection(TextConstant.projectCollection)
      .doc(projectName)
      .collection(TextConstant.fileCollection)
      .doc(fileName)
      .collection(TextConstant.recordsCollection);

  Stream<List<RecordModel>> watchAll() => _col
      .orderBy('id_column',descending: true).limit(10)
      .snapshots()
      .map((snap) => snap.docs.map((d) => RecordModel.fromDoc(d)).toList());

  Future<void> addRecord(RecordModel r) async {
    final ts = DateTime.now().millisecondsSinceEpoch.toString();
    await _col.doc(ts).set(r.toMap());
  }

  Future<void> updateRecord(String docId, RecordModel r) async {
    await _col.doc(docId).update(r.toMap());
  }
}
