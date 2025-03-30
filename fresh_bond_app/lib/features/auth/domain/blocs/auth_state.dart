import 'package:equatable/equatable.dart';
import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final UserModel user;

  const AuthAuthenticatedState({required this.user});

  @override
  List<Object?> get props => [user];
}

class AuthUnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;

  const AuthErrorState({required this.message});

  @override
  List<Object?> get props => [message];
}

class AuthPasswordResetSentState extends AuthState {
  final String email;

  const AuthPasswordResetSentState({required this.email});

  @override
  List<Object?> get props => [email];
}
