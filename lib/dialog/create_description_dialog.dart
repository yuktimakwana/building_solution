import 'package:duplicate_building_solution/dialog/component/cancel_button.dart';
import 'package:duplicate_building_solution/widgets/input_field.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/height_constant.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:duplicate_building_solution/utils/width_constant.dart';
import 'package:duplicate_building_solution/widgets/default_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void createDescriptionDialog(
    {required BuildContext context,
    required String text,
    required String image,
    required String screenName,
    required TextEditingController controller1,
    required TextEditingController controller2,
    required Widget createButton}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Consumer<ChangeNotifierEx>(
          builder: (context, changeNotifierEx, child) {
        return AlertDialog(
          backgroundColor: ColorConstant.naturalWhiteColor,
          surfaceTintColor: Colors.transparent,
          content: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HeightConstant.sizedBoxHeight5(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(Icons.arrow_back_ios, size: 25)),
                    WidthConstant.sizedBoxWidth20(),
                    Text(
                      text,
                      style: StyleConstant.bigBlackTextStyle,
                      textAlign: TextAlign.center,
                    ),
                    WidthConstant.sizedBoxWidth20(),
                    WidthConstant.sizedBoxWidth10()
                  ],
                ),
                DefaultImage(title: image, height: 100, width: 100),
                HeightConstant.sizedBoxHeight4(),
                InputField(
                    textInputType: TextInputType.text,
                    onChanged: (value) {
                      changeNotifierEx.setChecked();
                    },
                    textInputAction: TextInputAction.next,
                    controller: controller1,
                    maxLines: 1,
                    hintText: TextConstant.enterNameHere),
                Consumer<ErrorValidation>(builder: (context, error, child) {
                  return error.isErrorText.isNotEmpty
                      ? Align(
                          alignment: Alignment.topLeft,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 7),
                            child: Text(
                              error.isErrorText,
                              style: StyleConstant.errorTextColor,
                              textAlign: TextAlign.left,
                            ),
                          ),
                        )
                      : const SizedBox();
                }),
                HeightConstant.sizedBoxHeight10(),
                InputField(
                    textInputAction: TextInputAction.next,
                    textInputType: TextInputType.text,
                    controller: controller2,
                    maxLines: 5,
                    hintText: TextConstant.addDescription),
                HeightConstant.sizedBoxHeight10(),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    cancelButton(context),
                    WidthConstant.sizedBoxWidth10(),
                    createButton
                  ],
                ),
                HeightConstant.sizedBoxHeight10(),
              ],
            ),
          ),
        );
      });
    },
  );
}
