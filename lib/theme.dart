import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF00C8FF);
  static const Color secondary = Color(0xFFFF6B35);
  static const Color background = Color(0xFF0A0E1A);
  static const Color surface = Color(0xFF141828);
  static const Color card = Color(0xFF1C2440);
  static const Color cardLight = Color(0xFF232B4A);
  static const Color border = Color(0xFF2A3356);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF8B95B0);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFD600);
  static const Color danger = Color(0xFFFF1744);
  static const Color orange = Color(0xFFFF6B00);

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: background,
        colorScheme: ColorScheme.dark(
          primary: primary,
          secondary: secondary,
          surface: surface,
          onPrimary: Colors.black,
          onSecondary: Colors.white,
          onSurface: textPrimary,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: background,
          foregroundColor: textPrimary,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        cardTheme: CardTheme(
          color: card,
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: border),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: surface,
          selectedItemColor: primary,
          unselectedItemColor: textSecondary,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedLabelStyle:
              TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          unselectedLabelStyle: TextStyle(fontSize: 11),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primary,
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle: const TextStyle(
                fontSize: 15, fontWeight: FontWeight.w700),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: primary,
            side: const BorderSide(color: border),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: card,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: danger),
          ),
          labelStyle: const TextStyle(color: textSecondary),
          hintStyle: const TextStyle(color: textSecondary),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: primary,
          foregroundColor: Colors.black,
          shape: CircleBorder(),
        ),
        dividerTheme:
            const DividerThemeData(color: border, thickness: 1),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: cardLight,
          contentTextStyle:
              const TextStyle(color: textPrimary, fontSize: 14),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        switchTheme: SwitchThemeData(
          thumbColor:
              WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primary : textSecondary),
          trackColor:
              WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? primary.withValues(alpha: 0.3) : border),
        ),
        sliderTheme: const SliderThemeData(
          activeTrackColor: primary,
          thumbColor: primary,
          inactiveTrackColor: border,
          overlayColor: Color(0x2900C8FF),
        ),
        chipTheme: ChipThemeData(
          backgroundColor: card,
          selectedColor: primary.withValues(alpha: 0.2),
          labelStyle: const TextStyle(color: textPrimary, fontSize: 13),
          side: const BorderSide(color: border),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
              color: textPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(
              color: textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(
              color: textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: textPrimary, fontSize: 16),
          bodyMedium: TextStyle(color: textSecondary, fontSize: 14),
          labelLarge: TextStyle(
              color: textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500),
        ),
      );
}
