import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/data/repositories/firebase_auth_repository.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter_test/flutter_test.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mocktail/mocktail.dart';

// Mocktail mocks
class MockFirebaseAuth extends Mock implements firebase_auth.FirebaseAuth {}
class MockUser extends Mock implements firebase_auth.User {}
class MockUserCredential extends Mock implements firebase_auth.UserCredential {}
class MockGoogleSignIn extends Mock implements GoogleSignIn {}
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}

// Fallback values for non-nullable parameters
class MapFallback extends Fake implements Map<String, dynamic> {}
class MapObjectFallback extends Fake implements Map<Object, Object?> {}

void main() {
  setUpAll(() {
    // Register fallback values
    registerFallbackValue(MapFallback());
    registerFallbackValue(MapObjectFallback());
    registerFallbackValue('dummy-string');
  });

  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseFirestore mockFirestore;
  late MockGoogleSignIn mockGoogleSignIn;
  late FirebaseAuthRepository repository;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;
  late MockCollectionReference mockUsersCollection;
  late MockDocumentReference mockUserDoc;
  late MockDocumentSnapshot mockUserSnapshot;
  
  final testTimestamp = Timestamp.now();
  final testUserData = {
    'id': 'test-uid',
    'email': 'test@example.com',
    'displayName': 'Test User',
    'photoUrl': 'https://example.com/photo.jpg',
    'phoneNumber': null,
    'dateOfBirth': null,
    'gender': null,
    'bio': null,
    'interests': ['coding', 'reading'],
    'location': null,
    'isProfileComplete': true,
    'isEmailVerified': true,
    'createdAt': testTimestamp,
    'lastLoginAt': testTimestamp,
    'tokenBalance': 100,
    'isDonor': false,
    'donorTier': null,
    'settings': null,
  };

  setUp(() {
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirestore = MockFirebaseFirestore();
    mockGoogleSignIn = MockGoogleSignIn();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    mockUsersCollection = MockCollectionReference();
    mockUserDoc = MockDocumentReference();
    mockUserSnapshot = MockDocumentSnapshot();

    // Setup basic mocks
    when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(() => mockUsersCollection.doc(any())).thenReturn(mockUserDoc);
    when(() => mockUserDoc.get()).thenAnswer((_) async => mockUserSnapshot);
    when(() => mockUserDoc.set(any())).thenAnswer((_) async => {});
    when(() => mockUserDoc.update(any())).thenAnswer((_) async => {});
    
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
    when(() => mockUser.uid).thenReturn('test-uid');
    when(() => mockUser.email).thenReturn('test@example.com');
    when(() => mockUser.displayName).thenReturn('Test User');
    when(() => mockUser.photoURL).thenReturn('https://example.com/photo.jpg');
    when(() => mockUser.emailVerified).thenReturn(true);
    when(() => mockUser.sendEmailVerification()).thenAnswer((_) async => {});
    when(() => mockUser.updateDisplayName(any())).thenAnswer((_) async => {});
    
    // Mock document snapshot id and data
    when(() => mockUserSnapshot.id).thenReturn('test-uid');
    when(() => mockUserSnapshot.data()).thenReturn(testUserData);

    repository = FirebaseAuthRepository(
      firebaseAuth: mockFirebaseAuth,
      firestore: mockFirestore,
      googleSignIn: mockGoogleSignIn,
    );
  });

  group('user stream', () {
    test('returns UserModel when user is logged in', () async {
      // Arrange
      final mockAuthStateStream = Stream.value(mockUser);
      when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => mockAuthStateStream);
      when(() => mockUserSnapshot.exists).thenReturn(true);

      // Act
      final userStream = repository.user;

      // Assert
      expect(userStream, emits(isA<UserModel>()));
    });

    test('returns null when user is not logged in', () async {
      // Arrange
      final mockAuthStateStream = Stream<firebase_auth.User?>.value(null);
      when(() => mockFirebaseAuth.authStateChanges()).thenAnswer((_) => mockAuthStateStream);

      // Act
      final userStream = repository.user;

      // Assert
      expect(userStream, emits(null));
    });
  });

  group('signInWithEmailAndPassword', () {
    test('calls Firebase auth signInWithEmailAndPassword', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUserSnapshot.exists).thenReturn(true);

      // Act
      final result = await repository.signInWithEmailAndPassword(
        'test@example.com',
        'password123',
      );

      // Assert
      expect(result, isA<UserModel>());
      verify(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
    });

    test('throws exception on sign in failure', () async {
      // Arrange
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(firebase_auth.FirebaseAuthException(code: 'user-not-found'));

      // Act & Assert
      expect(
        () => repository.signInWithEmailAndPassword(
          'test@example.com',
          'password123',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('No user found for that email')
        )),
      );
    });
  });

  group('signUpWithEmailAndPassword', () {
    test('calls Firebase auth createUserWithEmailAndPassword', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenAnswer((_) async => mockUserCredential);
      when(() => mockUserCredential.user).thenReturn(mockUser);
      when(() => mockUserSnapshot.exists).thenReturn(false);

      // Act
      final result = await repository.signUpWithEmailAndPassword(
        'test@example.com',
        'password123',
        'Test User',
      );

      // Assert
      expect(result, isA<UserModel>());
      verify(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).called(1);
      verify(() => mockUser.updateDisplayName('Test User')).called(1);
    });

    test('throws exception on sign up failure', () async {
      // Arrange
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
        email: 'test@example.com',
        password: 'password123',
      )).thenThrow(firebase_auth.FirebaseAuthException(code: 'email-already-in-use'));

      // Act & Assert
      expect(
        () => repository.signUpWithEmailAndPassword(
          'test@example.com',
          'password123',
          'Test User',
        ),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('The email address is already in use')
        )),
      );
    });
  });

  group('signOut', () {
    test('signs out user successfully', () async {
      // Arrange
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async => {});
      when(() => mockGoogleSignIn.signOut()).thenAnswer((_) async => null);

      // Act
      await repository.signOut();

      // Assert
      verify(() => mockFirebaseAuth.signOut()).called(1);
      verify(() => mockGoogleSignIn.signOut()).called(1);
    });
  });

  group('sendPasswordResetEmail', () {
    test('sends password reset email successfully', () async {
      // Arrange
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@example.com',
      )).thenAnswer((_) async => {});

      // Act
      await repository.sendPasswordResetEmail('test@example.com');

      // Assert
      verify(() => mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@example.com',
      )).called(1);
    });

    test('throws exception on password reset failure', () async {
      // Arrange
      when(() => mockFirebaseAuth.sendPasswordResetEmail(
        email: 'test@example.com',
      )).thenThrow(firebase_auth.FirebaseAuthException(code: 'user-not-found'));

      // Act & Assert
      expect(
        () => repository.sendPasswordResetEmail('test@example.com'),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('No user found for that email')
        )),
      );
    });
  });

  group('sendEmailVerification', () {
    test('sends email verification successfully', () async {
      // Act
      await repository.sendEmailVerification();

      // Assert
      verify(() => mockUser.sendEmailVerification()).called(1);
    });

    test('throws exception when no user is signed in', () async {
      // Arrange
      when(() => mockFirebaseAuth.currentUser).thenReturn(null);

      // Act & Assert
      expect(
        () => repository.sendEmailVerification(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(), 
          'message', 
          contains('No user is signed in')
        )),
      );
    });
  });
}
