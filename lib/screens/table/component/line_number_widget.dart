import 'package:duplicate_building_solution/bloc/add_table_data/add_table_data_bloc.dart';
import 'package:duplicate_building_solution/repository/add_table_data_repository.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/utils/width_constant.dart';
import 'package:duplicate_building_solution/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

class LineNumberWidget extends StatefulWidget {
  final num updateId;
  final num lastId;
  final String partyName, projectName, fileName, isScreen;

  const LineNumberWidget(
      {super.key,
      required this.updateId,
      required this.lastId,
      required this.isScreen,
      required this.partyName,
      required this.fileName,
      required this.projectName});

  @override
  State<LineNumberWidget> createState() => LineNumberWidgetState();
}

class LineNumberWidgetState extends State<LineNumberWidget> {
  var addTableDataBloc =
      AddTableDataBloc(addTableDataRepository: AddTableDataRepository());

  unUsedMethod(){

  }


  bool isExtraIdAdd = false;

  @override
  Widget build(BuildContext context) {
    double width = ScreenSize(context).width;

    return Container(
      height: 45,
      width: width,
      padding: const EdgeInsets.only(left: 10),
      color: ColorConstant.containerColor,
      child: Consumer<UpdateLineNumber>(
          builder: (context, updateLineNumber, child) {
        return Consumer<CountTotalLess>(builder: (context, countTotal, child) {
          return Consumer<AddRowNotifier>(
            builder: (context, row, child) {
              return Row(
                children: [
                  const Text('Line #: '),
                  Text(
                      '${Globals.isUpdate ? updateLineNumber.id.toStringAsFixed(2) : (Globals.tableId + 1)}'),
                  const Spacer(),
                  MultiBlocProvider(
                      providers: [BlocProvider.value(value: addTableDataBloc)],
                      child: BlocConsumer<AddTableDataBloc, AddTableDataState>(
                          listener: (context, state) {
                        if (state is AddTableDataError) {
                          customToast(state.errorMessage);
                        } else if (state is AddTableDataComplete) {
                          row.setValue([], null, unUsedMethod);

                        }
                      }, builder: (context, state) {
                        return GestureDetector(
                          onTap: () {
                            if (row.selectedIndex == null) {
                              return;
                            } else {
                              setState(() {
                                final newWidget = Table(
                                    columnWidths: Globals.columnWidth,
                                    border: TableBorder.all(
                                        color: ColorConstant
                                            .outLineBorderGreyColor),
                                    children: [
                                      TableRow(children: [
                                        textWidget((updateLineNumber.id + 0.1)
                                            .toStringAsFixed(2)),
                                        textWidget(''),
                                        textWidget(''),
                                        textWidget(''),
                                        textWidget(''),
                                        textWidget(''),
                                        textWidget(''),
                                      ]),
                                    ]);
                                row.table.insert(row.selectedIndex!, newWidget);
                                row.pageReload!();

                                if (!addTableDataBloc.isClosed) {
                                  addTableDataBloc.add(NewAddTableDataEvent(
                                      note: '',
                                      feet: '',
                                      rft: '',
                                      id: num.parse((updateLineNumber.id + 0.1)
                                          .toStringAsFixed(2)),
                                      inch: '',
                                      total: '',
                                      less: false,
                                      partyName: widget.partyName,
                                      projectName: widget.projectName,
                                      fileName: widget.fileName,
                                      qty: ''));
                                }
                              });
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 5),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              decoration: BoxDecoration(
                                  color: ColorConstant.darkColor,
                                  borderRadius: BorderRadius.circular(5)),
                              child: Text(TextConstant.addRow,
                                  style:
                                      StyleConstant.mediumWhiteGreyTextStyle),
                            ),
                          ),
                        );
                      })),
                  WidthConstant.sizedBoxWidth10(),
                  Consumer<ChangeTextStyle>(
                      builder: (context, textStyle, child) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          updateLineNumber.setId(Globals.tableId + 1, false);
                          Globals.txtFeetController.text = '';
                          Globals.txtInchController.text = '';
                          Globals.txtNoteController.text = '';
                          Globals.txtQtyController.text = '';
                          countTotal.setValue(0, false);
                          Globals.tableId = widget.lastId;
                          textStyle.setValue(StyleConstant.smallLightTextStyle);
                          row.setValue([],null, unUsedMethod);
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              vertical: 5, horizontal: 10),
                          decoration: BoxDecoration(
                              color: ColorConstant.darkColor,
                              borderRadius: BorderRadius.circular(5)),
                          child: Text(TextConstant.reset,
                              style: StyleConstant.mediumWhiteGreyTextStyle),
                        ),
                      ),
                    );
                  }),
                  WidthConstant.sizedBoxWidth10(),
                ],
              );
            },
          );
        });
      }),
    );
  }

  Widget textWidget(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Center(
        child: Text(title,
            textAlign: TextAlign.center,
            style: StyleConstant.smallLightTextStyle),
      ),
    );
  }
}
