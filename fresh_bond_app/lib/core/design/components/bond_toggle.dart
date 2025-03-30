import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bond_colors.dart';
import '../bond_design_system.dart';
import '../bond_typography.dart';

/// A customizable toggle switch component implementing the Bond Design System
///
/// Features:
/// - Modern design with smooth animations
/// - Optional label
/// - Customizable colors
/// - Haptic feedback
class BondToggle extends StatefulWidget {
  /// Whether the toggle is on
  final bool value;
  
  /// Callback when the toggle is changed
  final ValueChanged<bool> onChanged;
  
  /// Label to display next to the toggle
  final String? label;
  
  /// Whether the label is on the left side
  final bool labelLeft;
  
  /// Whether the toggle is enabled
  final bool enabled;
  
  /// Active color when toggle is on
  final Color? activeColor;
  
  /// Inactive color when toggle is off
  final Color? inactiveColor;
  
  /// Thumb color
  final Color? thumbColor;
  
  /// Whether to use haptic feedback
  final bool useHapticFeedback;
  
  /// Size of the toggle
  final BondToggleSize size;

  /// Constructor
  const BondToggle({
    Key? key,
    required this.value,
    required this.onChanged,
    this.label,
    this.labelLeft = true,
    this.enabled = true,
    this.activeColor,
    this.inactiveColor,
    this.thumbColor,
    this.useHapticFeedback = true,
    this.size = BondToggleSize.medium,
  }) : super(key: key);

  @override
  State<BondToggle> createState() => _BondToggleState();
}

/// Toggle sizes
enum BondToggleSize {
  /// Small toggle
  small,
  
  /// Medium toggle
  medium,
  
  /// Large toggle
  large
}

class _BondToggleState extends State<BondToggle> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: BondDesignSystem.tokens.durationFast,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    if (widget.value) {
      _animationController.value = 1.0;
    }
  }
  
  @override
  void didUpdateWidget(BondToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      if (widget.value) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    if (!widget.enabled) return;
    
    if (widget.useHapticFeedback) {
      // Add haptic feedback
      HapticFeedback.lightImpact();
    }
    
    widget.onChanged(!widget.value);
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Get dimensions based on size
    final ToggleDimensions dimensions = _getDimensions();
    
    // Determine colors
    final Color activeColor = widget.activeColor ?? BondColors.bondTeal;
    final Color inactiveColor = widget.inactiveColor ?? 
        (isDark ? BondColors.slate.withOpacity(0.5) : BondColors.cloud);
    final Color thumbColor = widget.thumbColor ?? Colors.white;
    
    // Build the toggle switch
    final Widget toggle = GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: dimensions.width,
              minHeight: dimensions.height,
            ),
            child: Container(
              width: dimensions.width,
              height: dimensions.height,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(dimensions.height / 2),
                color: Color.lerp(inactiveColor, activeColor, _animation.value),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: _animation.value * (dimensions.width - dimensions.thumbSize - dimensions.padding * 2) + dimensions.padding,
                    top: dimensions.padding,
                    child: Container(
                      width: dimensions.thumbSize,
                      height: dimensions.thumbSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: widget.enabled ? thumbColor : thumbColor.withOpacity(0.7),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 2,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
    
    // If no label, just return the toggle
    if (widget.label == null) {
      return toggle;
    }
    
    // Build with label
    return Opacity(
      opacity: widget.enabled ? 1.0 : 0.5,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.labelLeft) ...[
            Text(
              widget.label!,
              style: BondTypography.body(context),
            ),
            SizedBox(width: dimensions.labelSpacing),
            toggle,
          ] else ...[
            toggle,
            SizedBox(width: dimensions.labelSpacing),
            Text(
              widget.label!,
              style: BondTypography.body(context),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Get dimensions based on size
  ToggleDimensions _getDimensions() {
    switch (widget.size) {
      case BondToggleSize.small:
        return const ToggleDimensions(
          width: 36,
          height: 20,
          thumbSize: 16,
          padding: 2,
          labelSpacing: 8,
        );
      case BondToggleSize.large:
        return const ToggleDimensions(
          width: 56,
          height: 30,
          thumbSize: 24,
          padding: 3,
          labelSpacing: 12,
        );
      case BondToggleSize.medium:
      default:
        return const ToggleDimensions(
          width: 46,
          height: 24,
          thumbSize: 20,
          padding: 2,
          labelSpacing: 10,
        );
    }
  }
}

/// Dimensions for the toggle switch
class ToggleDimensions {
  /// Width of the toggle
  final double width;
  
  /// Height of the toggle
  final double height;
  
  /// Size of the thumb
  final double thumbSize;
  
  /// Padding around the thumb
  final double padding;
  
  /// Spacing between label and toggle
  final double labelSpacing;
  
  const ToggleDimensions({
    required this.width,
    required this.height,
    required this.thumbSize,
    required this.padding,
    required this.labelSpacing,
  });
}
