import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// The portfolio's visual identity: two independently-specified color
/// schemes (dark is the primary identity, light is a deliberately
/// restrained/neutral secondary), a Space Grotesk/Inter/JetBrains Mono
/// typography system, and a shared rounded shape language.
///
/// See docs/superpowers/specs/2026-08-28-portfolio-visual-identity-design.md
class AppTheme {
  AppTheme._();

  // Dark theme colors — the primary identity (GitHub/VS Code dark inspired).
  static const Color _darkBackground = Color(0xFF0D1117);
  static const Color _darkSurface = Color(0xFF161B22);
  static const Color _darkOutline = Color(0xFF30363D);
  static const Color _darkTextPrimary = Color(0xFFE6EDF3);
  static const Color _darkTextSecondary = Color(0xFF8B949E);
  static const Color _darkAccent = Color(0xFF4D8DFF);
  static const Color _darkOnAccent = Color(0xFF0D1117);
  static const Color _darkError = Color(0xFFF85149);

  // Light theme colors — neutral/grayscale chrome; the accent is reserved
  // for interactive elements only (links, primary buttons, active/hover
  // states), not general decoration.
  static const Color _lightBackground = Color(0xFFFFFFFF);
  static const Color _lightSurface = Color(0xFFFAFAFA);
  static const Color _lightOutline = Color(0xFFE5E5E5);
  static const Color _lightTextPrimary = Color(0xFF2B2B2B);
  static const Color _lightTextSecondary = Color(0xFF6B6B6B);
  static const Color _lightAccent = Color(0xFF0969DA);
  static const Color _lightOnAccent = Color(0xFFFFFFFF);
  static const Color _lightError = Color(0xFFCF222E);

  // Standard corner radius for buttons/cards/inputs. Chip/tag-style widgets
  // introduced in a later phase (skill tags, etc.) should use a full-pill
  // radius (StadiumBorder) instead, per the Fase 4 design spec — there's no
  // chip UI in the codebase yet, so nothing to apply that to here.
  static const double _cornerRadius = 8;

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: _darkAccent,
      onPrimary: _darkOnAccent,
      secondary: _darkAccent,
      onSecondary: _darkOnAccent,
      surface: _darkSurface,
      onSurface: _darkTextPrimary,
      outline: _darkOutline,
      error: _darkError,
      onError: _darkOnAccent,
    );
    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: _darkBackground,
      textPrimary: _darkTextPrimary,
      textSecondary: _darkTextSecondary,
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: _lightAccent,
      onPrimary: _lightOnAccent,
      secondary: _lightAccent,
      onSecondary: _lightOnAccent,
      surface: _lightSurface,
      onSurface: _lightTextPrimary,
      outline: _lightOutline,
      error: _lightError,
      onError: _lightOnAccent,
    );
    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackground: _lightBackground,
      textPrimary: _lightTextPrimary,
      textSecondary: _lightTextSecondary,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackground,
    required Color textPrimary,
    required Color textSecondary,
  }) {
    final headlineStyle = GoogleFonts.spaceGrotesk(color: textPrimary);
    final bodyStyle = GoogleFonts.inter(color: textPrimary);
    final labelStyle = GoogleFonts.inter(color: textSecondary);

    final textTheme = TextTheme(
      headlineLarge: headlineStyle,
      headlineMedium: headlineStyle,
      headlineSmall: headlineStyle,
      titleLarge: headlineStyle,
      bodyLarge: bodyStyle,
      bodyMedium: bodyStyle,
      bodySmall: bodyStyle,
      labelLarge: labelStyle,
      labelMedium: labelStyle,
      labelSmall: labelStyle,
    );

    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(_cornerRadius),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBackground,
      textTheme: textTheme,
      cardTheme: CardTheme(color: colorScheme.surface, shape: shape),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(shape: shape),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(shape: shape),
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(_cornerRadius),
        ),
      ),
    );
  }

  /// Monospace text style for technical/code-like UI elements (e.g. skill
  /// tags in a later phase). Not part of [TextTheme] — call sites opt in
  /// explicitly via `Theme.of(context)` is not applicable here; use
  /// `AppTheme.monoTextStyle` directly.
  static TextStyle get monoTextStyle => GoogleFonts.jetBrainsMono();
}
