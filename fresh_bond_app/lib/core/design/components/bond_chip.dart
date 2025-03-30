import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';
import '../bond_design_system.dart';

/// Chip variants
enum BondChipVariant {
  /// Primary chip
  primary,
  
  /// Secondary chip
  secondary,
  
  /// Outlined chip
  outlined,
  
  /// Subtle chip
  subtle,
}

/// Chip sizes
enum BondChipSize {
  /// Small chip
  small,
  
  /// Medium chip
  medium,
  
  /// Large chip
  large,
}

/// A customizable chip component implementing the Bond Design System
///
/// Features:
/// - Multiple variants: primary, secondary, outlined, subtle
/// - Multiple sizes: small, medium, large
/// - Optional leading and trailing icons
/// - Optional avatar
/// - Selectable state
/// - Deletable
class BondChip extends StatelessWidget {
  /// Label text
  final String label;
  
  /// Chip variant
  final BondChipVariant variant;
  
  /// Chip size
  final BondChipSize size;
  
  /// Whether the chip is selected
  final bool selected;
  
  /// Whether the chip is enabled
  final bool enabled;
  
  /// Leading icon
  final IconData? leadingIcon;
  
  /// Trailing icon
  final IconData? trailingIcon;
  
  /// Avatar widget to display
  final Widget? avatar;
  
  /// Whether the chip is deletable
  final bool deletable;
  
  /// Callback when the chip is tapped
  final VoidCallback? onTap;
  
  /// Callback when the chip is deleted
  final VoidCallback? onDeleted;
  
  /// Custom background color
  final Color? backgroundColor;
  
  /// Custom text color
  final Color? textColor;
  
  /// Custom border color
  final Color? borderColor;
  
  /// Whether to use haptic feedback
  final bool useHapticFeedback;

