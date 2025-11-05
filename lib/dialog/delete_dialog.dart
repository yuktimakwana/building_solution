import 'package:duplicate_building_solution/model/file_model.dart';
import 'package:duplicate_building_solution/model/party_model.dart';
import 'package:duplicate_building_solution/model/project_model.dart';
import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/globals.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

void deleteDialog(
    {required BuildContext context,
    required String title,
    required String deleteButtonText,
    required Function() onPressed}) {
  showDialog(
    barrierDismissible: true,
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        actionsAlignment: MainAxisAlignment.center,
        backgroundColor: ColorConstant.naturalWhiteColor,
        surfaceTintColor: Colors.transparent,
        contentPadding: const EdgeInsets.all(10),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset("assets/anim/delete_anim.json", height: 50, width: 50),
            Text(
              title,
              style: StyleConstant.mediumTextStyle,
              textAlign: TextAlign.center,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      FocusScope.of(context).unfocus();

                    },
                    child: Text(TextConstant.cancel,
                        style: StyleConstant.smallBoldTextStyle)),
                TextButton(
                    onPressed: onPressed,
                    child: Text(deleteButtonText,
                        style: StyleConstant.pastelRedTextStyle)),
              ],
            )
          ],
        ),
      );
    },
  );
}