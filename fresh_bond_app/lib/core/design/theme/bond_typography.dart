import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';

/// Bond app typography system
class BondTypography {
  static const String _fontFamily = 'Poppins';

  /// Heading 1 style
  static final TextStyle heading1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: BondColors.text,
    height: 1.2,
  );

  /// Heading 2 style
  static final TextStyle heading2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: BondColors.text,
    height: 1.3,
  );

  /// Heading 3 style
  static final TextStyle heading3 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: BondColors.text,
    height: 1.4,
  );

  /// Heading 4 style
  static final TextStyle heading4 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: BondColors.text,
    height: 1.5,
  );

  /// Heading 5 style
  static final TextStyle heading5 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: BondColors.text,
    height: 1.5,
  );

  /// Heading 6 style
  static final TextStyle heading6 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: BondColors.text,
    height: 1.5,
  );

  /// Body 1 style (primary body text)
  static final TextStyle body1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: BondColors.text,
    height: 1.5,
  );

  /// Body 2 style (secondary body text)
  static final TextStyle body2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: BondColors.text,
    height: 1.5,
  );

  /// Subtitle 1 style
  static final TextStyle subtitle1 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: BondColors.text,
    height: 1.5,
  );

  /// Subtitle 2 style
  static final TextStyle subtitle2 = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: BondColors.text,
    height: 1.5,
  );

  /// Caption style (for small text elements)
  static final TextStyle caption = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: BondColors.textSecondary,
    height: 1.5,
  );

  /// Button text style
  static final TextStyle button = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 1.25,
  );

  /// Overline text style (for labels above elements)
  static final TextStyle overline = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 10,
    fontWeight: FontWeight.normal,
    color: BondColors.textSecondary,
    letterSpacing: 1.5,
    height: 1.5,
  );
}
