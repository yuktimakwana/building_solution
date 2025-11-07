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

    // Header row
    final headers = const ['#', 'Note', 'Feet', 'Inch', 'Rft', 'Qty', 'Total'];

    return Table(
      border: border,
      columnWidths: const {
        0: FixedColumnWidth(36),
        1: FlexColumnWidth(2),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
        4: FlexColumnWidth(1),
        5: FlexColumnWidth(1),
        6: FlexColumnWidth(1.4),
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
                    horizontal: 6,
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
        ...List.generate(records.length, (i) {
          final r = records[i];
          final selected = selectedIndex == i;
          final bg = selected
              ? const Color(0xFFE6F4EA)
              : Colors.white; // soft green highlight
          return TableRow(
            decoration: BoxDecoration(color: bg),
            children: [
              _cell('${r.idColumn}'),
              _cell(r.note),
              _cell(r.feet.toString()),
              _cell(r.inch.toString()),
              _cell(r.rft.toStringAsFixed(2)),
              _cell(r.qty.toString()),
              _cell(r.total.toStringAsFixed(2)),
            ],
          ).withTap(() => onTapRow(i));
        }),
      ],
    );
  }

  Widget _cell(String s) => InkWell(
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
      child: Text(s,textAlign: TextAlign.center),
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
