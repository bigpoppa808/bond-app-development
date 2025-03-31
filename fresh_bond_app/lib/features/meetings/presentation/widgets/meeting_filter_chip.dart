import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';

/// A custom filter chip for meetings filtering
class MeetingFilterChip extends StatefulWidget {
  /// The label text to display
  final String label;
  
  /// Whether the chip is selected
  final bool isSelected;
  
  /// Callback for when the selection state changes
  final ValueChanged<bool>? onSelected;
  
  /// Constructor
  const MeetingFilterChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onSelected,
  }) : super(key: key);

  @override
  State<MeetingFilterChip> createState() => _MeetingFilterChipState();
}

class _MeetingFilterChipState extends State<MeetingFilterChip> {
  late bool _isSelected;
  
  @override
  void initState() {
    super.initState();
    _isSelected = widget.isSelected;
  }
  
  @override
  void didUpdateWidget(MeetingFilterChip oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      _isSelected = widget.isSelected;
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final newValue = !_isSelected;
        setState(() {
          _isSelected = newValue;
        });
        widget.onSelected?.call(newValue);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _isSelected ? BondColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isSelected ? BondColors.primary : BondColors.slate,
            width: 1,
          ),
        ),
        child: Text(
          widget.label,
          style: BondTypography.button.copyWith(
            color: _isSelected ? Colors.white : BondColors.slate,
          ),
        ),
      ),
    );
  }
}