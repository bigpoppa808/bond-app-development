import 'dart:ui';
import 'package:flutter/material.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';
import '../bond_design_system.dart';

/// Toast variants
enum BondToastVariant {
  /// Info toast
  info,
  
  /// Success toast
  success,
  
  /// Warning toast
  warning,
  
  /// Error toast
  error,
}

/// Toast positions
enum BondToastPosition {
  /// Top position
  top,
  
  /// Bottom position
  bottom,
  
  /// Center position
  center,
}

/// A customizable toast component implementing the Bond Design System
///
/// Features:
/// - Multiple variants: info, success, warning, error
/// - Customizable appearance and animations
/// - Support for actions
/// - Glass effect option
class BondToast {
  /// Show a toast message
  static Future<void> show(
    BuildContext context, {
    required String message,
    String? title,
    BondToastVariant variant = BondToastVariant.info,
    BondToastPosition position = BondToastPosition.bottom,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
    String? actionLabel,
    VoidCallback? onAction,
    bool useGlassEffect = false,
    Color? backgroundColor,
    bool isDismissible = true,
    EdgeInsetsGeometry margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    double? width,
  }) async {
    // Create an overlay entry
    final OverlayState overlayState = Overlay.of(context);
    late final OverlayEntry overlayEntry;
    
    overlayEntry = OverlayEntry(
      builder: (context) => _BondToastWidget(
        message: message,
        title: title,
        variant: variant,
        position: position,
        onTap: onTap,
        actionLabel: actionLabel,
        onAction: onAction,
        useGlassEffect: useGlassEffect,
        backgroundColor: backgroundColor,
        isDismissible: isDismissible,
        margin: margin,
        width: width,
        onDismiss: () {
          overlayEntry.remove();
        },
      ),
    );
    
    // Insert the overlay entry
    overlayState.insert(overlayEntry);
    
    // Remove after duration
    if (duration != Duration.zero) {
      await Future.delayed(duration);
      if (overlayEntry.mounted) {
        overlayEntry.remove();
      }
    }
  }
  
  /// Show an info toast
  static Future<void> info(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    BondToastPosition position = BondToastPosition.bottom,
    bool useGlassEffect = false,
  }) {
    return show(
      context,
      message: message,
      title: title,
      variant: BondToastVariant.info,
      duration: duration,
      position: position,
      useGlassEffect: useGlassEffect,
    );
  }
  
  /// Show a success toast
  static Future<void> success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    BondToastPosition position = BondToastPosition.bottom,
    bool useGlassEffect = false,
  }) {
    return show(
      context,
      message: message,
      title: title,
      variant: BondToastVariant.success,
      duration: duration,
      position: position,
      useGlassEffect: useGlassEffect,
    );
  }
  
  /// Show a warning toast
  static Future<void> warning(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    BondToastPosition position = BondToastPosition.bottom,
    bool useGlassEffect = false,
  }) {
    return show(
      context,
      message: message,
      title: title,
      variant: BondToastVariant.warning,
      duration: duration,
      position: position,
      useGlassEffect: useGlassEffect,
    );
  }
  
  /// Show an error toast
  static Future<void> error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
    BondToastPosition position = BondToastPosition.bottom,
    bool useGlassEffect = false,
  }) {
    return show(
      context,
      message: message,
      title: title,
      variant: BondToastVariant.error,
      duration: duration,
      position: position,
      useGlassEffect: useGlassEffect,
    );
  }
}

/// Widget for displaying the toast
class _BondToastWidget extends StatefulWidget {
  /// Message to display
  final String message;
  
  /// Title of the toast
  final String? title;
  
  /// Variant of the toast
  final BondToastVariant variant;
  
  /// Position of the toast
  final BondToastPosition position;
  
  /// Callback when the toast is tapped
  final VoidCallback? onTap;
  
  /// Label for the action button
  final String? actionLabel;
  
  /// Callback when the action button is tapped
  final VoidCallback? onAction;
  
  /// Whether to use glass effect
  final bool useGlassEffect;
  
  /// Background color of the toast
  final Color? backgroundColor;
  
  /// Whether the toast is dismissible
  final bool isDismissible;
  
  /// Margin around the toast
  final EdgeInsetsGeometry margin;
  
  /// Width of the toast
  final double? width;
  
  /// Callback when the toast is dismissed
  final VoidCallback onDismiss;

