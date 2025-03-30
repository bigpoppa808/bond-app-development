import 'package:equatable/equatable.dart';

/// Entity representing a notification in the Bond app
class NotificationEntity extends Equatable {
  /// Unique identifier for the notification
  final String id;
  
  /// Title of the notification
  final String title;
  
  /// Detailed message content
  final String message;
  
  /// Type of notification (message, friend, alert, action, etc.)
  final String type;
  
  /// Whether the notification has been read by the user
  final bool isRead;
  
  /// When the notification was created
  final DateTime createdAt;
  
  /// Optional data related to the notification (e.g., user ID, post ID)
  final Map<String, dynamic>? data;

  /// Constructor
  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  @override
  List<Object?> get props => [id, title, message, type, isRead, createdAt, data];

  /// Create a copy of this notification with some fields changed
  NotificationEntity copyWith({
    String? id,
    String? title,
    String? message,
    String? type,
    bool? isRead,
    DateTime? createdAt,
    Map<String, dynamic>? data,
  }) {
    return NotificationEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      data: data ?? this.data,
    );
  }

  /// Convenience factory to create a notification as read
  factory NotificationEntity.asRead(NotificationEntity notification) {
    return notification.copyWith(isRead: true);
  }

  /// Convenience factory to create a notification as unread
  factory NotificationEntity.asUnread(NotificationEntity notification) {
    return notification.copyWith(isRead: false);
  }
}
