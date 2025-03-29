import 'package:bond_app/features/connections/data/models/connection_model.dart';

/// Repository interface for managing user connections
abstract class ConnectionRepository {
  /// Get all connections for a user
  Future<List<ConnectionModel>> getUserConnections(String userId);
  
  /// Get pending connection requests sent to a user
  Future<List<ConnectionModel>> getPendingRequests(String userId);
  
  /// Get pending connection requests sent by a user
  Future<List<ConnectionModel>> getSentRequests(String userId);
  
  /// Get accepted connections for a user
  Future<List<ConnectionModel>> getAcceptedConnections(String userId);
  
  /// Get a specific connection between two users
  Future<ConnectionModel?> getConnection(String userId1, String userId2);
  
  /// Send a connection request
  Future<ConnectionModel> sendConnectionRequest({
    required String senderId,
    required String receiverId,
    String? message,
  });
  
  /// Accept a connection request
  Future<ConnectionModel> acceptRequest(String connectionId);
  
  /// Decline a connection request
  Future<ConnectionModel> declineRequest(String connectionId);
  
  /// Block a connection
  Future<ConnectionModel> blockConnection(String connectionId);
  
  /// Mark a connection as read by the sender
  Future<ConnectionModel> markReadBySender(String connectionId);
  
  /// Mark a connection as read by the receiver
  Future<ConnectionModel> markReadByReceiver(String connectionId);
  
  /// Delete a connection
  Future<void> deleteConnection(String connectionId);
  
  /// Stream of connections for a user
  Stream<List<ConnectionModel>> connectionsStream(String userId);
  
  /// Stream of pending requests for a user
  Stream<List<ConnectionModel>> pendingRequestsStream(String userId);
  
  /// Stream of a specific connection
  Stream<ConnectionModel?> connectionStream(String connectionId);
}
