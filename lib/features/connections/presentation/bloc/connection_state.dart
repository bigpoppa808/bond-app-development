import 'package:equatable/equatable.dart';
import 'package:bond_app/features/connections/data/models/connection_model.dart';

/// Base class for all connection states
abstract class ConnectionState extends Equatable {
  /// Constructor
  const ConnectionState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class ConnectionInitial extends ConnectionState {}

/// State when connections are being loaded
class ConnectionsLoading extends ConnectionState {}

/// State when connections have been loaded successfully
class ConnectionsLoaded extends ConnectionState {
  /// List of all connections for the user
  final List<ConnectionModel> connections;

  /// Constructor
  const ConnectionsLoaded({required this.connections});

  @override
  List<Object?> get props => [connections];
}

/// State when pending requests have been loaded successfully
class PendingRequestsLoaded extends ConnectionState {
  /// List of pending connection requests for the user
  final List<ConnectionModel> pendingRequests;

  /// Constructor
  const PendingRequestsLoaded({required this.pendingRequests});

  @override
  List<Object?> get props => [pendingRequests];
}

/// State when sent requests have been loaded successfully
class SentRequestsLoaded extends ConnectionState {
  /// List of connection requests sent by the user
  final List<ConnectionModel> sentRequests;

  /// Constructor
  const SentRequestsLoaded({required this.sentRequests});

  @override
  List<Object?> get props => [sentRequests];
}

/// State when a connection request has been sent successfully
class ConnectionRequestSent extends ConnectionState {
  /// The connection that was created
  final ConnectionModel connection;

  /// Constructor
  const ConnectionRequestSent({required this.connection});

  @override
  List<Object?> get props => [connection];
}

/// State when a connection request has been accepted
class ConnectionRequestAccepted extends ConnectionState {
  /// The updated connection
  final ConnectionModel connection;

  /// Constructor
  const ConnectionRequestAccepted({required this.connection});

  @override
  List<Object?> get props => [connection];
}

/// State when a connection request has been declined
class ConnectionRequestDeclined extends ConnectionState {
  /// The updated connection
  final ConnectionModel connection;

  /// Constructor
  const ConnectionRequestDeclined({required this.connection});

  @override
  List<Object?> get props => [connection];
}

/// State when a connection has been blocked
class ConnectionBlocked extends ConnectionState {
  /// The updated connection
  final ConnectionModel connection;

  /// Constructor
  const ConnectionBlocked({required this.connection});

  @override
  List<Object?> get props => [connection];
}

/// State when a connection has been marked as read
class ConnectionMarkedAsRead extends ConnectionState {
  /// The updated connection
  final ConnectionModel connection;

  /// Constructor
  const ConnectionMarkedAsRead({required this.connection});

  @override
  List<Object?> get props => [connection];
}

/// State when a connection has been deleted
class ConnectionDeleted extends ConnectionState {
  /// ID of the deleted connection
  final String connectionId;

  /// Constructor
  const ConnectionDeleted({required this.connectionId});

  @override
  List<Object?> get props => [connectionId];
}

/// State when an error occurs
class ConnectionError extends ConnectionState {
  /// Error message
  final String message;

  /// Constructor
  const ConnectionError({required this.message});

  @override
  List<Object?> get props => [message];
}
