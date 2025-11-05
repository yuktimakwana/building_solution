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
      String projectName = '';

      AddProjectBloc addProjectBloc = AddProjectBloc(
        addProjectRepository: AddProjectRepository(),
      );

      void duplicateProjectName() {
        for (int i = 0; i < projectModel.length; i++) {
          if (projectNameController.text == projectModel[i].projectName) {
            projectName = projectModel[i].projectName ?? '';
          }
        }
      }

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
                        Navigator.pop(context);
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
                                duplicateProjectName();
                                if (projectNameController.text
                                        .toLowerCase()
                                        .trim() ==
                                    projectName.toLowerCase().trim()) {
                                  error.setValue(
                                    '${TextConstant.projectName} ${TextConstant.alreadyExist}',
                                  );
                                } else {
                                  if (!addProjectBloc.isClosed) {
                                    addProjectBloc.add(
                                      NewAddProjectEvent(
                                        partyName: partyName,
                                        projectDeleted: 'no',
                                        projectName: projectNameController.text,
                                        projectNameLower: projectNameController
                                            .text
                                            .trim()
                                            .replaceAll(RegExp(r'\s+'), '')
                                            .toLowerCase(),
                                        projectDescription:
                                            projectDescController.text,
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
