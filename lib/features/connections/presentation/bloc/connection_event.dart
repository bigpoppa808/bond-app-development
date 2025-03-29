import 'package:equatable/equatable.dart';

/// Base class for all connection events
abstract class ConnectionEvent extends Equatable {
  /// Constructor
  const ConnectionEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load all connections for the current user
class LoadConnections extends ConnectionEvent {
  /// User ID to load connections for
  final String userId;

  /// Constructor
  const LoadConnections({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to load pending connection requests for the current user
class LoadPendingRequests extends ConnectionEvent {
  /// User ID to load pending requests for
  final String userId;

  /// Constructor
  const LoadPendingRequests({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to load sent connection requests for the current user
class LoadSentRequests extends ConnectionEvent {
  /// User ID to load sent requests for
  final String userId;

  /// Constructor
  const LoadSentRequests({required this.userId});

  @override
  List<Object?> get props => [userId];
}

/// Event to send a connection request
class SendConnectionRequest extends ConnectionEvent {
  /// ID of the user sending the request
  final String senderId;
  
  /// ID of the user receiving the request
  final String receiverId;
  
  /// Optional message to include with the request
  final String? message;

  /// Constructor
  const SendConnectionRequest({
    required this.senderId,
    required this.receiverId,
    this.message,
  });

  @override
  List<Object?> get props => [senderId, receiverId, message];
}

/// Event to accept a connection request
class AcceptConnectionRequest extends ConnectionEvent {
  /// ID of the connection to accept
  final String connectionId;

  /// Constructor
  const AcceptConnectionRequest({required this.connectionId});

  @override
  List<Object?> get props => [connectionId];
}

/// Event to decline a connection request
class DeclineConnectionRequest extends ConnectionEvent {
  /// ID of the connection to decline
  final String connectionId;

  /// Constructor
  const DeclineConnectionRequest({required this.connectionId});

  @override
  List<Object?> get props => [connectionId];
}

/// Event to block a connection
class BlockConnection extends ConnectionEvent {
  /// ID of the connection to block
  final String connectionId;

  /// Constructor
  const BlockConnection({required this.connectionId});

  @override
  List<Object?> get props => [connectionId];
}

/// Event to mark a connection as read by the sender
class MarkConnectionReadBySender extends ConnectionEvent {
  /// ID of the connection to mark as read
  final String connectionId;

  /// Constructor
  const MarkConnectionReadBySender({required this.connectionId});

  @override
  List<Object?> get props => [connectionId];
}

/// Event to mark a connection as read by the receiver
class MarkConnectionReadByReceiver extends ConnectionEvent {
  /// ID of the connection to mark as read
  final String connectionId;

  /// Constructor
  const MarkConnectionReadByReceiver({required this.connectionId});

  @override
  List<Object?> get props => [connectionId];
}

/// Event to delete a connection
class DeleteConnection extends ConnectionEvent {
  /// ID of the connection to delete
  final String connectionId;

  /// Constructor
  const DeleteConnection({required this.connectionId});

  @override
  List<Object?> get props => [connectionId];
}

/// Event to refresh connections data
class RefreshConnections extends ConnectionEvent {
  /// User ID to refresh connections for
  final String userId;

  /// Constructor
  const RefreshConnections({required this.userId});

  @override
  List<Object?> get props => [userId];
}
