import 'package:cloud_firestore/cloud_firestore.dart';

class RecordModel {
  final String docId; // Firestore document id (timestamp-based when adding)
  final num idColumn; // Line # (primary-key-like, unique, e.g., 6, 6.1, 7)
  final String note;
  final String feet;
  final String inch;
  final String rft; // convenience (feet + inch/12)
  final int qty; // can be negative if LESS
  final String total;

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
    'no': idColumn,
    'note': note,
    'feet': feet,
    'inch': inch,
    'rft': rft,
    'qty': qty,
    'total': total,
  };

  factory RecordModel.fromDoc(QueryDocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return RecordModel.fromMapData(d, docId: doc.id);
  }

  factory RecordModel.fromMapData(
    Map<String, dynamic> d, {
    required String docId,
  }) {
    // Handle feet: if int/double, to string. If string, use directly.
    final feetVal = d['feet'];
    final String feet = feetVal?.toString() ?? '0';

    final inchVal = d['inch'];
    final String inch = inchVal?.toString() ?? '0';

    // rft might not exist, or be num
    final rftVal = d['rft'];
    String rft;
    if (rftVal != null) {
      rft = rftVal.toString();
    } else {
      // fallback calculation if missing (migration)
      final f = num.tryParse(feet) ?? 0;
      final i = num.tryParse(inch) ?? 0;
      rft = (f + (i / 12)).toStringAsFixed(2);
    }

    // Safe parse qty
    final qtyRaw = d['qty'];
    int qty;
    if (qtyRaw is int) {
      qty = qtyRaw;
    } else if (qtyRaw is num) {
      qty = qtyRaw.toInt();
    } else {
      qty = int.tryParse(qtyRaw?.toString() ?? '1') ?? 1;
    }

    // Safe parse idColumn
    final noRaw = d['no'];
    num idColumn;
    if (noRaw is num) {
      idColumn = noRaw;
    } else {
      idColumn = num.tryParse(noRaw?.toString() ?? '0') ?? 0;
    }

    final totalVal = d['total'];
    String total;
    if (totalVal != null) {
      total = totalVal.toString();
    } else {
      // fallback
      final r = num.tryParse(rft) ?? 0;
      total = (qty * r).toStringAsFixed(2);
    }

    return RecordModel(
      docId: docId,
      idColumn: idColumn,
      note: d['note'] ?? '',
      feet: feet,
      inch: inch,
      rft: rft,
      qty: qty,
      total: total,
    );
  }
}
