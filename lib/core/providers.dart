import 'package:expen/provider/amount_provider.dart';
import 'package:expen/provider/currency_provider.dart';
import 'package:expen/provider/theme_provider.dart';
import 'package:expen/provider/version_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Widget appProvider(Widget child) {
  return MultiProvider(
    providers: [
      //For Amount
      ChangeNotifierProvider(create: (context) => AmountProvider()),

      //For Theme
      ChangeNotifierProvider(create: (context) => ThemeProvider()),

      //For Version
      ChangeNotifierProvider(
        create: (context) => VersionProvider()..loadVersion(),
      ),

      //For Currency Symbols
      ChangeNotifierProvider(create: (context) => CurrencyProvider()),
    ],
    child: child,
  );
}
