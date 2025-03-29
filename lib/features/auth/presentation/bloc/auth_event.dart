import 'package:equatable/equatable.dart';
import 'package:bond_app/features/auth/data/models/user_model.dart';

/// Base class for authentication events
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

/// Event to check the current authentication state
class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

/// Event when a user signs in with email and password
class SignInWithEmailPasswordRequested extends AuthEvent {
  final String email;
  final String password;

  const SignInWithEmailPasswordRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Event when a user signs up with email and password
class SignUpWithEmailPasswordRequested extends AuthEvent {
  final String email;
  final String password;
  final String displayName;

  const SignUpWithEmailPasswordRequested({
    required this.email,
    required this.password,
    required this.displayName,
  });

  @override
  List<Object> get props => [email, password, displayName];
}

/// Event when a user signs in with Google
class SignInWithGoogleRequested extends AuthEvent {
  const SignInWithGoogleRequested();
}

/// Event when a user signs in with Apple
class SignInWithAppleRequested extends AuthEvent {
  const SignInWithAppleRequested();
}

/// Event when a user requests a password reset
class PasswordResetRequested extends AuthEvent {
  final String email;

  const PasswordResetRequested({required this.email});

  @override
  List<Object> get props => [email];
}

/// Event when a user signs out
class SignOutRequested extends AuthEvent {
  const SignOutRequested();
}

/// Event when a user requests email verification
class EmailVerificationRequested extends AuthEvent {
  const EmailVerificationRequested();
}

/// Event when a user updates their profile
class UpdateProfileRequested extends AuthEvent {
  final UserModel user;

  const UpdateProfileRequested({required this.user});

  @override
  List<Object> get props => [user];
}

/// Event when a user deletes their account
class DeleteAccountRequested extends AuthEvent {
  const DeleteAccountRequested();
}
