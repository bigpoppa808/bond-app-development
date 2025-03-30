import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/analytics/analytics_service.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_event.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_state.dart';
import 'package:fresh_bond_app/features/notifications/domain/repositories/notification_repository.dart';

/// BLoC for managing the notifications feature
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository _notificationRepository;
  final AppLogger _logger;

  NotificationBloc({
    required NotificationRepository notificationRepository,
    required AppLogger logger,
  })  : _notificationRepository = notificationRepository,
        _logger = logger,
        super(const NotificationInitialState()) {
    // Register event handlers
    on<LoadAllNotificationsEvent>(_onLoadAllNotifications);
    on<LoadUnreadNotificationsEvent>(_onLoadUnreadNotifications);
    on<MarkNotificationAsReadEvent>(_onMarkNotificationAsRead);
    on<MarkAllNotificationsAsReadEvent>(_onMarkAllNotificationsAsRead);
    on<DeleteNotificationEvent>(_onDeleteNotification);
    on<DeleteAllNotificationsEvent>(_onDeleteAllNotifications);
    on<SubscribeToNotificationsEvent>(_onSubscribeToNotifications);
    on<UnsubscribeFromNotificationsEvent>(_onUnsubscribeFromNotifications);
  }

  /// Handle loading all notifications
  Future<void> _onLoadAllNotifications(
    LoadAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _logger.d('Loading all notifications');
      emit(const NotificationLoadingState());
      
      final notifications = await _notificationRepository.getAllNotifications();
      final unreadCount = notifications.where((n) => !n.isRead).length;
      
      emit(NotificationsLoadedState(notifications, unreadCount));
      
      // Track analytics
      AnalyticsService.instance.logEvent('view_all_notifications', 
        parameters: {
          'count': notifications.length,
          'unread_count': unreadCount,
        });
    } catch (e) {
      _logger.e('Error loading notifications', error: e);
      emit(NotificationErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error loading notifications: ${e.toString()}');
    }
  }

  /// Handle loading unread notifications
  Future<void> _onLoadUnreadNotifications(
    LoadUnreadNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _logger.d('Loading unread notifications');
      emit(const NotificationLoadingState());
      
      final notifications = await _notificationRepository.getUnreadNotifications();
      
      emit(UnreadNotificationsLoadedState(notifications));
      
      // Track analytics
      AnalyticsService.instance.logEvent('view_unread_notifications', 
        parameters: {'count': notifications.length});
    } catch (e) {
      _logger.e('Error loading unread notifications', error: e);
      emit(NotificationErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error loading unread notifications: ${e.toString()}');
    }
  }

  /// Handle marking a notification as read
  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _logger.d('Marking notification as read: ${event.notificationId}');
      
      final success = await _notificationRepository.markAsRead(event.notificationId);
      
      if (success) {
        emit(NotificationMarkedAsReadState(event.notificationId));
        
        // Refresh notifications list
        add(const LoadAllNotificationsEvent());
        
        // Track analytics
        AnalyticsService.instance.logEvent('mark_notification_as_read', 
          parameters: {'notification_id': event.notificationId});
      } else {
        emit(const NotificationErrorState('Failed to mark notification as read'));
      }
    } catch (e) {
      _logger.e('Error marking notification as read', error: e);
      emit(NotificationErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error marking notification as read: ${e.toString()}');
    }
  }

  /// Handle marking all notifications as read
  Future<void> _onMarkAllNotificationsAsRead(
    MarkAllNotificationsAsReadEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _logger.d('Marking all notifications as read');
      
      final success = await _notificationRepository.markAllAsRead();
      
      if (success) {
        emit(const AllNotificationsMarkedAsReadState());
        
        // Refresh notifications list
        add(const LoadAllNotificationsEvent());
        
        // Track analytics
        AnalyticsService.instance.logEvent('mark_all_notifications_as_read');
      } else {
        emit(const NotificationErrorState('Failed to mark all notifications as read'));
      }
    } catch (e) {
      _logger.e('Error marking all notifications as read', error: e);
      emit(NotificationErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error marking all notifications as read: ${e.toString()}');
    }
  }

  /// Handle deleting a notification
  Future<void> _onDeleteNotification(
    DeleteNotificationEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _logger.d('Deleting notification: ${event.notificationId}');
      
      final success = await _notificationRepository.deleteNotification(event.notificationId);
      
      if (success) {
        emit(NotificationDeletedState(event.notificationId));
        
        // Refresh notifications list
        add(const LoadAllNotificationsEvent());
        
        // Track analytics
        AnalyticsService.instance.logEvent('delete_notification', 
          parameters: {'notification_id': event.notificationId});
      } else {
        emit(const NotificationErrorState('Failed to delete notification'));
      }
    } catch (e) {
      _logger.e('Error deleting notification', error: e);
      emit(NotificationErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error deleting notification: ${e.toString()}');
    }
  }

  /// Handle deleting all notifications
  Future<void> _onDeleteAllNotifications(
    DeleteAllNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _logger.d('Deleting all notifications');
      
      final success = await _notificationRepository.deleteAllNotifications();
      
      if (success) {
        emit(const AllNotificationsDeletedState());
        
        // Refresh notifications list
        add(const LoadAllNotificationsEvent());
        
        // Track analytics
        AnalyticsService.instance.logEvent('delete_all_notifications');
      } else {
        emit(const NotificationErrorState('Failed to delete all notifications'));
      }
    } catch (e) {
      _logger.e('Error deleting all notifications', error: e);
      emit(NotificationErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error deleting all notifications: ${e.toString()}');
    }
  }

  /// Handle subscribing to real-time notifications
  Future<void> _onSubscribeToNotifications(
    SubscribeToNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _logger.d('Subscribing to notifications');
      
      await _notificationRepository.subscribeToNotifications();
      
      // Track analytics
      AnalyticsService.instance.logEvent('subscribe_to_notifications');
    } catch (e) {
      _logger.e('Error subscribing to notifications', error: e);
      emit(NotificationErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error subscribing to notifications: ${e.toString()}');
    }
  }

  /// Handle unsubscribing from real-time notifications
  Future<void> _onUnsubscribeFromNotifications(
    UnsubscribeFromNotificationsEvent event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      _logger.d('Unsubscribing from notifications');
      
      await _notificationRepository.unsubscribeFromNotifications();
      
      // Track analytics
      AnalyticsService.instance.logEvent('unsubscribe_from_notifications');
    } catch (e) {
      _logger.e('Error unsubscribing from notifications', error: e);
      emit(NotificationErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error unsubscribing from notifications: ${e.toString()}');
    }
  }
}
