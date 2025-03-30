import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';
import '../bond_design_system.dart';
import 'bond_button.dart';

/// A customizable dialog component implementing the Bond Design System
///
/// Features:
/// - Modern design with glass effect option
/// - Customizable appearance and animations
/// - Support for various dialog types: alert, confirmation, input, etc.
/// - Haptic feedback on actions
class BondDialog extends StatelessWidget {
  /// Title of the dialog
  final String? title;
  
  /// Content of the dialog
  final Widget content;
  
  /// Primary action button
  final BondDialogAction? primaryAction;
  
  /// Secondary action button
  final BondDialogAction? secondaryAction;
  
  /// Whether to use glass effect
  final bool useGlassEffect;
  
  /// Whether the dialog is dismissible by tapping outside
  final bool isDismissible;
  
  /// Background color of the dialog
  final Color? backgroundColor;
  
  /// Border radius of the dialog
  final double? borderRadius;
  
  /// Padding around the dialog content
  final EdgeInsetsGeometry contentPadding;
  
  /// Alignment of the dialog actions
  final MainAxisAlignment actionsAlignment;
  
  /// Spacing between dialog actions
  final double actionsSpacing;
  
  /// Whether to use haptic feedback on actions
  final bool useHapticFeedback;

  /// Constructor
  const BondDialog({
    Key? key,
    this.title,
    required this.content,
    this.primaryAction,
    this.secondaryAction,
    this.useGlassEffect = false,
    this.isDismissible = true,
    this.backgroundColor,
    this.borderRadius,
    this.contentPadding = const EdgeInsets.all(24),
    this.actionsAlignment = MainAxisAlignment.end,
    this.actionsSpacing = 16,
    this.useHapticFeedback = true,
  }) : super(key: key);

  /// Show a dialog with Bond Design System styling
  static Future<T?> show<T>({
    required BuildContext context,
    String? title,
    required Widget content,
    BondDialogAction? primaryAction,
    BondDialogAction? secondaryAction,
    bool useGlassEffect = false,
    bool isDismissible = true,
    Color? backgroundColor,
    double? borderRadius,
    EdgeInsetsGeometry contentPadding = const EdgeInsets.all(24),
    MainAxisAlignment actionsAlignment = MainAxisAlignment.end,
    double actionsSpacing = 16,
    bool useHapticFeedback = true,
    bool barrierDismissible = true,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible && isDismissible,
      barrierColor: Colors.black54,
      builder: (context) => BondDialog(
        title: title,
        content: content,
        primaryAction: primaryAction,
        secondaryAction: secondaryAction,
        useGlassEffect: useGlassEffect,
        isDismissible: isDismissible,
        backgroundColor: backgroundColor,
        borderRadius: borderRadius,
        contentPadding: contentPadding,
        actionsAlignment: actionsAlignment,
        actionsSpacing: actionsSpacing,
        useHapticFeedback: useHapticFeedback,
      ),
    );
  }
  
  /// Show an alert dialog
  static Future<void> showAlert({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool useGlassEffect = false,
  }) {
    return show(
      context: context,
      title: title,
      useGlassEffect: useGlassEffect,
      content: Text(
        message,
        style: BondTypography.body(context),
      ),
      primaryAction: BondDialogAction(
        label: buttonText,
        onPressed: () {
          Navigator.of(context).pop();
          if (onPressed != null) {
            onPressed();
          }
        },
      ),
    );
  }
  
  /// Show a confirmation dialog
  static Future<bool?> showConfirmation({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = 'Confirm',
    String cancelText = 'Cancel',
    bool isDestructive = false,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    bool useGlassEffect = false,
  }) {
    return show<bool>(
      context: context,
      title: title,
      useGlassEffect: useGlassEffect,
      content: Text(
        message,
        style: BondTypography.body(context),
      ),
      primaryAction: BondDialogAction(
        label: confirmText,
        onPressed: () {
          Navigator.of(context).pop(true);
          if (onConfirm != null) {
            onConfirm();
          }
        },
        isDestructive: isDestructive,
      ),
      secondaryAction: BondDialogAction(
        label: cancelText,
        onPressed: () {
          Navigator.of(context).pop(false);
          if (onCancel != null) {
            onCancel();
          }
        },
        isSecondary: true,
      ),
    );
  }
  
