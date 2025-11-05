import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:flutter/material.dart';

Widget loadingWidget(BuildContext context) {
  return const Center(
    child: CircularProgressIndicator(color: ColorConstant.greenColor),
  );
}
