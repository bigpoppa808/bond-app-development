import '../entities/notification_entity.dart';
import '../models/notification_model.dart';

/// Adapter to convert between NotificationModel and NotificationEntity
class NotificationAdapter {
  /// Convert a NotificationModel to a NotificationEntity
  static NotificationEntity toEntity(NotificationModel model) {
    // Convert notification type to string for entity
    String typeString;
    switch (model.type) {
      case NotificationType.connectionRequest:
        typeString = 'friend';
        break;
      case NotificationType.connectionAccepted:
        typeString = 'friend';
        break;
      case NotificationType.message:
        typeString = 'message';
        break;
      case NotificationType.system:
        typeString = 'alert';
        break;
    }

    return NotificationEntity(
      id: model.id,
      title: model.title,
      message: model.body,
      type: typeString,
      isRead: model.isRead,
      createdAt: model.createdAt,
      data: model.data,
    );
  }

  /// Convert a list of NotificationModel to a list of NotificationEntity
  static List<NotificationEntity> toEntityList(List<NotificationModel> models) {
    return models.map((model) => toEntity(model)).toList();
  }

  /// Convert a NotificationEntity to a NotificationModel
  static NotificationModel toModel(NotificationEntity entity) {
    // Convert notification type string to enum
    NotificationType type;
    switch (entity.type.toLowerCase()) {
      case 'friend':
        type = NotificationType.connectionRequest;
        break;
      case 'message':
        type = NotificationType.message;
        break;
      case 'alert':
        type = NotificationType.system;
        break;
      default:
        type = NotificationType.system;
        break;
    }

    return NotificationModel(
      id: entity.id,
      title: entity.title,
      body: entity.message,
      type: type,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      data: entity.data,
    );
  }
}
