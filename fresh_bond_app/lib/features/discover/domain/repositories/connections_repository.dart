import 'package:fresh_bond_app/features/discover/domain/models/connection_model.dart';

/// Repository interface for handling user connections
abstract class ConnectionsRepository {
  /// Get recommended connections for the current user
  Future<List<ConnectionModel>> getRecommendedConnections();
  
  /// Search for connections based on a query string
  Future<List<ConnectionModel>> searchConnections(String query);
  
  /// Send a connection request to another user
  Future<bool> sendConnectionRequest(String userId);
  
  /// Accept a pending connection request
  Future<bool> acceptConnectionRequest(String userId);
  
  /// Reject a pending connection request
  Future<bool> rejectConnectionRequest(String userId);
  
  /// Get pending connection requests for the current user
  Future<List<ConnectionModel>> getPendingRequests();
  
  /// Get all connections for the current user
  Future<List<ConnectionModel>> getConnections();
  
  /// Get count of connections for a user
  Future<int> getConnectionCount(String userId);
}
