import 'package:duplicate_building_solution/utils/color_constant.dart';
import 'package:fluttertoast/fluttertoast.dart';

void customToast(String toastMessage) {
  Fluttertoast.showToast(
      msg: toastMessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: ColorConstant.jetBlackColor,
      textColor: ColorConstant.naturalWhiteColor,
      fontSize: 16.0);
}
