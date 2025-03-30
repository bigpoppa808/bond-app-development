import 'package:equatable/equatable.dart';

/// Model representing a user connection
class ConnectionModel extends Equatable {
  final String id;
  final String name;
  final String? avatarUrl;
  final String? bio;
  final String? email;
  final bool isConnected;
  final ConnectionType type;
  final List<String> mutualConnections;

  const ConnectionModel({
    required this.id,
    required this.name,
    this.avatarUrl,
    this.bio,
    this.email,
    this.isConnected = false,
    this.type = ConnectionType.other,
    this.mutualConnections = const [],
  });

  @override
  List<Object?> get props => [
        id,
        name,
        avatarUrl,
        bio,
        email,
        isConnected,
        type,
        mutualConnections,
      ];

  /// Create a copy of this connection with modified fields
  ConnectionModel copyWith({
    String? id,
    String? name,
    String? avatarUrl,
    String? bio,
    String? email,
    bool? isConnected,
    ConnectionType? type,
    List<String>? mutualConnections,
  }) {
    return ConnectionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      email: email ?? this.email,
      isConnected: isConnected ?? this.isConnected,
      type: type ?? this.type,
      mutualConnections: mutualConnections ?? this.mutualConnections,
    );
  }

  /// Factory to create a connection from json data
  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      email: json['email'] as String?,
      isConnected: json['is_connected'] as bool? ?? false,
      type: _typeFromString(json['type'] as String?),
      mutualConnections: (json['mutual_connections'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }

  /// Convert connection to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar_url': avatarUrl,
      'bio': bio,
      'email': email,
      'is_connected': isConnected,
      'type': type.toString().split('.').last,
      'mutual_connections': mutualConnections,
    };
  }

  /// Helper method to convert string to ConnectionType
  static ConnectionType _typeFromString(String? type) {
    switch (type) {
      case 'family':
        return ConnectionType.family;
      case 'friend':
        return ConnectionType.friend;
      case 'colleague':
        return ConnectionType.colleague;
      case 'acquaintance':
        return ConnectionType.acquaintance;
      default:
        return ConnectionType.other;
    }
  }
}

/// Enum representing different types of connections
enum ConnectionType {
  family,
  friend,
  colleague,
  acquaintance,
  other,
}
