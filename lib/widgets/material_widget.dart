import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:flutter/material.dart';

class MaterialWidget extends StatelessWidget {
  final Widget child;
  final Color? color;
  const MaterialWidget({super.key,required this.child,this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8),
      shadowColor: ColorConstant.naturalBlackColor,
      color: color ?? ColorConstant.naturalWhiteColor,
      elevation: 4,
      child: child,
    );
  }
}
