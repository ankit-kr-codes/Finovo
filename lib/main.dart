import 'dart:ui';

import 'package:expen/core/providers.dart';
import 'package:expen/core/router.dart';
import 'package:expen/core/theme.dart';
import 'package:expen/hive/backup_and_reset.dart';
import 'package:expen/hive/hive_database.dart';
import 'package:expen/provider/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

//Entry point of app
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  Hive.registerAdapter(AmountAdapter());

  try {
    await Hive.openBox<Amount>("expenses");
  } catch (e) {
    await backupAndResetHive();
  }

  PlatformDispatcher.instance.onPlatformConfigurationChanged = () {};
  runApp(appProvider(const MyApp()));

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(systemNavigationBarColor: AppColors.transparent),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Get theme mode from provider
    var themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior(),
      title: "Expen",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: router,
    );
  }
}
