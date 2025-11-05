import 'package:duplicate_building_solution/screens/table/component/add_table_data_button.dart';
import 'package:duplicate_building_solution/screens/table/component/note_row.dart';
import 'package:duplicate_building_solution/screens/table/component/rft_row.dart';
import 'package:duplicate_building_solution/screens/table/component/total_row.dart';
import 'package:duplicate_building_solution/screens/table/component/line_number_widget.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/height_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class TableInputFields extends StatefulWidget {
  final String projectName, partyName, fileName, isScreen;
  final num updateId, lastId;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> tableData;

  const TableInputFields(
      {super.key,
      required this.projectName,
      required this.partyName,
      required this.fileName,
      required this.updateId,
      required this.lastId,
      required this.isScreen,
      required this.tableData});

  @override
  State<TableInputFields> createState() => TableInputFieldsState();
}

class TableInputFieldsState extends State<TableInputFields> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        HeightConstant.sizedBoxHeight10(),
        LineNumberWidget(
          isScreen: widget.isScreen,
          projectName: widget.projectName,
          partyName: widget.partyName,
          fileName: widget.fileName,
          lastId: widget.lastId,
          updateId: widget.updateId,
        ),
        HeightConstant.sizedBoxHeight20(),
        NoteRow(txtNoteController: Globals.txtNoteController),
        HeightConstant.sizedBoxHeight10(),
        RftRow(
            txtFeetController: Globals.txtFeetController,
            txtInchController: Globals.txtInchController),
        HeightConstant.sizedBoxHeight15(),
        TotalRow(
            txtQtyController: Globals.txtQtyController,
            txtInchController: Globals.txtInchController,
            txtFeetController: Globals.txtFeetController),
        HeightConstant.sizedBoxHeight15(),
        AddTableDataButton(
            fileName: widget.fileName,
            projectName: widget.projectName,
            partyName: widget.partyName,
            tableData: widget.tableData,
            isScreen: widget.isScreen,
            txtNoteController: Globals.txtNoteController,
            txtFeetController: Globals.txtFeetController,
            txtInchController: Globals.txtInchController,
            txtQtyController: Globals.txtQtyController),
      ],
    );
  }
}
