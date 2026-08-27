import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Placeholder seed color — the real palette is decided in Phase 4 (Design).
  static const Color _seedColor = Color(0xFF2563EB);

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.light,
        ),
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
      );
}
