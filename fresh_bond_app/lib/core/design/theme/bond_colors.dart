import 'package:flutter/material.dart';

/// Bond app color palette
class BondColors {
  /// Primary brand color
  static const Color primary = Color(0xFF6200EE);
  
  /// Secondary brand color
  static const Color secondary = Color(0xFF03DAC6);
  
  /// Error color
  static const Color error = Color(0xFFB00020);
  
  /// Success color
  static const Color success = Color(0xFF4CAF50);
  
  /// Warning color
  static const Color warning = Color(0xFFFFC107);
  
  /// Info color
  static const Color info = Color(0xFF2196F3);
  
  /// Primary text color
  static const Color text = Color(0xFF121212);
  
  /// Secondary text color
  static const Color textSecondary = Color(0xFF757575);
  
  /// Primary background color
  static const Color background = Color(0xFFF5F5F5);
  
  /// Secondary background color
  static const Color backgroundSecondary = Color(0xFFFFFFFF);
  
  /// Divider color
  static const Color divider = Color(0xFFE0E0E0);
  
  /// Disabled color
  static const Color disabled = Color(0xFFBDBDBD);
  
  /// Primary color for dark mode
  static const Color primaryDark = Color(0xFFBB86FC);
  
  /// Secondary color for dark mode
  static const Color secondaryDark = Color(0xFF03DAC6);
  
  /// Background color for dark mode
  static const Color backgroundDark = Color(0xFF121212);
  
  /// Secondary background color for dark mode
  static const Color backgroundSecondaryDark = Color(0xFF1E1E1E);
  
  /// Text color for dark mode
  static const Color textDark = Color(0xFFFFFFFF);
  
  /// Secondary text color for dark mode
  static const Color textSecondaryDark = Color(0xFFB0B0B0);
  
  /// Slate color for UI elements
  static const Color slate = Color(0xFF64748B);
  
  /// Primary color alias for compatibility
  static const Color primaryColor = primary;
  
  /// Glass background color for light mode (Neo-Glassmorphism)
  static const Color glassBackground = Color(0xDDFFFFFF);
  
  /// Glass background color for dark mode (Neo-Glassmorphism)
  static const Color darkGlassBackground = Color(0xDD2A2A2A);
  
  /// Glass border color for light mode
  static const Color glassBorder = Color(0x33FFFFFF);
  
  /// Glass border color for dark mode
  static const Color darkGlassBorder = Color(0x33FFFFFF);
  
  /// Glass shadow color for light mode
  static const Color glassShadow = Color(0x40000000);
  
  /// Glass shadow color for dark mode
  static const Color darkGlassShadow = Color(0x40000000);
  
  /// Primary gradient for buttons and UI elements
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}