  /// Constructor
  const BondChip({
    Key? key,
    required this.label,
    this.variant = BondChipVariant.primary,
    this.size = BondChipSize.medium,
    this.selected = false,
    this.enabled = true,
    this.leadingIcon,
    this.trailingIcon,
    this.avatar,
    this.deletable = false,
    this.onTap,
    this.onDeleted,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
    this.useHapticFeedback = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get colors based on variant and state
    final ChipColors colors = _getColors(isDark);
    
    // Get dimensions based on size
    final ChipDimensions dimensions = _getDimensions();
    
    // Determine text style
    final TextStyle textStyle = _getTextStyle(context, colors.textColor);
    
    // Handle tap with optional haptic feedback
    void handleTap() {
      if (!enabled || onTap == null) return;
      
      if (useHapticFeedback) {
        // Add haptic feedback
        HapticFeedback.lightImpact();
      }
      
      onTap!();
    }
    
    // Handle delete with optional haptic feedback
    void handleDelete() {
      if (!enabled || onDeleted == null) return;
      
      if (useHapticFeedback) {
        // Add haptic feedback
        HapticFeedback.lightImpact();
      }
      
      onDeleted!();
    }
    
    // Build the chip content
    List<Widget> chipContent = [];
    
    // Add avatar or leading icon
    if (avatar != null) {
      chipContent.add(
        SizedBox(
          width: dimensions.iconSize,
          height: dimensions.iconSize,
          child: avatar,
        ),
      );
      chipContent.add(SizedBox(width: dimensions.spacing));
    } else if (leadingIcon != null) {
      chipContent.add(
        Icon(
          leadingIcon,
          size: dimensions.iconSize,
          color: colors.textColor,
        ),
      );
      chipContent.add(SizedBox(width: dimensions.spacing));
    }
    
    // Add label
    chipContent.add(
      Text(
        label,
        style: textStyle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
    
    // Add trailing icon or delete button
    if (deletable) {
      chipContent.add(SizedBox(width: dimensions.spacing));
      chipContent.add(
        GestureDetector(
          onTap: handleDelete,
          child: Icon(
            Icons.close,
            size: dimensions.iconSize,
            color: colors.textColor,
          ),
        ),
      );
    } else if (trailingIcon != null) {
      chipContent.add(SizedBox(width: dimensions.spacing));
      chipContent.add(
        Icon(
          trailingIcon,
          size: dimensions.iconSize,
          color: colors.textColor,
        ),
      );
    }
    
    // Build the chip
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: GestureDetector(
        onTap: handleTap,
        child: Container(
          height: dimensions.height,
          padding: EdgeInsets.symmetric(
            horizontal: dimensions.horizontalPadding,
            vertical: dimensions.verticalPadding,
          ),
          decoration: BoxDecoration(
            color: colors.backgroundColor,
            borderRadius: BorderRadius.circular(dimensions.height / 2),
            border: Border.all(
              color: colors.borderColor,
              width: 1,
            ),
            boxShadow: [
              if (selected)
                BoxShadow(
                  color: colors.backgroundColor.withOpacity(0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: chipContent,
          ),
        ),
      ),
    );
  }
  
  /// Get colors based on variant and state
  ChipColors _getColors(bool isDark) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    
    switch (variant) {
      case BondChipVariant.primary:
        bgColor = selected 
            ? BondColors.bondTeal 
            : (isDark ? BondColors.bondTeal.withOpacity(0.2) : BondColors.bondTeal.withOpacity(0.1));
        textColor = selected 
            ? Colors.white 
            : (isDark ? Colors.white : BondColors.bondTeal);
        borderColor = selected 
            ? BondColors.bondTeal 
            : Colors.transparent;
        break;
        
      case BondChipVariant.secondary:
        bgColor = selected 
            ? BondColors.connectionPurple 
            : (isDark ? BondColors.connectionPurple.withOpacity(0.2) : BondColors.connectionPurple.withOpacity(0.1));
        textColor = selected 
            ? Colors.white 
            : (isDark ? Colors.white : BondColors.connectionPurple);
        borderColor = selected 
            ? BondColors.connectionPurple 
            : Colors.transparent;
        break;
        
      case BondChipVariant.outlined:
        bgColor = selected 
            ? (isDark ? BondColors.slate.withOpacity(0.3) : BondColors.cloud.withOpacity(0.5)) 
            : Colors.transparent;
        textColor = isDark ? Colors.white : BondColors.slate;
        borderColor = isDark ? BondColors.slate.withOpacity(0.5) : BondColors.cloud;
        break;
        
      case BondChipVariant.subtle:
        bgColor = selected 
            ? (isDark ? BondColors.slate.withOpacity(0.3) : BondColors.cloud.withOpacity(0.8)) 
            : (isDark ? BondColors.slate.withOpacity(0.1) : BondColors.cloud.withOpacity(0.3));
        textColor = isDark ? Colors.white : BondColors.slate;
        borderColor = Colors.transparent;
        break;
    }
    
    // Override with custom colors if provided
    return ChipColors(
      backgroundColor: this.backgroundColor ?? bgColor,
      textColor: this.textColor ?? textColor,
      borderColor: this.borderColor ?? borderColor,
    );
  }
  
  /// Get dimensions based on size
  ChipDimensions _getDimensions() {
    switch (size) {
      case BondChipSize.small:
        return const ChipDimensions(
          height: 24,
          horizontalPadding: 8,
          verticalPadding: 2,
          iconSize: 16,
          spacing: 4,
        );
      case BondChipSize.large:
        return const ChipDimensions(
          height: 40,
          horizontalPadding: 16,
          verticalPadding: 8,
          iconSize: 24,
          spacing: 8,
        );
      case BondChipSize.medium:
      default:
        return const ChipDimensions(
          height: 32,
          horizontalPadding: 12,
          verticalPadding: 6,
          iconSize: 18,
          spacing: 6,
        );
    }
  }
  
  /// Get text style based on size and color
  TextStyle _getTextStyle(BuildContext context, Color color) {
    switch (size) {
      case BondChipSize.small:
        return BondTypography.caption(context).copyWith(color: color);
      case BondChipSize.large:
        return BondTypography.body(context).copyWith(color: color);
      case BondChipSize.medium:
      default:
        return BondTypography.caption(context).copyWith(color: color);
    }
  }
}

/// Colors for the chip
class ChipColors {
  /// Background color
  final Color backgroundColor;
  
  /// Text color
  final Color textColor;
  
  /// Border color
  final Color borderColor;
  
  const ChipColors({
    required this.backgroundColor,
    required this.textColor,
    required this.borderColor,
  });
}

/// Dimensions for the chip
class ChipDimensions {
  /// Height of the chip
  final double height;
  
  /// Horizontal padding
  final double horizontalPadding;
  
  /// Vertical padding
  final double verticalPadding;
  
  /// Icon size
  final double iconSize;
  
  /// Spacing between elements
  final double spacing;
  
  const ChipDimensions({
    required this.height,
    required this.horizontalPadding,
    required this.verticalPadding,
    required this.iconSize,
    required this.spacing,
  });
}
