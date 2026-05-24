import 'dart:ui';

import 'package:expen/core/providers.dart';
import 'package:expen/core/router.dart';
import 'package:expen/core/theme.dart';
import 'package:expen/hive/backup_and_reset.dart';
import 'package:expen/hive/hive_database.dart';
import 'package:expen/provider/theme_provider.dart';
import 'package:expen/services/sms_service.dart';
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
  Hive.registerAdapter(BudgetLimitAdapter());
  Hive.registerAdapter(SavingsGoalAdapter());
  Hive.registerAdapter(RecurringExpenseAdapter());
  Hive.registerAdapter(CustomCategoryAdapter());
  Hive.registerAdapter(PendingTransactionAdapter()); // SMS pending transactions

  try {
    await Hive.openBox<Amount>("expenses");
    await Hive.openBox<BudgetLimit>("budgets");
    await Hive.openBox<SavingsGoal>("goals");
    await Hive.openBox<RecurringExpense>("recurring");
    await Hive.openBox<CustomCategory>("categories");
  } catch (e) {
    await backupAndResetHive();
  }

  // Initialize SMS service (opens sms_pending Hive box + notification plugin)
  await SmsService().init();

  PlatformDispatcher.instance.onPlatformConfigurationChanged = () {};
  runApp(appProvider(const MyApp()));

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(systemNavigationBarColor: AppColors.transparent),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      scrollBehavior: const MaterialScrollBehavior(),
      title: "Finovo",
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: themeProvider.themeMode,
      routerConfig: router,
    );
  }
}
