import 'dart:ui';
import 'package:flutter/material.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';
import '../bond_design_system.dart';

/// A customizable bottom sheet component implementing the Bond Design System
///
/// Features:
/// - Modern design with glass effect option
/// - Customizable height and appearance
/// - Drag handle and dismissible behavior
/// - Support for custom content and actions
class BondBottomSheet extends StatelessWidget {
  /// Title of the bottom sheet
  final String? title;
  
  /// Content of the bottom sheet
  final Widget content;
  
  /// Actions to display at the bottom
  final List<Widget>? actions;
  
  /// Whether to show a drag handle
  final bool showDragHandle;
  
  /// Whether to use glass effect
  final bool useGlassEffect;
  
  /// Whether the bottom sheet is dismissible
  final bool isDismissible;
  
  /// Maximum height as a percentage of screen height (0.0 to 1.0)
  final double? maxHeightFactor;
  
  /// Initial height as a percentage of screen height (0.0 to 1.0)
  final double? initialHeightFactor;
  
  /// Background color of the bottom sheet
  final Color? backgroundColor;
  
  /// Border radius of the bottom sheet
  final double? borderRadius;
  
  /// Callback when the bottom sheet is dismissed
  final VoidCallback? onDismiss;

  /// Constructor
  const BondBottomSheet({
    Key? key,
    this.title,
    required this.content,
    this.actions,
    this.showDragHandle = true,
    this.useGlassEffect = false,
    this.isDismissible = true,
    this.maxHeightFactor = 0.9,
    this.initialHeightFactor,
    this.backgroundColor,
    this.borderRadius,
    this.onDismiss,
  }) : super(key: key);

  /// Show a modal bottom sheet with Bond Design System styling
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    List<Widget>? actions,
    bool showDragHandle = true,
    bool useGlassEffect = false,
    bool isDismissible = true,
    double? maxHeightFactor = 0.9,
    double? initialHeightFactor,
    Color? backgroundColor,
    double? borderRadius,
    VoidCallback? onDismiss,
    bool isScrollControlled = true,
    bool enableDrag = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(borderRadius ?? BondDesignSystem.tokens.radiusL),
        ),
      ),
      builder: (context) => BondBottomSheet(
        title: title,
        content: content,
        actions: actions,
        showDragHandle: showDragHandle,
        useGlassEffect: useGlassEffect,
        isDismissible: isDismissible,
        maxHeightFactor: maxHeightFactor,
        initialHeightFactor: initialHeightFactor,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        onDismiss: onDismiss,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    final viewInsets = MediaQuery.of(context).viewInsets.bottom;
    
    // Calculate max height
    final double maxHeight = screenHeight * (maxHeightFactor ?? 0.9);
    
    // Determine colors
    final Color bgColor = backgroundColor ?? 
        (isDark ? Colors.grey[900]! : Colors.white);
    
    // Determine border radius
    final double radius = borderRadius ?? BondDesignSystem.tokens.radiusL;
    
    // Build the content
    Widget sheetContent = Container(
      constraints: BoxConstraints(
        maxHeight: maxHeight,
        minHeight: initialHeightFactor != null 
            ? screenHeight * initialHeightFactor! 
            : 0,
      ),
      padding: EdgeInsets.only(
        bottom: viewInsets + (actions != null ? 0 : 16),
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          if (showDragHandle) _buildDragHandle(context),
          
          // Title
          if (title != null) _buildTitle(context, title!),
          
          // Content
          Flexible(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: content,
            ),
          ),
          
          // Actions
          if (actions != null) _buildActions(context, actions!),
        ],
      ),
    );
    
    // Apply glass effect if needed
    if (useGlassEffect) {
      sheetContent = ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.8),
              borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
              border: Border.all(
                color: isDark 
                    ? Colors.white.withOpacity(0.1) 
                    : Colors.black.withOpacity(0.05),
              ),
            ),
            child: sheetContent,
          ),
        ),
      );
    } else {
      sheetContent = Container(
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: sheetContent,
      );
    }
    
    // Make dismissible if needed
    if (isDismissible) {
      return GestureDetector(
        onTap: () {
          if (onDismiss != null) {
            onDismiss!();
          }
          Navigator.of(context).pop();
        },
        behavior: HitTestBehavior.opaque,
        child: GestureDetector(
          onTap: () {}, // Prevent taps from dismissing
          child: sheetContent,
        ),
      );
    }
    
    return sheetContent;
  }
  
  /// Build the drag handle
  Widget _buildDragHandle(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: isDark 
                ? Colors.white.withOpacity(0.3) 
                : Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
  
  /// Build the title
  Widget _buildTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Text(
        title,
        style: BondTypography.heading2(context),
        textAlign: TextAlign.center,
      ),
    );
  }
  
  /// Build the actions
  Widget _buildActions(BuildContext context, List<Widget> actions) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark 
            ? Colors.black.withOpacity(0.3) 
            : Colors.grey[50],
        border: Border(
          top: BorderSide(
            color: isDark 
                ? Colors.white.withOpacity(0.1) 
                : Colors.black.withOpacity(0.05),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: actions.length == 1 
            ? MainAxisAlignment.center 
            : MainAxisAlignment.spaceEvenly,
        children: actions,
      ),
    );
  }
}

/// Helper class to create a bottom sheet with a list of options
class BondBottomSheetOptions {
  /// Show a bottom sheet with a list of options
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required List<BondBottomSheetOption<T>> options,
    bool useGlassEffect = false,
    bool showCancelButton = true,
    String cancelButtonText = 'Cancel',
    VoidCallback? onCancel,
  }) {
    return BondBottomSheet.show<T>(
      context: context,
      title: title,
      useGlassEffect: useGlassEffect,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: options.map((option) {
          return ListTile(
            leading: option.icon != null 
                ? Icon(option.icon, color: option.iconColor) 
                : null,
            title: Text(
              option.label,
              style: BondTypography.body(context).copyWith(
                color: option.textColor,
                fontWeight: option.isDestructive 
                    ? FontWeight.bold 
                    : FontWeight.normal,
              ),
            ),
            onTap: () {
              Navigator.of(context).pop(option.value);
            },
          );
        }).toList(),
      ),
      actions: showCancelButton ? [
        TextButton(
          onPressed: () {
            if (onCancel != null) {
              onCancel();
            }
            Navigator.of(context).pop();
          },
          child: Text(
            cancelButtonText,
            style: BondTypography.button(context),
          ),
        ),
      ] : null,
    );
  }
}

/// Option for the bottom sheet options
class BondBottomSheetOption<T> {
  /// Label for the option
  final String label;
  
  /// Value to return when selected
  final T value;
  
  /// Icon to display
  final IconData? icon;
  
  /// Color of the icon
  final Color? iconColor;
  
  /// Color of the text
  final Color? textColor;
  
  /// Whether this is a destructive action
  final bool isDestructive;
  
  /// Constructor
  const BondBottomSheetOption({
    required this.label,
    required this.value,
    this.icon,
    this.iconColor,
    this.textColor,
    this.isDestructive = false,
  });
}
