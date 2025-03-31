import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';

/// Background gradient types for the Bond app
enum BondGradientType {
  /// Primary gradient (teal to purple)
  primary,

  /// Secondary gradient (purple to orange)
  secondary,

  /// Dark gradient for dark theme
  dark,

  /// Light gradient for light theme
  light,

  /// Special gradient for profiles
  profile,

  /// Gradient for meetings feature
  meetings,
}

/// A background component with optional gradient and noise texture overlay
/// for consistent background treatment across the app.
class BondBackground extends StatelessWidget {
  /// The child widget to display on top of the background
  final Widget child;
  
  /// Whether to use a gradient background
  final bool useGradient;
  
  /// Whether to add a noise texture overlay
  final bool useNoise;
  
  /// The gradient type to use
  final BondGradientType gradientType;
  
  /// A custom gradient to use instead of the predefined ones
  final Gradient? customGradient;
  
  /// The opacity of the noise texture
  final double noiseOpacity;

  /// Default constructor
  const BondBackground({
    Key? key,
    required this.child,
    this.useGradient = true,
    this.useNoise = true,
    this.gradientType = BondGradientType.primary,
    this.customGradient,
    this.noiseOpacity = 0.03,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get the appropriate gradient based on type and theme
    final gradient = customGradient ?? _getGradientByType(gradientType, isDarkMode);
    
    return Container(
      decoration: BoxDecoration(
        gradient: useGradient ? gradient : null,
        color: useGradient 
            ? null 
            : (isDarkMode ? BondColors.darkBackground : Colors.white),
      ),
      child: Stack(
        children: [
          // Child content
          child,
          
          // Noise texture overlay
          if (useNoise)
            Positioned.fill(
              child: Opacity(
                opacity: noiseOpacity,
                child: Image.asset(
                  'assets/images/noise_texture.png',
                  repeat: ImageRepeat.repeat,
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
  
  /// Get gradient based on type and theme
  Gradient _getGradientByType(BondGradientType type, bool isDarkMode) {
    switch (type) {
      case BondGradientType.primary:
        return BondColors.primaryGradient;
        
      case BondGradientType.secondary:
        return BondColors.secondaryGradient;
        
      case BondGradientType.dark:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF1A1E2F),
            const Color(0xFF121623),
          ],
        );
        
      case BondGradientType.light:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            const Color(0xFFF8F9FD),
          ],
        );
        
      case BondGradientType.profile:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode 
              ? [
                  const Color(0xFF252A44),
                  const Color(0xFF191C2E),
                ] 
              : [
                  BondColors.primary.withOpacity(0.1),
                  Colors.white,
                ],
        );
        
      case BondGradientType.meetings:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDarkMode 
              ? [
                  const Color(0xFF272C45),
                  const Color(0xFF1A1F30),
                ] 
              : [
                  BondColors.secondary.withOpacity(0.1),
                  Colors.white,
                ],
        );
    }
  }
}

/// Extension methods for BondBackground to make it easier to use
extension BondBackgroundExtension on Widget {
  /// Wrap this widget with a BondBackground
  Widget withBondBackground({
    bool useGradient = true,
    bool useNoise = true,
    BondGradientType gradientType = BondGradientType.primary,
    Gradient? customGradient,
    double noiseOpacity = 0.03,
  }) {
    return BondBackground(
      useGradient: useGradient,
      useNoise: useNoise,
      gradientType: gradientType,
      customGradient: customGradient,
      noiseOpacity: noiseOpacity,
      child: this,
    );
  }
}