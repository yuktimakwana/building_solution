import 'package:duplicate_building_solution/screens/table/component/update_dialog.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TableListWidget extends StatefulWidget {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>>? tableData;
  final String isScreen, projectName, partyName, fileName;

  const TableListWidget({
    super.key,
    required this.tableData,
    required this.isScreen,
    required this.projectName,
    required this.fileName,
    required this.partyName,
  });

  @override
  State<TableListWidget> createState() => _TableListWidgetState();
}

class _TableListWidgetState extends State<TableListWidget> {
  int? selectedIndex;
  num extraRowId = 0.1;
  List<Widget> widgets = [];

  pageReload() {
    setState(() {});
  }

  Widget textWidget(String title, int i) {
    return Consumer<ChangeTextStyle>(builder: (context, textStyle, child) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Center(
          child: Text(title,
              textAlign: TextAlign.center,
              style: selectedIndex == i
                  ? textStyle.style
                  : StyleConstant.smallLightTextStyle),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    widgets = List.generate(
        (widget.tableData ?? []).length,
        (i) => Table(
                columnWidths: Globals.columnWidth,
                border: TableBorder.all(
                    color: ColorConstant.outLineBorderGreyColor),
                children: [
                  TableRow(children: [
                    Consumer<AddRowNotifier>(builder: (context, row, child) {
                      return Consumer<CountTotalLess>(
                          builder: (context, countTotal, child) {
                        return Consumer<UpdateLineNumber>(
                            builder: (context, updateLineNumber, child) {
                          return Consumer<ChangeTextStyle>(
                              builder: (context, textStyle, child) {
                            return GestureDetector(
                                onLongPress: () {
                                  setState(() {
                                    updateLineNumber.setId(
                                        widget.tableData?[i][Globals.idColumn],
                                        false);
                                    textStyle.setValue(
                                        StyleConstant.mediumBlueTextStyle);
                                    selectedIndex = i;
                                    row.setValue(
                                        widgets, selectedIndex, pageReload);
                                  });
                                },
                                onTap: widget.isScreen == 'allData'
                                    ? () {}
                                    : () {
                                        setState(() {
                                          Globals.txtNoteController.text =
                                              widget.tableData?[i]
                                                  [Globals.noteColumn];
                                          Globals.txtQtyController.text = widget
                                              .tableData?[i][Globals.qtyColumn];
                                          Globals.txtFeetController.text =
                                              widget.tableData?[i]
                                                  [Globals.feetColumn];
                                          Globals.txtInchController.text =
                                              widget.tableData?[i]
                                                  [Globals.inchColumn];
                                          countTotal.setValue(
                                              widget.tableData?[i][Globals
                                                          .totalColumn] !=
                                                      ''
                                                  ? num.parse(
                                                      widget.tableData?[i]
                                                          [Globals.totalColumn])
                                                  : 0,
                                              widget.tableData?[i]
                                                  [Globals.lessColumn]);

                                          updateLineNumber.setId(
                                              widget.tableData?[i]
                                                  [Globals.idColumn],
                                              true);

                                          Globals.tableId = updateLineNumber.id;
                                        });

                                        if (widget.isScreen == 'allData') {
                                          updateTableData(
                                              isScreen: widget.isScreen,
                                              context: context,
                                              fileName: widget.fileName,
                                              tableData: widget.tableData ?? [],
                                              lastId: widget.tableData
                                                  ?.first[Globals.idColumn],
                                              id: widget.tableData?[i]
                                                  [Globals.idColumn],
                                              partyName: widget.partyName,
                                              projectName: widget.projectName);
                                        }
                                      },
                                child: textWidget(
                                    '${widget.tableData?[i][Globals.idColumn]}',
                                    i));
                          });
                        });
                      });
                    }),
                    textWidget(
                        '${widget.tableData?[i][Globals.noteColumn]}', i),
                    textWidget(
                        '${widget.tableData?[i][Globals.feetColumn]}', i),
                    textWidget(
                        '${widget.tableData?[i][Globals.inchColumn]}', i),
                    textWidget('${widget.tableData?[i][Globals.rftColumn]}', i),
                    textWidget('${widget.tableData?[i][Globals.qtyColumn]}', i),
                    textWidget(
                        '${widget.tableData?[i][Globals.totalColumn]}', i)
                  ])
                ]));
    return ListView.builder(
        reverse: true,
        shrinkWrap: true,
        itemCount: widgets.length,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, i) {
          return widgets[i];
        });
  }
}
