import 'package:equatable/equatable.dart';

/// Base class for all notification events
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all notifications
class LoadAllNotificationsEvent extends NotificationEvent {
  const LoadAllNotificationsEvent();
}

/// Event to load only unread notifications
class LoadUnreadNotificationsEvent extends NotificationEvent {
  const LoadUnreadNotificationsEvent();
}

/// Event to mark a notification as read
class MarkNotificationAsReadEvent extends NotificationEvent {
  final String notificationId;

  const MarkNotificationAsReadEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to mark all notifications as read
class MarkAllNotificationsAsReadEvent extends NotificationEvent {
  const MarkAllNotificationsAsReadEvent();
}

/// Event to delete a notification
class DeleteNotificationEvent extends NotificationEvent {
  final String notificationId;

  const DeleteNotificationEvent(this.notificationId);

  @override
  List<Object?> get props => [notificationId];
}

/// Event to delete all notifications
class DeleteAllNotificationsEvent extends NotificationEvent {
  const DeleteAllNotificationsEvent();
}

/// Event to subscribe to real-time notifications
class SubscribeToNotificationsEvent extends NotificationEvent {
  const SubscribeToNotificationsEvent();
}

/// Event to unsubscribe from real-time notifications
class UnsubscribeFromNotificationsEvent extends NotificationEvent {
  const UnsubscribeFromNotificationsEvent();
}
