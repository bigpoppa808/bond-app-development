import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/data/repositories/firebase_profile_repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Mock classes
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockFirebaseStorage extends Mock implements FirebaseStorage {}
class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}
class MockStorageReference extends Mock implements Reference {}
class MockUploadTask extends Mock implements UploadTask {}
class MockTaskSnapshot extends Mock implements TaskSnapshot {}

void main() {
  late FirebaseProfileRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockFirebaseStorage mockStorage;
  late MockCollectionReference mockCollectionReference;
  
  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockStorage = MockFirebaseStorage();
    mockCollectionReference = MockCollectionReference();
    
    when(() => mockFirestore.collection('profiles'))
        .thenReturn(mockCollectionReference);
    
    repository = FirebaseProfileRepository(
      firestore: mockFirestore,
      storage: mockStorage,
    );
  });
  
  group('getProfile', () {
    test('should return ProfileModel when document exists', () async {
      // Arrange
      final userId = 'test_user_id';
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      when(() => mockCollectionReference.doc(userId))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocSnapshot.id).thenReturn(userId);
      when(() => mockDocSnapshot.data())
          .thenReturn({
            'occupation': 'Software Engineer',
            'education': 'Computer Science',
            'languages': ['English', 'Spanish'],
            'hobbies': ['Coding', 'Reading'],
            'skills': ['Flutter', 'Dart'],
            'isPublic': true,
            'lastUpdated': Timestamp.fromDate(DateTime(2023, 1, 1)),
          });
      
      // Act
      final result = await repository.getProfile(userId);
      
      // Assert
      expect(result, isA<ProfileModel>());
      expect(result!.userId, equals(userId));
      expect(result.occupation, equals('Software Engineer'));
      expect(result.education, equals('Computer Science'));
      expect(result.languages, equals(['English', 'Spanish']));
      expect(result.hobbies, equals(['Coding', 'Reading']));
      expect(result.skills, equals(['Flutter', 'Dart']));
      expect(result.isPublic, isTrue);
      expect(result.lastUpdated, equals(DateTime(2023, 1, 1)));
    });
    
    test('should return null when document does not exist', () async {
      // Arrange
      final userId = 'test_user_id';
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      when(() => mockCollectionReference.doc(userId))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);
      
      // Act
      final result = await repository.getProfile(userId);
      
      // Assert
      expect(result, isNull);
    });
    
    test('should throw exception when get fails', () async {
      // Arrange
      final userId = 'test_user_id';
      final mockDocRef = MockDocumentReference();
      
      when(() => mockCollectionReference.doc(userId))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenThrow(Exception('Firestore error'));
      
      // Act & Assert
      expect(
        () => repository.getProfile(userId),
        throwsA(isA<Exception>()),
      );
    });
  });
  
  group('createProfile', () {
    test('should create profile and return it', () async {
      // Arrange
      final userId = 'test_user_id';
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      final profile = ProfileModel.create(userId: userId);
      
      when(() => mockCollectionReference.doc(userId))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);
      when(() => mockDocRef.set(any()))
          .thenAnswer((_) async => {});
      
      // Act
      final result = await repository.createProfile(profile);
      
      // Assert
      expect(result, isA<ProfileModel>());
      expect(result.userId, equals(userId));
      verify(() => mockDocRef.set(any())).called(1);
    });
    
    test('should throw exception when profile already exists', () async {
      // Arrange
      final userId = 'test_user_id';
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      final profile = ProfileModel.create(userId: userId);
      
      when(() => mockCollectionReference.doc(userId))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(true);
      
      // Act & Assert
      expect(
        () => repository.createProfile(profile),
        throwsA(isA<Exception>()),
      );
    });
  });
  
  group('updateProfile', () {
    test('should update profile and return it', () async {
      // Arrange
      final userId = 'test_user_id';
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      final profile = ProfileModel.create(userId: userId).copyWith(
        occupation: 'Software Engineer',
      );
      
      when(() => mockCollectionReference.doc(userId))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(true);
      when(() => mockDocRef.update(any()))
          .thenAnswer((_) async => {});
      
      // Act
      final result = await repository.updateProfile(profile);
      
      // Assert
      expect(result, isA<ProfileModel>());
      expect(result.userId, equals(userId));
      expect(result.occupation, equals('Software Engineer'));
      verify(() => mockDocRef.update(any())).called(1);
    });
    
    test('should throw exception when profile does not exist', () async {
      // Arrange
      final userId = 'test_user_id';
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      final profile = ProfileModel.create(userId: userId);
      
      when(() => mockCollectionReference.doc(userId))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);
      
      // Act & Assert
      expect(
        () => repository.updateProfile(profile),
        throwsA(isA<Exception>()),
      );
    });
  });
  
  group('profileExists', () {
    test('should return true when profile exists', () async {
      // Arrange
      final userId = 'test_user_id';
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      when(() => mockCollectionReference.doc(userId))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(true);
      
      // Act
      final result = await repository.profileExists(userId);
      
      // Assert
      expect(result, isTrue);
    });
    
    test('should return false when profile does not exist', () async {
      // Arrange
      final userId = 'test_user_id';
      final mockDocRef = MockDocumentReference();
      final mockDocSnapshot = MockDocumentSnapshot();
      
      when(() => mockCollectionReference.doc(userId))
          .thenReturn(mockDocRef);
      when(() => mockDocRef.get())
          .thenAnswer((_) async => mockDocSnapshot);
      when(() => mockDocSnapshot.exists).thenReturn(false);
      
      // Act
      final result = await repository.profileExists(userId);
      
      // Assert
      expect(result, isFalse);
    });
  });
}
