import 'package:equatable/equatable.dart';
import 'package:bond_app/features/auth/data/models/user_model.dart';

/// Base class for authentication states
abstract class AuthState extends Equatable {
  const AuthState();
  
  @override
  List<Object?> get props => [];
}

/// Initial state when the app starts
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State when authentication status is being determined
class AuthInProgress extends AuthState {
  const AuthInProgress();
}

/// State when a user is authenticated
class Authenticated extends AuthState {
  final UserModel user;
  
  const Authenticated(this.user);
  
  @override
  List<Object> get props => [user];
}

/// State when a user is not authenticated
class Unauthenticated extends AuthState {
  const Unauthenticated();
}

/// State when authentication fails
class AuthFailure extends AuthState {
  final String message;
  
  const AuthFailure(this.message);
  
  @override
  List<Object> get props => [message];
}

/// State when a password reset email is sent
class PasswordResetSent extends AuthState {
  const PasswordResetSent();
}

/// State when email verification is sent
class EmailVerificationSent extends AuthState {
  const EmailVerificationSent();
}

/// State when profile is updated
class ProfileUpdated extends AuthState {
  final UserModel user;
  
  const ProfileUpdated(this.user);
  
  @override
  List<Object> get props => [user];
}

/// State when account is deleted
class AccountDeleted extends AuthState {
  const AccountDeleted();
}
