import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'bond_colors.dart';

/// Bond Design System - Theme
/// 
/// A comprehensive theme implementation that applies the Bond Design System
/// colors, typography, and component styles to the entire application.
/// Supports both light and dark modes according to the design specifications.
class BondTheme {
  BondTheme._(); // Private constructor to prevent instantiation

  /// Applies the Bond light theme to ThemeData
  static ThemeData get lightTheme {
    return _createTheme(
      brightness: Brightness.light, 
      primaryColor: BondColors.bondTeal,
      secondaryColor: BondColors.connectionPurple,
      backgroundColor: BondColors.snow,
      scaffoldBackgroundColor: BondColors.snow,
      cardColor: Colors.white,
      textPrimaryColor: BondColors.night,
      textSecondaryColor: BondColors.slate,
      dividerColor: BondColors.cloud,
    );
  }
  
  /// Applies the Bond dark theme to ThemeData
  static ThemeData get darkTheme {
    return _createTheme(
      brightness: Brightness.dark,
      primaryColor: BondColors.bondTeal,
      secondaryColor: BondColors.connectionPurple,
      backgroundColor: BondColors.night,
      scaffoldBackgroundColor: Color(0xFF0A1118), // Slightly darker than night
      cardColor: Color(0xFF1A2634), // Slightly lighter than night
      textPrimaryColor: BondColors.snow,
      textSecondaryColor: BondColors.cloud,
      dividerColor: BondColors.slate.withOpacity(0.2),
    );
  }

  /// Creates a theme from specified colors
  static ThemeData _createTheme({
    required Brightness brightness,
    required Color primaryColor,
    required Color secondaryColor, 
    required Color backgroundColor,
    required Color scaffoldBackgroundColor,
    required Color cardColor,
    required Color textPrimaryColor,
    required Color textSecondaryColor,
    required Color dividerColor,
  }) {
    final isDark = brightness == Brightness.dark;
    
    // Set system overlay style based on theme
    final overlayStyle = isDark 
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      primaryColor: primaryColor,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primaryColor,
        onPrimary: Colors.white,
        secondary: secondaryColor,
        onSecondary: Colors.white,
        error: BondColors.error,
        onError: Colors.white,
        background: backgroundColor,
        onBackground: textPrimaryColor,
        surface: cardColor,
        onSurface: textPrimaryColor,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      cardColor: cardColor,
      dividerColor: dividerColor,
      
      // Set text theme with correct colors
      textTheme: TextTheme(
        displayLarge: TextStyle(color: textPrimaryColor),
        displayMedium: TextStyle(color: textPrimaryColor),
        displaySmall: TextStyle(color: textPrimaryColor),
        headlineLarge: TextStyle(color: textPrimaryColor),
        headlineMedium: TextStyle(color: textPrimaryColor),
        headlineSmall: TextStyle(color: textPrimaryColor),
        titleLarge: TextStyle(color: textPrimaryColor),
        titleMedium: TextStyle(color: textPrimaryColor),
        titleSmall: TextStyle(color: textPrimaryColor),
        bodyLarge: TextStyle(color: textPrimaryColor),
        bodyMedium: TextStyle(color: textPrimaryColor),
        bodySmall: TextStyle(color: textSecondaryColor),
        labelLarge: TextStyle(color: textPrimaryColor),
        labelMedium: TextStyle(color: textSecondaryColor),
        labelSmall: TextStyle(color: textSecondaryColor),
      ),
      
      // AppBar theme with transparency
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: textPrimaryColor,
        systemOverlayStyle: overlayStyle,
      ),
      
      // Button themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryColor,
          side: BorderSide(color: primaryColor, width: 1.5),
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primaryColor,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
      
      // Floating action button theme
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Card theme
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input decoration theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark 
            ? BondColors.slate.withOpacity(0.2) 
            : BondColors.cloud.withOpacity(0.5),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark 
                ? BondColors.slate.withOpacity(0.3) 
                : BondColors.cloud,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: primaryColor,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: BondColors.error,
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: BondColors.error,
            width: 1.5,
          ),
        ),
      ),
      
      // Checkbox theme
      checkboxTheme: CheckboxThemeData(
        fillColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return isDark ? BondColors.slate : BondColors.cloud;
        }),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
      
      // Bottom navigation bar theme
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: isDark ? cardColor : Colors.white,
        selectedItemColor: primaryColor,
        unselectedItemColor: textSecondaryColor,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      
      // Divider theme
      dividerTheme: DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: 1,
      ),
      
      // Switch theme
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor;
          }
          return isDark ? BondColors.slate : BondColors.cloud;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return primaryColor.withOpacity(0.5);
          }
          return isDark 
              ? BondColors.slate.withOpacity(0.3) 
              : BondColors.cloud.withOpacity(0.7);
        }),
      ),
      
      // Slider theme
      sliderTheme: SliderThemeData(
        activeTrackColor: primaryColor,
        inactiveTrackColor: isDark 
            ? BondColors.slate.withOpacity(0.3) 
            : BondColors.cloud,
        thumbColor: primaryColor,
        overlayColor: primaryColor.withOpacity(0.2),
        thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: RoundSliderOverlayShape(overlayRadius: 24),
      ),
      
      // Tooltip theme
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? cardColor : Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        textStyle: TextStyle(
          color: textPrimaryColor,
          fontSize: 12,
        ),
      ),
    );
  }

  /// Update status bar based on theme brightness
  static void setStatusBarTheme(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    SystemChrome.setSystemUIOverlayStyle(
      isDark 
          ? SystemUiOverlayStyle.light.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: BondColors.night,
              systemNavigationBarIconBrightness: Brightness.light,
            ) 
          : SystemUiOverlayStyle.dark.copyWith(
              statusBarColor: Colors.transparent,
              systemNavigationBarColor: Colors.white,
              systemNavigationBarIconBrightness: Brightness.dark,
            ),
    );
  }
}
