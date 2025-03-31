import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_event.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_state.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/nfc_verification_repository_interface.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'nfc_verification_bloc_test.mocks.dart';

@GenerateMocks([NfcVerificationRepositoryInterface])
void main() {
  late NfcVerificationBloc nfcVerificationBloc;
  late MockNfcVerificationRepositoryInterface mockNfcRepository;

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
    mockNfcRepository = MockNfcVerificationRepositoryInterface();
    nfcVerificationBloc = NfcVerificationBloc(
      nfcRepository: mockNfcRepository,
    );
  });

  tearDown(() {
    nfcVerificationBloc.close();
  });

  group('NfcVerificationBloc', () {
    test('initial state is NfcVerificationInitialState', () {
      expect(nfcVerificationBloc.state, isA<NfcVerificationInitialState>());
    });

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcInitializingState, NfcAvailableState] when InitializeNfcEvent is added and NFC is available',
      build: () {
        when(mockNfcRepository.initialize()).thenAnswer((_) async {});
        when(mockNfcRepository.isNfcAvailable()).thenReturn(true);
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(InitializeNfcEvent()),
      expect: () => [
        isA<NfcInitializingState>(),
        isA<NfcAvailableState>(),
      ],
      verify: (_) {
        verify(mockNfcRepository.initialize()).called(1);
        verify(mockNfcRepository.isNfcAvailable()).called(1);
      },
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcInitializingState, NfcNotAvailableState] when InitializeNfcEvent is added and NFC is not available',
      build: () {
        when(mockNfcRepository.initialize()).thenAnswer((_) async {});
        when(mockNfcRepository.isNfcAvailable()).thenReturn(false);
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(InitializeNfcEvent()),
      expect: () => [
        isA<NfcInitializingState>(),
        isA<NfcNotAvailableState>(),
      ],
      verify: (_) {
        verify(mockNfcRepository.initialize()).called(1);
        verify(mockNfcRepository.isNfcAvailable()).called(1);
      },
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcAvailableState] when CheckNfcAvailabilityEvent is added and NFC is available',
      build: () {
        when(mockNfcRepository.isNfcAvailable()).thenReturn(true);
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(CheckNfcAvailabilityEvent()),
      expect: () => [
        isA<NfcAvailableState>(),
      ],
      verify: (_) {
        verify(mockNfcRepository.isNfcAvailable()).called(1);
      },
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcNotAvailableState] when CheckNfcAvailabilityEvent is added and NFC is not available',
      build: () {
        when(mockNfcRepository.isNfcAvailable()).thenReturn(false);
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(CheckNfcAvailabilityEvent()),
      expect: () => [
        isA<NfcNotAvailableState>(),
      ],
      verify: (_) {
        verify(mockNfcRepository.isNfcAvailable()).called(1);
      },
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcNotAvailableState] when StartNfcSessionEvent is added but NFC is not available',
      build: () {
        when(mockNfcRepository.isNfcAvailable()).thenReturn(false);
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(StartNfcSessionEvent(testMeeting)),
      expect: () => [
        isA<NfcNotAvailableState>(),
      ],
      verify: (_) {
        verify(mockNfcRepository.isNfcAvailable()).called(1);
        verifyNever(mockNfcRepository.startNfcSession(any));
      },
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcSessionInProgressState, NfcTagDetectedState] when StartNfcSessionEvent is added and tag is detected',
      build: () {
        when(mockNfcRepository.isNfcAvailable()).thenReturn(true);
        when(mockNfcRepository.startNfcSession(testMeeting)).thenAnswer(
          (_) async => {'success': true, 'payload': 'test-payload'},
        );
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(StartNfcSessionEvent(testMeeting)),
      expect: () => [
        isA<NfcSessionInProgressState>(),
        isA<NfcTagDetectedState>(),
      ],
      verify: (_) {
        verify(mockNfcRepository.isNfcAvailable()).called(1);
        verify(mockNfcRepository.startNfcSession(testMeeting)).called(1);
      },
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcAvailableState] when StopNfcSessionEvent is added',
      build: () {
        when(mockNfcRepository.stopNfcSession()).thenAnswer((_) async {});
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(StopNfcSessionEvent()),
      expect: () => [
        isA<NfcAvailableState>(),
      ],
      verify: (_) {
        verify(mockNfcRepository.stopNfcSession()).called(1);
      },
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [VerifyingMeetingState, MeetingVerifiedState] when VerifyMeetingWithNfcEvent is added and verification succeeds',
      build: () {
        when(mockNfcRepository.verifyMeeting(
          'test-meeting-id',
          {'success': true, 'payload': 'test-payload'},
        )).thenAnswer((_) async => testMeeting);
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(VerifyMeetingWithNfcEvent(
        meetingId: 'test-meeting-id',
        nfcData: {'success': true, 'payload': 'test-payload'},
      )),
      expect: () => [
        isA<VerifyingMeetingState>(),
        isA<MeetingVerifiedState>(),
      ],
      verify: (_) {
        verify(mockNfcRepository.verifyMeeting(
          'test-meeting-id',
          {'success': true, 'payload': 'test-payload'},
        )).called(1);
      },
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcTagDetectedState] when NfcTagDetectedEvent is added during an active session',
      seed: () => NfcSessionInProgressState(testMeeting),
      build: () => nfcVerificationBloc,
      act: (bloc) => bloc.add(NfcTagDetectedEvent(
        {'success': true, 'payload': 'test-payload'},
      )),
      expect: () => [
        isA<NfcTagDetectedState>(),
      ],
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcVerificationErrorState] when NfcTagDetectedEvent is added without an active session',
      build: () => nfcVerificationBloc,
      act: (bloc) => bloc.add(NfcTagDetectedEvent(
        {'success': true, 'payload': 'test-payload'},
      )),
      expect: () => [
        isA<NfcVerificationErrorState>(),
      ],
    );

    // Exception handling tests
    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcVerificationErrorState] when InitializeNfcEvent throws an exception',
      build: () {
        when(mockNfcRepository.initialize()).thenThrow(Exception('Test error'));
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(InitializeNfcEvent()),
      expect: () => [
        isA<NfcInitializingState>(),
        isA<NfcVerificationErrorState>(),
      ],
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcVerificationErrorState] when StartNfcSessionEvent throws an exception',
      build: () {
        when(mockNfcRepository.isNfcAvailable()).thenReturn(true);
        when(mockNfcRepository.startNfcSession(testMeeting))
            .thenThrow(Exception('Test error'));
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(StartNfcSessionEvent(testMeeting)),
      expect: () => [
        isA<NfcSessionInProgressState>(),
        isA<NfcVerificationErrorState>(),
      ],
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [NfcVerificationErrorState] when StopNfcSessionEvent throws an exception',
      build: () {
        when(mockNfcRepository.stopNfcSession())
            .thenThrow(Exception('Test error'));
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(StopNfcSessionEvent()),
      expect: () => [
        isA<NfcVerificationErrorState>(),
      ],
    );

    blocTest<NfcVerificationBloc, NfcVerificationState>(
      'emits [VerifyingMeetingState, NfcVerificationErrorState] when VerifyMeetingWithNfcEvent throws an exception',
      build: () {
        when(mockNfcRepository.verifyMeeting(
          'test-meeting-id',
          {'success': true, 'payload': 'test-payload'},
        )).thenThrow(Exception('Test error'));
        return nfcVerificationBloc;
      },
      act: (bloc) => bloc.add(VerifyMeetingWithNfcEvent(
        meetingId: 'test-meeting-id',
        nfcData: {'success': true, 'payload': 'test-payload'},
      )),
      expect: () => [
        isA<VerifyingMeetingState>(),
        isA<NfcVerificationErrorState>(),
      ],
    );
  });
}