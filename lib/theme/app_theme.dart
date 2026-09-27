import 'package:flutter/material.dart';

/// Côte d'Ivoire palette: the flag's green and orange, on warm ivory.
/// Shades are deepened where white text sits on them (WCAG AA contrast).
class AppColors {
  static const Color ivoryGreen = Color(0xFF00794A); // flag green #009E60, deepened
  static const Color flagGreen = Color(0xFF009E60);
  static const Color ivoryOrange = Color(0xFFC75C00); // flag orange #F77F00, deepened
  static const Color flagOrange = Color(0xFFF77F00);
  static const Color lagoon = Color(0xFF0F766E);
  static const Color ivory = Color(0xFFFBF7EF);
  static const Color ink = Color(0xFF1C2421);
  static const Color slate = Color(0xFF5E6B66);
}

class AppTheme {
  static LinearGradient heroGradient(Brightness brightness) {
    if (brightness == Brightness.dark) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFF06291C), Color(0xFF0B4A33), Color(0xFF5A2E06)],
      );
    }
    return const LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [AppColors.ivoryGreen, Color(0xFF00603B), AppColors.ivoryOrange],
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.ivoryGreen,
      brightness: Brightness.light,
    ).copyWith(
      primary: AppColors.ivoryGreen,
      onPrimary: Colors.white,
      secondary: AppColors.ivoryOrange,
      onSecondary: Colors.white,
      tertiary: AppColors.lagoon,
      surface: Colors.white,
      surfaceContainerHighest: const Color(0xFFEFEAE0),
      onSurface: AppColors.ink,
      outline: const Color(0xFFD9D2C3),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.ivoryGreen,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF4FD19A),
      onPrimary: const Color(0xFF00301C),
      secondary: const Color(0xFFFFA24A),
      onSecondary: const Color(0xFF3A1D00),
      tertiary: const Color(0xFF5ECFC4),
      surface: const Color(0xFF141A17),
      onSurface: const Color(0xFFE9EEEA),
      outline: const Color(0xFF34423C),
    );

    return _buildTheme(colorScheme);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme) {
    final isDark = colorScheme.brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor:
          isDark ? const Color(0xFF0E1311) : AppColors.ivory,
      textTheme: ThemeData(
        brightness: colorScheme.brightness,
      ).textTheme.apply(
            bodyColor: colorScheme.onSurface,
            displayColor: colorScheme.onSurface,
          ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        color: colorScheme.surface,
        shadowColor: colorScheme.primary.withOpacity(0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: colorScheme.outline),
          foregroundColor: colorScheme.onSurface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? const Color(0xFF1A221E) : Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: colorScheme.surfaceContainerHighest.withOpacity(0.6),
        selectedColor: colorScheme.primary.withOpacity(0.16),
        labelStyle: TextStyle(color: colorScheme.onSurface),
        side: BorderSide(color: colorScheme.outline.withOpacity(0.4)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withOpacity(0.14),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontSize: 12,
            fontWeight:
                states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: colorScheme.surface,
        indicatorColor: colorScheme.primary.withOpacity(0.14),
        selectedIconTheme: IconThemeData(color: colorScheme.primary),
        selectedLabelTextStyle:
            TextStyle(color: colorScheme.primary, fontWeight: FontWeight.w700),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? const Color(0xFF22302A) : AppColors.ink,
        contentTextStyle: const TextStyle(color: Colors.white),
      ),
    );
  }
}