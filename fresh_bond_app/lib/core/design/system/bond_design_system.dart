import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_spacing.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';

/// Bond Design System constants and utilities
class BondDesignSystem {
  /// Default animation duration
  static const Duration animationDuration = Duration(milliseconds: 200);
  
  /// Default animation curve
  static const Curve animationCurve = Curves.easeInOut;
  
  /// Default border radius
  static const double borderRadius = 12.0;
  
  /// Default shadow
  static List<BoxShadow> defaultShadow(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return [
      BoxShadow(
        color: isDark 
            ? Colors.black.withOpacity(0.3) 
            : Colors.black.withOpacity(0.1),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ];
  }
  
  /// Default elevation
  static const double defaultElevation = 2.0;
  
  /// Get color based on theme brightness
  static Color getThemedColor(
    BuildContext context, {
    required Color lightColor,
    required Color darkColor,
  }) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkColor
        : lightColor;
  }
  
  /// Get text style based on theme brightness
  static TextStyle getThemedTextStyle(
    BuildContext context, {
    required TextStyle lightStyle,
    required TextStyle darkStyle,
  }) {
    return Theme.of(context).brightness == Brightness.dark
        ? darkStyle
        : lightStyle;
  }
}
