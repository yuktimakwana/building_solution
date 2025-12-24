import 'package:flutter/material.dart';
import 'package:duplicate_building_solution/model/record_model.dart';

class RecordsTable extends StatelessWidget {
  const RecordsTable({
    super.key,
    required this.records,
    required this.selectedIndex,
    required this.onTapRow,
  });

  final List<RecordModel> records;
  final int? selectedIndex;
  final void Function(int index) onTapRow;

  @override
  Widget build(BuildContext context) {
    final border = TableBorder.all(color: Colors.black54, width: 1);

    /// 1️⃣ Make copy of original list
    final List<RecordModel> sortedRecords =
    List<RecordModel>.from(records);

    /// 2️⃣ SORT ASCENDING by numeric ID (IMPORTANT FIX)
    sortedRecords.sort((a, b) {
      final double aId = double.tryParse('${a.idColumn}') ?? 0;
      final double bId = double.tryParse('${b.idColumn}') ?? 0;
      return aId.compareTo(bId);
    });

    /// 3️⃣ TAKE LAST 10 RECORDS (ASCENDING)
    final List<RecordModel> displayRecords =
    sortedRecords.length > 10
        ? sortedRecords.sublist(sortedRecords.length - 10)
        : sortedRecords;

    const headers = ['#', 'Note', 'Feet', 'Inch', 'Rft', 'Qty', 'Total'];

    return Table(
      border: border,
      columnWidths: const {
        0: FractionColumnWidth(0.08),
        1: FractionColumnWidth(0.33),
        2: FractionColumnWidth(0.1),
        3: FractionColumnWidth(0.1),
        4: FractionColumnWidth(0.15),
        5: FractionColumnWidth(0.08),
        6: FractionColumnWidth(0.15),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        /// HEADER
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
          children: headers
              .map(
                (h) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                h,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          )
              .toList(),
        ),

        /// ROWS
        ...List.generate(displayRecords.length, (i) {
          final record = displayRecords[i];

          /// 4️⃣ FIND CORRECT INDEX FROM ORIGINAL LIST
          final int actualIndex = records.indexWhere(
                (e) => e.idColumn == record.idColumn,
          );

          return TableRow(
            decoration: BoxDecoration(
              color: selectedIndex == actualIndex
                  ? const Color(0xFFE6F4EA)
                  : Colors.white,
            ),
            children: [
              _cell('${record.idColumn}'),
              _cell(record.note),
              _cell(record.feet),
              _cell(record.inch),
              _cell(record.rft),
              _cell(record.qty.toString()),
              _cell(record.total),
            ],
          ).withTap(() => onTapRow(actualIndex));
        }),
      ],
    );
  }

  Widget _cell(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    child: Text(text, textAlign: TextAlign.center),
  );
}

extension on TableRow {
  TableRow withTap(VoidCallback onTap) {
    return TableRow(
      decoration: decoration,
      children: children
          .map((child) => InkWell(onTap: onTap, child: child))
          .toList(),
    );
  }
}
