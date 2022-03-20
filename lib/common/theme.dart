import 'package:flutter/material.dart';

final themeData = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.orange[300],
  primarySwatch: Colors.orange,
  accentColor: Colors.orange[300],
  scaffoldBackgroundColor: const Color(0xFF151515),

  fontFamily: 'Montserrat',

  // Buttons:
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.orange[300],
  ),

  // FIXME: Obsolete?
  buttonTheme: ButtonThemeData(
    highlightColor: Colors.orange[300],
    buttonColor: Colors.orange[300],
    textTheme: ButtonTextTheme.normal,
  ),
  // elevatedButtonTheme: ElevatedButtonThemeData(
  //   style: ElevatedButton.styleFrom(
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.circular(10.0),
  //     ),
  //   ),
  // ),

  colorScheme: const ColorScheme.dark(
    secondary: Color(0xFF9B60EC),
    // primary: Colors.orange[300],
    // primaryVariant: Colors.orange[300],
    // secondary: Colors.orange[300],
    // secondaryVariant: Colors.orange[300],
    // surface: Colors.orange[300],
    // background: Colors.orange[300],
    // error: Colors.orange[300],
    // onPrimary: Colors.orange[300],
    // onSecondary: Colors.orange[300],
    // onSurface: Colors.orange[300],
    // onBackground: Colors.orange[300],
    // onError: Colors.orange[300],
    // brightness: Brightness.dark,
  ),
);
