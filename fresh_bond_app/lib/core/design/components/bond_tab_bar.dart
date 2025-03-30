import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';
import '../bond_design_system.dart';

/// Tab bar variants
enum BondTabBarVariant {
  /// Standard tab bar with underline indicator
  standard,
  
  /// Pill-shaped tab bar with background indicator
  pill,
  
  /// Glass effect tab bar
  glass,
}

/// A customizable tab bar component implementing the Bond Design System
///
/// Features:
/// - Multiple variants: standard, pill, glass
/// - Customizable appearance and animations
/// - Support for icons and badges
/// - Haptic feedback on tab changes
class BondTabBar extends StatefulWidget {
  /// Tab items
  final List<BondTabItem> tabs;
  
  /// Current selected tab index
  final int currentIndex;
  
  /// Callback when a tab is selected
  final ValueChanged<int> onTabSelected;
  
  /// Tab bar variant
  final BondTabBarVariant variant;
  
  /// Whether to use haptic feedback
  final bool useHapticFeedback;
  
  /// Whether to scroll horizontally
  final bool isScrollable;
  
  /// Background color of the tab bar
  final Color? backgroundColor;
  
  /// Indicator color
  final Color? indicatorColor;
  
  /// Selected tab color
  final Color? selectedColor;
  
  /// Unselected tab color
  final Color? unselectedColor;
  
  /// Padding around the tab bar
  final EdgeInsetsGeometry padding;
  
  /// Height of the tab bar
  final double height;
  
  /// Animation duration
  final Duration animationDuration;

  /// Constructor
  const BondTabBar({
    Key? key,
    required this.tabs,
    required this.currentIndex,
    required this.onTabSelected,
    this.variant = BondTabBarVariant.standard,
    this.useHapticFeedback = true,
    this.isScrollable = false,
    this.backgroundColor,
    this.indicatorColor,
    this.selectedColor,
    this.unselectedColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
    this.height = 48,
    this.animationDuration = const Duration(milliseconds: 200),
  }) : super(key: key);

  @override
  State<BondTabBar> createState() => _BondTabBarState();
}

