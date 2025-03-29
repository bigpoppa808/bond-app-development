import 'package:bond_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:bond_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AuthRepository authRepository;
  late AuthRemoteDataSource authRemoteDataSource;
  
  setUpAll(() async {
    // Initialize Firebase with real configuration
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    
    // Create real instances of the data source and repository
    authRemoteDataSource = AuthRemoteDataSourceImpl(FirebaseAuth.instance);
    authRepository = AuthRepositoryImpl(authRemoteDataSource);
  });

  group('Firebase Authentication Tests', () {
    test('Sign in with invalid credentials should fail', () async {
      // Attempt to sign in with invalid credentials
      final result = await authRepository.signInWithEmailAndPassword(
        email: 'nonexistent@example.com',
        password: 'wrongpassword',
      );
      
      // Verify the result is a failure
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, contains('invalid')),
        (user) => fail('Should not succeed with invalid credentials'),
      );
    });

    test('Sign in with empty credentials should fail', () async {
      // Attempt to sign in with empty credentials
      final result = await authRepository.signInWithEmailAndPassword(
        email: '',
        password: '',
      );
      
      // Verify the result is a failure
      expect(result.isLeft(), isTrue);
      result.fold(
        (failure) => expect(failure.message, isNotEmpty),
        (user) => fail('Should not succeed with empty credentials'),
      );
    });

    test('Sign out should succeed', () async {
      // Sign out
      final result = await authRepository.signOut();
      
      // Verify the result is a success
      expect(result.isRight(), isTrue);
    });

    // Note: We're not testing successful sign-in as it would require valid credentials
    // which we don't want to hardcode in tests
  });
}
