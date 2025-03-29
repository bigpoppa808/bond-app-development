import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';

// Mock repositories
class MockAuthRepository extends Mock implements AuthRepository {}
class MockProfileRepository extends Mock implements ProfileRepository {}

void main() {
  late MockAuthRepository authRepository;
  late MockProfileRepository profileRepository;
  late AuthBloc authBloc;
  late ProfileBloc profileBloc;
  
  const testUserId = 'test-user-id';
  final testUser = UserModel(
    id: testUserId,
    email: 'test@example.com',
    isEmailVerified: true,
    createdAt: DateTime.now(),
    lastLoginAt: DateTime.now(),
  );
  
  final testProfile = ProfileModel(
    userId: testUserId,
    displayName: 'Test User',
    bio: 'This is a test bio',
    photoUrl: 'https://example.com/photo.jpg',
    interests: ['Music', 'Sports'],
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  setUp(() {
    authRepository = MockAuthRepository();
    profileRepository = MockProfileRepository();
    
    // Setup AuthBloc
    authBloc = AuthBloc(
      authRepository: authRepository,
      profileRepository: profileRepository,
    );
    
    // Setup ProfileBloc
    profileBloc = ProfileBloc(
      profileRepository: profileRepository,
    );
  });

  tearDown(() {
    authBloc.close();
    profileBloc.close();
  });

  group('Profile integration with Auth', () {
    test('Should create a profile when user signs up', () async {
      // Arrange
      when(authRepository.signUp(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => testUser);
      
      when(profileRepository.createProfile(any)).thenAnswer((_) async => testProfile);
      
      // Act - Sign up a user
      await authBloc.signUp(email: 'test@example.com', password: 'password123');
      
      // Assert - Verify profile was created
      verify(profileRepository.createProfile(any)).called(1);
    });
    
    test('Should ensure a profile exists when user signs in', () async {
      // Arrange
      when(authRepository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => testUser);
      
      when(profileRepository.getProfile(testUserId))
          .thenAnswer((_) async => testProfile);
      
      // Act - Sign in a user
      await authBloc.signIn(email: 'test@example.com', password: 'password123');
      
      // Assert - Verify profile existence was checked
      verify(profileRepository.getProfile(testUserId)).called(1);
    });
    
    test('Should create profile if none exists during sign in', () async {
      // Arrange
      when(authRepository.signIn(
        email: anyNamed('email'),
        password: anyNamed('password'),
      )).thenAnswer((_) async => testUser);
      
      // Return null to simulate no profile found
      when(profileRepository.getProfile(testUserId))
          .thenAnswer((_) async => null);
      
      when(profileRepository.createProfile(any))
          .thenAnswer((_) async => testProfile);
      
      // Act - Sign in a user
      await authBloc.signIn(email: 'test@example.com', password: 'password123');
      
      // Assert - Verify profile was created
      verify(profileRepository.createProfile(any)).called(1);
    });
  });
}
