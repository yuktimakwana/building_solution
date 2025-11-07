import 'package:cloud_firestore/cloud_firestore.dart';

class RecordModel {
  final String docId; // Firestore document id (timestamp-based when adding)
  final num idColumn; // Line # (primary-key-like, unique, e.g., 6, 6.1, 7)
  final String note;
  final num feet;
  final num inch;
  final num rft; // convenience (feet + inch/12)
  final int qty; // can be negative if LESS
  final num total;

  RecordModel({
    required this.docId,
    required this.idColumn,
    required this.note,
    required this.feet,
    required this.inch,
    required this.rft,
    required this.qty,
    required this.total,
  });

  Map<String, dynamic> toMap() => {
    'id_column': idColumn,
    'note': note,
    'feet': feet,
    'inch': inch,
    'rft': rft,
    'qty': qty,
    'total': total,
  };

  factory RecordModel.fromDoc(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    final num feet = (d['feet'] ?? 0) is int
        ? (d['feet'] ?? 0)
        : (d['feet'] ?? 0.0);
    final num inch = (d['inch'] ?? 0) is int
        ? (d['inch'] ?? 0)
        : (d['inch'] ?? 0.0);
    final num rft = (d['rft'] ?? (feet + (inch / 12)));
    final int qty = (d['qty'] ?? 0) is int
        ? d['qty']
        : (d['qty'] as num).toInt();
    final num total = d['total'] ?? (qty * rft);

    return RecordModel(
      docId: doc.id,
      idColumn: d['id_column'] ?? 0,
      note: d['note'] ?? '',
      feet: feet,
      inch: inch,
      rft: rft,
      qty: qty,
      total: total,
    );
  }
}
