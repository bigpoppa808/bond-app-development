import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/components/bond_button.dart' as core_button;

/// @Deprecated - Use BondButton from core/design/components/bond_button.dart instead
/// 
/// This enum is kept for backward compatibility
enum BondButtonType { primary, secondary, outline, text }

/// @Deprecated - Use BondButton from core/design/components/bond_button.dart instead
/// 
/// This class is a wrapper around the new BondButton implementation
/// to maintain backward compatibility. For new code, use the new implementation directly.
class BondButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final BondButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double height;

  const BondButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = BondButtonType.primary,
    this.isLoading = false,
    this.icon,
    this.width,
    this.height = 48,
  });

  @override
  Widget build(BuildContext context) {
    // Convert old BondButtonType to new BondButtonVariant
    core_button.BondButtonVariant variant;
    switch (type) {
      case BondButtonType.primary:
        variant = core_button.BondButtonVariant.primary;
        break;
      case BondButtonType.secondary:
        variant = core_button.BondButtonVariant.secondary;
        break;
      case BondButtonType.outline:
        variant = core_button.BondButtonVariant.secondary;
        break;
      case BondButtonType.text:
        variant = core_button.BondButtonVariant.tertiary;
        break;
    }

    // Use the new BondButton implementation
    return core_button.BondButton(
      label: text,
      onPressed: onPressed,
      variant: variant,
      isLoading: isLoading,
      icon: icon,
      width: width,
      height: height,
    );
  }
}
