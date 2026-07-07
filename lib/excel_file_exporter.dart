import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExcelReportExtractor {
  String partyName, projectName, fileName;

  ExcelReportExtractor({
    required this.partyName,
    required this.projectName,
    required this.fileName,
  });

  final Excel excelFile = Excel.createExcel();

  Future<void> create({required List<Map<String, dynamic>> model}) async {
    Sheet sheetObject = excelFile['Sheet1'];
    // final allKeys = model.expand((map) => map.keys).toSet().toList().reversed;

    // Define the desired column order
    final desiredOrder = [
      TextConstant.idColumn,
      TextConstant.noteColumn,
      TextConstant.feetColumn,
      TextConstant.inchColumn,
      TextConstant.rftColumn,
      TextConstant.qtyColumn,
      TextConstant.totalColumn,
      TextConstant.dataAddOnColumn,
    ];

    // Write headers
    int colNum = 0;
    for (var header in desiredOrder) {
      sheetObject
          .cell(CellIndex.indexByString('${String.fromCharCode(65 + colNum)}1'))
          .value = TextCellValue(
        header,
      );
      colNum++;
    }

    // Write data
    int rowNum = 1;
    for (var rowData in model) {
      int colNum = 0;
      for (var header in desiredOrder) {
        final value = rowData[header];
        dynamic cellValue;
        if (value is num) {
          cellValue = TextCellValue(value.toString());
        } else if (value is Timestamp) {
          final formatter = DateFormat('dd MMM yyyy');
          cellValue = TextCellValue(formatter.format(value.toDate()));
        } else {
          cellValue = TextCellValue(value ?? '');
        }
        sheetObject
                .cell(
                  CellIndex.indexByString(
                    '${String.fromCharCode(65 + colNum)}${rowNum + 1}',
                  ),
                )
                .value =
            cellValue;
        colNum++;
      }
      rowNum++;
    } // Working code

    // Determine columns to sum
    final columnsToSum = [
      TextConstant.feetColumn,
      TextConstant.inchColumn,
      TextConstant.rftColumn,
      TextConstant.qtyColumn,
      TextConstant.totalColumn,
    ]; // Replace with your column names

    // Find column indexes
    final columnIndexes = <String, int>{};
    for (var i = 0; i < sheetObject.rows.first.length; i++) {
      final header = sheetObject.rows.first[i]?.value;
      if (columnsToSum.contains(header.toString())) {
        columnIndexes[header.toString()] = i;
      }
    }

    // Calculate totals and write to Excel
    final lastRow = sheetObject.rows.length + 1;

    for (final column in columnsToSum) {
      final columnIndex = columnIndexes[column];
      if (columnIndex != null) {
        num total = 0;
        for (var row = 1; row < sheetObject.rows.length; row++) {
          final cellValue = sheetObject
              .cell(
                CellIndex.indexByString(
                  '${String.fromCharCode(65 + columnIndex)}${row + 1}',
                ),
              )
              .value;
          // if ((double.tryParse(cellValue.toString()) ?? 0) > 0) {
          total += (double.tryParse(cellValue.toString()) ?? 0);
          // }
        }

        sheetObject
            .cell(
              CellIndex.indexByString(
                '${String.fromCharCode(65 + columnIndex)}$lastRow',
              ),
            )
            .value = TextCellValue(
          total.toStringAsFixed(2),
        );
      }
    }

    // Find the index of the "ID" column
    final idColumnIndex = sheetObject.rows.first.indexWhere(
      (cell) => cell?.value == TextCellValue(TextConstant.idColumn),
    );

    // Add "Total" label to the "ID" column
    sheetObject
        .cell(
          CellIndex.indexByString(
            '${String.fromCharCode(65 + idColumnIndex)}$lastRow',
          ),
        )
        .value = TextCellValue(
      TextConstant.totalColumn,
    );

    // // Write headers
    // int rowNum = 0;
    // for (var key in allKeys) {
    //   sheetObject
    //       .cell(CellIndex.indexByString('${String.fromCharCode(65 + rowNum)}1'))
    //       .value = TextCellValue(key);
    //   rowNum++;
    // }
    //
    // rowNum = 1;
    // for (var rowData in model.reversed) {
    //   int colNum = 0;
    //   for (var key in allKeys) {
    //     final value = rowData[key];
    //     dynamic cellValue;
    //     if (value is Timestamp) {
    //       final formatter = DateFormat('dd MMM yyyy');
    //       cellValue = TextCellValue(formatter.format(value.toDate()));
    //     } else {
    //       cellValue = TextCellValue(value.toString() ?? '');
    //     }
    //     sheetObject
    //         .cell(CellIndex.indexByString(
    //             '${String.fromCharCode(65 + colNum)}${rowNum + 1}'))
    //         .value = cellValue; // Handle null values
    //     colNum++;
    //   }
    //   rowNum++;
    // }
    // Working code

    // Map<String, dynamic> merged = {};
    // merged.addEntries([
    //   MapEntry("Created at:",
    //       DateFormat('dd.MM.yyyy HH.mm').format(DateTime.now().toUtc()))
    // ]);
    //
    // for (var element in model) {
    //   merged.addEntries(element.entries);
    //   print(element.values);
    // }
    //
    // Sheet defaultSheet = excelFile[excelFile.getDefaultSheet()!];
    // List.generate(merged.keys.length, (index) {
    //   if (index % 2 == 0) {
    //     defaultSheet
    //         .cell(CellIndex.indexByString(
    //           "A${(index + 1).toString()}",
    //         ))
    //         .value = TextCellValue(merged.keys.elementAt(index));
    //
    //     defaultSheet.cell(CellIndex.indexByString(
    //       "B${(index + 1).toString()}",
    //     ))
    //       ..value = TextCellValue(merged.values.elementAt(index).toString())
    //       ..cellStyle = CellStyle(
    //         bold: true,
    //         textWrapping: TextWrapping.WrapText,
    //         fontFamily: getFontFamily(FontFamily.Arial),
    //         rotation: 0,
    //         horizontalAlign: HorizontalAlign.Right,
    //       );
    //
    //     defaultSheet.cell(CellIndex.indexByString(
    //       "C${(index + 1).toString()}",
    //     ))
    //       ..value = TextCellValue(merged.values.elementAt(index).toString())
    //       ..cellStyle = CellStyle(
    //         bold: true,
    //         textWrapping: TextWrapping.WrapText,
    //         fontFamily: getFontFamily(FontFamily.Arial),
    //         rotation: 0,
    //         horizontalAlign: HorizontalAlign.Right,
    //       );
    //   } else {
    //     defaultSheet.cell(CellIndex.indexByString(
    //       "A${(index + 1).toString()}",
    //     ))
    //       ..value = TextCellValue(merged.keys.elementAt(index))
    //       ..cellStyle = CellStyle(
    //           backgroundColorHex: ExcelColor.fromHexString('#D7D7D7'));
    //
    //     defaultSheet.cell(CellIndex.indexByString(
    //       "B${(index + 1).toString()}",
    //     ))
    //       ..value = TextCellValue(merged.values.elementAt(index).toString())
    //       ..cellStyle = CellStyle(
    //           bold: true,
    //           textWrapping: TextWrapping.WrapText,
    //           fontFamily: getFontFamily(FontFamily.Arial),
    //           rotation: 0,
    //           horizontalAlign: HorizontalAlign.Right,
    //           backgroundColorHex: ExcelColor.fromHexString('#D7D7D7'));
    //   }
    // });
    //
    // defaultSheet.setColumnAutoFit(0);
    // defaultSheet.setColumnAutoFit(1);
    // defaultSheet.setColumnAutoFit(2);

    String finalNameOfFile = "${partyName}_${projectName}_$fileName.xlsx";

    excelFile.save(fileName: finalNameOfFile);
    var fileBytes = excelFile.save(fileName: finalNameOfFile);
    var directory = await getApplicationDocumentsDirectory();

    File(join("${directory.path}/$finalNameOfFile"))
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes ?? []);

    // Share the file using share_plus
    await SharePlus.instance.share(
      ShareParams(files: [XFile("${directory.path}/$finalNameOfFile")]),
    );
  }
}
