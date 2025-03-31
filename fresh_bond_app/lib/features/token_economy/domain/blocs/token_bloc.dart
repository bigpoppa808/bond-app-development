import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../models/token_balance.dart';
import '../models/token_transaction.dart';
import '../repositories/token_repository.dart';

part 'token_event.dart';
part 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenRepository tokenRepository;

  TokenBloc({required this.tokenRepository}) : super(TokenInitial()) {
    on<FetchBalanceEvent>(_onFetchBalance);
    on<FetchTransactionsEvent>(_onFetchTransactions);
    on<EarnTokensEvent>(_onEarnTokens);
    on<SpendTokensEvent>(_onSpendTokens);
  }

  Future<void> _onFetchBalance(FetchBalanceEvent event, Emitter<TokenState> emit) async {
    try {
      emit(TokenLoading());
      
      final balance = await tokenRepository.getBalance(event.userId);
      
      emit(TokenBalanceLoaded(balance: balance));
    } catch (e) {
      emit(TokenError(message: 'Failed to fetch token balance: ${e.toString()}'));
    }
  }

  Future<void> _onFetchTransactions(
      FetchTransactionsEvent event, Emitter<TokenState> emit) async {
    try {
      emit(TokenLoading());
      
      final transactions = await tokenRepository.getTransactions(
        event.userId,
        limit: event.limit ?? 20,
        offset: event.offset ?? 0,
      );
      
      emit(TokenTransactionsLoaded(transactions: transactions));
    } catch (e) {
      emit(TokenError(message: 'Failed to fetch token transactions: ${e.toString()}'));
    }
  }

  Future<void> _onEarnTokens(EarnTokensEvent event, Emitter<TokenState> emit) async {
    try {
      emit(TokenProcessing());
      
      await tokenRepository.createTransaction(
        userId: event.userId,
        amount: event.amount,
        type: TokenTransactionType.earned,
        source: event.source,
        metadata: event.metadata,
      );
      
      final updatedBalance = await tokenRepository.getBalance(event.userId);
      
      emit(TokenEarned(
        amount: event.amount,
        source: event.source,
        balance: updatedBalance,
      ));
    } catch (e) {
      emit(TokenError(message: 'Failed to earn tokens: ${e.toString()}'));
    }
  }

  Future<void> _onSpendTokens(SpendTokensEvent event, Emitter<TokenState> emit) async {
    try {
      emit(TokenProcessing());
      
      // Check if user has enough tokens
      final currentBalance = await tokenRepository.getBalance(event.userId);
      
      if (currentBalance.balance < event.amount) {
        emit(TokenInsufficientBalance(
          requested: event.amount,
          available: currentBalance.balance,
        ));
        return;
      }
      
      await tokenRepository.createTransaction(
        userId: event.userId,
        amount: event.amount,
        type: TokenTransactionType.spent,
        source: event.source,
        metadata: event.metadata,
      );
      
      final updatedBalance = await tokenRepository.getBalance(event.userId);
      
      emit(TokenSpent(
        amount: event.amount,
        source: event.source,
        balance: updatedBalance,
      ));
    } catch (e) {
      emit(TokenError(message: 'Failed to spend tokens: ${e.toString()}'));
    }
  }
}
