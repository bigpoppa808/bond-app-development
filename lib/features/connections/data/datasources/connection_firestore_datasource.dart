import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bond_app/features/connections/data/models/connection_model.dart';

/// Firestore data source for connections
class ConnectionFirestoreDataSource {
  final FirebaseFirestore _firestore;
  
  /// Collection reference for connections
  final CollectionReference _connectionsCollection;
  
  /// Constructor
  ConnectionFirestoreDataSource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _connectionsCollection = (firestore ?? FirebaseFirestore.instance).collection('connections');
  
  /// Get all connections for a user
  Future<List<ConnectionModel>> getUserConnections(String userId) async {
    final querySnapshot = await _connectionsCollection
        .where(Filter.or(
          Filter('senderId', isEqualTo: userId),
          Filter('receiverId', isEqualTo: userId),
        ))
        .get();
    
    return querySnapshot.docs
        .map((doc) => ConnectionModel.fromFirestore(doc))
        .toList();
  }
  
  /// Get pending connection requests sent to a user
  Future<List<ConnectionModel>> getPendingRequests(String userId) async {
    final querySnapshot = await _connectionsCollection
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: ConnectionStatus.pending.toString().split('.').last)
        .get();
    
    return querySnapshot.docs
        .map((doc) => ConnectionModel.fromFirestore(doc))
        .toList();
  }
  
  /// Get pending connection requests sent by a user
  Future<List<ConnectionModel>> getSentRequests(String userId) async {
    final querySnapshot = await _connectionsCollection
        .where('senderId', isEqualTo: userId)
        .where('status', isEqualTo: ConnectionStatus.pending.toString().split('.').last)
        .get();
    
    return querySnapshot.docs
        .map((doc) => ConnectionModel.fromFirestore(doc))
        .toList();
  }
  
  /// Get accepted connections for a user
  Future<List<ConnectionModel>> getAcceptedConnections(String userId) async {
    final querySnapshot = await _connectionsCollection
        .where(Filter.or(
          Filter('senderId', isEqualTo: userId),
          Filter('receiverId', isEqualTo: userId),
        ))
        .where('status', isEqualTo: ConnectionStatus.accepted.toString().split('.').last)
        .get();
    
    return querySnapshot.docs
        .map((doc) => ConnectionModel.fromFirestore(doc))
        .toList();
  }
  
  /// Get a specific connection between two users
  Future<ConnectionModel?> getConnection(String userId1, String userId2) async {
    final querySnapshot1 = await _connectionsCollection
        .where('senderId', isEqualTo: userId1)
        .where('receiverId', isEqualTo: userId2)
        .limit(1)
        .get();
    
    if (querySnapshot1.docs.isNotEmpty) {
      return ConnectionModel.fromFirestore(querySnapshot1.docs.first);
    }
    
    final querySnapshot2 = await _connectionsCollection
        .where('senderId', isEqualTo: userId2)
        .where('receiverId', isEqualTo: userId1)
        .limit(1)
        .get();
    
    if (querySnapshot2.docs.isNotEmpty) {
      return ConnectionModel.fromFirestore(querySnapshot2.docs.first);
    }
    
    return null;
  }
  
  /// Send a connection request
  Future<ConnectionModel> sendConnectionRequest({
    required String senderId,
    required String receiverId,
    String? message,
  }) async {
    // Check if a connection already exists
    final existingConnection = await getConnection(senderId, receiverId);
    if (existingConnection != null) {
      throw Exception('A connection already exists between these users');
    }
    
    // Create a new connection request
    final connectionRequest = ConnectionModel.createRequest(
      senderId: senderId,
      receiverId: receiverId,
      message: message,
    );
    
    // Add to Firestore
    final docRef = await _connectionsCollection.add(connectionRequest.toFirestore());
    
    // Return the created connection with the document ID
    return connectionRequest;
  }
  
  /// Get a connection by ID
  Future<ConnectionModel?> getConnectionById(String connectionId) async {
    final docSnapshot = await _connectionsCollection.doc(connectionId).get();
    
    if (docSnapshot.exists) {
      return ConnectionModel.fromFirestore(docSnapshot);
    }
    
    return null;
  }
  
  /// Update a connection
  Future<ConnectionModel> updateConnection(String connectionId, ConnectionModel connection) async {
    await _connectionsCollection.doc(connectionId).update(connection.toFirestore());
    return connection;
  }
  
  /// Delete a connection
  Future<void> deleteConnection(String connectionId) async {
    await _connectionsCollection.doc(connectionId).delete();
  }
  
  /// Stream of connections for a user
  Stream<List<ConnectionModel>> connectionsStream(String userId) {
    return _connectionsCollection
        .where(Filter.or(
          Filter('senderId', isEqualTo: userId),
          Filter('receiverId', isEqualTo: userId),
        ))
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConnectionModel.fromFirestore(doc))
            .toList());
  }
  
  /// Stream of pending requests for a user
  Stream<List<ConnectionModel>> pendingRequestsStream(String userId) {
    return _connectionsCollection
        .where('receiverId', isEqualTo: userId)
        .where('status', isEqualTo: ConnectionStatus.pending.toString().split('.').last)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ConnectionModel.fromFirestore(doc))
            .toList());
  }
  
  /// Stream of a specific connection
  Stream<ConnectionModel?> connectionStream(String connectionId) {
    return _connectionsCollection
        .doc(connectionId)
        .snapshots()
        .map((snapshot) => snapshot.exists 
            ? ConnectionModel.fromFirestore(snapshot) 
            : null);
  }
}
