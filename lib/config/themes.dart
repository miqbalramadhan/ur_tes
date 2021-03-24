import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:ur_tes/values/colors.dart';

ThemeData defaultThemes(BuildContext context) {
  return ThemeData(
    visualDensity: VisualDensity.adaptivePlatformDensity,
    primaryColor: MyColors.indigo,
    accentColor: MyColors.primary,
    errorColor: MyColors.error,
    canvasColor: Colors.white,
    buttonColor: MyColors.primary,
    textTheme: GoogleFonts.openSansTextTheme(
      TextTheme(
        button: TextStyle(color: Colors.white),
        bodyText1: TextStyle(color: MyColors.black[900], fontWeight: FontWeight.bold, fontSize: 14),
        bodyText2: TextStyle(color: MyColors.black[700], fontSize: 14),
        overline: TextStyle(fontSize: 12, letterSpacing: 0.0),
        subtitle1: TextStyle(fontSize: 14),
      ),
    ),
    buttonTheme: ButtonThemeData(
      height: 45,
      buttonColor: MyColors.primary,
      disabledColor: MyColors.primary[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hintStyle: TextStyle(
        color: MyColors.black[700],
      ),
      contentPadding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 10.0,
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: MyColors.black[400]),
      ),
      border: OutlineInputBorder(
        borderSide: BorderSide(width: 1, color: MyColors.black[400]),
      ),
    ),
    appBarTheme: AppBarTheme(
      iconTheme: IconThemeData(
        color: MyColors.indigo,
      ),
      color: Colors.transparent,
      elevation: 0.0,
      brightness: Brightness.light,
      actionsIconTheme: IconThemeData(
        color: MyColors.indigo,
      ),
      textTheme: TextTheme(
        headline6: TextStyle(color: MyColors.indigo),
      ),
    ),
    brightness: Brightness.light,
  );
}

extension CustomTextStyle on TextTheme {
  TextStyle get bodyText3 {
    return TextStyle(
      fontSize: 18.0,
      color: Colors.red,
      fontWeight: FontWeight.bold,
    );
  }
}
