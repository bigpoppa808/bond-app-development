import 'package:flutter/material.dart';

/// A responsive grid layout system inspired by Japanese bento boxes.
///
/// The BondBentoGrid creates a modular, grid-based layout system that allows
/// for flexible component organization with consistent spacing. The grid adapts
/// to different screen sizes automatically.
class BondBentoGrid extends StatelessWidget {
  /// The list of children to display in the grid
  final List<Widget> children;
  
  /// The space between each grid item
  final double spacing;
  
  /// The number of columns to display on mobile devices
  final int mobileColumns;
  
  /// The number of columns to display on tablet devices
  final int tabletColumns;
  
  /// The number of columns to display on desktop devices
  final int desktopColumns;
  
  /// Padding around the entire grid
  final EdgeInsetsGeometry padding;
  
  /// Minimum width threshold for tablet layout
  final double tabletBreakpoint;
  
  /// Minimum width threshold for desktop layout
  final double desktopBreakpoint;

  const BondBentoGrid({
    Key? key,
    required this.children,
    this.spacing = 16.0,
    this.mobileColumns = 1,
    this.tabletColumns = 2,
    this.desktopColumns = 3,
    this.padding = EdgeInsets.zero,
    this.tabletBreakpoint = 600.0,
    this.desktopBreakpoint = 900.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the number of columns based on screen width
        final currentWidth = constraints.maxWidth;
        int columns;
        
        if (currentWidth >= desktopBreakpoint) {
          columns = desktopColumns;
        } else if (currentWidth >= tabletBreakpoint) {
          columns = tabletColumns;
        } else {
          columns = mobileColumns;
        }
        
        return Padding(
          padding: padding,
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: columns,
              crossAxisSpacing: spacing,
              mainAxisSpacing: spacing,
              // Allow children to have different heights
              childAspectRatio: 1.0,
              mainAxisExtent: null,
            ),
            itemCount: children.length,
            itemBuilder: (context, index) => children[index],
          ),
        );
      },
    );
  }
}

/// A bento box grid item that can span multiple columns or rows
class BondBentoItem extends StatelessWidget {
  /// The content to display in the grid item
  final Widget child;
  
  /// The number of columns this item should span (1-based)
  final int columnSpan;
  
  /// The number of rows this item should span (1-based)
  final int rowSpan;
  
  /// The aspect ratio of the item (width / height)
  final double aspectRatio;
  
  /// The minimum height of the item
  final double minHeight;
  
  /// Whether to make the item fill the available space
  final bool fillSpace;

  const BondBentoItem({
    Key? key,
    required this.child,
    this.columnSpan = 1,
    this.rowSpan = 1,
    this.aspectRatio = 1.0,
    this.minHeight = 100.0,
    this.fillSpace = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (fillSpace) {
      return SizedBox(
        height: minHeight * rowSpan,
        child: child,
      );
    }
    
    return AspectRatio(
      aspectRatio: aspectRatio * columnSpan / rowSpan,
      child: child,
    );
  }
}

/// A layout that combines fixed and flexible bento grid items
///
/// This complex layout combines the concept of a bento box grid with
/// the flexibility of custom positioning to create visually interesting
/// yet organized layouts.
class BondBentoLayout extends StatelessWidget {
  /// The items to display in the layout
  final List<Widget> children;
  
  /// The layout configuration for different screen sizes
  final Map<BentoLayoutSize, BentoLayoutConfig> layoutConfigs;
  
  /// Spacing between items
  final double spacing;
  
  /// Padding around the entire layout
  final EdgeInsetsGeometry padding;

  const BondBentoLayout({
    Key? key,
    required this.children,
    required this.layoutConfigs,
    this.spacing = 16.0,
    this.padding = EdgeInsets.zero,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Determine the current layout size
        final currentWidth = constraints.maxWidth;
        BentoLayoutSize currentSize;
        
        if (currentWidth >= 1200.0) {
          currentSize = BentoLayoutSize.large;
        } else if (currentWidth >= 800.0) {
          currentSize = BentoLayoutSize.medium;
        } else {
          currentSize = BentoLayoutSize.small;
        }
        
        // Get the appropriate layout config or fall back to small
        final config = layoutConfigs[currentSize] ?? 
                       layoutConfigs[BentoLayoutSize.small]!;
        
        return Padding(
          padding: padding,
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Stack(
                  children: [
                    // Create the grid based on the config
                    for (final item in config.items.asMap().entries)
                      if (item.key < children.length)
                        Positioned(
                          left: item.value.left,
                          top: item.value.top,
                          width: item.value.width,
                          height: item.value.height,
                          child: Padding(
                            padding: EdgeInsets.all(spacing / 2),
                            child: children[item.key],
                          ),
                        ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Screen size categories for bento layouts
enum BentoLayoutSize {
  small,
  medium,
  large,
}

/// Configuration for a specific bento layout size
class BentoLayoutConfig {
  final List<BentoItemPosition> items;
  final double totalHeight;

  BentoLayoutConfig({
    required this.items,
    required this.totalHeight,
  });
}

/// Position and size information for a bento item
class BentoItemPosition {
  final double left;
  final double top;
  final double width;
  final double height;

  BentoItemPosition({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  });
}
