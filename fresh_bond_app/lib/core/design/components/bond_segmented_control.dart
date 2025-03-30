import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';
import '../bond_design_system.dart';

/// Segmented control variants
enum BondSegmentedControlVariant {
  /// Standard segmented control
  standard,
  
  /// Outlined segmented control
  outlined,
  
  /// Glass effect segmented control
  glass,
}

/// A customizable segmented control component implementing the Bond Design System
///
/// Features:
/// - Multiple variants: standard, outlined, glass
/// - Support for icons and text
/// - Customizable appearance and animations
/// - Haptic feedback on selection
class BondSegmentedControl<T> extends StatefulWidget {
  /// Segments to display
  final List<BondSegment<T>> segments;
  
  /// Currently selected value
  final T selectedValue;
  
  /// Callback when a segment is selected
  final ValueChanged<T> onSegmentSelected;
  
  /// Variant of the segmented control
  final BondSegmentedControlVariant variant;
  
  /// Whether to use haptic feedback
  final bool useHapticFeedback;
  
  /// Background color of the segmented control
  final Color? backgroundColor;
  
  /// Selected segment color
  final Color? selectedColor;
  
  /// Border color of the segmented control
  final Color? borderColor;
  
  /// Text color of the selected segment
  final Color? selectedTextColor;
  
  /// Text color of unselected segments
  final Color? unselectedTextColor;
  
  /// Border radius of the segmented control
  final double? borderRadius;
  
  /// Animation duration
  final Duration animationDuration;

