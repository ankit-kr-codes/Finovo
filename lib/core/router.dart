import 'package:go_router/go_router.dart';
import 'package:expen/pages/home.dart';
import 'package:expen/pages/chart.dart';
import 'package:expen/pages/add_expense.dart';
import 'package:expen/pages/settings.dart';
import 'package:expen/pages/about.dart';

//Go router
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      //For Home Screen
      path: '/',
      builder: (context, state) => const Home(),
    ),
    GoRoute(
      //For Chart Screen
      path: '/chart',
      builder: (context, state) => const Chart(),
    ),
    GoRoute(
      //For Adding Expense Screen
      path: '/addexpense',
      builder: (context, state) => const AddExpense(),
    ),
    GoRoute(
      //For Settings Screen
      path: '/settings',
      builder: (context, state) => const Settings(),
    ),
    GoRoute(
      //For About Screen
      path: '/about',
      builder: (context, state) => const About(),
    ),
  ],
);
