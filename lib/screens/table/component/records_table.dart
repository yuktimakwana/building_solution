import 'package:duplicate_building_solution/model/record_model.dart';
import 'package:flutter/material.dart';

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

    final last10Desc = records.length > 10
        ? records.take(10).toList()
        : List.of(records);

    final displayRecords = last10Desc.reversed.toList();

    // Header row
    final headers = const ['#', 'Note', 'Feet', 'Inch', 'Rft', 'Qty', 'Total'];

    return Table(
      border: border,
      columnWidths:   {
        0: const FractionColumnWidth(0.08),
        1: const FractionColumnWidth(0.33),
        2: const FractionColumnWidth(0.1),
        3: const FractionColumnWidth(0.1),
        4: const FractionColumnWidth(0.15),
        5: const FractionColumnWidth(0.08),
        6: const FractionColumnWidth(0.15),
        },
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      children: [
        TableRow(
          decoration: const BoxDecoration(color: Color(0xFFF2F2F2)),
          children: headers
              .map(
                (h) => Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 8,
                    horizontal: 2,
                  ),
                  child: Text(
                    h,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
              .toList(),
        ),
        ...List.generate(displayRecords.length, (i) {
          final r = displayRecords[i];
          final selected = selectedIndex == i;
          final bg = selected
              ? const Color(0xFFE6F4EA)
              : Colors.white; // soft green highlight
          return TableRow(
            decoration: BoxDecoration(color: bg),
            children: [
              _cell('${r.idColumn}'),
              _cell(r.note),
              _cell(r.feet),
              _cell(r.inch),
              _cell(r.rft),
              _cell(r.qty.toString()),
              _cell(r.total),
            ],
          ).withTap(() => onTapRow(i));
        }),
      ],
    );
  }

  Widget _cell(String s) => InkWell(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 5),
      child: Text(s, textAlign: TextAlign.center),
    ),
  );
}

extension on TableRow {
  TableRow withTap(VoidCallback onTap) {
    return TableRow(
      decoration: decoration,
      children: children.map((c) => InkWell(onTap: onTap, child: c)).toList(),
    );
  }
}
