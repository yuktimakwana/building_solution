import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:flutter/material.dart';

Widget confirmButton(
    {required BuildContext context,
    required String title,
    Color? color,
    required Function()? onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: ColorConstant.naturalWhiteColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
    child: Text(title, style: StyleConstant.mediumWhiteGreyTextStyle),
  );
}
