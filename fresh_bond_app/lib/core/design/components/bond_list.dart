import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';
import '../bond_design_system.dart';

/// List item variants
enum BondListItemVariant {
  /// Standard list item
  standard,
  
  /// Card-style list item
  card,
  
  /// Glass effect list item
  glass,
}

/// A customizable list component implementing the Bond Design System
///
/// Features:
/// - Consistent styling with the Bond Design System
/// - Support for section headers and dividers
/// - Empty state handling
/// - Pull-to-refresh functionality
class BondList extends StatelessWidget {
  /// List items
  final List<Widget> children;
  
  /// Whether to show dividers between items
  final bool showDividers;
  
  /// Whether the list is scrollable
  final bool scrollable;
  
  /// Empty state widget to show when the list is empty
  final Widget? emptyStateWidget;
  
  /// Padding around the list
  final EdgeInsetsGeometry padding;
  
  /// Scroll physics
  final ScrollPhysics? physics;
  
  /// Refresh callback for pull-to-refresh
  final Future<void> Function()? onRefresh;
  
  /// Whether to shrink wrap the list
  final bool shrinkWrap;
  
  /// Scroll controller
  final ScrollController? controller;

  /// Constructor
  const BondList({
    Key? key,
    required this.children,
    this.showDividers = false,
    this.scrollable = true,
    this.emptyStateWidget,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
    this.physics,
    this.onRefresh,
    this.shrinkWrap = false,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If list is empty, show empty state
    if (children.isEmpty && emptyStateWidget != null) {
      return emptyStateWidget!;
    }
    
    // Build list items with optional dividers
    List<Widget> listItems = [];
    for (int i = 0; i < children.length; i++) {
      listItems.add(children[i]);
      
      // Add divider if needed (except after the last item)
      if (showDividers && i < children.length - 1) {
        listItems.add(const Divider(height: 1));
      }
    }
    
    // Build the list
    Widget list = ListView(
      padding: padding,
      physics: physics ?? (scrollable ? const AlwaysScrollableScrollPhysics() : const NeverScrollableScrollPhysics()),
      shrinkWrap: shrinkWrap,
      controller: controller,
      children: listItems,
    );
    
    // Add pull-to-refresh if needed
    if (onRefresh != null) {
      return RefreshIndicator(
        onRefresh: onRefresh!,
        color: BondColors.bondTeal,
        child: list,
      );
    }
    
    return list;
  }
  
  /// Create a section header for the list
  static Widget sectionHeader(
    BuildContext context, {
    required String title,
    Widget? trailing,
    EdgeInsetsGeometry padding = const EdgeInsets.fromLTRB(16, 24, 16, 8),
  }) {
    return Padding(
      padding: padding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: BondTypography.heading3(context),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }
  
  /// Create an empty state widget
  static Widget emptyState(
    BuildContext context, {
    required String message,
    IconData? icon,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 64,
                color: BondColors.slate.withOpacity(0.5),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              message,
              style: BondTypography.body(context).copyWith(
                color: BondColors.slate,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              TextButton(
                onPressed: onAction,
                child: Text(actionLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A customizable list item component implementing the Bond Design System
///
/// Features:
/// - Multiple variants: standard, card, glass
/// - Support for leading and trailing widgets
/// - Customizable content and styling
/// - Interactive feedback with haptic support
class BondListItem extends StatelessWidget {
  /// Title of the list item
  final String? title;
  
  /// Subtitle of the list item
  final String? subtitle;
  
  /// Leading widget (usually an icon or avatar)
  final Widget? leading;
  
  /// Trailing widget (usually an icon or button)
  final Widget? trailing;
  
  /// Custom content widget (used instead of title/subtitle)
  final Widget? content;
  
  /// Variant of the list item
  final BondListItemVariant variant;
  
  /// Whether the list item is enabled
  final bool enabled;
  
  /// Callback when the list item is tapped
  final VoidCallback? onTap;
  
  /// Callback when the list item is long-pressed
  final VoidCallback? onLongPress;
  
  /// Background color of the list item
  final Color? backgroundColor;
  
  /// Padding around the list item content
  final EdgeInsetsGeometry contentPadding;
  
  /// Whether to use haptic feedback on tap
  final bool useHapticFeedback;
  
  /// Whether to show a divider at the bottom
  final bool showDivider;

  /// Constructor
  const BondListItem({
    Key? key,
    this.title,
    this.subtitle,
    this.leading,
    this.trailing,
    this.content,
    this.variant = BondListItemVariant.standard,
    this.enabled = true,
    this.onTap,
    this.onLongPress,
    this.backgroundColor,
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.useHapticFeedback = true,
    this.showDivider = false,
  }) : assert(
         (title != null || content != null),
         'Either title or content must be provided',
       ),
       super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on variant
    final Color bgColor = _getBackgroundColor(isDark);
    
    // Handle tap with optional haptic feedback
    void _handleTap() {
      if (!enabled || onTap == null) return;
      
      if (useHapticFeedback) {
        // Add haptic feedback
        HapticFeedback.selectionClick();
      }
      
      onTap!();
    }
    
    // Build the content
    Widget itemContent;
    if (content != null) {
      // Use custom content
      itemContent = content!;
    } else {
      // Use title/subtitle
      itemContent = Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title!,
            style: BondTypography.body(context).copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              style: BondTypography.caption(context).copyWith(
                color: isDark ? BondColors.cloud : BondColors.slate,
              ),
            ),
          ],
        ],
      );
    }
    
    // Build the list item row
    Widget listItemRow = Row(
      children: [
        if (leading != null) ...[
          leading!,
          SizedBox(width: contentPadding.horizontal / 2),
        ],
        Expanded(child: itemContent),
        if (trailing != null) ...[
          SizedBox(width: contentPadding.horizontal / 2),
          trailing!,
        ],
      ],
    );
    
    // Apply padding
    listItemRow = Padding(
      padding: contentPadding,
      child: listItemRow,
    );
    
    // Apply variant-specific styling
    Widget styledItem;
    switch (variant) {
      case BondListItemVariant.card:
        styledItem = Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(BondDesignSystem.tokens.radiusM),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BondDesignSystem.tokens.radiusM),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: enabled ? _handleTap : null,
                onLongPress: enabled ? onLongPress : null,
                child: listItemRow,
              ),
            ),
          ),
        );
        break;
        
