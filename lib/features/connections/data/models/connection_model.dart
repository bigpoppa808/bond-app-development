import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Status of a connection between users
enum ConnectionStatus {
  /// A connection request has been sent but not yet accepted or declined
  pending,
  
  /// The connection request has been accepted
  accepted,
  
  /// The connection request has been declined
  declined,
  
  /// The connection has been blocked
  blocked,
}

/// Model representing a connection between two users
class ConnectionModel extends Equatable {
  /// ID of the user who initiated the connection
  final String senderId;
  
  /// ID of the user who received the connection request
  final String receiverId;
  
  /// Current status of the connection
  final ConnectionStatus status;
  
  /// When the connection was created (request sent)
  final DateTime createdAt;
  
  /// When the connection status was last updated
  final DateTime updatedAt;
  
  /// Optional message sent with the connection request
  final String? message;
  
  /// Whether the sender has read the latest update
  final bool isSenderRead;
  
  /// Whether the receiver has read the latest update
  final bool isReceiverRead;

  /// Constructor
  const ConnectionModel({
    required this.senderId,
    required this.receiverId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.message,
    this.isSenderRead = false,
    this.isReceiverRead = false,
  });

  /// Create a new connection request
  factory ConnectionModel.createRequest({
    required String senderId,
    required String receiverId,
    String? message,
  }) {
    final now = DateTime.now();
    return ConnectionModel(
      senderId: senderId,
      receiverId: receiverId,
      status: ConnectionStatus.pending,
      createdAt: now,
      updatedAt: now,
      message: message,
      isSenderRead: true,
      isReceiverRead: false,
    );
  }

  /// Create a ConnectionModel from a Firestore document
  factory ConnectionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    
    return ConnectionModel(
      senderId: data['senderId'] as String,
      receiverId: data['receiverId'] as String,
      status: ConnectionStatus.values.firstWhere(
        (e) => e.toString() == 'ConnectionStatus.${data['status']}',
        orElse: () => ConnectionStatus.pending,
      ),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
      message: data['message'] as String?,
      isSenderRead: data['isSenderRead'] as bool? ?? false,
      isReceiverRead: data['isReceiverRead'] as bool? ?? false,
    );
  }

  /// Convert to a Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'status': status.toString().split('.').last,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'message': message,
      'isSenderRead': isSenderRead,
      'isReceiverRead': isReceiverRead,
    };
  }

  /// Create a copy of this ConnectionModel with the given fields replaced with new values
  ConnectionModel copyWith({
    String? senderId,
    String? receiverId,
    ConnectionStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? message,
    bool? isSenderRead,
    bool? isReceiverRead,
  }) {
    return ConnectionModel(
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      message: message ?? this.message,
      isSenderRead: isSenderRead ?? this.isSenderRead,
      isReceiverRead: isReceiverRead ?? this.isReceiverRead,
    );
  }

  /// Mark as read by the sender
  ConnectionModel markReadBySender() {
    return copyWith(
      isSenderRead: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Mark as read by the receiver
  ConnectionModel markReadByReceiver() {
    return copyWith(
      isReceiverRead: true,
      updatedAt: DateTime.now(),
    );
  }

  /// Accept the connection request
  ConnectionModel accept() {
    return copyWith(
      status: ConnectionStatus.accepted,
      updatedAt: DateTime.now(),
      isSenderRead: false,
      isReceiverRead: true,
    );
  }

  /// Decline the connection request
  ConnectionModel decline() {
    return copyWith(
      status: ConnectionStatus.declined,
      updatedAt: DateTime.now(),
      isSenderRead: false,
      isReceiverRead: true,
    );
  }

  /// Block the connection
  ConnectionModel block() {
    return copyWith(
      status: ConnectionStatus.blocked,
      updatedAt: DateTime.now(),
      isSenderRead: false,
      isReceiverRead: true,
    );
  }

  /// Check if this connection is with the given user
  bool isWithUser(String userId) {
    return senderId == userId || receiverId == userId;
  }

  /// Get the ID of the other user in this connection
  String getOtherUserId(String userId) {
    return senderId == userId ? receiverId : senderId;
  }

  /// Check if the connection is pending
  bool get isPending => status == ConnectionStatus.pending;

  /// Check if the connection is accepted
  bool get isAccepted => status == ConnectionStatus.accepted;

  /// Check if the connection is declined
  bool get isDeclined => status == ConnectionStatus.declined;

  /// Check if the connection is blocked
  bool get isBlocked => status == ConnectionStatus.blocked;

  @override
  List<Object?> get props => [
        senderId,
        receiverId,
        status,
        createdAt,
        updatedAt,
        message,
        isSenderRead,
        isReceiverRead,
      ];
}
