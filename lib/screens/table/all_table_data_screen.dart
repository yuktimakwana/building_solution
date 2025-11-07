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
