import 'package:flutter/material.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';

/// Badge variants
enum BondBadgeVariant {
  /// Primary badge
  primary,
  
  /// Secondary badge
  secondary,
  
  /// Success badge
  success,
  
  /// Warning badge
  warning,
  
  /// Error badge
  error,
  
  /// Info badge
  info,
  
  /// Custom badge
  custom
}

/// Badge sizes
enum BondBadgeSize {
  /// Small badge
  small,
  
  /// Medium badge
  medium,
  
  /// Large badge
  large
}

/// A customizable badge component implementing the Bond Design System
///
/// Features:
/// - Multiple variants and sizes
/// - Support for icons
/// - Customizable colors and shapes
class BondBadge extends StatelessWidget {
  /// The text to display
  final String text;
  
  /// The variant of the badge
  final BondBadgeVariant variant;
  
  /// The size of the badge
  final BondBadgeSize size;
  
  /// The icon to display before the text
  final IconData? icon;
  
  /// Whether the badge is outlined
  final bool outlined;
  
  /// Custom background color (only used when variant is custom)
  final Color? backgroundColor;
  
  /// Custom text color (only used when variant is custom)
  final Color? textColor;
  
  /// Whether the badge is rounded
  final bool rounded;
  
  /// Whether to show a dot indicator
  final bool showDot;
  
  /// Dot color (defaults to badge color)
  final Color? dotColor;
  
  /// Callback when badge is tapped
  final VoidCallback? onTap;

  /// Constructor
  const BondBadge({
    Key? key,
    required this.text,
    this.variant = BondBadgeVariant.primary,
    this.size = BondBadgeSize.medium,
    this.icon,
    this.outlined = false,
    this.backgroundColor,
    this.textColor,
    this.rounded = true,
    this.showDot = false,
    this.dotColor,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on variant
    final Color bgColor = _getBackgroundColor(isDark);
    final Color txtColor = _getTextColor(isDark, bgColor);
    
    // Determine padding based on size
    final EdgeInsetsGeometry padding = _getPadding();
    
    // Determine font size based on size
    final TextStyle textStyle = _getTextStyle(context, txtColor);
    
    // Determine border radius
    final double borderRadius = rounded ? 100.0 : 4.0;
    
    // Build the badge
    Widget badge = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: outlined ? Colors.transparent : bgColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: outlined ? Border.all(color: bgColor) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dotColor ?? bgColor,
              ),
            ),
            const SizedBox(width: 4),
          ],
          if (icon != null) ...[
            Icon(
              icon,
              size: _getIconSize(),
              color: txtColor,
            ),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: textStyle,
          ),
        ],
      ),
    );
    
    // Make it tappable if needed
    if (onTap != null) {
      badge = GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }
    
    // Wrap in a constrained box to prevent layout issues
    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 16,
        minHeight: 16,
      ),
      child: badge,
    );
  }
  
  /// Get background color based on variant
  Color _getBackgroundColor(bool isDark) {
    if (variant == BondBadgeVariant.custom && backgroundColor != null) {
      return backgroundColor!;
    }
    
    switch (variant) {
      case BondBadgeVariant.primary:
        return BondColors.bondTeal;
      case BondBadgeVariant.secondary:
        return isDark ? BondColors.slate : BondColors.cloud;
      case BondBadgeVariant.success:
        return BondColors.success;
      case BondBadgeVariant.warning:
        return BondColors.warning;
      case BondBadgeVariant.error:
        return BondColors.error;
      case BondBadgeVariant.info:
        return BondColors.bondPurple;
      default:
        return BondColors.bondTeal;
    }
  }
  
  /// Get text color based on variant
  Color _getTextColor(bool isDark, Color bgColor) {
    if (variant == BondBadgeVariant.custom && textColor != null) {
      return textColor!;
    }
    
    if (outlined) {
      return bgColor;
    }
    
    // For secondary variant, use dark text on light background
    if (variant == BondBadgeVariant.secondary) {
      return isDark ? Colors.white : BondColors.night;
    }
    
    // For other variants, use white text
    return Colors.white;
  }
  
  /// Get padding based on size
  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case BondBadgeSize.small:
        return const EdgeInsets.symmetric(horizontal: 6, vertical: 2);
      case BondBadgeSize.large:
        return const EdgeInsets.symmetric(horizontal: 12, vertical: 6);
      case BondBadgeSize.medium:
      default:
        return const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
    }
  }
  
  /// Get text style based on size
  TextStyle _getTextStyle(BuildContext context, Color color) {
    switch (size) {
      case BondBadgeSize.small:
        return BondTypography.caption(context).copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        );
      case BondBadgeSize.large:
        return BondTypography.body(context).copyWith(
          color: color,
          fontWeight: FontWeight.w500,
        );
      case BondBadgeSize.medium:
      default:
        return BondTypography.caption(context).copyWith(
          fontWeight: FontWeight.w600,
          color: color,
        );
    }
  }
  
  /// Get icon size based on badge size
  double _getIconSize() {
    switch (size) {
      case BondBadgeSize.small:
        return 12;
      case BondBadgeSize.large:
        return 18;
      case BondBadgeSize.medium:
      default:
        return 14;
    }
  }
}
