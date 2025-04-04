import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_bond_app/core/utils/error_handler.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/meetings/data/repositories/meeting_repository_impl.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'meeting_repository_test.mocks.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore, 
  CollectionReference, 
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  QueryDocumentSnapshot,
  Query,
  AuthRepository,
  AppLogger,
  ErrorHandler,
])
void main() {
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollectionReference;
  late MockDocumentReference<Map<String, dynamic>> mockDocumentReference;
  late MockDocumentSnapshot<Map<String, dynamic>> mockDocumentSnapshot;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockAuthRepository mockAuthRepository;
  late MockAppLogger mockLogger;
  late MockErrorHandler mockErrorHandler;
  late MeetingRepositoryImpl meetingRepository;

  // Test data
  final testUser = UserModel(
    id: 'user1',
    email: 'user1@example.com',
    displayName: 'Test User',
  );

  final now = DateTime.now();
  final scheduledTime = now.add(const Duration(days: 3));
  
  final testMeeting = MeetingModel(
    id: 'meeting123',
    title: 'Coffee Chat',
    description: 'Networking over coffee',
    location: 'Downtown Cafe',
    scheduledTime: scheduledTime,
    durationMinutes: 60,
    creatorId: 'user1',  // Same as the test user
    inviteeId: 'user2',
    status: MeetingStatus.pending,
    createdAt: now.subtract(const Duration(days: 1)),
    updatedAt: now.subtract(const Duration(days: 1)),
    notes: 'Bring resume',
    topics: ['Career', 'Networking'],
  );

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollectionReference = MockCollectionReference<Map<String, dynamic>>();
    mockDocumentReference = MockDocumentReference<Map<String, dynamic>>();
    mockDocumentSnapshot = MockDocumentSnapshot<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockAuthRepository = MockAuthRepository();
    mockLogger = MockAppLogger();
    mockErrorHandler = MockErrorHandler();

    // Set up common mocks
    when(mockFirestore.collection('meetings')).thenReturn(mockCollectionReference);
    when(mockAuthRepository.getCurrentUser()).thenAnswer((_) async => testUser);
    
    // Mock error handler to return a string error message
    when(mockErrorHandler.handleError(any)).thenAnswer((invocation) {
      final error = invocation.positionalArguments.first;
      return error.toString();
    });
  });

  // Convert a meeting model to the expected Firestore data format
  Map<String, dynamic> meetingToFirestoreData(MeetingModel meeting) {
    final data = meeting.toJson();
    data.remove('id'); // ID is in document reference, not data
    return data;
  }

  group('MeetingRepository', () {
    test('getMeeting returns meeting when it exists and user is authorized', () async {
      // Arrange
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(testMeeting));
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // Act
      final result = await meetingRepository.getMeeting('meeting123');
      
      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals('meeting123'));
      expect(result.title, equals('Coffee Chat'));
      expect(result.creatorId, equals('user1'));
      
      verify(mockCollectionReference.doc('meeting123')).called(1);
      verify(mockDocumentReference.get()).called(1);
    });

    test('getMeeting returns null when meeting does not exist', () async {
      // Arrange
      when(mockCollectionReference.doc('nonexistent')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // Act
      final result = await meetingRepository.getMeeting('nonexistent');
      
      // Assert
      expect(result, isNull);
      
      verify(mockCollectionReference.doc('nonexistent')).called(1);
      verify(mockDocumentReference.get()).called(1);
    });

    test('getMeeting throws exception when user is not authorized', () async {
      // Arrange
      final unauthorizedMeeting = testMeeting.copyWith(
        creatorId: 'otherUser1',
        inviteeId: 'otherUser2',
      );
      
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(unauthorizedMeeting));
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // First verify the setup calls will occur
      try {
        await meetingRepository.getMeeting('meeting123');
      } catch (_) {
        // Expected to throw
      }
      
      // Verify the calls were made
      verify(mockCollectionReference.doc('meeting123')).called(1);
      verify(mockDocumentReference.get()).called(1);
      
      // Now test the exception
      expect(
        () => meetingRepository.getMeeting('meeting123'),
        throwsA(isA<Object>()),
      );
    });

    test('createMeeting creates a new meeting and returns it with generated ID', () async {
      // Arrange
      final newMeeting = testMeeting.copyWith(id: '');
      
      when(mockCollectionReference.add(any)).thenAnswer((_) async => mockDocumentReference);
      when(mockDocumentReference.id).thenReturn('generatedId123');
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // Act
      final result = await meetingRepository.createMeeting(newMeeting);
      
      // Assert
      expect(result, isNotNull);
      expect(result.id, equals('generatedId123'));
      expect(result.title, equals(newMeeting.title));
      expect(result.status, equals(MeetingStatus.pending));
      
      verify(mockCollectionReference.add(any)).called(1);
    });

    test('createMeeting throws exception when creator is not current user', () async {
      // Arrange
      final unauthorizedMeeting = testMeeting.copyWith(
        creatorId: 'otherUser',  // Different from test user
      );
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // First try the operation to verify calls
      try {
        await meetingRepository.createMeeting(unauthorizedMeeting);
      } catch (_) {
        // Expected to throw
      }
      
      // Verify no add was called
      verifyNever(mockCollectionReference.add(any));
      
      // Now test the exception
      expect(
        () => meetingRepository.createMeeting(unauthorizedMeeting),
        throwsA(isA<Object>()),
      );
    });

    test('updateMeeting updates an existing meeting', () async {
      // Arrange
      final updatedMeeting = testMeeting.copyWith(
        title: 'Updated Title',
        description: 'Updated Description',
      );
      
      // Mock for checking if meeting exists
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(testMeeting));
      
      // Mock for update
      when(mockDocumentReference.update(any)).thenAnswer((_) async {});
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // Act
      final result = await meetingRepository.updateMeeting(updatedMeeting);
      
      // Assert
      expect(result, isNotNull);
      expect(result.id, equals('meeting123'));
      expect(result.title, equals('Updated Title'));
      expect(result.description, equals('Updated Description'));
      
      verify(mockDocumentReference.get()).called(1);
      verify(mockDocumentReference.update(any)).called(1);
    });

    test('confirmMeeting confirms a pending meeting', () async {
      // Arrange - set up the meeting to be confirmed
      final pendingMeeting = testMeeting.copyWith(
        inviteeId: 'user1', // Make the current user the invitee
      );
      
      // Mock for getting the meeting
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(pendingMeeting));
      
      // Mock for update
      when(mockDocumentReference.update(any)).thenAnswer((_) async {});
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // Act
      final result = await meetingRepository.confirmMeeting('meeting123');
      
      // Assert
      expect(result, isNotNull);
      expect(result.id, equals('meeting123'));
      expect(result.status, equals(MeetingStatus.confirmed));
      
      verify(mockDocumentReference.get()).called(1);
      verify(mockDocumentReference.update(any)).called(1);
    });

    test('confirmMeeting throws exception when user is not the invitee', () async {
      // Arrange - current user is the creator, not the invitee
      // Mock for getting the meeting
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(testMeeting));
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // First try the operation to verify calls
      try {
        await meetingRepository.confirmMeeting('meeting123');
      } catch (_) {
        // Expected to throw
      }
      
      // Verify calls
      verify(mockDocumentReference.get()).called(1);
      verifyNever(mockDocumentReference.update(any));
      
      // Act & Assert
      expect(
        () => meetingRepository.confirmMeeting('meeting123'),
        throwsA(isA<Object>()),
      );
    });

    test('cancelMeeting cancels a meeting and adds a reason', () async {
      // Arrange
      // Mock for getting the meeting
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(testMeeting));
      
      // Mock for update
      when(mockDocumentReference.update(any)).thenAnswer((_) async {});
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // Act
      final result = await meetingRepository.cancelMeeting('meeting123', reason: 'Schedule conflict');
      
      // Assert
      expect(result, isNotNull);
      expect(result.id, equals('meeting123'));
      expect(result.status, equals(MeetingStatus.canceled));
      expect(result.notes, equals('Schedule conflict'));
      
      verify(mockDocumentReference.get()).called(1);
      verify(mockDocumentReference.update(any)).called(1);
    });

    test('completeMeeting marks a confirmed meeting as completed', () async {
      // Arrange
      final confirmedMeeting = testMeeting.copyWith(
        status: MeetingStatus.confirmed,
      );
      
      // Mock for getting the meeting
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(confirmedMeeting));
      
      // Mock for update
      when(mockDocumentReference.update(any)).thenAnswer((_) async {});
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // Act
      final result = await meetingRepository.completeMeeting('meeting123');
      
      // Assert
      expect(result, isNotNull);
      expect(result.id, equals('meeting123'));
      expect(result.status, equals(MeetingStatus.completed));
      
      verify(mockDocumentReference.get()).called(1);
      verify(mockDocumentReference.update(any)).called(1);
    });

    test('completeMeeting throws exception when user is not the creator', () async {
      // Arrange - make a meeting where user is not the creator
      final othersCreatorMeeting = testMeeting.copyWith(
        creatorId: 'otherUser',
        status: MeetingStatus.confirmed,
      );
      
      // Mock for getting the meeting
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(othersCreatorMeeting));
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // First try the operation to verify calls
      try {
        await meetingRepository.completeMeeting('meeting123');
      } catch (_) {
        // Expected to throw
      }
      
      // Verify calls
      verify(mockDocumentReference.get()).called(1);
      verifyNever(mockDocumentReference.update(any));
      
      // Act & Assert
      expect(
        () => meetingRepository.completeMeeting('meeting123'),
        throwsA(isA<Object>()),
      );
    });

    test('rescheduleMeeting changes the scheduled time and duration', () async {
      // Arrange
      final newDateTime = now.add(const Duration(days: 7));
      const newDuration = 90;
      
      // Mock for getting the meeting
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(testMeeting));
      
      // Mock for update
      when(mockDocumentReference.update(any)).thenAnswer((_) async {});
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // Act
      final result = await meetingRepository.rescheduleMeeting(
        'meeting123', 
        newDateTime, 
        newDurationMinutes: newDuration,
      );
      
      // Assert
      expect(result, isNotNull);
      expect(result.id, equals('meeting123'));
      expect(result.status, equals(MeetingStatus.rescheduled));
      expect(result.scheduledTime, equals(newDateTime));
      expect(result.durationMinutes, equals(newDuration));
      
      verify(mockDocumentReference.get()).called(1);
      verify(mockDocumentReference.update(any)).called(1);
    });

    test('deleteMeeting deletes a meeting', () async {
      // Arrange
      // Mock for getting the meeting
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(testMeeting));
      
      // Mock for delete
      when(mockDocumentReference.delete()).thenAnswer((_) async {});
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // Act
      await meetingRepository.deleteMeeting('meeting123');
      
      // Assert
      verify(mockDocumentReference.get()).called(1);
      verify(mockDocumentReference.delete()).called(1);
    });

    test('deleteMeeting throws exception when user is not the creator', () async {
      // Arrange - make a meeting where user is not the creator
      final othersCreatorMeeting = testMeeting.copyWith(
        creatorId: 'otherUser',
      );
      
      // Mock for getting the meeting
      when(mockCollectionReference.doc('meeting123')).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.id).thenReturn('meeting123');
      when(mockDocumentSnapshot.data()).thenReturn(meetingToFirestoreData(othersCreatorMeeting));
      
      meetingRepository = MeetingRepositoryImpl(
        firestore: mockFirestore,
        authRepository: mockAuthRepository,
        logger: mockLogger,
        errorHandler: mockErrorHandler,
      );
      
      // First try the operation to verify calls
      try {
        await meetingRepository.deleteMeeting('meeting123');
      } catch (_) {
        // Expected to throw
      }
      
      // Verify calls
      verify(mockDocumentReference.get()).called(1);
      verifyNever(mockDocumentReference.delete());
      
      // Act & Assert
      expect(
        () => meetingRepository.deleteMeeting('meeting123'),
        throwsA(isA<Object>()),
      );
    });
  });
}