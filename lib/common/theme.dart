import 'package:flutter/material.dart';

final themeData = ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.orange[300],
  primarySwatch: Colors.orange,
  fontFamily: 'Montserrat',
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.orange[300],
  ),
  buttonTheme: ButtonThemeData(
    highlightColor: Colors.orange[300],
    buttonColor: Colors.orange[300],
    textTheme: ButtonTextTheme.normal,
  ),
);
