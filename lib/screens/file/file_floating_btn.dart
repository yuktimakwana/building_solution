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
  AddFileBloc addFileBloc = AddFileBloc(addFileRepository: AddFileRepository());

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
                        Navigator.of(context, rootNavigator: true).pop();
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
                                if (fileNameController.text.isEmpty) {
                                  error.setValue(
                                    TextConstant.folderNameRequired,
                                  );
                                } else {
                                  final enteredName = fileNameController.text
                                      .trim()
                                      .toLowerCase();

                                  final isDuplicate = fileModel.any((file) {
                                    final existingName =
                                        (file.fileNameLower ?? "")
                                            .trim()
                                            .replaceAll(RegExp(r'\s+'), '')
                                            .toLowerCase();

                                    final newName = enteredName.replaceAll(
                                      RegExp(r'\s+'),
                                      '',
                                    );

                                    return existingName == newName;
                                  });

                                  if (isDuplicate) {
                                    error.setValue(
                                      '${TextConstant.fileName} ${TextConstant.alreadyExist}',
                                    );
                                    return;
                                  } else {
                                    addFileBloc.add(
                                      NewAddFileEvent(
                                        fileDesc: fileDescController.text,
                                        fileName: fileNameController.text
                                            .trim(),
                                        partyName: partyName,
                                        projectName: projectName,
                                        fileNameLower: enteredName.replaceAll(
                                          RegExp(r'\s+'),
                                          '',
                                        ),
                                        fileDeleted: 'no',
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
