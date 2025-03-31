import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';
import 'package:fresh_bond_app/core/design/system/bond_design_system.dart';

/// Input field variants
enum BondInputVariant {
  /// Standard input with outline
  outlined,
  
  /// Input with glass effect
  glass,
  
  /// Input with filled background
  filled,
}

/// A customizable input field component implementing the Bond Design System
///
/// Features:
/// - Multiple variants: outlined, glass, filled
/// - Validation support with error messages
/// - Prefix and suffix icons
/// - Label and placeholder text
/// - Character counter
class BondInput extends StatefulWidget {
  /// Label text displayed above the input
  final String? label;
  
  /// Placeholder text when input is empty
  final String? placeholder;
  
  /// Helper text displayed below the input
  final String? helperText;
  
  /// Error message displayed when validation fails
  final String? errorText;
  
  /// Icon displayed at the start of the input
  final Widget? prefixIcon;
  
  /// Icon displayed at the end of the input
  final Widget? suffixIcon;
  
  /// Whether the input is obscured (for passwords)
  final bool obscureText;
  
  /// Whether the input is enabled
  final bool enabled;
  
  /// Maximum number of characters allowed
  final int? maxLength;
  
  /// Whether to show character counter
  final bool showCounter;
  
  /// Callback when input value changes
  final ValueChanged<String>? onChanged;
  
  /// Callback when input is submitted
  final ValueChanged<String>? onSubmitted;
  
  /// Focus node for controlling focus
  final FocusNode? focusNode;
  
  /// Text controller for the input
  final TextEditingController? controller;
  
  /// Input type (text, number, email, etc.)
  final TextInputType? keyboardType;
  
  /// Input formatters for restricting input
  final List<TextInputFormatter>? inputFormatters;
  
  /// Visual style variant
  final BondInputVariant variant;
  
  /// Whether to auto-focus this input
  final bool autofocus;
  
  /// Maximum number of lines for multiline input
  final int? maxLines;
  
  /// Minimum number of lines for multiline input
  final int? minLines;
  
  /// Validator function
  final String? Function(String?)? validator;

  /// Constructor
  const BondInput({
    Key? key,
    this.label,
    this.placeholder,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.maxLength,
    this.showCounter = false,
    this.onChanged,
    this.onSubmitted,
    this.focusNode,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.variant = BondInputVariant.outlined,
    this.autofocus = false,
    this.maxLines = 1,
    this.minLines,
    this.validator,
  }) : super(key: key);

  @override
  State<BondInput> createState() => _BondInputState();
}

class _BondInputState extends State<BondInput> {
  late FocusNode _focusNode;
  late TextEditingController _controller;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _controller = widget.controller ?? TextEditingController();
    
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Determine colors based on state and variant
    final Color backgroundColor;
    final Color borderColor;
    final BorderRadius borderRadius = BorderRadius.circular(12.0);
    
    if (hasError) {
      borderColor = BondColors.error;
      backgroundColor = BondColors.error.withOpacity(0.05);
    } else if (!widget.enabled) {
      borderColor = isDark ? BondColors.slate.withOpacity(0.3) : BondColors.divider;
      backgroundColor = isDark ? BondColors.slate.withOpacity(0.1) : BondColors.backgroundSecondary;
    } else if (_isFocused) {
      borderColor = BondColors.primary;
      backgroundColor = isDark ? Colors.black.withOpacity(0.3) : Colors.white;
    } else {
      borderColor = isDark ? BondColors.slate.withOpacity(0.5) : BondColors.divider;
      backgroundColor = isDark ? Colors.black.withOpacity(0.2) : Colors.white.withOpacity(0.8);
    }
    
    // Build the input field based on the variant
    Widget inputField = TextField(
      controller: _controller,
      focusNode: _focusNode,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      maxLength: widget.showCounter ? widget.maxLength : null,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      inputFormatters: widget.inputFormatters,
      autofocus: widget.autofocus,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      style: BondTypography.body1,
      decoration: InputDecoration(
        hintText: widget.placeholder,
        hintStyle: BondTypography.body1.copyWith(
          color: isDark ? BondColors.slate.withOpacity(0.7) : BondColors.slate.withOpacity(0.5),
        ),
        prefixIcon: widget.prefixIcon,
        suffixIcon: widget.suffixIcon,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: InputBorder.none,
        counterText: widget.showCounter ? null : '',
      ),
    );
    
    // Apply variant-specific styling
    Widget styledInput;
    switch (widget.variant) {
      case BondInputVariant.glass:
        styledInput = ClipRRect(
          borderRadius: borderRadius,
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor.withOpacity(0.7),
                borderRadius: borderRadius,
                border: Border.all(color: borderColor),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: inputField,
            ),
          ),
        );
        break;
        
      case BondInputVariant.filled:
        styledInput = Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: borderRadius,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: inputField,
        );
        break;
        
      case BondInputVariant.outlined:
        styledInput = Container(
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: borderRadius,
            border: Border.all(color: borderColor),
          ),
          child: inputField,
        );
        break;
    }
    
    // Build the complete input with label, helper text, and error
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: BondTypography.caption.copyWith(
              color: hasError ? BondColors.error : null,
            ),
          ),
          const SizedBox(height: 4),
        ],
        
        // Wrap the input in a constrained box to prevent layout issues
        ConstrainedBox(
          constraints: const BoxConstraints(
            minHeight: 48, // Minimum height to ensure proper sizing
          ),
          child: styledInput,
        ),
        
        if (widget.helperText != null && !hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.helperText!,
            style: BondTypography.caption.copyWith(
              color: isDark ? BondColors.textDark : BondColors.slate,
            ),
          ),
        ],
        
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            widget.errorText!,
            style: BondTypography.caption.copyWith(
              color: BondColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