  /// Constructor
  const _BondToastWidget({
    Key? key,
    required this.message,
    this.title,
    required this.variant,
    required this.position,
    this.onTap,
    this.actionLabel,
    this.onAction,
    required this.useGlassEffect,
    this.backgroundColor,
    required this.isDismissible,
    required this.margin,
    this.width,
    required this.onDismiss,
  }) : super(key: key);

  @override
  State<_BondToastWidget> createState() => _BondToastWidgetState();
}

class _BondToastWidgetState extends State<_BondToastWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Create animations based on position
    switch (widget.position) {
      case BondToastPosition.top:
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );
        _slideAnimation = Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );
        break;
        
      case BondToastPosition.center:
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );
        _slideAnimation = Tween<Offset>(begin: const Offset(0, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );
        break;
        
      case BondToastPosition.bottom:
      default:
        _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );
        _slideAnimation = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOut,
          ),
        );
        break;
    }
    
    // Start the animation
    _animationController.forward();
  }
  
  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
  
  void _dismiss() {
    // Reverse the animation and then remove the overlay
    _animationController.reverse().then((_) {
      widget.onDismiss();
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on variant
    final Color variantColor = _getVariantColor();
    final Color bgColor = widget.backgroundColor ?? 
        (isDark ? Colors.grey[850]! : Colors.white);
    final IconData variantIcon = _getVariantIcon();
    
    // Build the toast content
    Widget toastContent = Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: widget.useGlassEffect ? bgColor.withOpacity(0.7) : bgColor,
        borderRadius: BorderRadius.circular(BondDesignSystem.tokens.radiusM),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: variantColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Variant icon
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: variantColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              variantIcon,
              color: variantColor,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),
          
          // Message content
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.title != null) ...[
                  Text(
                    widget.title!,
                    style: BondTypography.bodyLarge(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  widget.message,
                  style: BondTypography.body(context),
                ),
              ],
            ),
          ),
          
          // Action or close button
          if (widget.actionLabel != null && widget.onAction != null) ...[
            const SizedBox(width: 8),
            TextButton(
              onPressed: () {
                widget.onAction!();
                _dismiss();
              },
              child: Text(
                widget.actionLabel!,
                style: BondTypography.button(context).copyWith(
                  color: variantColor,
                ),
              ),
            ),
          ] else if (widget.isDismissible) ...[
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.close, size: 16),
              onPressed: _dismiss,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(
                minWidth: 24,
                minHeight: 24,
              ),
            ),
          ],
        ],
      ),
    );
    
    // Apply glass effect if needed
    if (widget.useGlassEffect) {
      toastContent = ClipRRect(
        borderRadius: BorderRadius.circular(BondDesignSystem.tokens.radiusM),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: toastContent,
        ),
      );
    }
    
    // Make the toast tappable if needed
    if (widget.onTap != null) {
      toastContent = GestureDetector(
        onTap: () {
          widget.onTap!();
          _dismiss();
        },
        child: toastContent,
      );
    }
    
    // Apply animations
    toastContent = FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: toastContent,
      ),
    );
    
    // Position the toast
    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Align(
          alignment: _getAlignment(),
          child: Padding(
            padding: widget.margin,
            child: toastContent,
          ),
        ),
      ),
    );
  }
  
  /// Get the color based on variant
  Color _getVariantColor() {
    switch (widget.variant) {
      case BondToastVariant.success:
        return BondColors.success;
      case BondToastVariant.warning:
        return BondColors.warning;
      case BondToastVariant.error:
        return BondColors.error;
      case BondToastVariant.info:
      default:
        return BondColors.bondTeal;
    }
  }
  
  /// Get the icon based on variant
  IconData _getVariantIcon() {
    switch (widget.variant) {
      case BondToastVariant.success:
        return Icons.check_circle_outline;
      case BondToastVariant.warning:
        return Icons.warning_amber_outlined;
      case BondToastVariant.error:
        return Icons.error_outline;
      case BondToastVariant.info:
      default:
        return Icons.info_outline;
    }
  }
  
  /// Get the alignment based on position
  Alignment _getAlignment() {
    switch (widget.position) {
      case BondToastPosition.top:
        return Alignment.topCenter;
      case BondToastPosition.center:
        return Alignment.center;
      case BondToastPosition.bottom:
      default:
        return Alignment.bottomCenter;
    }
  }
}
