part of 'token_bloc.dart';

abstract class TokenState extends Equatable {
  const TokenState();
  
  @override
  List<Object> get props => [];
}

class TokenInitial extends TokenState {}

class TokenLoading extends TokenState {}

class TokenProcessing extends TokenState {}

class TokenBalanceLoaded extends TokenState {
  final TokenBalance balance;

  const TokenBalanceLoaded({required this.balance});

  @override
  List<Object> get props => [balance];
}

class TokenTransactionsLoaded extends TokenState {
  final List<TokenTransaction> transactions;

  const TokenTransactionsLoaded({required this.transactions});

  @override
  List<Object> get props => [transactions];
}

class TokenEarned extends TokenState {
  final int amount;
  final String source;
  final TokenBalance balance;

  const TokenEarned({
    required this.amount,
    required this.source,
    required this.balance,
  });

  @override
  List<Object> get props => [amount, source, balance];
}

class TokenSpent extends TokenState {
  final int amount;
  final String source;
  final TokenBalance balance;

  const TokenSpent({
    required this.amount,
    required this.source,
    required this.balance,
  });

  @override
  List<Object> get props => [amount, source, balance];
}

class TokenInsufficientBalance extends TokenState {
  final int requested;
  final int available;

  const TokenInsufficientBalance({
    required this.requested,
    required this.available,
  });

  @override
  List<Object> get props => [requested, available];
}

class TokenError extends TokenState {
  final String message;

  const TokenError({required this.message});

  @override
  List<Object> get props => [message];
}
