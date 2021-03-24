import 'package:flutter/material.dart';

class MyColors {
  static const MaterialColor primary = MaterialColor(
    _tradaruPrimaryValue,
    <int, Color>{
      100: Color(0xffDCF4F5),
      200: Color(0xffB9E8EA),
      300: Color(0xff96DDE0),
      400: Color(0xff73D2D5),
      500: Color(0xff50C7CB),
      600: Color(0xff2DBBC0),
      700: Color(_tradaruPrimaryValue),
      800: Color(0xff09A7AC),
      900: Color(0xff089EA3),
    },
  );
  static const MaterialColor error = MaterialColor(
    _tradaruErrorValue,
    <int, Color>{
      50: Color(0xffF7F0F2),
      100: Color(0xffFEE2E8),
      200: Color(0xffFDC5D2),
      300: Color(0xffFBA7BB),
      400: Color(0xffFA8AA5),
      500: Color(_tradaruErrorValue),
      600: Color(0xffF74A73),
    },
  );
  static const MaterialColor dark = MaterialColor(
    _tradaruDarkValue,
    <int, Color>{
      100: Color(0xffC9C9C9),
      200: Color(0xffBEBEBE),
      300: Color(0xffA7A7A7),
      400: Color(0xff707070),
      500: Color(_tradaruDarkValue),
      600: Color(0xff000000),
    },
  );
  static const MaterialColor light = MaterialColor(
    _tradaruLightValue,
    <int, Color>{
      100: Color(0xffD4D4D4),
      200: Color(0xffDADADA),
      300: Color(0xffE5E5E5),
      400: Color(0xffF2F2F2),
      500: Color(_tradaruLightValue),
      600: Color(0xffFFFFFF),
    },
  );
  static const MaterialColor yellow = MaterialColor(
    _tradaruYellowValue,
    <int, Color>{
      50: Color(0xffF7F5F1),
      100: Color(0xffF7F0DE),
      200: Color(0xffF6E5B8),
      300: Color(0xffF7D57B),
      400: Color(0xffF8C63E),
      500: Color(_tradaruYellowValue),
      600: Color(0xffDFA200),
    },
  );
  static const MaterialColor green = MaterialColor(
    _tradaruGreenValue,
    <int, Color>{
      100: Color(0xffE8F8E8),
      200: Color(0xffD2F1D2),
      300: Color(0xffBBEABB),
      400: Color(0xffA5E4A5),
      500: Color(0xff8EDD8E),
      600: Color(0xff78D678),
      700: Color(_tradaruGreenValue),
      800: Color(0xff50CA50),
      900: Color(0xff31BE31),
    },
  );
  static const MaterialColor indigo = MaterialColor(
    _tradaruIndigoValue,
    <int, Color>{
      100: Color(0xffECECFC),
      200: Color(0xffD9D9F9),
      300: Color(0xffC6C6F6),
      400: Color(0xffB2B2F3),
      500: Color(0xff9F9FF0),
      600: Color(0xff8C8CED),
      700: Color(_tradaruIndigoValue),
      800: Color(0xff6969E7),
      900: Color(0xff5A5AE5),
    },
  );
  static const MaterialColor black = MaterialColor(
    _tradaruBlackValue,
    <int, Color>{
      100: Color(0xffF2F2F2),
      200: Color(0xffE5E5E5),
      300: Color(0xffDADADA),
      400: Color(0xffD4D4D4),
      500: Color(0xffC9C9C9),
      600: Color(0xffBEBEBE),
      700: Color(_tradaruBlackValue),
      800: Color(0xff707070),
      900: Color(0xff383838),
    },
  );
  static const MaterialColor pink = MaterialColor(
    _tradaruPinkValue,
    <int, Color>{
      100: Color(0xffFEEAEF),
      200: Color(0xffFDD5DF),
      300: Color(0xffFCC0CF),
      400: Color(0xffFCACBE),
      500: Color(0xffFB97AE),
      600: Color(0xffFA829E),
      700: Color(_tradaruPinkValue),
      800: Color(0xffF85B80),
      900: Color(0xffF74A73),
    },
  );
  static const MaterialColor orange = MaterialColor(
    _tradaruOrangeValue,
    <int, Color>{
      100: Color(0xffFFF5DB),
      200: Color(0xffFFEBB6),
      300: Color(0xffFFE192),
      400: Color(0xffFFD86D),
      500: Color(0xffFFCE49),
      600: Color(0xffFFC424),
      700: Color(_tradaruOrangeValue),
      800: Color(0xffF6B400),
      900: Color(0xffEDAD00),
    },
  );

  static const int _tradaruPrimaryValue = 0xff0AB0B6;
  static const int _tradaruErrorValue = 0xffF96D8E;
  static const int _tradaruDarkValue = 0xff383838;
  static const int _tradaruLightValue = 0xffF8F8F8;
  static const int _tradaruIndigoValue = 0xff7979EA;
  static const int _tradaruYellowValue = 0xffF8B500;
  static const int _tradaruGreenValue = 0xff61CF61;
  static const int _tradaruBlackValue = 0xffA7A7A7;
  static const int _tradaruPinkValue = 0xffF96D8E;
  static const int _tradaruOrangeValue = 0xffFFBA00;
  static const MaterialColor appBarColor = black;
  static const softGray = Color(0xffF8F8F8);
}