  /// Show an input dialog
  static Future<String?> showInput({
    required BuildContext context,
    required String title,
    String? initialValue,
    String? hintText,
    String confirmText = 'Submit',
    String cancelText = 'Cancel',
    bool useGlassEffect = false,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    final TextEditingController controller = TextEditingController(text: initialValue);
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();
    
    return show<String>(
      context: context,
      title: title,
      useGlassEffect: useGlassEffect,
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          autofocus: true,
          keyboardType: keyboardType,
          maxLength: maxLength,
          decoration: InputDecoration(
            hintText: hintText,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(BondDesignSystem.tokens.radiusM),
            ),
          ),
          validator: validator,
        ),
      ),
      primaryAction: BondDialogAction(
        label: confirmText,
        onPressed: () {
          if (formKey.currentState?.validate() ?? true) {
            Navigator.of(context).pop(controller.text);
          }
        },
      ),
      secondaryAction: BondDialogAction(
        label: cancelText,
        onPressed: () {
          Navigator.of(context).pop();
        },
        isSecondary: true,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors
    final Color bgColor = backgroundColor ?? 
        (isDark ? Colors.grey[900]! : Colors.white);
    
    // Determine border radius
    final double radius = borderRadius ?? BondDesignSystem.tokens.radiusL;
    
    // Build the content
    Widget dialogContent = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        if (title != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: contentPadding.horizontal / 2,
              right: contentPadding.horizontal / 2,
              top: contentPadding.vertical / 2,
              bottom: 16,
            ),
            child: Text(
              title!,
              style: BondTypography.heading2(context),
              textAlign: TextAlign.center,
            ),
          ),
        ],
        
        // Content
        Padding(
          padding: EdgeInsets.only(
            left: contentPadding.horizontal / 2,
            right: contentPadding.horizontal / 2,
            top: title != null ? 0 : contentPadding.vertical / 2,
            bottom: (primaryAction != null || secondaryAction != null) ? 24 : contentPadding.vertical / 2,
          ),
          child: content,
        ),
        
        // Actions
        if (primaryAction != null || secondaryAction != null) ...[
          Padding(
            padding: EdgeInsets.only(
              left: contentPadding.horizontal / 2,
              right: contentPadding.horizontal / 2,
              bottom: contentPadding.vertical / 2,
            ),
            child: Row(
              mainAxisAlignment: actionsAlignment,
              children: [
                if (secondaryAction != null) ...[
                  _buildActionButton(context, secondaryAction!, true),
                ],
                if (secondaryAction != null && primaryAction != null) ...[
                  SizedBox(width: actionsSpacing),
                ],
                if (primaryAction != null) ...[
                  _buildActionButton(context, primaryAction!, false),
                ],
              ],
            ),
          ),
        ],
      ],
    );
    
    // Apply glass effect if needed
    Widget dialog;
    if (useGlassEffect) {
      dialog = Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(radius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              decoration: BoxDecoration(
                color: bgColor.withOpacity(0.8),
                borderRadius: BorderRadius.circular(radius),
                border: Border.all(
                  color: isDark 
                      ? Colors.white.withOpacity(0.1) 
                      : Colors.black.withOpacity(0.05),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: dialogContent,
            ),
          ),
        ),
      );
    } else {
      dialog = Dialog(
        backgroundColor: bgColor,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radius),
        ),
        child: dialogContent,
      );
    }
    
    // Make dismissible if needed
    if (isDismissible) {
      return dialog;
    } else {
      return WillPopScope(
        onWillPop: () async => false,
        child: dialog,
      );
    }
  }
  
  /// Build an action button
  Widget _buildActionButton(BuildContext context, BondDialogAction action, bool isSecondary) {
    // Handle tap with optional haptic feedback
    void handleTap() {
      if (useHapticFeedback) {
        HapticFeedback.mediumImpact();
      }
      
      action.onPressed();
    }
    
    return BondButton(
      label: action.label,
      onPressed: handleTap,
      variant: action.isDestructive 
          ? BondButtonVariant.primary  // Use primary with custom styling for danger
          : (isSecondary || action.isSecondary 
              ? BondButtonVariant.secondary 
              : BondButtonVariant.primary),
      useHapticFeedback: false, // We're handling haptic feedback manually
    );
  }
}

/// Action for the dialog
class BondDialogAction {
  /// Label for the action
  final String label;
  
  /// Callback when the action is pressed
  final VoidCallback onPressed;
  
  /// Whether this is a destructive action
  final bool isDestructive;
  
  /// Whether this is a secondary action
  final bool isSecondary;
  
  /// Constructor
  const BondDialogAction({
    required this.label,
    required this.onPressed,
    this.isDestructive = false,
    this.isSecondary = false,
  });
}