  /// Constructor
  const BondSegmentedControl({
    Key? key,
    required this.segments,
    required this.selectedValue,
    required this.onSegmentSelected,
    this.variant = BondSegmentedControlVariant.standard,
    this.useHapticFeedback = true,
    this.backgroundColor,
    this.selectedColor,
    this.borderColor,
    this.selectedTextColor,
    this.unselectedTextColor,
    this.borderRadius,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<BondSegmentedControl<T>> createState() => _BondSegmentedControlState<T>();
}

class _BondSegmentedControlState<T> extends State<BondSegmentedControl<T>> {
  int _selectedIndex = 0;
  
  @override
  void initState() {
    super.initState();
    _updateSelectedIndex();
  }
  
  @override
  void didUpdateWidget(BondSegmentedControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedValue != widget.selectedValue) {
      _updateSelectedIndex();
    }
  }
  
  void _updateSelectedIndex() {
    for (int i = 0; i < widget.segments.length; i++) {
      if (widget.segments[i].value == widget.selectedValue) {
        _selectedIndex = i;
        break;
      }
    }
  }
  
  void _handleSegmentSelected(int index) {
    if (index == _selectedIndex) return;
    
    if (widget.useHapticFeedback) {
      // Add haptic feedback
      HapticFeedback.selectionClick();
    }
    
    widget.onSegmentSelected(widget.segments[index].value);
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors
    final Color bgColor = widget.backgroundColor ?? 
        (isDark ? BondColors.night : Colors.white);
    final Color selectedColor = widget.selectedColor ?? 
        (isDark ? BondColors.bondTeal.withOpacity(0.3) : BondColors.bondTeal.withOpacity(0.1));
    final Color borderColor = widget.borderColor ?? 
        (isDark ? Colors.white.withOpacity(0.2) : BondColors.cloud);
    final Color selectedTextColor = widget.selectedTextColor ?? 
        (isDark ? Colors.white : BondColors.bondTeal);
    final Color unselectedTextColor = widget.unselectedTextColor ?? 
        (isDark ? Colors.white.withOpacity(0.7) : BondColors.slate);
    
    // Determine border radius
    final double radius = widget.borderRadius ?? BondDesignSystem.tokens.radiusM;
    
    // Build the segmented control based on variant
    switch (widget.variant) {
      case BondSegmentedControlVariant.outlined:
        return _buildOutlinedSegmentedControl(
          context,
          bgColor,
          selectedColor,
          borderColor,
          selectedTextColor,
          unselectedTextColor,
          radius,
        );
        
      case BondSegmentedControlVariant.glass:
        return _buildGlassSegmentedControl(
          context,
          bgColor,
          selectedColor,
          borderColor,
          selectedTextColor,
          unselectedTextColor,
          radius,
        );
        
      case BondSegmentedControlVariant.standard:
      default:
        return _buildStandardSegmentedControl(
          context,
          bgColor,
          selectedColor,
          borderColor,
          selectedTextColor,
          unselectedTextColor,
          radius,
        );
    }
  }
  
  /// Build a standard segmented control
  Widget _buildStandardSegmentedControl(
    BuildContext context,
    Color bgColor,
    Color selectedColor,
    Color borderColor,
    Color selectedTextColor,
    Color unselectedTextColor,
    double radius,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Stack(
          children: [
            // Segments
            Row(
              children: _buildSegments(
                selectedTextColor,
                unselectedTextColor,
              ),
            ),
            
            // Selection indicator
            AnimatedPositioned(
              duration: widget.animationDuration,
              curve: Curves.easeInOut,
              left: _selectedIndex * (MediaQuery.of(context).size.width - 8) / widget.segments.length,
              top: 0,
              bottom: 0,
              width: (MediaQuery.of(context).size.width - 8) / widget.segments.length,
              child: Container(
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(radius - 2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build an outlined segmented control
  Widget _buildOutlinedSegmentedControl(
    BuildContext context,
    Color bgColor,
    Color selectedColor,
    Color borderColor,
    Color selectedTextColor,
    Color unselectedTextColor,
    double radius,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Stack(
          children: [
            // Segments
            Row(
              children: _buildSegments(
                selectedTextColor,
                unselectedTextColor,
              ),
            ),
            
            // Selection indicator
            AnimatedPositioned(
              duration: widget.animationDuration,
              curve: Curves.easeInOut,
              left: _selectedIndex * (MediaQuery.of(context).size.width - 4) / widget.segments.length,
              top: 0,
              bottom: 0,
              width: (MediaQuery.of(context).size.width - 4) / widget.segments.length,
              child: Container(
                decoration: BoxDecoration(
                  color: selectedColor,
                  borderRadius: BorderRadius.circular(radius - 3),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// Build a glass segmented control
  Widget _buildGlassSegmentedControl(
    BuildContext context,
    Color bgColor,
    Color selectedColor,
    Color borderColor,
    Color selectedTextColor,
    Color unselectedTextColor,
    double radius,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.5),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(
              color: borderColor.withOpacity(0.3),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Stack(
              children: [
                // Segments
                Row(
                  children: _buildSegments(
                    selectedTextColor,
                    unselectedTextColor,
                  ),
                ),
                
                // Selection indicator
                AnimatedPositioned(
                  duration: widget.animationDuration,
                  curve: Curves.easeInOut,
                  left: _selectedIndex * (MediaQuery.of(context).size.width - 8) / widget.segments.length,
                  top: 0,
                  bottom: 0,
                  width: (MediaQuery.of(context).size.width - 8) / widget.segments.length,
                  child: Container(
                    decoration: BoxDecoration(
                      color: selectedColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(radius - 2),
                      boxShadow: [
                        BoxShadow(
                          color: selectedColor.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        ),
                      ],
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
  
  /// Build segments
  List<Widget> _buildSegments(
    Color selectedTextColor,
    Color unselectedTextColor,
  ) {
    return List.generate(
      widget.segments.length,
      (index) {
        final BondSegment<T> segment = widget.segments[index];
        final bool isSelected = index == _selectedIndex;
        final Color textColor = isSelected ? selectedTextColor : unselectedTextColor;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => _handleSegmentSelected(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (segment.icon != null) ...[
                      Icon(
                        segment.icon,
                        size: 18,
                        color: textColor,
                      ),
                      const SizedBox(width: 6),
                    ],
                    Text(
                      segment.label,
                      style: BondTypography.button(context).copyWith(
                        color: textColor,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Segment for the segmented control
class BondSegment<T> {
  /// Label for the segment
  final String label;
  
  /// Value of the segment
  final T value;
  
  /// Icon for the segment
  final IconData? icon;
  
  /// Constructor
  const BondSegment({
    required this.label,
    required this.value,
    this.icon,
  });
}
