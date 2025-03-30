import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';

abstract class AuthRepository {
  Stream<bool> get authStateChanges;
  
  Future<UserModel> signIn(String email, String password);
  
  Future<UserModel> signUp(String email, String password);
  
  Future<void> signOut();
  
  Future<void> sendPasswordResetEmail(String email);
  
  Future<UserModel?> getCurrentUser();
  
  Future<String?> getIdToken();
  
  Future<bool> isSignedIn();
}
