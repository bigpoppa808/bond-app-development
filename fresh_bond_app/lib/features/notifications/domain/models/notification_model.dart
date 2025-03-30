import 'package:equatable/equatable.dart';

/// Types of notifications that can be displayed in the app
enum NotificationType {
  /// New connection request received
  connectionRequest,
  
  /// Connection request accepted
  connectionAccepted,
  
  /// New message received
  message,
  
  /// System notification (app updates, etc.)
  system,
}

/// Model representing a notification in the app
class NotificationModel extends Equatable {
  /// Unique ID of the notification
  final String id;
  
  /// Title of the notification
  final String title;
  
  /// Body text of the notification
  final String body;
  
  /// Type of notification
  final NotificationType type;
  
  /// Whether the notification has been read
  final bool isRead;
  
  /// Timestamp when the notification was created
  final DateTime createdAt;
  
  /// Associated user ID (if applicable)
  final String? userId;
  
  /// Additional data for the notification (depends on type)
  final Map<String, dynamic>? data;

  const NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    this.isRead = false,
    required this.createdAt,
    this.userId,
    this.data,
  });

  /// Create a copy of this notification with updated values
  NotificationModel copyWith({
    String? id,
    String? title,
    String? body,
    NotificationType? type,
    bool? isRead,
    DateTime? createdAt,
    String? userId,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      data: data ?? this.data,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        body,
        type,
        isRead,
        createdAt,
        userId,
        data,
      ];
}
