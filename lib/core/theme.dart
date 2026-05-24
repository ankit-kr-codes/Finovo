import 'package:flutter/material.dart';

class AppColors {
  // Theme Backgrounds
  static const Color lightBg = Color(0xFFF7F5F2); // Warm Off-White
  static const Color darkBg = Color(0xFF0D1117); // Deep dark background

  // Cards & Elevated Elements
  static const Color lightCard = Colors.white;
  static const Color darkCard = Color(0xFF161B22); // Dark mode card
  static const Color darkCardSurface = Color(0xFF1F2937); // Slightly elevated

  // Brand Accents
  static const Color primary = Color(0xFF264E46); // Deep Forest Green (light mode)
  static const Color primaryDark = Color(0xFF2DD4BF); // Vivid Teal (dark mode accent)
  static const Color secondary = Color(0xFFA8B6A1); // Soft Sage Green
  static const List<Color> cardGradient = [
    primary,
    secondary,
  ]; // Gradient for glassmorphic cards
  static const Color accent = Color(0xFF8B5CF6); // Violet

  // Financial Semantics
  static const Color income = Color(0xFF10B981); // Emerald Green
  static const Color expense = Color(0xFFEF4444); // Rose Red
  static const Color warning = Color(0xFFF59E0B); // Amber Warning

  // Spending health colors
  static const Color healthGood = Color(0xFF10B981);    // Under 60%
  static const Color healthFair = Color(0xFFF59E0B);    // 60–85%
  static const Color healthBad  = Color(0xFFEF4444);    // Over 85%

  // Neutrals
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color textDark = Color(0xFF1F2933);
  static const Color textLight = Color(0xFFF0F6FC);
  static const Color textMutedDark = Color(0xFF6B7280);
  static const Color textMutedLight = Color(0xFF8B949E);
  static const Color borderLight = Color(0xFFE2E8F0);
  static const Color borderDark = Color(0xFF30363D);

  // Backward Compatible Colors
  static const Color blue = Color(0xFF6366F1);
  static const Color red = Color(0xFFEF4444);
  static const Color green = Color(0xFF10B981);
  static const Color grey = Color(0xFF94A3B8);
  static const Color lightGrey = Color(0xFFE2E8F0);
  static const Color darkGrey = Color(0xFF64748B);
  static const Color lightTransparent = Color(0x0C64748B);

  // Gradient Colors
  static const List<Color> balanceGradient = [
    Color(0xFF1E40AF),
    Color(0xFF3B82F6),
  ];
  static const List<Color> incomeGradient = [
    Color(0xFF10B981),
    Color(0xFF059669),
  ];
  static const List<Color> expenseGradient = [
    Color(0xFFEF4444),
    Color(0xFFDC2626),
  ];
  static const List<Color> accentGradient = [
    Color(0xFF8B5CF6),
    Color(0xFF6366F1),
  ];
  // Dark mode balance gradient — deeper, visible on dark bg
  static const List<Color> balanceGradientDark = [
    Color(0xFF0F4C81),
    Color(0xFF1E6FBF),
  ];

  List<Color> get gradientColors => [primary, secondary];
}

// Global Card Decoration Helpers
BoxDecoration premiumCardDeco({required bool isDark}) {
  return BoxDecoration(
    color: isDark ? AppColors.darkCard : AppColors.lightCard,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(
      color: isDark ? AppColors.borderDark : AppColors.borderLight,
    ),
    boxShadow: [
      BoxShadow(
        color:
            isDark
                ? Colors.black.withValues(alpha: 0.15)
                : Colors.grey.withValues(alpha: 0.08),
        offset: const Offset(0, 4),
        blurRadius: 12,
      ),
    ],
  );
}

BoxDecoration glassmorphicDeco({
  required bool isDark,
  required List<Color> gradient,
}) {
  return BoxDecoration(
    gradient: LinearGradient(
      colors: gradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(24),
    boxShadow: [
      BoxShadow(
        color: gradient.first.withValues(alpha: 0.3),
        offset: const Offset(0, 8),
        blurRadius: 20,
      ),
    ],
  );
}

// Base Borders
final OutlineInputBorder border = OutlineInputBorder(
  borderRadius: BorderRadius.circular(16),
  borderSide: BorderSide.none,
);

// Light Theme
final ThemeData lightTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.lightBg,
  colorScheme: const ColorScheme.light(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    error: AppColors.expense,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.lightBg,
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textDark,
    ),
    iconTheme: IconThemeData(color: AppColors.textDark),
  ),
  cardTheme: CardThemeData(
    color: AppColors.lightCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: const BorderSide(color: AppColors.borderLight),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: Colors.white,
    filled: true,
    hintStyle: const TextStyle(color: AppColors.textMutedDark, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borderLight),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: Colors.white,
    selectedItemColor: AppColors.primary,
    unselectedItemColor: AppColors.textMutedDark,
    type: BottomNavigationBarType.fixed,
    enableFeedback: false,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primary,
    foregroundColor: Colors.white,
    elevation: 4,
    shape: CircleBorder(),
  ),
);

// Dark Theme
final ThemeData darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  primaryColor: AppColors.primary,
  scaffoldBackgroundColor: AppColors.darkBg,
  colorScheme: const ColorScheme.dark(
    primary: AppColors.primary,
    secondary: AppColors.secondary,
    surface: AppColors.darkCard,
    error: AppColors.expense,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.darkBg,
    elevation: 0,
    centerTitle: true,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textLight,
    ),
    iconTheme: IconThemeData(color: AppColors.textLight),
  ),
  cardTheme: CardThemeData(
    color: AppColors.darkCard,
    elevation: 0,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(24),
      side: const BorderSide(color: AppColors.borderDark),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    fillColor: AppColors.darkCardSurface,
    filled: true,
    hintStyle: const TextStyle(color: AppColors.textMutedLight, fontSize: 14),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borderDark),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.borderDark),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: AppColors.primaryDark, width: 1.5),
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    backgroundColor: AppColors.darkCard,
    selectedItemColor: AppColors.primaryDark,
    unselectedItemColor: AppColors.textMutedLight,
    type: BottomNavigationBarType.fixed,
    enableFeedback: false,
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: AppColors.primaryDark,
    foregroundColor: Colors.black,
    elevation: 4,
    shape: CircleBorder(),
  ),
);

class CategoryStyle {
  static IconData getIcon(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return Icons.restaurant_rounded;
      case 'hostel':
        return Icons.hotel_rounded;
      case 'transport':
        return Icons.directions_bus_rounded;
      case 'shopping':
        return Icons.shopping_bag_rounded;
      case 'recharge':
        return Icons.phone_android_rounded;
      case 'entertainment':
        return Icons.movie_rounded;
      case 'health':
        return Icons.medical_services_rounded;
      case 'savings goal':
        return Icons.savings_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  static Color getColor(String category) {
    switch (category.toLowerCase()) {
      case 'food':
        return const Color(0xFFFF7A59); // Warm Coral
      case 'hostel':
        return const Color(0xFF2DD4BF); // Mint Teal
      case 'transport':
        return const Color(0xFF38BDF8); // Sky Blue
      case 'shopping':
        return const Color(0xFFF43F5E); // Soft Rose
      case 'recharge':
        return const Color(0xFFC084FC); // Soft Purple
      case 'entertainment':
        return const Color(0xFFFB7185); // Crimson
      case 'health':
        return const Color(0xFF34D399); // Light Green
      case 'savings goal':
        return const Color(0xFF818CF8); // Soft Indigo
      default:
        return const Color(0xFF94A3B8); // Slate Grey
    }
  }
}
