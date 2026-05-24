import 'package:flutter/material.dart';
import 'package:expen/pages/home.dart';
import 'package:expen/pages/chart.dart';
import 'package:expen/pages/transactions_page.dart';
import 'package:expen/pages/budgets_goals_page.dart';
import 'package:expen/pages/recurring_page.dart';
import 'package:expen/core/theme.dart';

// Global key to allow external tab switching (e.g. "View All" from Home)
final GlobalKey<NavLayoutState> navLayoutKey = GlobalKey<NavLayoutState>();

class NavLayout extends StatefulWidget {
  const NavLayout({super.key});

  @override
  State<NavLayout> createState() => NavLayoutState();
}

// Public state class so navLayoutKey can call switchToTab from other files
class NavLayoutState extends State<NavLayout> {
  int _currentIndex = 0;

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  final List<Widget> _pages = const [
    Home(),
    TransactionsPage(),
    Chart(),
    BudgetsGoalsPage(),
    RecurringPage(),
  ];

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark : AppColors.borderLight,
              width: 0.5,
            ),
          ),
        ),
        // Wrap with Theme to completely kill splash/highlight on nav items
        child: Theme(
          data: Theme.of(context).copyWith(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
          ),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            enableFeedback: false,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            selectedFontSize: 11,
            unselectedFontSize: 11,
            iconSize: 22,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: "Dashboard",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.receipt_long_outlined),
                activeIcon: Icon(Icons.receipt_long),
                label: "History",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.bar_chart_outlined),
                activeIcon: Icon(Icons.bar_chart),
                label: "Reports",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.track_changes),
                activeIcon: Icon(Icons.track_changes_rounded),
                label: "Budgets & Goals",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.autorenew_outlined),
                activeIcon: Icon(Icons.autorenew),
                label: "Recurring",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
