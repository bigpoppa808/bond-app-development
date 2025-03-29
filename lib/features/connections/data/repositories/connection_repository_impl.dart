import 'package:bond_app/features/connections/data/datasources/connection_firestore_datasource.dart';
import 'package:bond_app/features/connections/data/models/connection_model.dart';
import 'package:bond_app/features/connections/domain/repositories/connection_repository.dart';

/// Implementation of the ConnectionRepository
class ConnectionRepositoryImpl implements ConnectionRepository {
  final ConnectionFirestoreDataSource _dataSource;
  
  /// Constructor
  ConnectionRepositoryImpl({
    required ConnectionFirestoreDataSource dataSource,
  }) : _dataSource = dataSource;
  
  @override
  Future<List<ConnectionModel>> getUserConnections(String userId) {
    return _dataSource.getUserConnections(userId);
  }
  
  @override
  Future<List<ConnectionModel>> getPendingRequests(String userId) {
    return _dataSource.getPendingRequests(userId);
  }
  
  @override
  Future<List<ConnectionModel>> getSentRequests(String userId) {
    return _dataSource.getSentRequests(userId);
  }
  
  @override
  Future<List<ConnectionModel>> getAcceptedConnections(String userId) {
    return _dataSource.getAcceptedConnections(userId);
  }
  
  @override
  Future<ConnectionModel?> getConnection(String userId1, String userId2) {
    return _dataSource.getConnection(userId1, userId2);
  }
  
  @override
  Future<ConnectionModel> sendConnectionRequest({
    required String senderId,
    required String receiverId,
    String? message,
  }) {
    return _dataSource.sendConnectionRequest(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
    );
  }
  
  @override
  Future<ConnectionModel> acceptRequest(String connectionId) async {
    final connection = await _dataSource.getConnectionById(connectionId);
    
    if (connection == null) {
      throw Exception('Connection not found');
    }
    
    if (connection.status != ConnectionStatus.pending) {
      throw Exception('Connection is not in pending state');
    }
    
    final updatedConnection = connection.accept();
    return _dataSource.updateConnection(connectionId, updatedConnection);
  }
  
  @override
  Future<ConnectionModel> declineRequest(String connectionId) async {
    final connection = await _dataSource.getConnectionById(connectionId);
    
    if (connection == null) {
      throw Exception('Connection not found');
    }
    
    if (connection.status != ConnectionStatus.pending) {
      throw Exception('Connection is not in pending state');
    }
    
    final updatedConnection = connection.decline();
    return _dataSource.updateConnection(connectionId, updatedConnection);
  }
  
  @override
  Future<ConnectionModel> blockConnection(String connectionId) async {
    final connection = await _dataSource.getConnectionById(connectionId);
    
    if (connection == null) {
      throw Exception('Connection not found');
    }
    
    final updatedConnection = connection.block();
    return _dataSource.updateConnection(connectionId, updatedConnection);
  }
  
  @override
  Future<ConnectionModel> markReadBySender(String connectionId) async {
    final connection = await _dataSource.getConnectionById(connectionId);
    
    if (connection == null) {
      throw Exception('Connection not found');
    }
    
    final updatedConnection = connection.markReadBySender();
    return _dataSource.updateConnection(connectionId, updatedConnection);
  }
  
  @override
  Future<ConnectionModel> markReadByReceiver(String connectionId) async {
    final connection = await _dataSource.getConnectionById(connectionId);
    
    if (connection == null) {
      throw Exception('Connection not found');
    }
    
    final updatedConnection = connection.markReadByReceiver();
    return _dataSource.updateConnection(connectionId, updatedConnection);
  }
  
  @override
  Future<void> deleteConnection(String connectionId) {
    return _dataSource.deleteConnection(connectionId);
  }
  
  @override
  Stream<List<ConnectionModel>> connectionsStream(String userId) {
    return _dataSource.connectionsStream(userId);
  }
  
  @override
  Stream<List<ConnectionModel>> pendingRequestsStream(String userId) {
    return _dataSource.pendingRequestsStream(userId);
  }
  
  @override
  Stream<ConnectionModel?> connectionStream(String connectionId) {
    return _dataSource.connectionStream(connectionId);
  }
}
