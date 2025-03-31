import 'package:equatable/equatable.dart';

/// Types of token transactions
enum TokenTransactionType {
  /// Tokens earned by the user
  earned,
  
  /// Tokens spent by the user
  spent,
  
  /// Tokens adjusted by the system (e.g., for admin purposes)
  adjusted,
}

/// Model representing a token transaction
class TokenTransaction extends Equatable {
  /// Unique ID of the transaction
  final String id;
  
  /// User ID associated with this transaction
  final String userId;
  
  /// Amount of tokens involved in the transaction
  final int amount;
  
  /// Type of transaction (earned, spent, adjusted)
  final TokenTransactionType type;
  
  /// Description of the transaction
  final String description;
  
  /// Optional reference ID (e.g., meeting ID, achievement ID)
  final String? referenceId;
  
  /// Timestamp of when the transaction occurred
  final DateTime timestamp;

  /// Creates a new token transaction
  const TokenTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    this.referenceId,
    required this.timestamp,
  });

  /// Creates a copy of this token transaction with the given fields replaced
  TokenTransaction copyWith({
    String? id,
    String? userId,
    int? amount,
    TokenTransactionType? type,
    String? description,
    String? referenceId,
    DateTime? timestamp,
  }) {
    return TokenTransaction(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      description: description ?? this.description,
      referenceId: referenceId ?? this.referenceId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// Converts this object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'amount': amount,
      'type': type.index,
      'description': description,
      'referenceId': referenceId,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  /// Creates a token transaction from a map
  factory TokenTransaction.fromMap(Map<String, dynamic> map) {
    return TokenTransaction(
      id: map['id'] as String,
      userId: map['userId'] as String,
      amount: map['amount'] as int,
      type: TokenTransactionType.values[map['type'] as int],
      description: map['description'] as String,
      referenceId: map['referenceId'] as String?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] as int),
    );
  }

  @override
  List<Object?> get props => [id, userId, amount, type, description, referenceId, timestamp];
}