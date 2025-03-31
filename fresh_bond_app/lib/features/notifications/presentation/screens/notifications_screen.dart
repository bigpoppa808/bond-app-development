import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_spacing.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_bloc.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_event.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_state.dart';
import 'package:fresh_bond_app/features/notifications/domain/models/notification_model.dart';
import 'package:fresh_bond_app/features/notifications/presentation/widgets/notification_item.dart';
import 'package:intl/intl.dart';

/// Screen that displays user notifications
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    
    // Load notifications
    context.read<NotificationBloc>().add(const LoadAllNotificationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondColors.background,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: BondColors.backgroundSecondary,
        elevation: 0,
        actions: [
          // Mark all as read
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed: _markAllAsRead,
          ),
          // Clear all
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            tooltip: 'Delete all',
            onPressed: _deleteAllNotifications,
          ),
        ],
      ),
      body: BlocConsumer<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state is NotificationActionSuccessState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: BondColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
          } else if (state is NotificationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: BondColors.error,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoadingState) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is NotificationsLoadedState) {
            final notifications = state.notifications;
            
            if (notifications.isEmpty) {
              return _buildEmptyState();
            }
            
            // Group notifications by date
            final groupedNotifications = _groupNotificationsByDate(notifications);
            return _buildNotificationsList(groupedNotifications);
          } else if (state is NotificationErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.notifications_off,
                    size: 64,
                    color: BondColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load notifications',
                    style: TextStyle(
                      fontSize: 18,
                      color: BondColors.textSecondary,
                    ),
                  ),
                ],
              ),
            );
          }
          
          return const SizedBox.shrink();
        },
      ),
    );
  }
  
  Widget _buildNotificationsList(Map<String, List<NotificationModel>> groupedNotifications) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8, bottom: 16),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        final dateGroup = groupedNotifications.keys.elementAt(index);
        final notificationsInGroup = groupedNotifications[dateGroup]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                dateGroup,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: BondColors.textSecondary,
                ),
              ),
            ),
            ...notificationsInGroup.map((notification) => NotificationItem(
              notification: notification,
              onTap: () => _handleNotificationTap(notification),
              onMarkAsRead: () => _markAsRead(notification.id),
              onDelete: () => _deleteNotification(notification.id),
            )),
          ],
        );
      },
    );
  }

  /// Group notifications by date (Today, Yesterday, This Week, etc.)
  Map<String, List<NotificationModel>> _groupNotificationsByDate(
    List<NotificationModel> notifications
  ) {
    final Map<String, List<NotificationModel>> grouped = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    for (final notification in notifications) {
      final notificationDate = notification.createdAt;
      final difference = today.difference(
        DateTime(notificationDate.year, notificationDate.month, notificationDate.day)
      ).inDays;
      
      final String groupKey;
      if (difference == 0) {
        groupKey = 'Today';
      } else if (difference == 1) {
        groupKey = 'Yesterday';
      } else if (difference < 7) {
        groupKey = 'This Week';
      } else if (difference < 30) {
        groupKey = 'This Month';
      } else {
        groupKey = DateFormat('MMMM yyyy').format(notificationDate);
      }
      
      if (grouped.containsKey(groupKey)) {
        grouped[groupKey]!.add(notification);
      } else {
        grouped[groupKey] = [notification];
      }
    }
    
    return grouped;
  }

  void _handleNotificationTap(NotificationModel notification) {
    // Mark as read when tapped
    if (!notification.isRead) {
      _markAsRead(notification.id);
    }
    
    // Handle different notification types
    switch (notification.type) {
      case NotificationType.connectionRequest:
        // Navigate to connection requests
        if (notification.userId != null) {
          // In a real app, navigate to user profile or requests screen
          _showNotificationActionDialog(
            'Connection Request',
            'View and respond to ${notification.title}?',
            'View Request',
            () {
              // Navigate to connection request screen
              Navigator.of(context).pop();
              // context.go('/discover');
            },
          );
        }
        break;
        
      case NotificationType.connectionAccepted:
        // Navigate to new connection's profile
        if (notification.userId != null) {
          _showNotificationActionDialog(
            'Connection Accepted',
            'View this connection\'s profile?',
            'View Profile',
            () {
              // Navigate to profile screen
              Navigator.of(context).pop();
              // context.go('/profile/${notification.userId}');
            },
          );
        }
        break;
        
      case NotificationType.message:
        // Navigate to message conversation
        if (notification.data?.containsKey('conversationId') ?? false) {
          _showNotificationActionDialog(
            'New Message',
            'View this conversation?',
            'View Messages',
            () {
              // Navigate to messages screen
              Navigator.of(context).pop();
              // context.go('/messages/${notification.data!['conversationId']}');
            },
          );
        }
        break;
        
      case NotificationType.system:
        // System notifications might not need any action
        break;
    }
  }

  void _showNotificationActionDialog(
    String title,
    String message,
    String actionText,
    VoidCallback onAction,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: BondColors.primary,
            ),
            child: Text(actionText),
          ),
        ],
      ),
    );
  }

  void _markAsRead(String notificationId) {
    context.read<NotificationBloc>().add(MarkNotificationAsReadEvent(notificationId));
  }

  void _markAllAsRead() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark All as Read'),
        content: const Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationBloc>().add(const MarkAllNotificationsAsReadEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BondColors.primary,
            ),
            child: const Text('Mark All'),
          ),
        ],
      ),
    );
  }

  void _deleteNotification(String notificationId) {
    context.read<NotificationBloc>().add(DeleteNotificationEvent(notificationId));
  }

  void _deleteAllNotifications() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete All Notifications'),
        content: const Text('Are you sure you want to delete all notifications? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<NotificationBloc>().add(const DeleteAllNotificationsEvent());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: BondColors.error,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 64,
            color: BondColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              color: BondColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
