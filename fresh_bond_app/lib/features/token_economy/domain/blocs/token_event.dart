part of 'token_bloc.dart';

abstract class TokenEvent extends Equatable {
  const TokenEvent();

  @override
  List<Object> get props => [];
}

class FetchBalanceEvent extends TokenEvent {
  final String userId;

  const FetchBalanceEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class FetchTransactionsEvent extends TokenEvent {
  final String userId;
  final int? limit;
  final int? offset;

  const FetchTransactionsEvent({
    required this.userId,
    this.limit,
    this.offset,
  });

  @override
  List<Object> get props => [userId, limit ?? 0, offset ?? 0];
}

class EarnTokensEvent extends TokenEvent {
  final String userId;
  final int amount;
  final String source;
  final Map<String, dynamic>? metadata;

  const EarnTokensEvent({
    required this.userId,
    required this.amount,
    required this.source,
    this.metadata,
  });

  @override
  List<Object> get props => [userId, amount, source];
}

class SpendTokensEvent extends TokenEvent {
  final String userId;
  final int amount;
  final String source;
  final Map<String, dynamic>? metadata;

  const SpendTokensEvent({
    required this.userId,
    required this.amount,
    required this.source,
    this.metadata,
  });

  @override
  List<Object> get props => [userId, amount, source];
}
