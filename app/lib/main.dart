import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nutriscient/fcm/main.dart';
import 'package:nutriscient/fcm/message.dart';
import 'package:nutriscient/ui/nutriscient_app_theme.dart';
import 'package:nutriscient/ui/register/register_screen.dart';

import 'package:nutriscient/util/constants.dart';
import 'package:nutriscient/ui/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await loadConstants();
  await Firebase.initializeApp();
  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown])
      .then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: !kIsWeb && Platform.isAndroid ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarDividerColor: Colors.grey,
      systemNavigationBarIconBrightness: Brightness.dark,
    ));
    return MaterialApp(
      theme: nutriscientAppThemeData,
      debugShowCheckedModeBanner: false,
      // home: NutriscientHomeScreen(),
      routes: {
        '/': (context) => Application(),
        '/message': (context) => MessageView(),
        // '/message_register': (context) => RegisterScreen(),
      }
    );
  }
}

class HexColor extends Color {
  HexColor(final String hexColor) : super(_getColorFromHex(hexColor));

  static int _getColorFromHex(String hexColor) {
    hexColor = hexColor.toUpperCase().replaceAll('#', '');
    if (hexColor.length == 6) {
      hexColor = 'FF' + hexColor;
    }
    return int.parse(hexColor, radix: 16);
  }
}