      case BondListItemVariant.glass:
        styledItem = Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(BondDesignSystem.tokens.radiusM),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: bgColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(BondDesignSystem.tokens.radiusM),
                  border: Border.all(
                    color: isDark 
                        ? Colors.white.withOpacity(0.1) 
                        : Colors.black.withOpacity(0.05),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: enabled ? _handleTap : null,
                    onLongPress: enabled ? onLongPress : null,
                    child: listItemRow,
                  ),
                ),
              ),
            ),
          ),
        );
        break;
        
      case BondListItemVariant.standard:
      default:
        styledItem = Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? _handleTap : null,
            onLongPress: enabled ? onLongPress : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                listItemRow,
                if (showDivider)
                  const Divider(height: 1, indent: 16, endIndent: 16),
              ],
            ),
          ),
        );
        break;
    }
    
    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: styledItem,
    );
  }
  
  /// Get background color based on variant
  Color _getBackgroundColor(bool isDark) {
    if (backgroundColor != null) {
      return backgroundColor!;
    }
    
    switch (variant) {
      case BondListItemVariant.card:
        return isDark ? BondColors.night : Colors.white;
      case BondListItemVariant.glass:
        return isDark ? Colors.black.withOpacity(0.3) : Colors.white.withOpacity(0.7);
      case BondListItemVariant.standard:
      default:
        return Colors.transparent;
    }
  }
}
