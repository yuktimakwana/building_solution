import 'package:duplicate_building_solution/utils/animation_utils.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:duplicate_building_solution/model/record_model.dart';

class RecordsTable extends StatelessWidget {
  const RecordsTable({
    super.key,
    required this.records,
    required this.selectedIndex,
    required this.onTapRow,
    required this.onDeleteRow,
  });

  final List<RecordModel> records;
  final int? selectedIndex;
  final void Function(int index) onTapRow;
  final void Function(String docId) onDeleteRow;

  @override
  Widget build(BuildContext context) {
    final border = TableBorder.all(color: Colors.black54, width: 1);

    /// 1️⃣ Make copy of original list
    final List<RecordModel> sortedRecords = List<RecordModel>.from(records);

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

    const headers = ['#', 'Note', 'Feet', 'Inch', 'Rft', 'Qty', 'Total', ''];

    return Table(
      border: border,
      columnWidths: const {
        0: FractionColumnWidth(0.08),
        1: FractionColumnWidth(0.28),
        2: FractionColumnWidth(0.1),
        3: FractionColumnWidth(0.1),
        4: FractionColumnWidth(0.12),
        5: FractionColumnWidth(0.08),
        6: FractionColumnWidth(0.14),
        7: FractionColumnWidth(0.1),
      },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        /// HEADER
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
          children:
              headers
                  .map(
                    (h) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        h,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
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

          final bool isSelected = selectedIndex == actualIndex;

          return TableRow(
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFE6F4EA) : Colors.white,
            ),
            children: [
              _cell(
                key: ValueKey('${record.docId}_0'),
                child: Text(
                  '${record.idColumn}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                index: i,
                onTap: () => onTapRow(actualIndex),
              ),
              _cell(
                key: ValueKey('${record.docId}_1'),
                child: Text(
                  record.note,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                index: i,
                onTap: () => onTapRow(actualIndex),
              ),
              _cell(
                key: ValueKey('${record.docId}_2'),
                child: Text(
                  record.feet,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                index: i,
                onTap: () => onTapRow(actualIndex),
              ),
              _cell(
                key: ValueKey('${record.docId}_3'),
                child: Text(
                  record.inch,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                index: i,
                onTap: () => onTapRow(actualIndex),
              ),
              _cell(
                key: ValueKey('${record.docId}_4'),
                child: Text(
                  record.rft,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                index: i,
                onTap: () => onTapRow(actualIndex),
              ),
              _cell(
                key: ValueKey('${record.docId}_5'),
                child: Text(
                  record.qty.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                index: i,
                onTap: () => onTapRow(actualIndex),
              ),
              _cell(
                key: ValueKey('${record.docId}_6'),
                child: Text(
                  record.total,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12),
                ),
                index: i,
                onTap: () => onTapRow(actualIndex),
              ),
              _cell(
                key: ValueKey('${record.docId}_7'),
                child: const Icon(
                  Icons.delete_outline,
                  size: 18,
                  color: ColorConstant.pastelRedColor,
                ),
                index: i,
                onTap: () => onDeleteRow(record.docId),
              ),
            ],
          );
        }),
      ],
    );
  }

  Widget _cell({
    Key? key,
    required Widget child,
    required int index,
    required VoidCallback onTap,
  }) =>
      AnimationUtils.animatedListItem(
        key: key,
        index: index,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: child,
          ),
        ),
      );
}
