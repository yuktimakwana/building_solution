import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class StyleConstant {
  static TextStyle splashTextStyle = TextStyle(
      color: ColorConstant.greenColor,
      fontSize: 25.sp,
      height: 1.5,
      shadows: const [
        Shadow(
            color: ColorConstant.shadowTextColor,
            offset: Offset(2, 2),
            blurRadius: 2)
      ],
      fontWeight: FontWeight.w600);

  static TextStyle bigTextStyle = TextStyle(
      color: ColorConstant.naturalWhiteColor,
      fontSize: 18.sp,
      fontWeight: FontWeight.w600);

  static TextStyle bigBlackTextStyle = TextStyle(
      color: ColorConstant.lightBlackColor,
      fontSize: 18.sp,
      fontWeight: FontWeight.w600);

  static TextStyle bigGreenTextStyle = TextStyle(
      color: ColorConstant.greenColor,
      fontSize: 18.sp,
      fontWeight: FontWeight.w600);

  static TextStyle bigSkyTextStyle = TextStyle(
      color: ColorConstant.greenColor,
      fontSize: 18.sp,
      fontWeight: FontWeight.w600);

  static TextStyle bigBlack500TextStyle = TextStyle(
      color: ColorConstant.naturalBlackColor,
      fontSize: 18.sp,
      fontWeight: FontWeight.w500);

  static TextStyle mediumGreyTextStyle = TextStyle(
      color: ColorConstant.darkGreyColor,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400);

  static TextStyle mediumDarkGreyTextStyle = TextStyle(
      color: ColorConstant.darkGreyColor,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600);

  static TextStyle mediumDarkTextStyle = TextStyle(
      color: ColorConstant.naturalBlackColor,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600);

  static TextStyle mediumWhiteGreyTextStyle = TextStyle(
      color: ColorConstant.naturalWhiteColor,
      fontSize: 16.sp,
      fontWeight: FontWeight.w600);

  static TextStyle naturalBlackTextStyle = TextStyle(
      color: ColorConstant.lightBlackColor,
      fontSize: 16.sp,
      fontWeight: FontWeight.w400);

  static TextStyle mediumTextStyle = const TextStyle(
      color: ColorConstant.naturalBlackColor,
      fontSize: 14,
      fontWeight: FontWeight.w600);

  static TextStyle mediumWhiteTextStyle = const TextStyle(
      color: ColorConstant.naturalWhiteColor,
      fontSize: 14,
      fontWeight: FontWeight.w600);

  static TextStyle mediumBlueTextStyle = const TextStyle(
      color: ColorConstant.blueColor,
      fontSize: 16,
      fontWeight: FontWeight.bold);

  static TextStyle mediumLightTextStyle = const TextStyle(
      color: ColorConstant.darkColor,
      fontSize: 14,
      fontWeight: FontWeight.w500);

  static TextStyle errorTextColor = TextStyle(
      color: ColorConstant.errorColor,
      fontSize: 12.sp,
      fontWeight: FontWeight.w600);

  static TextStyle smallTextStyle = const TextStyle(
      color: ColorConstant.naturalBlackColor,
      fontSize: 12,
      fontWeight: FontWeight.w600);

  static TextStyle smallLightTextStyle = const TextStyle(
      color: ColorConstant.naturalBlackColor,
      fontSize: 12,
      fontWeight: FontWeight.w500);

  static TextStyle pastelRedTextStyle = const TextStyle(
      color: ColorConstant.pastelRedColor,
      fontSize: 12,
      fontWeight: FontWeight.w600);

  static TextStyle smallBoldTextStyle = const TextStyle(
      color: ColorConstant.mediumLightGreyColor,
      fontSize: 12,
      fontWeight: FontWeight.w400);
}
