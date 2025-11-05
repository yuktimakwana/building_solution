import 'package:duplicate_building_solution/screens/table/component/table_fields.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

updateTableData({
  required BuildContext context,
  required String fileName,
  required String partyName,
  required String isScreen,
  required num id,
  required int lastId,
  required List<QueryDocumentSnapshot<Map<String, dynamic>>> tableData,
  required String projectName,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer<ChangeNotifierEx>(
          builder: (context, changeNotifierEx, child) {
        return AlertDialog(
            backgroundColor: ColorConstant.naturalWhiteColor,
            surfaceTintColor: Colors.transparent,
            content: TableInputFields(
              isScreen: isScreen,
              tableData: tableData,
              fileName: fileName,
              projectName: projectName,
              partyName: partyName,
              updateId: id,
              lastId: lastId,
            ));
      });
    },
  );
}
