import 'package:duplicate_building_solution/bloc/add_file/add_file_bloc.dart';
import 'package:duplicate_building_solution/dialog/component/confirm_button.dart';
import 'package:duplicate_building_solution/dialog/create_description_dialog.dart';
import 'package:duplicate_building_solution/model/file_model.dart';
import 'package:duplicate_building_solution/repository/add_file_repository.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/image_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/widgets/custom_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

Widget fileFloatingBtn({
  required TextEditingController fileNameController,
  required TextEditingController fileDescController,
  required List<FileModel> fileModel,
  required String partyName,
  required String projectName,
  required ScrollController fileScrollController,
}) {
  String fileName = '';

  AddFileBloc addFileBloc = AddFileBloc(addFileRepository: AddFileRepository());

  void duplicateFileName() {
    for (int i = 0; i < fileModel.length; i++) {
      if (fileNameController.text == fileModel[i].fileName) {
        fileName = fileModel[i].fileName ?? '';
      }
    }
  }

  return Consumer<ErrorValidation>(
    builder: (context, error, child) {
      return FloatingActionButton(
        onPressed: () {
          error.setValue('');
          createDescriptionDialog(
            screenName: TextConstant.fileName,
            context: context,
            text: TextConstant.addFileCap,
            controller1: fileNameController,
            controller2: fileDescController,
            image: ImageConstant.noFileImage,
            createButton: MultiBlocProvider(
              providers: [BlocProvider.value(value: addFileBloc)],
              child: Consumer<ChangeNotifierEx>(
                builder: (context, changeNotifierEx, child) {
                  return BlocConsumer<AddFileBloc, AddFileState>(
                    listener: (context, state) {
                      if (state is AddFileComplete) {
                        Navigator.pop(context);
                        fileNameController.text = '';
                        fileDescController.text = '';
                        changeNotifierEx.isChecked = false;
                        if (fileScrollController.hasClients) {
                          fileScrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 2000),
                            curve: Curves.bounceInOut,
                          );
                        }
                      } else if (state is AddFileError) {
                        customToast(state.errorMessage);
                      }
                    },
                    builder: (context, state) {
                      return confirmButton(
                        color: changeNotifierEx.isChecked
                            ? ColorConstant.greenColor
                            : ColorConstant.opacityWhiteColor,
                        context: context,
                        title: TextConstant.create,
                        onPressed: changeNotifierEx.isChecked
                            ? () {
                                duplicateFileName();
                                if (fileNameController.text
                                        .toLowerCase()
                                        .trim() ==
                                    fileName.toLowerCase().trim()) {
                                  error.setValue(
                                    '${TextConstant.fileName} ${TextConstant.alreadyExist}',
                                  );
                                } else {
                                  if (!addFileBloc.isClosed) {
                                    addFileBloc.add(
                                      NewAddFileEvent(
                                        fileDeleted: 'no',
                                        partyName: partyName,
                                        fileNameLower: fileNameController.text
                                            .trim()
                                            .replaceAll(RegExp(r'\s+'), '')
                                            .toLowerCase(),
                                        projectName: projectName,
                                        fileName: fileNameController.text,
                                        fileDesc: fileDescController.text,
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
