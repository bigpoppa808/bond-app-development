import 'package:flutter/material.dart';

// Core design elements
export 'bond_colors.dart';
export 'bond_typography.dart';
export 'bond_theme.dart';

// Components
export 'components/bond_card.dart';
export 'components/bond_button.dart';
export 'components/bond_notification_item.dart';

// Layout
export 'layout/bond_bento_grid.dart';

/// Main entry point for the Bond Design System
///
/// This class provides convenient access to all Bond Design System 
/// elements and handles theme initialization.
class BondDesignSystem {
  BondDesignSystem._(); // Private constructor to prevent instantiation
  
  /// Initialize the Bond Design System
  static void initialize() {
    // Any initialization logic (like loading fonts) can go here
    _loadFonts();
  }
  
  /// Apply Bond Design System theme to the app
  static ThemeData themeFor(BuildContext context, {bool? darkMode}) {
    final brightness = darkMode ?? 
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    
    return brightness ? BondTheme.darkTheme : BondTheme.lightTheme;
  }
  
  /// Updates system UI elements to match the current theme
  static void updateSystemUI(BuildContext context) {
    BondTheme.setStatusBarTheme(context);
  }
  
  /// Load custom fonts used by the design system
  static void _loadFonts() {
    // In a real implementation, this would pre-warm font loading
    // For Flutter, this is handled by the pubspec.yaml font declarations
  }

  /// Design tokens that can be used throughout the app
  /// These ensure consistent spacing, sizing, and timing
  static class Tokens {
    // Spacing tokens
    static const double spaceXS = 4.0;
    static const double spaceS = 8.0;
    static const double spaceM = 16.0;
    static const double spaceL = 24.0;
    static const double spaceXL = 32.0;
    static const double spaceXXL = 48.0;
    
    // Border radius tokens
    static const double radiusS = 4.0;
    static const double radiusM = 8.0;
    static const double radiusL = 12.0;
    static const double radiusXL = 16.0;
    static const double radiusXXL = 24.0;
    static const double radiusCircular = 999.0;
    
    // Icon size tokens
    static const double iconS = 16.0;
    static const double iconM = 24.0;
    static const double iconL = 32.0;
    static const double iconXL = 48.0;
    
    // Animation duration tokens
    static const Duration durationFast = Duration(milliseconds: 150);
    static const Duration durationMedium = Duration(milliseconds: 300);
    static const Duration durationSlow = Duration(milliseconds: 500);
    
    // Animation curves
    static const Curve curveStandard = Curves.easeInOut;
    static const Curve curveDecelerate = Curves.easeOutCubic;
    static const Curve curveAccelerate = Curves.easeInCubic;
    static const Curve curveSharp = Curves.easeInOutCubic;
    
    // Elevation tokens (for shadow depths)
    static const double elevationXS = 2.0;
    static const double elevationS = 4.0;
    static const double elevationM = 8.0;
    static const double elevationL = 16.0;
    static const double elevationXL = 24.0;
  }
  
  /// Breakpoints for responsive design
  static class Breakpoints {
    static const double mobileS = 320.0;
    static const double mobileL = 375.0;
    static const double tablet = 768.0;
    static const double desktopS = 1024.0;
    static const double desktopL = 1440.0;
    
    /// Check if the current screen size is mobile
    static bool isMobile(BuildContext context) {
      return MediaQuery.of(context).size.width < tablet;
    }
    
    /// Check if the current screen size is tablet
    static bool isTablet(BuildContext context) {
      final width = MediaQuery.of(context).size.width;
      return width >= tablet && width < desktopS;
    }
    
    /// Check if the current screen size is desktop
    static bool isDesktop(BuildContext context) {
      return MediaQuery.of(context).size.width >= desktopS;
    }
  }
}
