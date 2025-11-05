import 'package:duplicate_building_solution/utils/image_constant.dart';
import 'package:flutter/material.dart';

class DefaultImage extends StatelessWidget {
  final String title;
  final double? height;
  final double? width;

  const DefaultImage({super.key, required this.title, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      '${ImageConstant.basePath}$title',
      height: height,
      width: width,
    );
  }
}