class _BondTabBarState extends State<BondTabBar> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late ScrollController _scrollController;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _scrollController = ScrollController();
    
    // Start with the animation at the current index
    _animationController.value = 1.0;
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  @override
  void didUpdateWidget(BondTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // If the current index changed, animate the indicator
    if (oldWidget.currentIndex != widget.currentIndex) {
      _animationController.forward(from: 0.0);
    }
  }
  
  void _handleTabSelected(int index) {
    if (index == widget.currentIndex) return;
    
    if (widget.useHapticFeedback) {
      // Add haptic feedback
      HapticFeedback.selectionClick();
    }
    
    widget.onTabSelected(index);
    
    // Scroll to the selected tab if needed
    if (widget.isScrollable) {
      final double screenWidth = MediaQuery.of(context).size.width;
      final double tabWidth = screenWidth / widget.tabs.length;
      final double offset = (index * tabWidth) - (screenWidth / 2) + (tabWidth / 2);
      
      _scrollController.animateTo(
        offset.clamp(0.0, _scrollController.position.maxScrollExtent),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors
    final Color bgColor = widget.backgroundColor ?? Colors.transparent;
    final Color indicatorColor = widget.indicatorColor ?? BondColors.bondTeal;
    final Color selectedColor = widget.selectedColor ?? 
        (isDark ? Colors.white : BondColors.slate);
    final Color unselectedColor = widget.unselectedColor ?? 
        (isDark ? Colors.white.withOpacity(0.6) : BondColors.slate.withOpacity(0.6));
    
    // Build the tab bar based on variant
    Widget tabBar;
    switch (widget.variant) {
      case BondTabBarVariant.pill:
        tabBar = _buildPillTabBar(
          context,
          bgColor,
          indicatorColor,
          selectedColor,
          unselectedColor,
        );
        break;
        
      case BondTabBarVariant.glass:
        tabBar = _buildGlassTabBar(
          context,
          bgColor,
          indicatorColor,
          selectedColor,
          unselectedColor,
        );
        break;
        
      case BondTabBarVariant.standard:
      default:
        tabBar = _buildStandardTabBar(
          context,
          bgColor,
          indicatorColor,
          selectedColor,
          unselectedColor,
        );
        break;
    }
    
    return SizedBox(
      height: widget.height,
      child: tabBar,
    );
  }
  
  /// Build a standard tab bar with underline indicator
  Widget _buildStandardTabBar(
    BuildContext context,
    Color bgColor,
    Color indicatorColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    return Container(
      color: bgColor,
      child: Stack(
        children: [
          // Tabs
          Padding(
            padding: widget.padding,
            child: Row(
              children: _buildTabItems(
                selectedColor,
                unselectedColor,
              ),
            ),
          ),
          
          // Indicator
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildUnderlineIndicator(indicatorColor),
          ),
        ],
      ),
    );
  }
  
  /// Build a pill-shaped tab bar
  Widget _buildPillTabBar(
    BuildContext context,
    Color bgColor,
    Color indicatorColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    return Container(
      padding: widget.padding,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(widget.height / 2),
      ),
      child: Stack(
        children: [
          // Tabs
          Row(
            children: _buildTabItems(
              selectedColor,
              unselectedColor,
            ),
          ),
          
          // Pill indicator
          AnimatedPositioned(
            duration: widget.animationDuration,
            curve: Curves.easeInOut,
            left: widget.currentIndex * (MediaQuery.of(context).size.width - widget.padding.horizontal) / widget.tabs.length,
            top: 4,
            bottom: 4,
            width: (MediaQuery.of(context).size.width - widget.padding.horizontal) / widget.tabs.length,
            child: Container(
              decoration: BoxDecoration(
                color: indicatorColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular((widget.height - 8) / 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  /// Build a glass effect tab bar
  Widget _buildGlassTabBar(
    BuildContext context,
    Color bgColor,
    Color indicatorColor,
    Color selectedColor,
    Color unselectedColor,
  ) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(widget.height / 2),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: widget.padding,
          decoration: BoxDecoration(
            color: bgColor.withOpacity(0.7),
            borderRadius: BorderRadius.circular(widget.height / 2),
            border: Border.all(
              color: Colors.white.withOpacity(0.1),
            ),
          ),
          child: Stack(
            children: [
              // Tabs
              Row(
                children: _buildTabItems(
                  selectedColor,
                  unselectedColor,
                ),
              ),
              
              // Glass indicator
              AnimatedPositioned(
                duration: widget.animationDuration,
                curve: Curves.easeInOut,
                left: widget.currentIndex * (MediaQuery.of(context).size.width - widget.padding.horizontal) / widget.tabs.length,
                top: 4,
                bottom: 4,
                width: (MediaQuery.of(context).size.width - widget.padding.horizontal) / widget.tabs.length,
                child: Container(
                  decoration: BoxDecoration(
                    color: indicatorColor.withOpacity(0.3),
                    borderRadius: BorderRadius.circular((widget.height - 8) / 2),
                    boxShadow: [
                      BoxShadow(
                        color: indicatorColor.withOpacity(0.2),
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
    );
  }
  
  /// Build tab items
  List<Widget> _buildTabItems(
    Color selectedColor,
    Color unselectedColor,
  ) {
    return List.generate(
      widget.tabs.length,
      (index) {
        final BondTabItem tab = widget.tabs[index];
        final bool isSelected = index == widget.currentIndex;
        final Color color = isSelected ? selectedColor : unselectedColor;
        
        return Expanded(
          child: GestureDetector(
            onTap: () => _handleTabSelected(index),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: widget.height,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (tab.icon != null) ...[
                      Icon(
                        tab.icon,
                        size: 20,
                        color: color,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      tab.label,
                      style: BondTypography.button(context).copyWith(
                        color: color,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (tab.badgeCount != null && tab.badgeCount! > 0) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: BondColors.error,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          tab.badgeCount! > 99 ? '99+' : tab.badgeCount.toString(),
                          style: BondTypography.caption(context).copyWith(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
  
  /// Build underline indicator
  Widget _buildUnderlineIndicator(Color indicatorColor) {
    return AnimatedPositioned(
      duration: widget.animationDuration,
      curve: Curves.easeInOut,
      left: widget.currentIndex * (MediaQuery.of(context).size.width - widget.padding.horizontal) / widget.tabs.length + widget.padding.horizontal / 2,
      bottom: 0,
      width: (MediaQuery.of(context).size.width - widget.padding.horizontal) / widget.tabs.length,
      height: 3,
      child: Container(
        decoration: BoxDecoration(
          color: indicatorColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(3)),
        ),
      ),
    );
  }
}

/// Tab item for the tab bar
class BondTabItem {
  /// Label for the tab
  final String label;
  
  /// Icon for the tab
  final IconData? icon;
  
  /// Badge count to display
  final int? badgeCount;
  
  /// Constructor
  const BondTabItem({
    required this.label,
    this.icon,
    this.badgeCount,
  });
}
