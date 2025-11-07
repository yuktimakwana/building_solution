import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:flutter/material.dart';

Widget errorWidget(BuildContext context) {
  return Center(
    child: Text(
      TextConstant.clientError,
      style: StyleConstant.naturalBlackTextStyle,
    ),
  );
}
