import 'package:duplicate_building_solution/bloc/add_party/add_party_bloc.dart';
import 'package:duplicate_building_solution/dialog/component/confirm_button.dart';
import 'package:duplicate_building_solution/dialog/create_description_dialog.dart';
import 'package:duplicate_building_solution/model/party_model.dart';
import 'package:duplicate_building_solution/repository/add_party_repository.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/image_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

Widget floatingActionButton({
  required TextEditingController partyNameController,
  required TextEditingController partyDescController,
  required List<PartyModel> partyModel,
  required ScrollController partyScrollController,
}) {
  String partyName = '';
  AddPartyBloc partyBloc = AddPartyBloc(
    addPartyRepository: AddPartyRepository(),
  );

  void duplicatePartyName() {
    for (int i = 0; i < partyModel.length; i++) {
      if (partyNameController.text == partyModel[i].partyName) {
        partyName = partyModel[i].partyName ?? '';
      }
    }
  }

  return Consumer<ErrorValidation>(
    builder: (context, error, child) {
      return FloatingActionButton(
        onPressed: () {
          error.setValue('');
          createDescriptionDialog(
            context: context,
            text: TextConstant.addPartyCap,
            screenName: TextConstant.partyName,
            image: ImageConstant.noPartyImage,
            controller1: partyNameController,
            controller2: partyDescController,
            createButton: MultiBlocProvider(
              providers: [BlocProvider.value(value: partyBloc)],
              child: Consumer<ChangeNotifierEx>(
                builder: (context, changeNotifierEx, child) {
                  return BlocConsumer<AddPartyBloc, AddPartyState>(
                    listener: (context, state) {
                      if (state is AddPartyError) {
                        customToast(state.errorMessage);
                      } else if (state is AddPartyComplete) {
                        Navigator.pop(context);
                        partyNameController.text = '';
                        partyDescController.text = '';
                        changeNotifierEx.isChecked = false;
                        if (partyScrollController.hasClients) {
                          partyScrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 2000),
                            curve: Curves.bounceInOut,
                          );
                        }

                        FocusScope.of(context).requestFocus(FocusNode());
                      }
                    },
                    builder: (context, state) {
                      return confirmButton(
                        context: context,
                        color: changeNotifierEx.isChecked
                            ? ColorConstant.greenColor
                            : ColorConstant.opacityWhiteColor,
                        title: TextConstant.create,
                        onPressed: changeNotifierEx.isChecked
                            ? () {
                                duplicatePartyName();
                                if (partyNameController.text
                                        .toLowerCase()
                                        .trim() ==
                                    partyName.toLowerCase().trim()) {
                                  error.setValue(
                                    '${TextConstant.partyName} ${TextConstant.alreadyExist}',
                                  );
                                } else {
                                  if (!partyBloc.isClosed) {
                                    partyBloc.add(
                                      NewAddPartyEvent(
                                        partyDesc: partyDescController.text,
                                        partyName: partyNameController.text,
                                        partyNameLower: partyNameController.text
                                            .trim()
                                            .replaceAll(RegExp(r'\s+'), '')
                                            .toLowerCase(),
                                        partyDeleted: 'no',
                                      ),
                                    );
                                  }
                                }
                              }
                            : () {},
                      );
                    },
                  );
                },
              ),
            ),
          );
        },
        backgroundColor: ColorConstant.greenColor,
        child: const Icon(Icons.add, color: ColorConstant.naturalWhiteColor),
      );
    },
  );
}
