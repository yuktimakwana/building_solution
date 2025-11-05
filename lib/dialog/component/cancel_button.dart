import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:flutter/material.dart';

Widget cancelButton(BuildContext context) {
  return ElevatedButton(
    onPressed: (){
      Navigator.pop(context);
    },
    style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
    child:
        Text(TextConstant.cancel, style: StyleConstant.mediumDarkGreyTextStyle),
  );
}
