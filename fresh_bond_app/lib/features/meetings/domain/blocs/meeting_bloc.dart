import 'package:bloc/bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_event.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_state.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/meeting_repository.dart';

/// BLoC for managing meeting-related operations
class MeetingBloc extends Bloc<MeetingEvent, MeetingState> {
  /// Repository for meeting data
  final MeetingRepository _meetingRepository;

  /// Constructor
  MeetingBloc({required MeetingRepository meetingRepository})
      : _meetingRepository = meetingRepository,
        super(const MeetingInitialState()) {
    on<LoadMeetingEvent>(_onLoadMeeting);
    on<LoadAllMeetingsEvent>(_onLoadAllMeetings);
    on<LoadMeetingsByStatusEvent>(_onLoadMeetingsByStatus);
    on<LoadUpcomingMeetingsEvent>(_onLoadUpcomingMeetings);
    on<LoadPastMeetingsEvent>(_onLoadPastMeetings);
    on<CreateMeetingEvent>(_onCreateMeeting);
    on<UpdateMeetingEvent>(_onUpdateMeeting);
    on<DeleteMeetingEvent>(_onDeleteMeeting);
    on<CancelMeetingEvent>(_onCancelMeeting);
    on<ConfirmMeetingEvent>(_onConfirmMeeting);
    on<RescheduleMeetingEvent>(_onRescheduleMeeting);
    on<CompleteMeetingEvent>(_onCompleteMeeting);
  }

  /// Handle loading a specific meeting
  Future<void> _onLoadMeeting(
    LoadMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meeting = await _meetingRepository.getMeeting(event.meetingId);
      
      if (meeting != null) {
        emit(MeetingLoadedState(meeting));
      } else {
        emit(const MeetingErrorState('Meeting not found'));
      }
    } catch (e) {
      emit(MeetingErrorState('Failed to load meeting: ${e.toString()}'));
    }
  }

  /// Handle loading all meetings for current user
  Future<void> _onLoadAllMeetings(
    LoadAllMeetingsEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meetings = await _meetingRepository.getMeetingsForCurrentUser();
      emit(MeetingsLoadedState(meetings, filterDescription: 'All Meetings'));
    } catch (e) {
      emit(MeetingErrorState('Failed to load meetings: ${e.toString()}'));
    }
  }

  /// Handle loading meetings by status
  Future<void> _onLoadMeetingsByStatus(
    LoadMeetingsByStatusEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meetings = await _meetingRepository.getMeetingsByStatus(event.status);
      emit(MeetingsLoadedState(
        meetings,
        filterDescription: '${event.status.name.toUpperCase()} Meetings',
      ));
    } catch (e) {
      emit(MeetingErrorState('Failed to load meetings: ${e.toString()}'));
    }
  }

  /// Handle loading upcoming meetings
  Future<void> _onLoadUpcomingMeetings(
    LoadUpcomingMeetingsEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meetings = await _meetingRepository.getUpcomingMeetings();
      emit(UpcomingMeetingsLoadedState(meetings));
    } catch (e) {
      emit(MeetingErrorState('Failed to load upcoming meetings: ${e.toString()}'));
    }
  }

  /// Handle loading past meetings
  Future<void> _onLoadPastMeetings(
    LoadPastMeetingsEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meetings = await _meetingRepository.getPastMeetings();
      emit(PastMeetingsLoadedState(meetings));
    } catch (e) {
      emit(MeetingErrorState('Failed to load past meetings: ${e.toString()}'));
    }
  }

  /// Handle creating a new meeting
  Future<void> _onCreateMeeting(
    CreateMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meeting = await _meetingRepository.createMeeting(event.meeting);
      emit(MeetingCreatedState(meeting));
    } catch (e) {
      emit(MeetingErrorState('Failed to create meeting: ${e.toString()}'));
    }
  }

  /// Handle updating an existing meeting
  Future<void> _onUpdateMeeting(
    UpdateMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meeting = await _meetingRepository.updateMeeting(event.meeting);
      emit(MeetingUpdatedState(meeting));
    } catch (e) {
      emit(MeetingErrorState('Failed to update meeting: ${e.toString()}'));
    }
  }

  /// Handle deleting a meeting
  Future<void> _onDeleteMeeting(
    DeleteMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      await _meetingRepository.deleteMeeting(event.meetingId);
      emit(MeetingDeletedState(event.meetingId));
    } catch (e) {
      emit(MeetingErrorState('Failed to delete meeting: ${e.toString()}'));
    }
  }

  /// Handle canceling a meeting
  Future<void> _onCancelMeeting(
    CancelMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meeting = await _meetingRepository.cancelMeeting(
        event.meetingId,
        reason: event.reason,
      );
      emit(MeetingCanceledState(meeting));
    } catch (e) {
      emit(MeetingErrorState('Failed to cancel meeting: ${e.toString()}'));
    }
  }

  /// Handle confirming a meeting
  Future<void> _onConfirmMeeting(
    ConfirmMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meeting = await _meetingRepository.confirmMeeting(event.meetingId);
      emit(MeetingConfirmedState(meeting));
    } catch (e) {
      emit(MeetingErrorState('Failed to confirm meeting: ${e.toString()}'));
    }
  }

  /// Handle rescheduling a meeting
  Future<void> _onRescheduleMeeting(
    RescheduleMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meeting = await _meetingRepository.rescheduleMeeting(
        event.meetingId,
        event.newDateTime,
        newDurationMinutes: event.newDurationMinutes,
      );
      emit(MeetingRescheduledState(meeting));
    } catch (e) {
      emit(MeetingErrorState('Failed to reschedule meeting: ${e.toString()}'));
    }
  }

  /// Handle completing a meeting
  Future<void> _onCompleteMeeting(
    CompleteMeetingEvent event,
    Emitter<MeetingState> emit,
  ) async {
    try {
      emit(const MeetingLoadingState());
      final meeting = await _meetingRepository.completeMeeting(event.meetingId);
      emit(MeetingCompletedState(meeting));
    } catch (e) {
      emit(MeetingErrorState('Failed to complete meeting: ${e.toString()}'));
    }
  }
}