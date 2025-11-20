import 'package:duplicate_building_solution/bloc/add_project/add_project_bloc.dart';
import 'package:duplicate_building_solution/dialog/component/confirm_button.dart';
import 'package:duplicate_building_solution/dialog/create_description_dialog.dart';
import 'package:duplicate_building_solution/model/project_model.dart';
import 'package:duplicate_building_solution/repository/add_project_repository.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/image_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/widgets/custom_toast.dart';
import 'package:duplicate_building_solution/screens/file/file_screen.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';

Widget projectFloatingBtn({
  required TextEditingController projectNameController,
  required TextEditingController projectDescController,
  required String partyName,
  required List<ProjectModel> projectModel,
  required ScrollController projectScrollController,
}) {
  return Consumer<ErrorValidation>(
    builder: (context, error, child) {
      AddProjectBloc addProjectBloc = AddProjectBloc(
        addProjectRepository: AddProjectRepository(),
      );

      return FloatingActionButton(
        backgroundColor: ColorConstant.greenColor,
        onPressed: () {
          error.setValue('');
          createDescriptionDialog(
            screenName: TextConstant.projectName,
            context: context,
            text: TextConstant.addProjectCap,
            controller1: projectNameController,
            controller2: projectDescController,
            image: ImageConstant.noProjectImage,
            createButton: MultiBlocProvider(
              providers: [BlocProvider.value(value: addProjectBloc)],
              child: Consumer<ChangeNotifierEx>(
                builder: (context, changeNotifierEx, child) {
                  return BlocConsumer<AddProjectBloc, AddProjectState>(
                    listener: (context, state) {
                      if (state is AddProjectComplete) {
                        Navigator.of(context, rootNavigator: true).pop();
                        projectNameController.text = '';
                        projectDescController.text = '';
                        changeNotifierEx.isChecked = false;
                        if (projectScrollController.hasClients) {
                          projectScrollController.animateTo(
                            0,
                            duration: const Duration(milliseconds: 2000),
                            curve: Curves.bounceInOut,
                          );
                        }
                      } else if (state is AddProjectError) {
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
                                if (projectNameController.text.isEmpty) {
                                  error.setValue(
                                    TextConstant.projectNameRequired,
                                  );
                                } else {
                                  final enteredName = projectNameController.text
                                      .trim()
                                      .toLowerCase();

                                  final isDuplicate = projectModel.any((
                                    project,
                                  ) {
                                    final existingName =
                                        (project.projectNameLower ?? "")
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
                                      '${TextConstant.projectName} ${TextConstant.alreadyExist}',
                                    );
                                    return;
                                  } else {
                                    addProjectBloc.add(
                                      NewAddProjectEvent(
                                        projectDescription:
                                            projectDescController.text,
                                        projectName: projectNameController.text
                                            .trim(),
                                        partyName: partyName,
                                        projectNameLower: enteredName
                                            .replaceAll(RegExp(r'\s+'), ''),
                                        projectDeleted: 'no',
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
        child: const Icon(Icons.add, color: ColorConstant.naturalWhiteColor),
      );
    },
  );
}
