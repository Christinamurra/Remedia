import 'package:flutter/material.dart';

class RemediaColors {
  // Light theme backgrounds
  static const Color creamBackground = Color(0xFFF5F0E8);
  static const Color warmBeige = Color(0xFFE8E0D4);
  static const Color cardSand = Color(0xFFEDE6DB);

  // Glossy light green card colors
  static const Color cardLightGreen = Color(0xFFD4E6D4);
  static const Color cardGlossyGreen = Color(0xFFE0F0E0);
  static const Color cardGlossyHighlight = Color(0xFFF0FAF0);

  // Accent colors
  static const Color mutedGreen = Color(0xFF7A9E7A);
  static const Color sageGreen = Color(0xFF8BA888);
  static const Color terraCotta = Color(0xFFBF8B67);
  static const Color warmRust = Color(0xFFC4956A);

  // Text colors
  static const Color textDark = Color(0xFF3D3D3D);
  static const Color textMuted = Color(0xFF8A8A7A);
  static const Color textLight = Color(0xFFA0998C);

  // Progress colors
  static const Color waterBlue = Color(0xFF7EB8C9);
  static const Color sleepBrown = Color(0xFFC9A87C);
  static const Color successGreen = Color(0xFF7A9E7A);

  // Nav bar
  static const Color navBackground = Color(0xFFE5DED2);
  static const Color navIconActive = Color(0xFF5A7A5A);
  static const Color navIconInactive = Color(0xFF9A9A8A);
}

class RemediaTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: RemediaColors.creamBackground,

      // Color scheme
      colorScheme: const ColorScheme.light(
        primary: RemediaColors.mutedGreen,
        secondary: RemediaColors.terraCotta,
        surface: RemediaColors.cardSand,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: RemediaColors.textDark,
      ),

      // App bar theme
      appBarTheme: const AppBarTheme(
        backgroundColor: RemediaColors.creamBackground,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: RemediaColors.textDark,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        iconTheme: IconThemeData(color: RemediaColors.textDark),
      ),

      // Bottom nav theme
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: RemediaColors.navBackground,
        selectedItemColor: RemediaColors.navIconActive,
        unselectedItemColor: RemediaColors.navIconInactive,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w400,
        ),
      ),

      // Card theme
      cardTheme: CardThemeData(
        color: RemediaColors.cardSand,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),

      // Elevated button theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: RemediaColors.mutedGreen,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // Text theme
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          color: RemediaColors.textDark,
          fontSize: 26,
          fontWeight: FontWeight.w700,
        ),
        headlineMedium: TextStyle(
          color: RemediaColors.textDark,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        headlineSmall: TextStyle(
          color: RemediaColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: RemediaColors.textDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: TextStyle(
          color: RemediaColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        bodyLarge: TextStyle(
          color: RemediaColors.textDark,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          color: RemediaColors.textMuted,
          fontSize: 14,
          fontWeight: FontWeight.w400,
          height: 1.4,
        ),
        labelLarge: TextStyle(
          color: RemediaColors.mutedGreen,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: RemediaColors.warmBeige,
        hintStyle: const TextStyle(color: RemediaColors.textLight),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: RemediaColors.mutedGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      ),

      // Floating action button theme
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: RemediaColors.mutedGreen,
        foregroundColor: Colors.white,
        elevation: 2,
        shape: CircleBorder(),
      ),

      // Chip theme
      chipTheme: ChipThemeData(
        backgroundColor: RemediaColors.warmBeige,
        selectedColor: RemediaColors.mutedGreen,
        labelStyle: const TextStyle(
          color: RemediaColors.textDark,
          fontSize: 13,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
    );
  }
}
