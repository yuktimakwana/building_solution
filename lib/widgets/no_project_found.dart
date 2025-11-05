import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/height_constant.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/widgets/default_image.dart';
import 'package:flutter/material.dart';

class NoProjectFound extends StatelessWidget {
  final String image;
  final String title;
  final String subTitle;

  const NoProjectFound({
    super.key,
    required this.image,
    required this.title,
    required this.subTitle,
  });

  @override
  Widget build(BuildContext context) {
    double width = ScreenSize(context).width;
    return SizedBox(
      width: width,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DefaultImage(title: image),
            HeightConstant.sizedBoxHeight10(),
            Text(
              title,
              style: StyleConstant.bigSkyTextStyle,
              textAlign: TextAlign.center,
            ),
            HeightConstant.sizedBoxHeight4(),
            Text(
              subTitle,
              style: StyleConstant.mediumGreyTextStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
