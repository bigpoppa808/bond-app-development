import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/bond_design_system.dart';
import '../../domain/adapters/notification_adapter.dart';
import '../../domain/entities/notification_entity.dart';
import '../../domain/blocs/notification_bloc.dart';
import '../../domain/blocs/notification_event.dart';
import '../../domain/blocs/notification_state.dart';

/// A redesigned Notifications screen that applies the Bond Design System
/// with Neo-Glassmorphism, Bento Box layout, and micro-interactions.
class NotificationsScreenV2 extends StatefulWidget {
  const NotificationsScreenV2({Key? key}) : super(key: key);

  @override
  State<NotificationsScreenV2> createState() => _NotificationsScreenV2State();
}

class _NotificationsScreenV2State extends State<NotificationsScreenV2> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _showAllNotifications = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _showAllNotifications = _tabController.index == 0;
      });
      
      // Load appropriate notifications based on selected tab
      if (_tabController.index == 0) {
        context.read<NotificationBloc>().add(LoadAllNotificationsEvent());
      } else {
        context.read<NotificationBloc>().add(LoadUnreadNotificationsEvent());
      }
    });

    // Initial load of all notifications
    context.read<NotificationBloc>().add(LoadAllNotificationsEvent());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Background with subtle gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Theme.of(context).brightness == Brightness.dark
                        ? BondColors.night.withOpacity(0.9)
                        : BondColors.snow.withOpacity(0.9),
                    Theme.of(context).brightness == Brightness.dark
                        ? BondColors.night
                        : BondColors.snow,
                  ],
                ),
              ),
            ),
            
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with animated transitions
                _buildHeaderSection(context),
                
                // Tab bar for notification filtering
                _buildTabBar(context),
                
                // Notifications list
                Expanded(
                  child: BlocBuilder<NotificationBloc, NotificationState>(
                    builder: (context, state) {
                      if (state is NotificationLoadingState) {
                        return _buildLoadingState();
                      } else if (state is NotificationsLoadedState) {
                        final notificationEntities = NotificationAdapter.toEntityList(
                          state.notifications,
                        );
                        
                        if (notificationEntities.isEmpty) {
                          return _buildEmptyState();
                        }
                        
                        return _buildNotificationsList(notificationEntities);
                      } else if (state is UnreadNotificationsLoadedState) {
                        final notificationEntities = NotificationAdapter.toEntityList(
                          state.notifications,
                        );
                            
                        if (notificationEntities.isEmpty) {
                          return _buildEmptyState();
                        }
                        
                        return _buildNotificationsList(notificationEntities);
                      } else if (state is NotificationErrorState) {
                        return _buildErrorState(state.message);
                      }
                      
                      return _buildLoadingState();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          // Back button with glass effect
          BondCard(
            borderRadius: BondDesignSystem.tokens.radiusCircular,
            padding: EdgeInsets.zero,
            height: 44,
            width: 44,
            elevated: true,
            onTap: () => context.go('/home'),
            child: const Center(
              child: Icon(Icons.arrow_back_rounded),
            ),
          ),
          const SizedBox(width: 16),
          
          // Title with secondary font
          Expanded(
            child: Text(
              'Notifications',
              style: BondTypography.heading2(context),
            ),
          ),
          
          // Mark all as read button
          BlocBuilder<NotificationBloc, NotificationState>(
            builder: (context, state) {
              if (state is NotificationsLoadedState || state is UnreadNotificationsLoadedState) {
                final hasUnread = state is NotificationsLoadedState
                    ? state.notifications.any((n) => !n.isRead)
                    : (state as UnreadNotificationsLoadedState).notifications.isNotEmpty;
                    
                if (hasUnread) {
                  return BondButton(
                    variant: BondButtonVariant.icon,
                    icon: Icons.done_all_rounded,
                    height: 44,
                    useGlass: true,
                    onPressed: () {
                      context.read<NotificationBloc>().add(MarkAllNotificationsAsReadEvent());
                    },
                  );
                }
              }
              
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
      child: BondCard(
        borderRadius: BondDesignSystem.tokens.radiusL,
        padding: const EdgeInsets.all(4),
        child: TabBar(
          controller: _tabController,
          indicatorSize: TabBarIndicatorSize.tab,
          indicator: BoxDecoration(
            borderRadius: BorderRadius.circular(BondDesignSystem.tokens.radiusM),
            color: BondColors.bondTeal,
          ),
          labelColor: Colors.white,
          unselectedLabelColor: Theme.of(context).brightness == Brightness.dark
              ? BondColors.cloud
              : BondColors.slate,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsList(List<NotificationEntity> notifications) {
    // Group notifications by date
    final groupedNotifications = _groupNotificationsByDate(notifications);
    
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      itemCount: groupedNotifications.length,
      itemBuilder: (context, index) {
        final dateGroup = groupedNotifications.keys.elementAt(index);
        final notificationsInGroup = groupedNotifications[dateGroup]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.only(left: 8, top: 16, bottom: 8),
              child: Text(
                dateGroup,
                style: BondTypography.caption(context).copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? BondColors.mist
                      : BondColors.slate,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            
            // Use BentoGrid for an interesting layout
            // On mobile, we'll keep a single column, but on tablet+
            // we'll switch to a multi-column layout
            BondBentoGrid(
              children: notificationsInGroup.map((notification) {
                return _buildNotificationItem(notification);
              }).toList(),
              mobileColumns: 1,
              tabletColumns: 2,
              desktopColumns: 3,
              spacing: 12,
            ),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(NotificationEntity notification) {
    // Convert our existing notification to use the new BondNotificationItem component
    return BondNotificationItem(
      title: notification.title,
      message: notification.message,
      timestamp: notification.createdAt,
      isRead: notification.isRead,
      priority: _getNotificationPriority(notification.type),
      onTap: () {
        // If unread, mark as read when tapped
        if (!notification.isRead) {
          context.read<NotificationBloc>().add(MarkNotificationAsReadEvent(notification.id));
        }
        
        // Handle notification tap (e.g., navigate to relevant screen)
        _handleNotificationTap(notification);
      },
      actions: [
        // Mark as read/unread toggle
        IconButton(
          icon: Icon(
            notification.isRead ? Icons.visibility_off : Icons.visibility,
            size: 20,
          ),
          onPressed: () {
            if (notification.isRead) {
              context.read<NotificationBloc>().add(MarkNotificationAsReadEvent(notification.id));
            } else {
              context.read<NotificationBloc>().add(MarkNotificationAsReadEvent(notification.id));
            }
          },
        ),
        
        // Delete notification
        IconButton(
          icon: const Icon(Icons.delete_outline, size: 20),
          onPressed: () {
            context.read<NotificationBloc>().add(DeleteNotificationEvent(notification.id));
          },
        ),
      ],
      avatar: _buildNotificationAvatar(notification),
    );
  }

  // Convert notification type to priority
  NotificationPriority _getNotificationPriority(String type) {
    switch (type.toLowerCase()) {
      case 'alert':
        return NotificationPriority.high;
      case 'action':
        return NotificationPriority.medium;
      default:
        return NotificationPriority.low;
    }
  }
  
  // Create an avatar widget based on notification type
  Widget? _buildNotificationAvatar(NotificationEntity notification) {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type.toLowerCase()) {
      case 'message':
        iconData = Icons.message_rounded;
        iconColor = BondColors.connectionPurple;
        break;
      case 'friend':
        iconData = Icons.person_add_rounded;
        iconColor = BondColors.trustBlue;
        break;
      case 'alert':
        iconData = Icons.notification_important_rounded;
        iconColor = BondColors.error;
        break;
      case 'action':
        iconData = Icons.pending_actions_rounded;
        iconColor = BondColors.warmthOrange;
        break;
      default:
        iconData = Icons.notifications_rounded;
        iconColor = BondColors.bondTeal;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.2),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Icon(
          iconData,
          color: iconColor,
          size: 20,
        ),
      ),
    );
  }
  
  void _handleNotificationTap(NotificationEntity notification) {
    // Handle navigation based on notification type
    // Implementation depends on app navigation structure
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(BondColors.bondTeal),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading notifications...',
            style: BondTypography.body(context),
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
            Icons.notifications_off_rounded,
            size: 64,
            color: Theme.of(context).brightness == Brightness.dark
                ? BondColors.mist
                : BondColors.slate,
          ),
          const SizedBox(height: 16),
          Text(
            _showAllNotifications 
                ? 'No notifications yet' 
                : 'No unread notifications',
            style: BondTypography.heading3(context),
          ),
          const SizedBox(height: 8),
          Text(
            _showAllNotifications
                ? 'You\'ll be notified when something happens'
                : 'Check the "All" tab to see previous notifications',
            style: BondTypography.body(context).copyWith(
              color: Theme.of(context).brightness == Brightness.dark
                  ? BondColors.mist
                  : BondColors.slate,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 64,
            color: BondColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Something went wrong',
            style: BondTypography.heading3(context),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: BondTypography.body(context),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          BondButton(
            label: 'Try Again',
            onPressed: () {
              context.read<NotificationBloc>().add(
                _showAllNotifications 
                    ? LoadAllNotificationsEvent() 
                    : LoadUnreadNotificationsEvent()
              );
            },
          ),
        ],
      ),
    );
  }

  // Helper function to group notifications by date
  Map<String, List<NotificationEntity>> _groupNotificationsByDate(
      List<NotificationEntity> notifications) {
    final Map<String, List<NotificationEntity>> groupedNotifications = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final notification in notifications) {
      final createdDate = DateTime(
        notification.createdAt.year,
        notification.createdAt.month,
        notification.createdAt.day,
      );

      String groupTitle;
      if (createdDate == today) {
        groupTitle = 'Today';
      } else if (createdDate == yesterday) {
        groupTitle = 'Yesterday';
      } else if (now.difference(createdDate).inDays < 7) {
        // Within the last week, show day name
        groupTitle = DateFormat('EEEE').format(createdDate);
      } else {
        // Older than a week, show date
        groupTitle = DateFormat('MMM d, y').format(createdDate);
      }

      if (!groupedNotifications.containsKey(groupTitle)) {
        groupedNotifications[groupTitle] = [];
      }
      groupedNotifications[groupTitle]!.add(notification);
    }

    return groupedNotifications;
  }
}
