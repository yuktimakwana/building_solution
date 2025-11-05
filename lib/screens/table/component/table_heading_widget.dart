import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TableHeadingWidget extends StatelessWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> tableData;

  const TableHeadingWidget({super.key, required this.tableData});

  @override
  Widget build(BuildContext context) {
    Widget totalTextWidget(String title) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3.0),
        child: Text(title,
            textAlign: TextAlign.center, style: StyleConstant.mediumTextStyle),
      );
    }

    return tableData.isEmpty
        ? const SizedBox()
        : Table(
        columnWidths: Globals.columnWidth,
            border: TableBorder.symmetric(
                inside: const BorderSide(
                    color: ColorConstant.outLineBorderGreyColor),
                outside:
                    const BorderSide(color: ColorConstant.naturalBlackColor)),
            children: [
              TableRow(children: [
                totalTextWidget('#'),
                totalTextWidget('Note'),
                totalTextWidget('feet'),
                totalTextWidget('Inch'),
                totalTextWidget('Rft'),
                totalTextWidget('Qty'),
                totalTextWidget('Total'),
              ]),
            ]);
  }
}
