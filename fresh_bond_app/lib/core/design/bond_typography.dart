import 'package:flutter/material.dart';

/// Bond Design System - Typography
/// 
/// A responsive typography system using "Satoshi" as the primary font and
/// "Cabinet Grotesk" as the secondary display font. Includes a fluid type scale
/// with different sizes for mobile and desktop.
class BondTypography {
  BondTypography._(); // Private constructor to prevent instantiation

  // Font Families
  static const String primaryFont = 'Satoshi';
  static const String secondaryFont = 'Cabinet Grotesk';
  
  // Fallback Font Families
  static const List<String> primaryFallbacks = ['SF Pro Text', 'Roboto', 'system-ui'];
  static const List<String> secondaryFallbacks = ['SF Pro Display', 'Montserrat', 'sans-serif'];

  /// Gets the complete font family string with fallbacks
  static String get primaryFontFamily => [primaryFont, ...primaryFallbacks].join(', ');
  static String get secondaryFontFamily => [secondaryFont, ...secondaryFallbacks].join(', ');

  // Base Font Sizes
  static const double _baseMobileSize = 14.0;
  static const double _baseDesktopSize = 16.0;

  // Font Scale Ratios
  static const double _mobileRatio = 1.2;
  static const double _desktopRatio = 1.25;

  /// Creates a responsive TextStyle based on screen size
  static TextStyle _createResponsiveStyle({
    required BuildContext context,
    required double mobileSize,
    required double desktopSize,
    required FontWeight weight,
    double? height,
    double? letterSpacing,
    bool useSecondaryFont = false,
  }) {
    final isDesktop = MediaQuery.of(context).size.width > 768;
    final fontSize = isDesktop ? desktopSize : mobileSize;
    
    return TextStyle(
      fontFamily: useSecondaryFont ? secondaryFontFamily : primaryFontFamily,
      fontSize: fontSize,
      fontWeight: weight,
      height: height,
      letterSpacing: letterSpacing,
    );
  }

  // Style Getters
  static TextStyle display(BuildContext context) {
    return _createResponsiveStyle(
      context: context,
      mobileSize: 36.0,
      desktopSize: 48.0,
      weight: FontWeight.w700,
      height: 1.1,
      letterSpacing: -0.5,
      useSecondaryFont: true,
    );
  }

  static TextStyle heading1(BuildContext context) {
    return _createResponsiveStyle(
      context: context,
      mobileSize: 28.0,
      desktopSize: 36.0,
      weight: FontWeight.w700,
      height: 1.2,
      useSecondaryFont: true,
    );
  }

  static TextStyle heading2(BuildContext context) {
    return _createResponsiveStyle(
      context: context,
      mobileSize: 22.0,
      desktopSize: 28.0,
      weight: FontWeight.w600,
      height: 1.25,
      useSecondaryFont: true,
    );
  }

  static TextStyle heading3(BuildContext context) {
    return _createResponsiveStyle(
      context: context,
      mobileSize: 18.0,
      desktopSize: 22.0,
      weight: FontWeight.w600,
      height: 1.3,
      useSecondaryFont: true,
    );
  }

  static TextStyle bodyLarge(BuildContext context) {
    return _createResponsiveStyle(
      context: context,
      mobileSize: 16.0,
      desktopSize: 18.0,
      weight: FontWeight.w400,
      height: 1.5,
    );
  }

  static TextStyle body(BuildContext context) {
    return _createResponsiveStyle(
      context: context,
      mobileSize: 14.0,
      desktopSize: 16.0,
      weight: FontWeight.w400,
      height: 1.5,
    );
  }

  static TextStyle bodySmall(BuildContext context) {
    return _createResponsiveStyle(
      context: context,
      mobileSize: 13.0,
      desktopSize: 14.0,
      weight: FontWeight.w400,
      height: 1.5,
    );
  }

  static TextStyle caption(BuildContext context) {
    return _createResponsiveStyle(
      context: context,
      mobileSize: 12.0,
      desktopSize: 12.0,
      weight: FontWeight.w500,
      height: 1.4,
      letterSpacing: 0.2,
    );
  }

  static TextStyle button(BuildContext context) {
    return _createResponsiveStyle(
      context: context,
      mobileSize: 14.0,
      desktopSize: 16.0,
      weight: FontWeight.w600,
      height: 1.4,
      letterSpacing: 0.2,
    );
  }
}
