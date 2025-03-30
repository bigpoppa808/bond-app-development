import 'dart:ui';
import 'package:flutter/material.dart';
import '../bond_colors.dart';

/// A glass-effect card component implementing the Neo-Glassmorphism style
/// from the Bond Design System.
///
/// Features:
/// - Frosted glass background effect with customizable opacity
/// - Subtle border for depth
/// - Optional shadow
/// - Variable padding and border radius
/// - Support for both light and dark modes
class BondCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final bool elevated;
  final double? height;
  final double? width;
  final Color? backgroundColor;
  final Color? borderColor;
  final double blurAmount;
  final VoidCallback? onTap;
  final double opacity;
  final bool addGrain;

  const BondCard({
    Key? key,
    required this.child,
    this.padding = const EdgeInsets.all(16.0),
    this.borderRadius = 16.0,
    this.elevated = true,
    this.height,
    this.width,
    this.backgroundColor,
    this.borderColor,
    this.blurAmount = 15.0,
    this.onTap,
    this.opacity = 0.7,
    this.addGrain = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on theme
    final bgColor = backgroundColor ?? 
        (isDarkMode ? BondColors.darkGlassBackground : BondColors.glassBackground);
    final border = borderColor ?? 
        (isDarkMode ? BondColors.darkGlassBorder : BondColors.glassBorder);
    final shadow = isDarkMode ? BondColors.darkGlassShadow : BondColors.glassShadow;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: elevated ? [
            BoxShadow(
              color: shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
              spreadRadius: 2,
            ),
          ] : null,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
            child: Stack(
              children: [
                // Base container with glass effect
                Container(
                  decoration: BoxDecoration(
                    color: bgColor.withOpacity(opacity),
                    borderRadius: BorderRadius.circular(borderRadius),
                    border: Border.all(
                      width: 0.5,
                      color: border,
                    ),
                  ),
                  padding: padding,
                  child: child,
                ),
                
                // Optional grain texture overlay
                if (addGrain)
                  Positioned.fill(
                    child: Opacity(
                      opacity: 0.05, // Very subtle grain
                      child: Image.asset(
                        'assets/images/noise_texture.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
