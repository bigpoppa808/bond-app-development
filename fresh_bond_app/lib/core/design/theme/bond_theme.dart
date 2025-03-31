import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';

/// Bond app theme
class BondTheme {
  /// Light theme
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.light(
      primary: BondColors.primary,
      onPrimary: Colors.white,
      secondary: BondColors.secondary,
      onSecondary: Colors.black,
      error: BondColors.error,
      onError: Colors.white,
      background: BondColors.background,
      onBackground: BondColors.text,
      surface: BondColors.backgroundSecondary,
      onSurface: BondColors.text,
    ),
    scaffoldBackgroundColor: BondColors.background,
    appBarTheme: AppBarTheme(
      backgroundColor: BondColors.backgroundSecondary,
      foregroundColor: BondColors.text,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: BondColors.backgroundSecondary,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BondColors.backgroundSecondary,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BondColors.divider),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BondColors.divider),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BondColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BondColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BondColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BondColors.primary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BondColors.primary,
        side: BorderSide(color: BondColors.primary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: BondColors.backgroundSecondary,
      selectedItemColor: BondColors.primary,
      unselectedItemColor: BondColors.textSecondary,
      type: BottomNavigationBarType.fixed,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: BondColors.backgroundSecondary,
      indicatorColor: BondColors.primary.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: BondColors.text,
        ),
      ),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: BondColors.primary);
        }
        return IconThemeData(color: BondColors.textSecondary);
      }),
    ),
    fontFamily: 'Poppins',
  );

  /// Dark theme
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.dark(
      primary: BondColors.primaryDark,
      onPrimary: Colors.black,
      secondary: BondColors.secondaryDark,
      onSecondary: Colors.black,
      error: BondColors.error,
      onError: Colors.white,
      background: BondColors.backgroundDark,
      onBackground: BondColors.textDark,
      surface: BondColors.backgroundSecondaryDark,
      onSurface: BondColors.textDark,
    ),
    scaffoldBackgroundColor: BondColors.backgroundDark,
    appBarTheme: AppBarTheme(
      backgroundColor: BondColors.backgroundSecondaryDark,
      foregroundColor: BondColors.textDark,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: BondColors.backgroundSecondaryDark,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BondColors.backgroundSecondaryDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BondColors.slate),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BondColors.slate),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BondColors.primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: BondColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: BondColors.primaryDark,
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: BondColors.primaryDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: BondColors.primaryDark,
        side: BorderSide(color: BondColors.primaryDark),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: BondColors.backgroundSecondaryDark,
      selectedItemColor: BondColors.primaryDark,
      unselectedItemColor: BondColors.textSecondaryDark,
      type: BottomNavigationBarType.fixed,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: BondColors.backgroundSecondaryDark,
      indicatorColor: BondColors.primaryDark.withOpacity(0.2),
      labelTextStyle: MaterialStateProperty.all(
        TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: BondColors.textDark,
        ),
      ),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: BondColors.primaryDark);
        }
        return IconThemeData(color: BondColors.textSecondaryDark);
      }),
    ),
    fontFamily: 'Poppins',
  );
}
