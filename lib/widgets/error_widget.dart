import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:flutter/material.dart';

Widget errorWidget(BuildContext context) {
  return Center(
    child: Text(
      Globals.clientError,
      style: StyleConstant.naturalBlackTextStyle,
    ),
  );
}
