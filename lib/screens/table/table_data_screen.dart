import 'package:duplicate_building_solution/screens/file/file_screen.dart';
import 'package:duplicate_building_solution/screens/table/all_table_data_screen.dart';
import 'package:duplicate_building_solution/screens/table/component/table_list_widget.dart';
import 'package:duplicate_building_solution/screens/table/component/table_fields.dart';
import 'package:duplicate_building_solution/screens/table/component/table_heading_widget.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/height_constant.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/widgets/app_bar_widget.dart';
import 'package:duplicate_building_solution/widgets/loading_widget.dart';
import 'package:duplicate_building_solution/widgets/padding_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TableDataScreen extends StatefulWidget {
  final String fileName, partyName, projectName;

  const TableDataScreen({
    super.key,
    required this.fileName,
    required this.partyName,
    required this.projectName,
  });

  @override
  State<TableDataScreen> createState() => _TableDataScreenState();
}

class _TableDataScreenState extends State<TableDataScreen> {
  ScrollController tableListController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Globals.partyCollection)
          .doc(widget.partyName)
          .collection(Globals.projectCollection)
          .doc(widget.projectName)
          .collection(Globals.fileCollection)
          .doc(widget.fileName)
          .collection(Globals.recordsCollection)
          .orderBy(Globals.idColumn, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox();
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return loadingWidget(context);
        } else {
          var tableData = snapshot.data?.docs;

          Globals.tableId = (tableData ?? []).isEmpty
              ? 0
              : tableData?.first[Globals.idColumn];

          return Consumer<UpdateLineNumber>(
            builder: (context, updateLineNumber, child) {
              return Consumer<CountTotalLess>(
                builder: (context, countTotal, child) {
                  return PopScope(
                    canPop: false,
                    onPopInvokedWithResult: (didPop, result) {
                      if (didPop) return;
                      pageTransition(
                        context,
                        FileScreen(
                          partyName: widget.partyName,
                          projectName: widget.projectName,
                        ),
                      );

                      setState(() {
                        Globals.txtInchController.text = '';
                        Globals.txtNoteController.text = '';
                        Globals.txtFeetController.text = '';
                        Globals.txtQtyController.text = '';
                        Globals.total = 0;

                        countTotal.setValue(0, false);
                        updateLineNumber.setId(Globals.tableId + 1, false);
                      });
                    },

                    child: Scaffold(
                      appBar: appBarWidget(
                        backPress: () {
                          pageTransition(
                            context,
                            FileScreen(
                              partyName: widget.partyName,
                              projectName: widget.projectName,
                            ),
                          );
                          setState(() {
                            Globals.txtInchController.text = '';
                            Globals.txtNoteController.text = '';
                            Globals.txtFeetController.text = '';
                            Globals.txtQtyController.text = '';
                            Globals.total = 0;

                            countTotal.setValue(0, false);
                            updateLineNumber.setId(Globals.tableId + 1, false);
                          });
                        },
                        color: ColorConstant.greenColor,
                        context: context,
                        title: widget.fileName,
                        action: [
                          (tableData ?? []).isEmpty
                              ? const SizedBox()
                              : TextButton(
                                  onPressed: () {
                                    pageTransition(
                                      context,
                                      AllTableDataScreen(
                                        fileName: widget.fileName,
                                        tableData: tableData ?? [],
                                        partyName: widget.partyName,
                                        projectName: widget.projectName,
                                      ),
                                    );
                                  },
                                  child: Text(
                                    TextConstant.view,
                                    style: StyleConstant.mediumWhiteTextStyle,
                                  ),
                                ),
                        ],
                      ),
                      body: Consumer<ScrollToUpOnKb>(
                        builder: (context, scroll, child) {
                          return SingleChildScrollView(
                            reverse: scroll.isReverse,
                            child: PaddingContainer(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  HeightConstant.sizedBoxHeight20(),
                                  SizedBox(
                                    height: (tableData ?? []).isNotEmpty
                                        ? ScreenSize(context).height / 4
                                        : 0,
                                    child: SingleChildScrollView(
                                      reverse: (tableData ?? []).length > 8
                                          ? true
                                          : false,
                                      controller: tableListController,
                                      child: Column(
                                        children: [
                                          TableHeadingWidget(
                                            tableData: tableData ?? [],
                                          ),
                                          TableListWidget(
                                            fileName: widget.fileName,
                                            projectName: widget.projectName,
                                            partyName: widget.partyName,
                                            isScreen: '',
                                            tableData: tableData,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  TableInputFields(
                                    lastId: (tableData ?? []).isEmpty
                                        ? 0
                                        : tableData?.first[Globals.idColumn],
                                    updateId: (tableData ?? []).isEmpty
                                        ? 0
                                        : tableData?.first[Globals.idColumn],
                                    isScreen: '',
                                    tableData: tableData ?? [],
                                    fileName: widget.fileName,
                                    projectName: widget.projectName,
                                    partyName: widget.partyName,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },
              );
            },
          );
        }
      },
    );
  }
}
