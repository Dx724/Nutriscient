import 'package:flutter/material.dart';

class NutriscientAppTheme {
  NutriscientAppTheme._();

  static const Color nearlyWhite = Color(0xFFFAFAFA);
  static const Color white = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF2F3F8);
  static const Color nearlyDarkBlue = Color(0xFF2633C5);

  static const Color nearlyBlue = Color(0xFF00B6F0);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'Roboto';

  static const TextTheme textTheme = TextTheme(
    headline1: display1,
    headline2: display1,
    headline3: display1,
    headline4: display1,
    headline5: headline,
    headline6: title,
    subtitle1: subtitle,
    subtitle2: subtitle,
    bodyText1: body1,
    bodyText2: body2,
    caption: caption,
  );

  static const TextStyle display1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 36,
    letterSpacing: 0.4,
    height: 0.9,
    color: darkerText,
  );

  static const TextStyle headline = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 24,
    letterSpacing: 0.27,
    color: darkerText,
  );

  static const TextStyle title = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.bold,
    fontSize: 16,
    letterSpacing: 0.18,
    color: darkerText,
  );

  static const TextStyle subtitle = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: -0.04,
    color: darkText,
  );

  static const TextStyle body2 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 14,
    letterSpacing: 0.2,
    color: darkText,
  );

  static const TextStyle body1 = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: -0.05,
    color: darkText,
  );

  static const TextStyle caption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w400,
    fontSize: 16,
    letterSpacing: 0.2,
    color: lightText, // was lightText
  );

  static const TextStyle imageCaption = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.normal,
    fontSize: 18,
    letterSpacing: 0.5,
    color: darkText,
  );

  static const TextStyle dropdownItem = TextStyle(
    fontFamily: fontName,
    fontWeight: FontWeight.w600,
    fontSize: 16,
    letterSpacing: 0.5,
    color: darkText,
  );
}

ThemeData nutriscientAppThemeData = ThemeData.light().copyWith(
    textTheme: NutriscientAppTheme.textTheme,
    dataTableTheme: ThemeData.light().dataTableTheme.copyWith(
          // dataRowColor: backgroundColor,
          dataTextStyle: NutriscientAppTheme.body2,
          // headingRowColor: backgroundColor,
          headingTextStyle: NutriscientAppTheme.title,
        ));

// Color getColor(Set<MaterialState> states) {
//   const Set<MaterialState> interactiveStates = <MaterialState>{
//     MaterialState.pressed,
//     MaterialState.hovered,
//     MaterialState.focused,
//   };
//   if (states.any(interactiveStates.contains)) {
//     return NutriscientAppTheme.dark_grey;
//   }
//   return NutriscientAppTheme.background;
// }
//
// MaterialStateProperty<Color> backgroundColor =
//     MaterialStateProperty.resolveWith(getColor);
