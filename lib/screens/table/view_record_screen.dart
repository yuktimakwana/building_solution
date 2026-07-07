/*
import 'package:duplicate_building_solution/excel_file_exporter.dart';

import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/height_constant.dart';
import 'package:duplicate_building_solution/widgets/app_bar_widget.dart';
import 'package:duplicate_building_solution/widgets/loading_widget.dart';
import 'package:duplicate_building_solution/widgets/padding_container.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AllTableDataScreen extends StatefulWidget {
  final String projectName, partyName, fileName;
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> tableData;

  const AllTableDataScreen({
    super.key,
    required this.projectName,
    required this.fileName,
    required this.partyName,
    required this.tableData,
  });

  @override
  State<AllTableDataScreen> createState() => AllTableDataScreenState();
}

class AllTableDataScreenState extends State<AllTableDataScreen> {
  String isScreen = '';

  List<QueryDocumentSnapshot<Map<String, dynamic>>> excelData = [];

  @override
  void initState() {
    isScreen = 'allData';
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        // pageTransition(
        //   context,
        //   TableDataScreen(
        //     fileName: widget.fileName,
        //     partyName: widget.partyName,
        //     projectName: widget.projectName,
        //   ),
        // );
      },

      child: Scaffold(
        appBar: appBarWidget(
          color: ColorConstant.greenColor,
          context: context,
          backPress: () {
            // pageTransition(
            //   context,
            //   TableDataScreen(
            //     fileName: widget.fileName,
            //     partyName: widget.partyName,
            //     projectName: widget.projectName,
            //   ),
            // );
          },
          title: widget.fileName,
          action: [

          ],
        ),
        body: StreamBuilder(
          stream: FirebaseRef.partyUserDoc
              .doc(widget.partyName)
              .collection('Globals.projectCollection')
              .doc(widget.projectName)
              .collection('Globals.fileCollection')
              .doc(widget.fileName)
              .collection('Globals.recordsCollection')
              .orderBy("Globals.idColumn", descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SizedBox();
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return loadingWidget(context);
            } else {
              var tableData = snapshot.data?.docs;
              excelData = tableData ?? [];

              return SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  child: PaddingContainer(
                    child: Column(
                      children: [
                        HeightConstant.sizedBoxHeight20(),
                        // TableHeadingWidget(tableData: tableData ?? []),
                        // TableListWidget(
                        //   isScreen: isScreen,
                        //   fileName: widget.fileName,
                        //   projectName: widget.projectName,
                        //   partyName: widget.partyName,
                        //   tableData: tableData,
                        // ),
                        HeightConstant.sizedBoxHeight15(),
                      ],
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/excel_file_exporter.dart';
import 'package:duplicate_building_solution/model/record_model.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/widgets/app_bar_widget.dart';
import 'package:duplicate_building_solution/widgets/loading_widget.dart';
import 'package:flutter/material.dart';

class ViewRecordsScreen extends StatefulWidget {
  final String partyName;
  final String projectName;
  final String fileName;

  const ViewRecordsScreen({
    super.key,
    required this.partyName,
    required this.projectName,
    required this.fileName,
  });

  @override
  State<ViewRecordsScreen> createState() => _ViewRecordsScreenState();
}

class _ViewRecordsScreenState extends State<ViewRecordsScreen> {
  List<QueryDocumentSnapshot<Map<String, dynamic>>> excelData = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBarWidget(
        title: widget.fileName,
        context: context,
        backPress: () {
          Navigator.pop(context);
        },
        color: ColorConstant.greenColor,
        showSearchBar: false,
        action: [
          IconButton(
            onPressed: () async {
              List<Map<String, dynamic>> model = [];
              for (var element in excelData) {
                model.add(element.data());
              }

              ExcelReportExtractor(
                partyName: widget.partyName,
                fileName: widget.fileName,
                projectName: widget.projectName,
              ).create(model: model);
            },
            icon: const Icon(
              Icons.download,
              color: ColorConstant.naturalWhiteColor,
            ),
          ),
        ],
      ),
      body: StreamBuilder(
        stream: FirebaseRef.partyUserDoc
            .doc(widget.partyName)
            .collection('project')
            .doc(widget.projectName)
            .collection('file')
            .doc(widget.fileName)
            .collection('records')
            .orderBy('no')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return loadingWidget(context);
          }

          final records = snapshot.data!.docs
              .map((doc) => RecordModel.fromDoc(doc))
              .toList();

          excelData = snapshot.data!.docs;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8,vertical: 16.0),
              child: _RecordsTable(records: records),
            ),
          );
        },
      ),
    );
  }
}

class _RecordsTable extends StatelessWidget {
  final List<RecordModel> records;

  const _RecordsTable({required this.records});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;

    final border = TableBorder.all(color: Colors.black54, width: 1);

    final headers = const ['#', 'Note', 'Feet', 'Inch', 'Rft', 'Qty', 'Total'];

    return SizedBox(
      width: screenWidth, // ✅ full device width

      child: Table(
        border: border,
        columnWidths:  {
          0: const FractionColumnWidth(0.08),
          1: const FractionColumnWidth(0.3),
          2: const FractionColumnWidth(0.09),
          3: const FractionColumnWidth(0.09),
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
                  (h) =>
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 8),
                    child: Text(
                      h,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
            )
                .toList(),
          ),
          ...records.map((r) {
            return TableRow(
              decoration: const BoxDecoration(color: Colors.white),
              children: [
                _cell('${r.idColumn}'),
                _cell(r.note),
                _cell(r.feet),
                _cell(r.inch),
                _cell(r.rft),
                _cell(r.qty.toString()),
                _cell(r.total),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _cell(String text) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2,vertical: 8),
        child: Text(
          text,
          style: const TextStyle(fontSize: 14),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          maxLines: 3,
        ),
      );
}
