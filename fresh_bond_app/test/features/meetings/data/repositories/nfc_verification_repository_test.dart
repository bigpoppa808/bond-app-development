import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_bond_app/core/utils/error_handler.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/meetings/data/repositories/nfc_verification_repository.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'nfc_verification_repository_test.mocks.dart';

@GenerateMocks([
  NfcManager,
  AuthRepository,
  MeetingRepository,
  AppLogger,
  ErrorHandler,
])
void main() {
  late NfcVerificationRepository nfcVerificationRepository;
  late MockNfcManager mockNfcManager;
  late MockAuthRepository mockAuthRepository;
  late MockMeetingRepository mockMeetingRepository;
  late MockAppLogger mockLogger;
  late MockErrorHandler mockErrorHandler;

  final testMeeting = MeetingModel(
    id: 'test-meeting-id',
    title: 'Test Meeting',
    description: 'Test Description',
    location: 'Test Location',
    scheduledTime: DateTime.now(),
    durationMinutes: 60,
    status: MeetingStatus.confirmed,
    creatorId: 'test-creator-id',
    inviteeId: 'test-invitee-id',
    topics: ['Test Topic'],
  );

  setUp(() {
    mockNfcManager = MockNfcManager();
    mockAuthRepository = MockAuthRepository();
    mockMeetingRepository = MockMeetingRepository();
    mockLogger = MockAppLogger();
    mockErrorHandler = MockErrorHandler();

    nfcVerificationRepository = NfcVerificationRepository(
      nfcManager: mockNfcManager,
      authRepository: mockAuthRepository,
      meetingRepository: mockMeetingRepository,
      logger: mockLogger,
      errorHandler: mockErrorHandler,
    );
  });

  group('NfcVerificationRepository', () {
    test('initialize() sets _isNfcAvailable to true when NFC is available', () async {
      // Arrange
      when(mockNfcManager.isAvailable()).thenAnswer((_) async => true);

      // Act
      await nfcVerificationRepository.initialize();

      // Assert
      expect(nfcVerificationRepository.isNfcAvailable(), true);
      verify(mockNfcManager.isAvailable()).called(1);
      verify(mockLogger.i(any)).called(1);
    });

    test('initialize() sets _isNfcAvailable to false when NFC is not available', () async {
      // Arrange
      when(mockNfcManager.isAvailable()).thenAnswer((_) async => false);

      // Act
      await nfcVerificationRepository.initialize();

      // Assert
      expect(nfcVerificationRepository.isNfcAvailable(), false);
      verify(mockNfcManager.isAvailable()).called(1);
      verify(mockLogger.i(any)).called(1);
    });

    test('initialize() sets _isNfcAvailable to false when an exception is thrown', () async {
      // Arrange
      when(mockNfcManager.isAvailable()).thenThrow(Exception('Test error'));

      // Act
      await nfcVerificationRepository.initialize();

      // Assert
      expect(nfcVerificationRepository.isNfcAvailable(), false);
      verify(mockNfcManager.isAvailable()).called(1);
      verify(mockLogger.e(any, error: anyNamed('error'))).called(1);
    });

    test('isNfcAvailable() returns the current NFC availability', () async {
      // Arrange
      when(mockNfcManager.isAvailable()).thenAnswer((_) async => true);
      await nfcVerificationRepository.initialize();

      // Act & Assert
      expect(nfcVerificationRepository.isNfcAvailable(), true);
    });

    test('startNfcSession() throws exception when NFC is not available', () async {
      // Arrange
      when(mockNfcManager.isAvailable()).thenAnswer((_) async => false);
      await nfcVerificationRepository.initialize();

      // Act & Assert
      expect(
        () => nfcVerificationRepository.startNfcSession(testMeeting),
        throwsA(isA<Exception>()),
      );
    });

    test('verifyMeeting() calls the meeting repository with correct arguments', () async {
      // Arrange
      final nfcData = {'success': true, 'payload': 'test-payload'};
      final testUser = {'id': 'test-user-id'};
      
      when(mockMeetingRepository.getMeeting('test-meeting-id'))
          .thenAnswer((_) async => testMeeting);
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);
      when(mockMeetingRepository.completeMeeting('test-meeting-id'))
          .thenAnswer((_) async => testMeeting);

      // Act
      final result = await nfcVerificationRepository.verifyMeeting(
        'test-meeting-id',
        nfcData,
      );

      // Assert
      expect(result, testMeeting);
      verify(mockMeetingRepository.getMeeting('test-meeting-id')).called(1);
      verify(mockAuthRepository.getCurrentUser()).called(1);
      verify(mockMeetingRepository.completeMeeting('test-meeting-id')).called(1);
    });

    test('verifyMeeting() throws exception when meeting is not found', () async {
      // Arrange
      final nfcData = {'success': true, 'payload': 'test-payload'};
      
      when(mockMeetingRepository.getMeeting('test-meeting-id'))
          .thenAnswer((_) async => null);
      when(mockErrorHandler.handleError(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      // Act & Assert
      expect(
        () => nfcVerificationRepository.verifyMeeting('test-meeting-id', nfcData),
        throwsA(isA<Exception>()),
      );
      verify(mockMeetingRepository.getMeeting('test-meeting-id')).called(1);
      verifyNever(mockMeetingRepository.completeMeeting(any));
    });

    test('verifyMeeting() throws exception when user is not authenticated', () async {
      // Arrange
      final nfcData = {'success': true, 'payload': 'test-payload'};
      
      when(mockMeetingRepository.getMeeting('test-meeting-id'))
          .thenAnswer((_) async => testMeeting);
      when(mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => null);
      when(mockErrorHandler.handleError(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      // Act & Assert
      expect(
        () => nfcVerificationRepository.verifyMeeting('test-meeting-id', nfcData),
        throwsA(isA<Exception>()),
      );
      verify(mockMeetingRepository.getMeeting('test-meeting-id')).called(1);
      verify(mockAuthRepository.getCurrentUser()).called(1);
      verifyNever(mockMeetingRepository.completeMeeting(any));
    });

    test('stopNfcSession() calls NfcManager.stopSession()', () async {
      // Arrange
      when(mockNfcManager.stopSession())
          .thenAnswer((_) async {});

      // Act
      await nfcVerificationRepository.stopNfcSession();

      // Assert
      verify(mockNfcManager.stopSession()).called(1);
    });

    test('stopNfcSession() handles exceptions gracefully', () async {
      // Arrange
      when(mockNfcManager.stopSession())
          .thenThrow(Exception('Test error'));
      when(mockErrorHandler.handleError(any))
          .thenAnswer((invocation) => invocation.positionalArguments.first);

      // Act & Assert
      expect(
        () => nfcVerificationRepository.stopNfcSession(),
        throwsA(isA<Exception>()),
      );
      verify(mockNfcManager.stopSession()).called(1);
      verify(mockLogger.e(any, error: anyNamed('error'))).called(1);
    });
  });
}