import 'package:flutter/material.dart';
import 'package:fresh_bond_app/app/theme.dart';
import 'package:fresh_bond_app/features/notifications/domain/models/notification_model.dart';
import 'package:intl/intl.dart';

/// Widget that displays a single notification item
class NotificationItem extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;
  final VoidCallback onMarkAsRead;
  final VoidCallback onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    required this.onTap,
    required this.onMarkAsRead,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(notification.id),
      background: Container(
        color: BondAppTheme.errorColor,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDelete(),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: notification.isRead
                ? BondAppTheme.backgroundPrimary
                : BondAppTheme.primaryColor.withOpacity(0.08),
            border: Border(
              bottom: BorderSide(
                color: const Color(0xFFD1D5DB), // Use the same color as in input decoration borders
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Notification icon
              _buildNotificationIcon(),
              const SizedBox(width: 16),
              
              // Notification content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      notification.title,
                      style: TextStyle(
                        fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    
                    // Body
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: BondAppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Time
                    Text(
                      _formatTime(notification.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: BondAppTheme.textTertiary,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Action buttons
              if (!notification.isRead)
                IconButton(
                  icon: const Icon(Icons.done),
                  tooltip: 'Mark as read',
                  onPressed: onMarkAsRead,
                  iconSize: 20,
                  color: BondAppTheme.primaryColor,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon() {
    final IconData iconData;
    final Color iconColor;
    
    switch (notification.type) {
      case NotificationType.connectionRequest:
        iconData = Icons.person_add;
        iconColor = Colors.blue;
        break;
      case NotificationType.connectionAccepted:
        iconData = Icons.people;
        iconColor = Colors.green;
        break;
      case NotificationType.message:
        iconData = Icons.message;
        iconColor = Colors.purple;
        break;
      case NotificationType.system:
        iconData = Icons.info;
        iconColor = Colors.orange;
        break;
    }
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final notificationDate = DateTime(time.year, time.month, time.day);
    
    if (notificationDate == today) {
      // Today - show time
      return DateFormat('h:mm a').format(time);
    } else if (notificationDate == yesterday) {
      // Yesterday
      return 'Yesterday, ${DateFormat('h:mm a').format(time)}';
    } else if (now.difference(time).inDays < 7) {
      // Within a week - show day name
      return DateFormat('EEEE, h:mm a').format(time);
    } else {
      // Older - show full date
      return DateFormat('MMM d, h:mm a').format(time);
    }
  }
}
