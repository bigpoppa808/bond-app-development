import 'package:equatable/equatable.dart';

/// Model representing a user's token balance
class TokenBalance extends Equatable {
  /// The user ID associated with this balance
  final String userId;
  
  /// The current token balance
  final int balance;
  
  /// When the balance was last updated
  final DateTime lastUpdated;

  /// Creates a new token balance
  const TokenBalance({
    required this.userId,
    required this.balance,
    required this.lastUpdated,
  });

  /// Creates a copy of this token balance with the given fields replaced
  TokenBalance copyWith({
    String? userId,
    int? balance,
    DateTime? lastUpdated,
  }) {
    return TokenBalance(
      userId: userId ?? this.userId,
      balance: balance ?? this.balance,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Converts this object to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'balance': balance,
      'lastUpdated': lastUpdated.millisecondsSinceEpoch,
    };
  }

  /// Creates a token balance from a map
  factory TokenBalance.fromMap(Map<String, dynamic> map) {
    return TokenBalance(
      userId: map['userId'] as String,
      balance: map['balance'] as int,
      lastUpdated: DateTime.fromMillisecondsSinceEpoch(map['lastUpdated'] as int),
    );
  }

  /// Creates an empty token balance for a user with zero tokens
  factory TokenBalance.empty(String userId) {
    return TokenBalance(
      userId: userId,
      balance: 0,
      lastUpdated: DateTime.now(),
    );
  }

  @override
  List<Object> get props => [userId, balance, lastUpdated];
}