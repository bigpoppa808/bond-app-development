import 'package:equatable/equatable.dart';
import 'package:fresh_bond_app/features/notifications/domain/models/notification_model.dart';

/// Base class for all notification states
abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state when bloc is first created
class NotificationInitialState extends NotificationState {
  const NotificationInitialState();
}

/// Loading state while fetching data
class NotificationLoadingState extends NotificationState {
  const NotificationLoadingState();
}

/// State representing successfully loaded notifications
class NotificationsLoadedState extends NotificationState {
  final List<NotificationModel> notifications;
  final int unreadCount;
  
  const NotificationsLoadedState(this.notifications, this.unreadCount);

  @override
  List<Object?> get props => [notifications, unreadCount];
}

/// State when only unread notifications are loaded
class UnreadNotificationsLoadedState extends NotificationState {
  final List<NotificationModel> notifications;
  
  const UnreadNotificationsLoadedState(this.notifications);

  @override
  List<Object?> get props => [notifications];
}

/// State representing successful notification read status update
class NotificationMarkedAsReadState extends NotificationState {
  final String notificationId;
  
  const NotificationMarkedAsReadState(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// State representing all notifications marked as read
class AllNotificationsMarkedAsReadState extends NotificationState {
  const AllNotificationsMarkedAsReadState();
}

/// State representing successful notification deletion
class NotificationDeletedState extends NotificationState {
  final String notificationId;
  
  const NotificationDeletedState(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// State representing all notifications deleted
class AllNotificationsDeletedState extends NotificationState {
  const AllNotificationsDeletedState();
}

/// Success state for notification actions
class NotificationActionSuccessState extends NotificationState {
  final String message;
  
  const NotificationActionSuccessState(this.message);

  @override
  List<Object?> get props => [message];
}

/// Error state
class NotificationErrorState extends NotificationState {
  final String message;
  
  const NotificationErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
