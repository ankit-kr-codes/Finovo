import 'package:go_router/go_router.dart';
import 'package:expen/pages/nav_layout.dart';
import 'package:expen/pages/add_expense.dart';
import 'package:expen/pages/settings.dart';
import 'package:expen/pages/about.dart';
import 'package:expen/pages/sms_review_page.dart';
import 'package:expen/pages/terms_of_service.dart';
import 'package:expen/pages/privacy_policy.dart';

//Go router
final GoRouter router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      // Main Navigation Layout (Dashboard, History, Analytics, Budgets/Goals, Recurring)
      path: '/',
      builder: (context, state) => NavLayout(key: navLayoutKey),
    ),
    GoRoute(
      // For Adding Transaction Screen
      path: '/addexpense',
      builder: (context, state) {
        var isIncome = state.uri.queryParameters['income'] == 'true';
        return AddExpense(isIncome: isIncome);
      },
    ),
    GoRoute(
      // For Settings Screen
      path: '/settings',
      builder: (context, state) => const Settings(),
    ),
    GoRoute(
      // For About Screen
      path: '/about',
      builder: (context, state) => const About(),
    ),
    GoRoute(
      // SMS transaction review screen
      path: '/sms-review',
      builder: (context, state) => const SmsReviewPage(),
    ),
    GoRoute(
      // Terms of Service
      path: '/terms',
      builder: (context, state) => const TermsOfService(),
    ),
    GoRoute(
      // Privacy Policy
      path: '/privacy',
      builder: (context, state) => const PrivacyPolicy(),
    ),
  ],
);

