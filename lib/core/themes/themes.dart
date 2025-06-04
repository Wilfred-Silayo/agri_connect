import 'package:agri_connect/core/constants/pallete.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static _border(Color color) => OutlineInputBorder(
    borderSide: BorderSide(color: color, width: 3),
    borderRadius: BorderRadius.circular(10),
  );

  static final ThemeData agriThemeLight = ThemeData.light(
    useMaterial3: true,
  ).copyWith(
    primaryColor: AppPalette.primaryGreen,

    scaffoldBackgroundColor: AppPalette.neutralLight,
    appBarTheme: AppBarTheme(
      backgroundColor: AppPalette.primaryGreen,
      foregroundColor: Colors.black,
    ),

    inputDecorationTheme: InputDecorationTheme(
      contentPadding: EdgeInsets.all(27),
      labelStyle: TextStyle(color: AppPalette.neutralDark),
      hintStyle: TextStyle(color: AppPalette.neutralDark),
      enabledBorder: _border(AppPalette.primaryGreen),
      focusedBorder: _border(AppPalette.deepForest),
    ),
  );
}
