import 'dart:ui';
import 'package:flutter/material.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';
import '../bond_design_system.dart';

/// Progress indicator variants
enum BondProgressVariant {
  /// Circular progress indicator
  circular,
  
  /// Linear progress indicator
  linear,
  
  /// Stepped progress indicator
  stepped,
}

/// Progress indicator sizes
enum BondProgressSize {
  /// Small progress indicator
  small,
  
  /// Medium progress indicator
  medium,
  
  /// Large progress indicator
  large,
}

/// A customizable progress indicator component implementing the Bond Design System
///
/// Features:
/// - Multiple variants: circular, linear, stepped
/// - Customizable colors and sizes
/// - Optional label and percentage display
/// - Glass effect option
class BondProgressIndicator extends StatelessWidget {
  /// Current value of the progress (0.0 to 1.0)
  final double value;
  
  /// Variant of the progress indicator
  final BondProgressVariant variant;
  
  /// Size of the progress indicator
  final BondProgressSize size;
  
  /// Color of the progress indicator
  final Color? color;
  
  /// Background color of the progress indicator
  final Color? backgroundColor;
  
  /// Label to display with the progress indicator
  final String? label;
  
  /// Whether to show the percentage
  final bool showPercentage;
  
  /// Whether to use glass effect
  final bool useGlassEffect;
  
  /// Number of steps for stepped variant
  final int steps;
  
  /// Whether the progress is indeterminate
  final bool isIndeterminate;
  
  /// Animation duration for indeterminate progress
  final Duration animationDuration;

  /// Constructor
  const BondProgressIndicator({
    Key? key,
    this.value = 0.0,
    this.variant = BondProgressVariant.circular,
    this.size = BondProgressSize.medium,
    this.color,
    this.backgroundColor,
    this.label,
    this.showPercentage = false,
    this.useGlassEffect = false,
    this.steps = 5,
    this.isIndeterminate = false,
    this.animationDuration = const Duration(milliseconds: 1500),
  }) : assert(
         value >= 0.0 && value <= 1.0,
         'Value must be between 0.0 and 1.0',
       ),
       assert(
         steps >= 2,
         'Steps must be at least 2',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors
    final Color progressColor = color ?? BondColors.bondTeal;
    final Color bgColor = backgroundColor ?? 
        (isDark ? Colors.white.withOpacity(0.2) : Colors.grey.withOpacity(0.2));
    
    // Build the progress indicator based on variant
    Widget progressIndicator;
    switch (variant) {
      case BondProgressVariant.linear:
        progressIndicator = _buildLinearProgress(
          context,
          progressColor,
          bgColor,
        );
        break;
        
      case BondProgressVariant.stepped:
        progressIndicator = _buildSteppedProgress(
          context,
          progressColor,
          bgColor,
        );
        break;
        
      case BondProgressVariant.circular:
      default:
        progressIndicator = _buildCircularProgress(
          context,
          progressColor,
          bgColor,
        );
        break;
    }
    
    // Apply glass effect if needed
    if (useGlassEffect) {
      progressIndicator = ClipRRect(
        borderRadius: BorderRadius.circular(
          variant == BondProgressVariant.circular ? _getSize() / 2 : BondDesignSystem.tokens.radiusS,
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: progressIndicator,
        ),
      );
    }
    
    // Add label if provided
    if (label != null || showPercentage) {
      final String displayText = label ?? '';
      final String percentageText = showPercentage ? '${(value * 100).toInt()}%' : '';
      final String combinedText = label != null && showPercentage 
          ? '$displayText: $percentageText' 
          : displayText + percentageText;
      
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          progressIndicator,
          if (combinedText.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              combinedText,
              style: BondTypography.caption(context),
            ),
          ],
        ],
      );
    }
    
    return progressIndicator;
  }
  
  /// Build a circular progress indicator
  Widget _buildCircularProgress(
    BuildContext context,
    Color progressColor,
    Color bgColor,
  ) {
    final double size = _getSize();
    
    if (isIndeterminate) {
      return SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          backgroundColor: bgColor,
          strokeWidth: _getStrokeWidth(),
        ),
      );
    }
    
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          CircularProgressIndicator(
            value: 1.0,
            valueColor: AlwaysStoppedAnimation<Color>(bgColor),
            strokeWidth: _getStrokeWidth(),
          ),
          
          // Progress circle
          CircularProgressIndicator(
            value: value,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            strokeWidth: _getStrokeWidth(),
          ),
          
          // Percentage text
          if (showPercentage && variant == BondProgressVariant.circular) ...[
            Text(
              '${(value * 100).toInt()}%',
              style: BondTypography.caption(context).copyWith(
                fontWeight: FontWeight.bold,
                fontSize: size / 4,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Build a linear progress indicator
  Widget _buildLinearProgress(
    BuildContext context,
    Color progressColor,
    Color bgColor,
  ) {
    final double height = _getLinearHeight();
    
    if (isIndeterminate) {
      return SizedBox(
        height: height,
        width: double.infinity,
        child: LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(progressColor),
          backgroundColor: bgColor,
        ),
      );
    }
    
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(height / 2),
      ),
      child: Stack(
        children: [
          // Progress bar
          FractionallySizedBox(
            widthFactor: value,
            child: Container(
              decoration: BoxDecoration(
                color: progressColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ),
          
          // Percentage text
          if (showPercentage && variant == BondProgressVariant.linear) ...[
            Center(
              child: Text(
                '${(value * 100).toInt()}%',
                style: BondTypography.caption(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: height * 0.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Build a stepped progress indicator
  Widget _buildSteppedProgress(
    BuildContext context,
    Color progressColor,
    Color bgColor,
  ) {
    final double height = _getLinearHeight();
    final int completedSteps = (value * steps).floor();
    
    return SizedBox(
      height: height,
      child: Row(
        children: List.generate(
          steps,
          (index) {
            final bool isCompleted = index < completedSteps;
            final bool isActive = index == completedSteps && value * steps > completedSteps;
            
            return Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  color: isCompleted 
                      ? progressColor 
                      : (isActive ? progressColor.withOpacity(0.5) : bgColor),
                  borderRadius: BorderRadius.circular(height / 2),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  
  /// Get the size of the circular progress indicator
  double _getSize() {
    switch (size) {
      case BondProgressSize.small:
        return 24.0;
      case BondProgressSize.large:
        return 64.0;
      case BondProgressSize.medium:
      default:
        return 40.0;
    }
  }
  
  /// Get the stroke width of the circular progress indicator
  double _getStrokeWidth() {
    switch (size) {
      case BondProgressSize.small:
        return 2.5;
      case BondProgressSize.large:
        return 6.0;
      case BondProgressSize.medium:
      default:
        return 4.0;
    }
  }
  
  /// Get the height of the linear progress indicator
  double _getLinearHeight() {
    switch (size) {
      case BondProgressSize.small:
        return 4.0;
      case BondProgressSize.large:
        return 12.0;
      case BondProgressSize.medium:
      default:
        return 8.0;
    }
  }
}
