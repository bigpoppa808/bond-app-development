import 'package:flutter/material.dart';
import '../bond_colors.dart';
import '../bond_typography.dart';
import 'bond_card.dart';

/// Priority levels for notifications
enum NotificationPriority {
  low,
  medium,
  high,
}

/// A notification item component implementing the Bond Design System
///
/// Features:
/// - Priority visual indicators
/// - Read/unread state styling
/// - Timestamp with relative formatting
/// - Action buttons for quick responses
/// - Neo-Glassmorphism styling through BondCard
class BondNotificationItem extends StatelessWidget {
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final NotificationPriority priority;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;
  final Widget? avatar;
  final List<Widget>? actions;

  const BondNotificationItem({
    Key? key,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
    this.priority = NotificationPriority.medium,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
    this.avatar,
    this.actions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BondCard(
      borderRadius: 12.0,
      padding: EdgeInsets.zero,
      opacity: isRead ? 0.6 : 0.75, // Less opacity if read
      onTap: onTap,
      child: Column(
        children: [
          // Priority indicator
          Container(
            height: 4,
            decoration: BoxDecoration(
              color: _getPriorityColor(),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with avatar and timestamp
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (avatar != null) ...[
                      avatar!,
                      const SizedBox(width: 12),
                    ],
                    
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: BondTypography.heading3(context).copyWith(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          
                          Text(
                            _formatTimestamp(context, timestamp),
                            style: BondTypography.caption(context).copyWith(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? BondColors.mist
                                  : BondColors.slate,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Unread indicator
                    if (!isRead) _buildUnreadIndicator(),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // Message content
                Text(
                  message,
                  style: BondTypography.body(context).copyWith(
                    color: isRead 
                        ? Theme.of(context).brightness == Brightness.dark
                            ? BondColors.mist
                            : BondColors.slate 
                        : null,
                  ),
                ),
                
                if (actions != null) ...[
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: actions!,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnreadIndicator() {
    return Container(
      width: 10,
      height: 10,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _getPriorityColor(),
      ),
    );
  }

  Color _getPriorityColor() {
    switch (priority) {
      case NotificationPriority.low:
        return BondColors.info;
      case NotificationPriority.medium:
        return BondColors.warmthOrange;
      case NotificationPriority.high:
        return BondColors.error;
    }
  }

  String _formatTimestamp(BuildContext context, DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else if (difference.inDays < 365) {
      return '${(timestamp.month)}/${timestamp.day}';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}
