import 'package:fresh_bond_app/features/notifications/domain/models/notification_model.dart';

/// Repository interface for managing notifications
abstract class NotificationRepository {
  /// Get all notifications for the current user
  Future<List<NotificationModel>> getAllNotifications();
  
  /// Get unread notifications for the current user
  Future<List<NotificationModel>> getUnreadNotifications();
  
  /// Mark a notification as read
  Future<bool> markAsRead(String notificationId);
  
  /// Mark all notifications as read
  Future<bool> markAllAsRead();
  
  /// Delete a notification
  Future<bool> deleteNotification(String notificationId);
  
  /// Delete all notifications
  Future<bool> deleteAllNotifications();
  
  /// Subscribe to receive real-time notifications
  Future<void> subscribeToNotifications();
  
  /// Unsubscribe from real-time notifications
  Future<void> unsubscribeFromNotifications();
}
