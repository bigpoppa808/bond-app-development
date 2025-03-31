import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_event.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_state.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'meeting_bloc_test.mocks.dart';

@GenerateMocks([MeetingRepository])
void main() {
  late MockMeetingRepository mockMeetingRepository;
  late MeetingBloc meetingBloc;
  
  // Test data
  final testMeeting = MeetingModel(
    id: 'meeting123',
    title: 'Coffee Chat',
    description: 'Networking over coffee',
    location: 'Downtown Cafe',
    scheduledTime: DateTime.now().add(const Duration(days: 3)),
    durationMinutes: 60,
    creatorId: 'user1',
    inviteeId: 'user2',
    status: MeetingStatus.pending,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    updatedAt: DateTime.now().subtract(const Duration(days: 1)),
    notes: 'Bring resume',
    topics: ['Career', 'Networking'],
  );
  
  final testMeetingsList = [
    testMeeting,
    testMeeting.copyWith(
      id: 'meeting456',
      title: 'Project Discussion',
      status: MeetingStatus.confirmed,
    ),
    testMeeting.copyWith(
      id: 'meeting789',
      title: 'Interview',
      status: MeetingStatus.completed,
      scheduledTime: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  setUp(() {
    mockMeetingRepository = MockMeetingRepository();
    meetingBloc = MeetingBloc(meetingRepository: mockMeetingRepository);
  });

  tearDown(() {
    meetingBloc.close();
  });

  group('MeetingBloc', () {
    test('initial state is MeetingInitialState', () {
      expect(meetingBloc.state, isA<MeetingInitialState>());
    });

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingLoadedState] when LoadMeetingEvent is added and successful',
      build: () {
        when(mockMeetingRepository.getMeeting('meeting123'))
            .thenAnswer((_) async => testMeeting);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const LoadMeetingEvent('meeting123')),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingLoadedState>(),
      ],
      verify: (_) {
        verify(mockMeetingRepository.getMeeting('meeting123')).called(1);
      },
    );

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingErrorState] when LoadMeetingEvent is added and meeting not found',
      build: () {
        when(mockMeetingRepository.getMeeting('invalid'))
            .thenAnswer((_) async => null);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const LoadMeetingEvent('invalid')),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingErrorState>(),
      ],
      verify: (_) {
        verify(mockMeetingRepository.getMeeting('invalid')).called(1);
      },
    );

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingsLoadedState] when LoadAllMeetingsEvent is added',
      build: () {
        when(mockMeetingRepository.getMeetingsForCurrentUser())
            .thenAnswer((_) async => testMeetingsList);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const LoadAllMeetingsEvent()),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingsLoadedState>(),
      ],
      verify: (bloc) {
        verify(mockMeetingRepository.getMeetingsForCurrentUser()).called(1);
        final state = bloc.state as MeetingsLoadedState;
        expect(state.meetings.length, equals(3));
        expect(state.filterDescription, equals('All Meetings'));
      },
    );

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingsLoadedState] when LoadMeetingsByStatusEvent is added',
      build: () {
        when(mockMeetingRepository.getMeetingsByStatus(MeetingStatus.confirmed))
            .thenAnswer((_) async => [testMeetingsList[1]]);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const LoadMeetingsByStatusEvent(MeetingStatus.confirmed)),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingsLoadedState>(),
      ],
      verify: (bloc) {
        verify(mockMeetingRepository.getMeetingsByStatus(MeetingStatus.confirmed)).called(1);
        final state = bloc.state as MeetingsLoadedState;
        expect(state.meetings.length, equals(1));
        expect(state.meetings[0].status, equals(MeetingStatus.confirmed));
        expect(state.filterDescription, equals('CONFIRMED Meetings'));
      },
    );

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, UpcomingMeetingsLoadedState] when LoadUpcomingMeetingsEvent is added',
      build: () {
        when(mockMeetingRepository.getUpcomingMeetings())
            .thenAnswer((_) async => [testMeetingsList[0], testMeetingsList[1]]);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const LoadUpcomingMeetingsEvent()),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<UpcomingMeetingsLoadedState>(),
      ],
      verify: (bloc) {
        verify(mockMeetingRepository.getUpcomingMeetings()).called(1);
        final state = bloc.state as UpcomingMeetingsLoadedState;
        expect(state.meetings.length, equals(2));
      },
    );

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, PastMeetingsLoadedState] when LoadPastMeetingsEvent is added',
      build: () {
        when(mockMeetingRepository.getPastMeetings())
            .thenAnswer((_) async => [testMeetingsList[2]]);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const LoadPastMeetingsEvent()),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<PastMeetingsLoadedState>(),
      ],
      verify: (bloc) {
        verify(mockMeetingRepository.getPastMeetings()).called(1);
        final state = bloc.state as PastMeetingsLoadedState;
        expect(state.meetings.length, equals(1));
        expect(state.meetings[0].status, equals(MeetingStatus.completed));
      },
    );

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingCreatedState] when CreateMeetingEvent is added',
      build: () {
        when(mockMeetingRepository.createMeeting(testMeeting))
            .thenAnswer((_) async => testMeeting);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(CreateMeetingEvent(testMeeting)),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingCreatedState>(),
      ],
      verify: (_) {
        verify(mockMeetingRepository.createMeeting(testMeeting)).called(1);
      },
    );

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingUpdatedState] when UpdateMeetingEvent is added',
      build: () {
        final updatedMeeting = testMeeting.copyWith(title: 'Updated Title');
        when(mockMeetingRepository.updateMeeting(updatedMeeting))
            .thenAnswer((_) async => updatedMeeting);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(UpdateMeetingEvent(testMeeting.copyWith(title: 'Updated Title'))),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingUpdatedState>(),
      ],
      verify: (bloc) {
        final updatedMeeting = testMeeting.copyWith(title: 'Updated Title');
        verify(mockMeetingRepository.updateMeeting(updatedMeeting)).called(1);
        final state = bloc.state as MeetingUpdatedState;
        expect(state.meeting.title, equals('Updated Title'));
      },
    );

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingDeletedState] when DeleteMeetingEvent is added',
      build: () {
        when(mockMeetingRepository.deleteMeeting('meeting123'))
            .thenAnswer((_) async {});
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const DeleteMeetingEvent('meeting123')),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingDeletedState>(),
      ],
      verify: (bloc) {
        verify(mockMeetingRepository.deleteMeeting('meeting123')).called(1);
        final state = bloc.state as MeetingDeletedState;
        expect(state.meetingId, equals('meeting123'));
      },
    );

    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingCanceledState] when CancelMeetingEvent is added',
      build: () {
        final canceledMeeting = testMeeting.copyWith(
          status: MeetingStatus.canceled,
          notes: 'Schedule conflict',
        );
        when(mockMeetingRepository.cancelMeeting('meeting123', reason: 'Schedule conflict'))
            .thenAnswer((_) async => canceledMeeting);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const CancelMeetingEvent('meeting123', reason: 'Schedule conflict')),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingCanceledState>(),
      ],
      verify: (bloc) {
        verify(mockMeetingRepository.cancelMeeting('meeting123', reason: 'Schedule conflict')).called(1);
        final state = bloc.state as MeetingCanceledState;
        expect(state.meeting.status, equals(MeetingStatus.canceled));
        expect(state.meeting.notes, equals('Schedule conflict'));
      },
    );
    
    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingConfirmedState] when ConfirmMeetingEvent is added',
      build: () {
        final confirmedMeeting = testMeeting.copyWith(status: MeetingStatus.confirmed);
        when(mockMeetingRepository.confirmMeeting('meeting123'))
            .thenAnswer((_) async => confirmedMeeting);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const ConfirmMeetingEvent('meeting123')),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingConfirmedState>(),
      ],
      verify: (bloc) {
        verify(mockMeetingRepository.confirmMeeting('meeting123')).called(1);
        final state = bloc.state as MeetingConfirmedState;
        expect(state.meeting.status, equals(MeetingStatus.confirmed));
      },
    );
    
    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingRescheduledState] when RescheduleMeetingEvent is added',
      build: () {
        // Use any matcher for the DateTime parameter
        final rescheduledMeeting = testMeeting.copyWith(
          status: MeetingStatus.rescheduled,
          scheduledTime: DateTime.now().add(const Duration(days: 7)),
          durationMinutes: 90,
        );
        when(mockMeetingRepository.rescheduleMeeting(
            'meeting123', 
            any, 
            newDurationMinutes: 90))
            .thenAnswer((_) async => rescheduledMeeting);
        return meetingBloc;
      },
      act: (bloc) {
        final newDate = DateTime.now().add(const Duration(days: 7));
        return bloc.add(RescheduleMeetingEvent('meeting123', newDate, newDurationMinutes: 90));
      },
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingRescheduledState>(),
      ],
      verify: (bloc) {
        verify(mockMeetingRepository.rescheduleMeeting(
            'meeting123', 
            any, 
            newDurationMinutes: 90)).called(1);
        final state = bloc.state as MeetingRescheduledState;
        expect(state.meeting.status, equals(MeetingStatus.rescheduled));
        expect(state.meeting.durationMinutes, equals(90));
      },
    );
    
    blocTest<MeetingBloc, MeetingState>(
      'emits [MeetingLoadingState, MeetingCompletedState] when CompleteMeetingEvent is added',
      build: () {
        final completedMeeting = testMeeting.copyWith(status: MeetingStatus.completed);
        when(mockMeetingRepository.completeMeeting('meeting123'))
            .thenAnswer((_) async => completedMeeting);
        return meetingBloc;
      },
      act: (bloc) => bloc.add(const CompleteMeetingEvent('meeting123')),
      expect: () => [
        isA<MeetingLoadingState>(),
        isA<MeetingCompletedState>(),
      ],
      verify: (bloc) {
        verify(mockMeetingRepository.completeMeeting('meeting123')).called(1);
        final state = bloc.state as MeetingCompletedState;
        expect(state.meeting.status, equals(MeetingStatus.completed));
      },
    );
  });
}