import 'package:flutter/material.dart';

class AppColors {
  //For Light Theme
  static Color lightPrimary = const Color.fromRGBO(66, 106, 143, 1);
  static Color lightSecondary = const Color.fromRGBO(116, 146, 183, 1);
  static Color lightTertiary = const Color.fromARGB(255, 234, 240, 235);
  static Color light4 = const Color.fromRGBO(39, 69, 100, 1);
  static Color lightBgColor = const Color.fromRGBO(255, 255, 255, 1);

  //For Dark Theme
  static Color darkPrimary = const Color.fromRGBO(20, 109, 169, 1);
  static Color darkSecondary = const Color.fromRGBO(127, 148, 179, 1);
  static Color darkTertiary = const Color.fromRGBO(26, 41, 54, 1);
  static Color dark4 = const Color.fromRGBO(154, 168, 182, 1);
  static Color darkBgColor = const Color.fromRGBO(12, 19, 24, 1);

  //Universal Colors
  static Color transparent = const Color.fromRGBO(0, 0, 0, 0);
  static Color lightTransparent = const Color.fromRGBO(116, 116, 116, 0.09);
  static Color white = const Color.fromRGBO(255, 255, 255, 1);
  static Color black = const Color.fromRGBO(0, 0, 0, 1);
  static Color grey = const Color.fromRGBO(184, 184, 184, 1);
  static Color lightGrey = const Color.fromRGBO(231, 231, 231, 1);
  static Color darkGrey = const Color.fromRGBO(123, 123, 123, 1);
  static Color red = const Color.fromRGBO(158, 21, 21, 1);
  static Color green = const Color.fromRGBO(19, 150, 38, 1);
  static Color blue = const Color.fromRGBO(16, 105, 164, 1);

  //Gradient colors for chart bars
  List<Color> gradientColors = [Colors.blue, Colors.blue];
}

OutlineInputBorder border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(10),
  borderSide: BorderSide.none,
);
// Light Theme
final ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: AppColors.lightPrimary,
  scaffoldBackgroundColor: AppColors.lightBgColor,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.lightBgColor,
    foregroundColor: AppColors.black,
    centerTitle: true,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.lightBgColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.lightTertiary,
    filled: true,
    hintStyle: TextStyle(color: AppColors.light4),
    border: border,
    enabledBorder: border,
    focusedBorder: border,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: AppColors.lightPrimary,
    refreshBackgroundColor: AppColors.lightPrimary,
    linearTrackColor: AppColors.lightTertiary,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.lightBgColor,
    selectedItemColor: AppColors.lightPrimary,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.lightPrimary,
    splashColor: AppColors.transparent,
  ),
  listTileTheme: ListTileThemeData(iconColor: AppColors.lightPrimary),
  splashColor: AppColors.transparent,

  ///
  ///
  ///
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(AppColors.lightPrimary),
    ),
  ),
  switchTheme: SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith<Color>(
      (states) =>
          states.contains(WidgetState.selected)
              ? AppColors.lightPrimary
              : AppColors.lightTertiary,
    ),
    thumbColor: WidgetStateProperty.resolveWith<Color>(
      (states) =>
          states.contains(WidgetState.selected)
              ? AppColors.lightTertiary
              : Colors.white,
    ),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
);

//Dark Theme
final ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: AppColors.darkPrimary,
  scaffoldBackgroundColor: AppColors.darkBgColor,
  appBarTheme: AppBarTheme(
    backgroundColor: AppColors.darkBgColor,
    foregroundColor: AppColors.white,
    centerTitle: true,
  ),
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: AppColors.darkBgColor,
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.darkTertiary,
    filled: true,
    hintStyle: TextStyle(color: AppColors.dark4),
    border: border,
    enabledBorder: border,
    focusedBorder: border,
  ),
  progressIndicatorTheme: ProgressIndicatorThemeData(
    color: AppColors.darkPrimary,
    refreshBackgroundColor: AppColors.darkPrimary,
    linearTrackColor: AppColors.darkTertiary,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.darkBgColor,
    selectedItemColor: AppColors.darkPrimary,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: AppColors.darkPrimary,
    splashColor: AppColors.transparent,
  ),
  listTileTheme: ListTileThemeData(iconColor: AppColors.darkPrimary),
  splashColor: AppColors.transparent,

  ////
  ///
  ///
  ///
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStatePropertyAll(AppColors.darkPrimary),
    ),
  ),
  switchTheme: SwitchThemeData(
    trackColor: WidgetStateProperty.resolveWith<Color>(
      (states) =>
          states.contains(WidgetState.selected)
              ? AppColors.darkPrimary
              : AppColors.darkTertiary,
    ),
    thumbColor: WidgetStateProperty.resolveWith<Color>(
      (states) =>
          states.contains(WidgetState.selected)
              ? AppColors.darkTertiary
              : Colors.white,
    ),
    trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
  ),
);
