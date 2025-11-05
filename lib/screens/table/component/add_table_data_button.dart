
import 'package:duplicate_building_solution/bloc/add_table_data/add_table_data_bloc.dart';
import 'package:duplicate_building_solution/dialog/component/confirm_button.dart';
import 'package:duplicate_building_solution/repository/add_table_data_repository.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/widgets/custom_toast.dart';
import 'package:duplicate_building_solution/widgets/loading_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

import '../../../utils/functions.dart';

class AddTableDataButton extends StatefulWidget {
  final TextEditingController txtNoteController,
      txtFeetController,
      txtInchController,
      txtQtyController;

  final List<QueryDocumentSnapshot<Map<String, dynamic>>> tableData;
  final String projectName, partyName, fileName, isScreen;

  const AddTableDataButton(
      {super.key,
      required this.txtNoteController,
      required this.txtFeetController,
      required this.txtInchController,
      required this.txtQtyController,
      required this.projectName,
      required this.partyName,
      required this.fileName,
      required this.isScreen,
      required this.tableData});

  @override
  State<AddTableDataButton> createState() => _AddTableDataButtonState();
}

class _AddTableDataButtonState extends State<AddTableDataButton> {
  var addTableDataBloc =
      AddTableDataBloc(addTableDataRepository: AddTableDataRepository());
  num rft = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<ChangeTextStyle>(builder: (context, textStyle, child) {
      return Consumer<ScrollToUpOnKb>(builder: (context, scroll, child) {
        return Consumer<CountTotalLess>(builder: (context, countTotal, child) {
          return Consumer<UpdateLineNumber>(
              builder: (context, updateLineNumber, child) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                MultiBlocProvider(
                  providers: [BlocProvider.value(value: addTableDataBloc)],
                  child: BlocConsumer<AddTableDataBloc, AddTableDataState>(
                    listener: (context, state) {
                      if (state is AddTableDataError) {
                        customToast(state.errorMessage);
                      } else if (state is AddTableDataComplete) {
                        setState(() {
                          widget.txtInchController.text = '';
                          widget.txtNoteController.text = '';
                          widget.txtFeetController.text = '';
                          widget.txtQtyController.text = '';
                          countTotal.setValue(0, false);
                          FocusScope.of(context)
                              .requestFocus(Globals.txtFeetFocusNode);
                          scroll.setValue(false);
                          textStyle.setValue(StyleConstant.smallLightTextStyle);
                          updateLineNumber.setId(Globals.tableId + 1, false);
                        });
                        if (widget.isScreen == "allData") {
                          Navigator.pop(context);
                        }
                      }
                    },
                    builder: (context, state) {
                      if (state is AddTableDataLoading) {
                        return loadingWidget(context);
                      }
                      return confirmButton(
                          color: ColorConstant.greenColor,
                          context: context,
                          title: TextConstant.nextCap,
                          onPressed: () async {
                            getTotal();

                            setState(() {
                              rft = (num.parse(
                                      Globals.txtFeetController.text.isEmpty
                                          ? '0'
                                          : Globals.txtFeetController.text) +
                                  (num.parse(Globals
                                              .txtInchController.text.isEmpty
                                          ? '0'
                                          : Globals.txtInchController.text)) /
                                      12);
                            });

                            if (!addTableDataBloc.isClosed) {
                              addTableDataBloc.add(NewAddTableDataEvent(
                                  note: widget.txtNoteController.text,
                                  feet: widget.txtFeetController.text.isEmpty
                                      ? '0'
                                      : widget.txtFeetController.text,
                                  rft: rft.toStringAsFixed(2),
                                  id: Globals.tableId + 1,
                                  inch: widget.txtInchController.text.isEmpty
                                      ? '0'
                                      : widget.txtInchController.text,
                                  total: Globals.total.toStringAsFixed(2),
                                  less: countTotal.isChecked,
                                  partyName: widget.partyName,
                                  projectName: widget.projectName,
                                  fileName: widget.fileName,
                                  qty: widget.txtQtyController.text.isEmpty
                                      ? '1'
                                      : widget.txtQtyController.text));
                            }
                          });

                      
                    },
                  ),
                )
              ],
            );
          });
        });
      });
    });
  }
  // Future<bool> check() async {
  //   var connectivityResult = await (Connectivity().checkConnectivity());
  //   if (connectivityResult == ConnectivityResult.mobile) {
  //     return true;
  //   } else if (connectivityResult == ConnectivityResult.wifi) {
  //     return true;
  //   }
  //   return false;
  // }
}
