import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository authRepository;
  
  setUpAll(() async {
    // Initialize Firebase with real configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Create real instances of the repository
    authRepository = FirebaseAuthRepository(
      firebaseAuth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
    );
  });

  group('Firebase Authentication Tests', () {
    test('Sign in with invalid credentials should throw an exception', () async {
      // Attempt to sign in with invalid credentials
      expect(
        () => authRepository.signInWithEmailAndPassword(
          'nonexistent@example.com',
          'wrongpassword',
        ),
        throwsException,
      );
    });

    test('Sign in with empty credentials should throw an exception', () async {
      // Attempt to sign in with empty credentials
      expect(
        () => authRepository.signInWithEmailAndPassword('', ''),
        throwsException,
      );
    });

    test('Sign out should complete without errors', () async {
      // Sign out
      await authRepository.signOut();
      
      // Verify the current user is null after sign out
      expect(FirebaseAuth.instance.currentUser, isNull);
    });

    // Note: We're not testing successful sign-in as it would require valid credentials
    // which we don't want to hardcode in tests
  });
}
