import 'package:equatable/equatable.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';

/// Base class for all meeting states
abstract class MeetingState extends Equatable {
  const MeetingState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class MeetingInitialState extends MeetingState {
  const MeetingInitialState();
}

/// Loading state for meetings
class MeetingLoadingState extends MeetingState {
  const MeetingLoadingState();
}

/// State when a single meeting is loaded
class MeetingLoadedState extends MeetingState {
  final MeetingModel meeting;

  const MeetingLoadedState(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// State when multiple meetings are loaded
class MeetingsLoadedState extends MeetingState {
  final List<MeetingModel> meetings;
  final String? filterDescription;

  const MeetingsLoadedState(this.meetings, {this.filterDescription});

  @override
  List<Object?> get props => [meetings, filterDescription];
}

/// State when upcoming meetings are loaded
class UpcomingMeetingsLoadedState extends MeetingState {
  final List<MeetingModel> meetings;

  const UpcomingMeetingsLoadedState(this.meetings);

  @override
  List<Object?> get props => [meetings];
}

/// State when past meetings are loaded
class PastMeetingsLoadedState extends MeetingState {
  final List<MeetingModel> meetings;

  const PastMeetingsLoadedState(this.meetings);

  @override
  List<Object?> get props => [meetings];
}

/// State for successful meeting creation
class MeetingCreatedState extends MeetingState {
  final MeetingModel meeting;

  const MeetingCreatedState(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// State for successful meeting update
class MeetingUpdatedState extends MeetingState {
  final MeetingModel meeting;

  const MeetingUpdatedState(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// State for successful meeting deletion
class MeetingDeletedState extends MeetingState {
  final String meetingId;

  const MeetingDeletedState(this.meetingId);

  @override
  List<Object?> get props => [meetingId];
}

/// State for successful meeting cancellation
class MeetingCanceledState extends MeetingState {
  final MeetingModel meeting;

  const MeetingCanceledState(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// State for successful meeting confirmation
class MeetingConfirmedState extends MeetingState {
  final MeetingModel meeting;

  const MeetingConfirmedState(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// State for successful meeting rescheduling
class MeetingRescheduledState extends MeetingState {
  final MeetingModel meeting;

  const MeetingRescheduledState(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// State for successful meeting completion
class MeetingCompletedState extends MeetingState {
  final MeetingModel meeting;

  const MeetingCompletedState(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// Error state for meetings
class MeetingErrorState extends MeetingState {
  final String message;

  const MeetingErrorState(this.message);

  @override
  List<Object?> get props => [message];
}