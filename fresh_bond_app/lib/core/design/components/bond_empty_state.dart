import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/components/bond_button.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';

/// Types of empty states for different contexts
enum BondEmptyStateType {
  /// Generic empty state
  generic,
  
  /// Empty connections list
  connections,
  
  /// Empty meetings list
  meetings,
  
  /// Empty notifications list
  notifications,
  
  /// Empty messages list
  messages,
  
  /// Empty search results
  search,
  
  /// Error state
  error,
}

/// A reusable empty state component with illustration and optional action
class BondEmptyState extends StatelessWidget {
  /// The title to display
  final String title;
  
  /// The message to display
  final String message;
  
  /// The type of empty state
  final BondEmptyStateType type;
  
  /// Optional custom illustration asset path
  final String? illustrationAsset;
  
  /// Optional action button
  final Widget? action;
  
  /// Whether to use a compact layout
  final bool compact;
  
  /// Optional animation to apply to the illustration
  final Animation<double>? animation;

  /// Default constructor
  const BondEmptyState({
    Key? key,
    required this.title,
    required this.message,
    this.type = BondEmptyStateType.generic,
    this.illustrationAsset,
    this.action,
    this.compact = false,
    this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    // Get the illustration asset path based on type
    final assetPath = illustrationAsset ?? _getIllustrationByType(type);
    
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 16.0 : 24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Illustration
            _buildIllustration(context, assetPath),
            
            SizedBox(height: compact ? 16.0 : 24.0),
            
            // Title
            Text(
              title,
              style: compact 
                ? BondTypography.subtitle1 
                : BondTypography.heading3,
              textAlign: TextAlign.center,
            ),
            
            SizedBox(height: compact ? 8.0 : 12.0),
            
            // Message
            Text(
              message,
              style: BondTypography.body1.copyWith(
                color: isDarkMode 
                  ? BondColors.slate 
                  : BondColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            
            // Action button if provided
            if (action != null) ...[
              SizedBox(height: compact ? 16.0 : 24.0),
              action!,
            ],
          ],
        ),
      ),
    );
  }
  
  /// Build the illustration widget
  Widget _buildIllustration(BuildContext context, String assetPath) {
    final size = compact ? 120.0 : 180.0;
    
    // Use a basic Image asset widget
    Widget illustration = Image.asset(
      assetPath,
      width: size,
      height: size,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to an icon if the image is not found
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: BondColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getIconByType(type),
            size: size / 2,
            color: BondColors.primary,
          ),
        );
      },
    );
    
    // Apply animation if provided
    if (animation != null) {
      illustration = AnimatedBuilder(
        animation: animation!,
        builder: (context, child) {
          return Transform.scale(
            scale: 0.8 + (0.2 * animation!.value),
            child: Opacity(
              opacity: 0.5 + (0.5 * animation!.value),
              child: child,
            ),
          );
        },
        child: illustration,
      );
    }
    
    return illustration;
  }
  
  /// Get illustration asset path based on type
  String _getIllustrationByType(BondEmptyStateType type) {
    switch (type) {
      case BondEmptyStateType.connections:
        return 'assets/illustrations/empty_states/connections.png';
      case BondEmptyStateType.meetings:
        return 'assets/illustrations/empty_states/meetings.png';
      case BondEmptyStateType.notifications:
        return 'assets/illustrations/empty_states/notifications.png';
      case BondEmptyStateType.messages:
        return 'assets/illustrations/empty_states/messages.png';
      case BondEmptyStateType.search:
        return 'assets/illustrations/empty_states/search.png';
      case BondEmptyStateType.error:
        return 'assets/illustrations/empty_states/error.png';
      case BondEmptyStateType.generic:
      default:
        return 'assets/illustrations/empty_states/generic.png';
    }
  }
  
  /// Get fallback icon based on type
  IconData _getIconByType(BondEmptyStateType type) {
    switch (type) {
      case BondEmptyStateType.connections:
        return Icons.people_outline;
      case BondEmptyStateType.meetings:
        return Icons.calendar_today;
      case BondEmptyStateType.notifications:
        return Icons.notifications_none;
      case BondEmptyStateType.messages:
        return Icons.chat_bubble_outline;
      case BondEmptyStateType.search:
        return Icons.search;
      case BondEmptyStateType.error:
        return Icons.error_outline;
      case BondEmptyStateType.generic:
      default:
        return Icons.inbox;
    }
  }
}

/// Factory class for common empty states
class BondEmptyStates {
  /// Create a connections empty state
  static BondEmptyState connections({
    String title = 'No Connections Yet',
    String message = 'Start exploring the discover tab to connect with others.',
    Widget? action,
    bool compact = false,
  }) {
    return BondEmptyState(
      title: title,
      message: message,
      type: BondEmptyStateType.connections,
      action: action ?? BondButton(
        label: 'Discover People',
        variant: BondButtonVariant.primary,
        onPressed: () {
          // Navigation would be handled by the caller
        },
      ),
      compact: compact,
    );
  }
  
  /// Create a meetings empty state
  static BondEmptyState meetings({
    String title = 'No Meetings Scheduled',
    String message = 'Schedule meetings with your connections to get started.',
    Widget? action,
    bool compact = false,
  }) {
    return BondEmptyState(
      title: title,
      message: message,
      type: BondEmptyStateType.meetings,
      action: action,
      compact: compact,
    );
  }
  
  /// Create a notifications empty state
  static BondEmptyState notifications({
    String title = 'No Notifications',
    String message = 'You\'ll see notifications about your activity here.',
    bool compact = false,
  }) {
    return BondEmptyState(
      title: title,
      message: message,
      type: BondEmptyStateType.notifications,
      compact: compact,
    );
  }
  
  /// Create a messages empty state
  static BondEmptyState messages({
    String title = 'No Messages',
    String message = 'Connect with people to start conversations.',
    Widget? action,
    bool compact = false,
  }) {
    return BondEmptyState(
      title: title,
      message: message,
      type: BondEmptyStateType.messages,
      action: action,
      compact: compact,
    );
  }
  
  /// Create a search empty state
  static BondEmptyState searchResults({
    String title = 'No Results Found',
    String message = 'Try adjusting your search criteria.',
    Widget? action,
    bool compact = false,
  }) {
    return BondEmptyState(
      title: title,
      message: message,
      type: BondEmptyStateType.search,
      action: action,
      compact: compact,
    );
  }
  
  /// Create an error state
  static BondEmptyState error({
    String title = 'Something Went Wrong',
    String message = 'We couldn\'t load the content. Please try again.',
    Widget? action,
    bool compact = false,
  }) {
    return BondEmptyState(
      title: title,
      message: message,
      type: BondEmptyStateType.error,
      action: action ?? BondButton(
        label: 'Try Again',
        variant: BondButtonVariant.primary,
        onPressed: () {
          // Retry action would be handled by the caller
        },
      ),
      compact: compact,
    );
  }
}