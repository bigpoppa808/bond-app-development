import 'package:flutter/material.dart';
import 'bond_colors.dart';

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

// Direct imports for internal use
import 'bond_theme.dart';

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
  static final tokens = _BondTokens();
  
  /// Breakpoints for responsive design
  static final breakpoints = _BondBreakpoints();
}

/// Design tokens for the Bond Design System
class _BondTokens {
  // Spacing tokens
  final double spaceXS = 4.0;
  final double spaceS = 8.0;
  final double spaceM = 16.0;
  final double spaceL = 24.0;
  final double spaceXL = 32.0;
  final double spaceXXL = 48.0;
  
  // Border radius tokens
  final double radiusS = 4.0;
  final double radiusM = 8.0;
  final double radiusL = 12.0;
  final double radiusXL = 16.0;
  final double radiusXXL = 24.0;
  final double radiusCircular = 999.0;
  
  // Icon size tokens
  final double iconS = 16.0;
  final double iconM = 24.0;
  final double iconL = 32.0;
  final double iconXL = 48.0;
  
  // Animation duration tokens
  final Duration durationFast = Duration(milliseconds: 150);
  final Duration durationMedium = Duration(milliseconds: 300);
  final Duration durationSlow = Duration(milliseconds: 500);
  
  // Animation curves
  final Curve curveStandard = Curves.easeInOut;
  final Curve curveDecelerate = Curves.easeOutCubic;
  final Curve curveAccelerate = Curves.easeInCubic;
  final Curve curveSharp = Curves.easeInOutCubic;
  
  // Elevation tokens (for shadow depths)
  final double elevationXS = 2.0;
  final double elevationS = 4.0;
  final double elevationM = 8.0;
  final double elevationL = 16.0;
  final double elevationXL = 24.0;
  
  // Avatar colors - used for generating consistent avatar background colors
  final List<Color> avatarColors = [
    BondColors.bondTeal,
    BondColors.bondPurple,
    Color(0xFF5E72E4), // Indigo
    Color(0xFF11CDEF), // Cyan
    Color(0xFFFB6340), // Orange
    Color(0xFF2DCE89), // Green
    Color(0xFFF5365C), // Pink
    Color(0xFFFFD600), // Yellow
  ];
}

/// Breakpoints for responsive design
class _BondBreakpoints {
  final double mobileS = 320.0;
  final double mobileL = 375.0;
  final double tablet = 768.0;
  final double desktopS = 1024.0;
  final double desktopL = 1440.0;
  
  /// Check if the current screen size is mobile
  bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tablet;
  }
  
  /// Check if the current screen size is tablet
  bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tablet && width < desktopS;
  }
  
  /// Check if the current screen size is desktop
  bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopS;
  }
}
