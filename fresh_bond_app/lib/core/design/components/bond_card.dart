import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';

/// Card variants for different use cases in the Bond Design System
enum BondCardVariant {
  /// Standard card for general content
  standard,
  
  /// Card for user connections
  connection,
  
  /// Card for meeting information
  meeting,
  
  /// Card for profile information
  profile,
  
  /// Card for notifications
  notification,
  
  /// Card for verification status
  verification,
}

/// A glass-effect card component implementing the Neo-Glassmorphism style
/// from the Bond Design System.
///
/// Features:
/// - Multiple variants for different content types (standard, connection, meeting, etc.)
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
  final BondCardVariant variant;
  final bool useGlass;

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
    this.variant = BondCardVariant.standard,
    this.useGlass = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Apply variant-specific styling
    final variantStyle = _getVariantStyle(context, variant);
    
    // Determine colors based on theme and variant
    final bgColor = backgroundColor ?? variantStyle.backgroundColor ?? 
        (isDarkMode ? BondColors.darkGlassBackground : BondColors.glassBackground);
    final border = borderColor ?? variantStyle.borderColor ?? 
        (isDarkMode ? BondColors.darkGlassBorder : BondColors.glassBorder);
    final shadow = isDarkMode ? BondColors.darkGlassShadow : BondColors.glassShadow;
    
    // Apply variant-specific borderRadius, elevation
    final actualBorderRadius = variantStyle.borderRadius ?? borderRadius;
    final actualElevated = variantStyle.elevated ?? elevated;
    final actualPadding = variantStyle.padding ?? padding;
    final actualOpacity = variantStyle.opacity ?? opacity;
    final actualUseGlass = variantStyle.useGlass ?? useGlass;
    
    // Main container for the card
    Widget cardContent = Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(actualBorderRadius),
        boxShadow: actualElevated ? [
          BoxShadow(
            color: shadow,
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: 2,
          ),
        ] : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(actualBorderRadius),
        child: actualUseGlass
            ? _buildGlassCard(
                context, 
                bgColor, 
                border, 
                actualBorderRadius, 
                actualOpacity, 
                actualPadding,
              )
            : _buildStandardCard(
                context, 
                bgColor, 
                border, 
                actualBorderRadius, 
                actualOpacity, 
                actualPadding,
              ),
      ),
    );
    
    // Apply custom decoration if provided by variant
    if (variantStyle.decorator != null) {
      cardContent = variantStyle.decorator!(cardContent);
    }
    
    // Make card tappable if onTap is provided
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: cardContent,
      );
    }
    
    return cardContent;
  }
  
  /// Builds a glass-effect card with backdrop filter
  Widget _buildGlassCard(
    BuildContext context,
    Color bgColor,
    Color borderColor,
    double borderRadius,
    double opacity,
    EdgeInsetsGeometry padding,
  ) {
    return BackdropFilter(
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
                color: borderColor,
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
                  errorBuilder: (context, error, stackTrace) {
                    // Return an empty container if the image is not found
                    return Container();
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
  
  /// Builds a standard card without glass effect
  Widget _buildStandardCard(
    BuildContext context,
    Color bgColor,
    Color borderColor,
    double borderRadius,
    double opacity,
    EdgeInsetsGeometry padding,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor.withOpacity(opacity),
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          width: 0.5,
          color: borderColor,
        ),
      ),
      padding: padding,
      child: child,
    );
  }
  
  /// Get styling for specific card variant
  _BondCardVariantStyle _getVariantStyle(BuildContext context, BondCardVariant variant) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    switch (variant) {
      case BondCardVariant.connection:
        return _BondCardVariantStyle(
          backgroundColor: BondColors.primary.withOpacity(0.05),
          borderColor: BondColors.primary.withOpacity(0.2),
          borderRadius: 12.0,
          elevated: true,
          opacity: 0.9,
          padding: const EdgeInsets.all(12.0),
          useGlass: true,
        );
        
      case BondCardVariant.meeting:
        return _BondCardVariantStyle(
          backgroundColor: isDarkMode 
              ? BondColors.darkBackground.withOpacity(0.7)
              : Colors.white.withOpacity(0.9),
          borderColor: BondColors.secondary.withOpacity(0.3),
          borderRadius: 14.0,
          elevated: true,
          opacity: 0.9,
          padding: const EdgeInsets.all(16.0),
          useGlass: true,
        );
        
      case BondCardVariant.profile:
        return _BondCardVariantStyle(
          backgroundColor: isDarkMode 
              ? BondColors.darkBackground.withOpacity(0.6)
              : Colors.white.withOpacity(0.8),
          borderColor: BondColors.primary.withOpacity(0.3),
          borderRadius: 16.0,
          elevated: true,
          opacity: 0.9,
          padding: const EdgeInsets.all(16.0),
          useGlass: true,
          decorator: (Widget child) {
            // Add subtle gradient overlay to profile cards
            return Stack(
              children: [
                child,
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        colors: [
                          BondColors.primary.withOpacity(0.15),
                          Colors.transparent,
                        ],
                        radius: 0.7,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        );
        
      case BondCardVariant.notification:
        return _BondCardVariantStyle(
          backgroundColor: isDarkMode 
              ? BondColors.darkBackground.withOpacity(0.6)
              : Colors.white.withOpacity(0.8),
          borderColor: Colors.transparent,
          borderRadius: 10.0,
          elevated: false,
          opacity: 0.9,
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
          useGlass: false,
        );
        
      case BondCardVariant.verification:
        return _BondCardVariantStyle(
          backgroundColor: isDarkMode 
              ? BondColors.darkBackground.withOpacity(0.7)
              : Colors.white.withOpacity(0.9),
          borderColor: BondColors.info.withOpacity(0.3),
          borderRadius: 20.0,
          elevated: true,
          opacity: 1.0,
          padding: const EdgeInsets.all(24.0),
          useGlass: true,
        );
        
      case BondCardVariant.standard:
      default:
        return _BondCardVariantStyle(
          backgroundColor: null,
          borderColor: null,
          borderRadius: null,
          elevated: null,
          opacity: null,
          padding: null,
          useGlass: null,
        );
    }
  }
}

/// Helper class for storing variant-specific styling
class _BondCardVariantStyle {
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderRadius;
  final bool? elevated;
  final double? opacity;
  final EdgeInsetsGeometry? padding;
  final bool? useGlass;
  final Widget Function(Widget child)? decorator;

  _BondCardVariantStyle({
    this.backgroundColor,
    this.borderColor,
    this.borderRadius,
    this.elevated,
    this.opacity,
    this.padding,
    this.useGlass,
    this.decorator,
  });
}
