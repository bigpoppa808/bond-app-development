import 'package:flutter/material.dart';
import '../bond_colors.dart';
import '../bond_design_system.dart';

/// Avatar sizes
enum BondAvatarSize {
  /// Extra small (24px)
  xs(24.0),
  
  /// Small (32px)
  sm(32.0),
  
  /// Medium (40px)
  md(40.0),
  
  /// Large (56px)
  lg(56.0),
  
  /// Extra large (72px)
  xl(72.0),
  
  /// Custom size
  custom(0.0);
  
  /// The size in pixels
  final double size;
  
  const BondAvatarSize(this.size);
}

/// Avatar status indicator
enum BondAvatarStatus {
  /// No status indicator
  none,
  
  /// Online status (green)
  online,
  
  /// Away status (yellow)
  away,
  
  /// Busy status (red)
  busy,
  
  /// Offline status (gray)
  offline
}

/// A customizable avatar component implementing the Bond Design System
///
/// Features:
/// - Multiple size variants
/// - Support for images, initials, and placeholders
/// - Status indicator
/// - Border and shadow options
class BondAvatar extends StatelessWidget {
  /// Image URL for the avatar
  final String? imageUrl;
  
  /// Initials to display when no image is available
  final String? initials;
  
  /// Size of the avatar
  final BondAvatarSize size;
  
  /// Custom size for the avatar (only used when size is custom)
  final double? customSize;
  
  /// Status indicator
  final BondAvatarStatus status;
  
  /// Whether to show a border
  final bool showBorder;
  
  /// Border color (defaults to white in light mode, dark gray in dark mode)
  final Color? borderColor;
  
  /// Background color for initials
  final Color? backgroundColor;
  
  /// Whether to show a shadow
  final bool showShadow;
  
  /// Callback when avatar is tapped
  final VoidCallback? onTap;
  
  /// Icon to display when no image or initials are available
  final IconData? placeholderIcon;

  /// Constructor
  const BondAvatar({
    Key? key,
    this.imageUrl,
    this.initials,
    this.size = BondAvatarSize.md,
    this.customSize,
    this.status = BondAvatarStatus.none,
    this.showBorder = true,
    this.borderColor,
    this.backgroundColor,
    this.showShadow = false,
    this.onTap,
    this.placeholderIcon = Icons.person,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final actualSize = size == BondAvatarSize.custom ? (customSize ?? 40.0) : size.size;
    final borderWidth = actualSize * 0.05 > 0 ? actualSize * 0.05 : 1.0; // Ensure positive value
    final statusSize = actualSize * 0.3 > 0 ? actualSize * 0.3 : 8.0; // Ensure positive value
    
    // Determine colors
    final defaultBorderColor = isDark ? BondColors.night : Colors.white;
    final actualBorderColor = borderColor ?? defaultBorderColor;
    final defaultBackgroundColor = _getDefaultBackgroundColor(context);
    final actualBackgroundColor = backgroundColor ?? defaultBackgroundColor;
    
    // Build the avatar content
    Widget avatarContent;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      // Image avatar
      avatarContent = ClipRRect(
        borderRadius: BorderRadius.circular(actualSize / 2), // Use half size for circular shape
        child: Image.network(
          imageUrl!,
          width: actualSize,
          height: actualSize,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildInitialsOrPlaceholder(
            context, 
            actualSize, 
            actualBackgroundColor
          ),
        ),
      );
    } else {
      // Initials or placeholder avatar
      avatarContent = _buildInitialsOrPlaceholder(
        context, 
        actualSize, 
        actualBackgroundColor
      );
    }
    
    // Add border if needed
    if (showBorder) {
      avatarContent = Container(
        width: actualSize,
        height: actualSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: actualBorderColor,
            width: borderWidth,
          ),
          boxShadow: showShadow ? [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ] : null,
        ),
        child: ClipOval(child: avatarContent),
      );
    }
    
    // Add status indicator if needed
    if (status != BondAvatarStatus.none) {
      avatarContent = Stack(
        clipBehavior: Clip.none,
        children: [
          avatarContent,
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: statusSize,
              height: statusSize,
              decoration: BoxDecoration(
                color: _getStatusColor(status),
                shape: BoxShape.circle,
                border: Border.all(
                  color: actualBorderColor,
                  width: borderWidth / 2 > 0 ? borderWidth / 2 : 0.5, // Ensure positive value
                ),
              ),
            ),
          ),
        ],
      );
    }
    
    // Make it tappable if needed
    if (onTap != null) {
      avatarContent = GestureDetector(
        onTap: onTap,
        child: avatarContent,
      );
    }
    
    return SizedBox(
      width: actualSize,
      height: actualSize,
      child: avatarContent,
    );
  }
  
  /// Build initials or placeholder
  Widget _buildInitialsOrPlaceholder(BuildContext context, double size, Color backgroundColor) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: initials != null && initials!.isNotEmpty
            ? Text(
                initials!.length > 2 ? initials!.substring(0, 2) : initials!,
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: size * 0.4 > 0 ? size * 0.4 : 12.0, // Ensure positive value
                ),
              )
            : Icon(
                placeholderIcon,
                color: Colors.white,
                size: size * 0.5 > 0 ? size * 0.5 : 12.0, // Ensure positive value
              ),
      ),
    );
  }
  
  /// Get status indicator color
  Color _getStatusColor(BondAvatarStatus status) {
    switch (status) {
      case BondAvatarStatus.online:
        return BondColors.success;
      case BondAvatarStatus.away:
        return BondColors.warning;
      case BondAvatarStatus.busy:
        return BondColors.error;
      case BondAvatarStatus.offline:
        return BondColors.slate;
      default:
        return Colors.transparent;
    }
  }
  
  /// Get default background color based on initials
  Color _getDefaultBackgroundColor(BuildContext context) {
    if (initials == null || initials!.isEmpty) {
      return BondColors.slate;
    }
    
    // Generate a consistent color based on the initials
    final colorIndex = initials!.codeUnitAt(0) % BondDesignSystem.tokens.avatarColors.length;
    return BondDesignSystem.tokens.avatarColors[colorIndex];
  }
}
