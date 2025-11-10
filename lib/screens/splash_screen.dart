import 'package:duplicate_building_solution/screens/party/party_screen.dart';
import 'package:duplicate_building_solution/Auth/sign_in.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:duplicate_building_solution/utils/height_constant.dart';
import 'package:duplicate_building_solution/utils/image_constant.dart';
import 'package:duplicate_building_solution/utils/style_constant.dart';
import 'package:duplicate_building_solution/utils/text_constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    Future.delayed(const Duration(seconds: 2), () async {
      getUser();
    });

    //clearSharedPreference();
    super.initState();
  }

  // Future<void> clearSharedPreference() async {
  //   final SharedPreferences sp = await SharedPreferences.getInstance();
  //   sp.clear();
  // }

  Future<void> getUser() async {

    SharedPreferences sp = await SharedPreferences.getInstance();
    String email = sp.getString('email') ?? '';

    if (!mounted) return; // ✅ Safety check

    if (email == FirebaseAuth.instance.currentUser?.email) {
      pageTransition(context, PartyScreen());
    } else {
      pageTransition(context, const SignInScreen());
    }
  }

  @override
  Widget build(BuildContext context) {
    double width = ScreenSize(context).width;
    return Scaffold(
      body: SizedBox(
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              '${ImageConstant.basePath}${ImageConstant.splashImage}',
              height: 150.h,
              width: 120.w,
            ),
            HeightConstant.sizedBoxHeight20(),
            Text(
              TextConstant.bestBuildingSolution,
              style: StyleConstant.splashTextStyle,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
