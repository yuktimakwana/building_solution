import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void showExitDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Confirm Exit'),
      content: const Text('Do you really want to go back?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(), // close dialog
          child: const Text('No',
              style: TextStyle(color: ColorConstant.greenColor)),
        ),
        TextButton(
          onPressed: () {
            SystemNavigator.pop();
          },
          child: const Text('Yes',
              style: TextStyle(color: ColorConstant.greenColor)),
        ),
      ],
    ),
  );
}
