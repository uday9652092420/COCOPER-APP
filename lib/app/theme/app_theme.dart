import 'package:flutter/material.dart';

abstract final class CocoperColors {
  static const teal = Color(0xFF083F3A);
  static const tealSoft = Color(0xFF0C5B52);
  static const lime = Color(0xFFA6D86E);
  static const coral = Color(0xFFF08A55);
  static const ink = Color(0xFF17322E);
  static const muted = Color(0xFF71807B);
  static const paper = Color(0xFFFBFCF8);
  static const line = Color(0xFFDFE8E1);
  static const mint = Color(0xFFDFF2E7);
  static const sand = Color(0xFFF8EAD2);
  static const rose = Color(0xFFF6E2E6);
  static const violet = Color(0xFFEDE6F7);
}

abstract final class AppTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: CocoperColors.teal,
      brightness: Brightness.light,
      primary: CocoperColors.teal,
      secondary: CocoperColors.coral,
      surface: CocoperColors.paper,
      outline: CocoperColors.line,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: CocoperColors.paper,
      fontFamily: 'sans-serif',
      visualDensity: VisualDensity.standard,
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          color: CocoperColors.ink,
          fontSize: 34,
          fontWeight: FontWeight.w800,
          letterSpacing: -1.4,
          height: 1.08,
        ),
        headlineMedium: TextStyle(
          color: CocoperColors.ink,
          fontSize: 25,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.8,
          height: 1.12,
        ),
        titleLarge: TextStyle(
          color: CocoperColors.ink,
          fontSize: 20,
          fontWeight: FontWeight.w800,
        ),
        titleMedium: TextStyle(
          color: CocoperColors.ink,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(
          color: CocoperColors.ink,
          fontSize: 14,
          height: 1.45,
        ),
        bodySmall: TextStyle(
          color: CocoperColors.muted,
          fontSize: 12,
          height: 1.4,
        ),
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
      ),
      cardTheme: const CardThemeData(
        elevation: 0,
        color: Colors.white,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
          side: BorderSide(color: CocoperColors.line),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: CocoperColors.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: CocoperColors.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
          borderSide: BorderSide(color: CocoperColors.tealSoft, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 17),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(48, 54),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          side: const BorderSide(color: CocoperColors.line),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        height: 72,
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFEDF6E8),
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
        ),
      ),
      navigationRailTheme: const NavigationRailThemeData(
        backgroundColor: Colors.white,
        indicatorColor: Color(0xFFEDF6E8),
        useIndicator: true,
        minWidth: 84,
        minExtendedWidth: 210,
      ),
      dividerColor: CocoperColors.line,
    );
  }
}
