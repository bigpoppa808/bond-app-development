import 'dart:ui';
import 'package:flutter/material.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';

/// Button variants according to the Bond Design System
enum BondButtonVariant {
  primary,
  secondary,
  tertiary,
  icon,
}

/// Shape options for buttons
enum BondButtonShape {
  rounded,   // Rounded corners (default)
  pill,      // Fully rounded sides
  circle,    // Perfect circle (for icon buttons)
}

/// A customizable button component implementing the Bond Design System
///
/// Features:
/// - Multiple variants: primary, secondary, tertiary, icon
/// - Glass effect option for Neo-Glassmorphism style
/// - Loading state with animated indicator
/// - Customizable shape
/// - Gradient background option
/// - Haptic feedback
class BondButton extends StatelessWidget {
  final String? label;
  final IconData? icon;
  final VoidCallback? onPressed;
  final BondButtonVariant variant;
  final BondButtonShape shape;
  final bool useGlass;
  final bool isLoading;
  final double? width;
  final double height;
  final bool useGradient;
  final EdgeInsetsGeometry? padding;
  final bool useHapticFeedback;

  const BondButton({
    Key? key,
    this.label,
    this.icon,
    this.onPressed,
    this.variant = BondButtonVariant.primary,
    this.shape = BondButtonShape.rounded,
    this.useGlass = false,
    this.isLoading = false,
    this.width,
    this.height = 48.0,
    this.useGradient = true,
    this.padding,
    this.useHapticFeedback = true,
  }) : assert(
         (variant == BondButtonVariant.icon && icon != null) || 
         (variant != BondButtonVariant.icon && label != null),
         'Icon buttons require an icon, other buttons require a label'
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine border radius based on shape
    final double borderRadius = shape == BondButtonShape.pill 
        ? 24.0 
        : (shape == BondButtonShape.circle ? height / 2 : 12.0);
    
    // Button styling variables
    late final Color backgroundColor;
    late final Color foregroundColor;
    late final Border? border;
    late final Gradient? gradient;
    late final EdgeInsetsGeometry buttonPadding;
    
    // Configure button appearance based on variant
    switch (variant) {
      case BondButtonVariant.primary:
        backgroundColor = BondColors.bondTeal;
        foregroundColor = Colors.white;
        border = null;
        gradient = useGradient ? BondColors.primaryGradient : null;
        buttonPadding = padding ?? const EdgeInsets.symmetric(horizontal: 24.0);
        break;
        
      case BondButtonVariant.secondary:
        backgroundColor = Colors.transparent;
        foregroundColor = BondColors.bondTeal;
        border = Border.all(color: BondColors.bondTeal, width: 1.5);
        gradient = null;
        buttonPadding = padding ?? const EdgeInsets.symmetric(horizontal: 24.0);
        break;
        
      case BondButtonVariant.tertiary:
        backgroundColor = Colors.transparent;
        foregroundColor = BondColors.bondTeal;
        border = null;
        gradient = null;
        buttonPadding = padding ?? const EdgeInsets.symmetric(horizontal: 16.0);
        break;
        
      case BondButtonVariant.icon:
        backgroundColor = BondColors.bondTeal.withOpacity(0.1);
        foregroundColor = BondColors.bondTeal;
        border = null;
        gradient = null;
        buttonPadding = EdgeInsets.zero;
        break;
    }

    // Create base button
    Widget buttonContent = _buildButtonContent(context, foregroundColor);
    
    // Apply glass effect if enabled
    if (useGlass && (variant == BondButtonVariant.primary || variant == BondButtonVariant.icon)) {
      return _buildGlassButton(
        context,
        buttonContent,
        borderRadius,
        buttonPadding,
      );
    }
    
    // Standard button implementation
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        borderRadius: BorderRadius.circular(borderRadius),
        child: Ink(
          width: variant == BondButtonVariant.icon ? height : width,
          height: height,
          padding: buttonPadding,
          decoration: BoxDecoration(
            color: backgroundColor,
            gradient: gradient,
            borderRadius: BorderRadius.circular(borderRadius),
            border: border,
          ),
          child: buttonContent,
        ),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context, Color foregroundColor) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          height: height * 0.5,
          width: height * 0.5,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
          ),
        ),
      );
    }

    if (variant == BondButtonVariant.icon) {
      return Center(
        child: Icon(icon, color: foregroundColor, size: height * 0.5),
      );
    }

    return Center(
      child: Text(
        label!,
        style: BondTypography.button(context).copyWith(color: foregroundColor),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildGlassButton(
    BuildContext context,
    Widget content,
    double borderRadius,
    EdgeInsetsGeometry buttonPadding,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8.0, sigmaY: 8.0),
        child: InkWell(
          onTap: isLoading ? null : () {
            if (useHapticFeedback) {
              HapticFeedback.lightImpact();
            }
            onPressed?.call();
          },
          borderRadius: BorderRadius.circular(borderRadius),
          child: Container(
            width: variant == BondButtonVariant.icon ? height : width,
            height: height,
            padding: buttonPadding,
            decoration: BoxDecoration(
              color: isDarkMode 
                  ? BondColors.darkGlassBackground 
                  : Colors.white.withOpacity(0.3),
              gradient: useGradient ? BondColors.primaryGradient.scale(0.8) : null,
              borderRadius: BorderRadius.circular(borderRadius),
              border: Border.all(
                color: isDarkMode 
                    ? BondColors.darkGlassBorder 
                    : Colors.white.withOpacity(0.5),
                width: 0.5,
              ),
            ),
            child: content,
          ),
        ),
      ),
    );
  }
}

extension GradientScaling on Gradient {
  /// Scale the opacity of colors in a gradient
  LinearGradient scale(double factor) {
    if (this is LinearGradient) {
      final LinearGradient linearGradient = this as LinearGradient;
      return LinearGradient(
        begin: linearGradient.begin,
        end: linearGradient.end,
        colors: linearGradient.colors.map((color) => 
          color.withOpacity((color.opacity * factor).clamp(0.0, 1.0))
        ).toList(),
        stops: linearGradient.stops,
      );
    }
    return this as LinearGradient;
  }
}
