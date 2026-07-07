import 'package:duplicate_building_solution/Auth/sign_in.dart';
import 'package:duplicate_building_solution/Auth/sign_up.dart';
import 'package:duplicate_building_solution/firebase_options.dart';
import 'package:duplicate_building_solution/screens/party/party_screen.dart';
import 'package:duplicate_building_solution/screens/profile/profile_screen.dart';
import 'package:duplicate_building_solution/screens/splash_screen.dart';
import 'package:duplicate_building_solution/theme/theme_constant.dart';
import 'package:duplicate_building_solution/offline/offline_sync_service.dart';
import 'package:duplicate_building_solution/utils/change_notifier_ex.dart';
import 'package:duplicate_building_solution/utils/functions.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'bloc/get_party_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseRef.init();
  await OfflineSyncService.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChangeNotifierEx()),

        ChangeNotifierProvider(create: (_) => ErrorValidation()),
        ChangeNotifierProvider(create: (_) => ScrollToUpOnKb()),

        ChangeNotifierProvider(create: (_) => GetPartyProvider()),
      ],
      child: ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) {
          return MaterialApp(
            initialRoute: '/',
            routes: {
              '/signin': (context) => SignInScreen(),
              '/signUp': (context) => SignUpScreen(),
              '/party': (context) => PartyScreen(),
              '/profile': (context) => const ProfileScreen(),
            },
            debugShowCheckedModeBanner: false,
            title: 'TBBS',
            theme: lightTheme,
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
