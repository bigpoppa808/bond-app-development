import 'package:equatable/equatable.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';

/// Base class for all meeting events
abstract class MeetingEvent extends Equatable {
  const MeetingEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load a specific meeting by ID
class LoadMeetingEvent extends MeetingEvent {
  final String meetingId;

  const LoadMeetingEvent(this.meetingId);

  @override
  List<Object?> get props => [meetingId];
}

/// Event to load all meetings for the current user
class LoadAllMeetingsEvent extends MeetingEvent {
  const LoadAllMeetingsEvent();
}

/// Event to load meetings with a specific status
class LoadMeetingsByStatusEvent extends MeetingEvent {
  final MeetingStatus status;

  const LoadMeetingsByStatusEvent(this.status);

  @override
  List<Object?> get props => [status];
}

/// Event to load upcoming meetings
class LoadUpcomingMeetingsEvent extends MeetingEvent {
  const LoadUpcomingMeetingsEvent();
}

/// Event to load past meetings
class LoadPastMeetingsEvent extends MeetingEvent {
  const LoadPastMeetingsEvent();
}

/// Event to create a new meeting
class CreateMeetingEvent extends MeetingEvent {
  final MeetingModel meeting;

  const CreateMeetingEvent(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// Event to update an existing meeting
class UpdateMeetingEvent extends MeetingEvent {
  final MeetingModel meeting;

  const UpdateMeetingEvent(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// Event to delete a meeting
class DeleteMeetingEvent extends MeetingEvent {
  final String meetingId;

  const DeleteMeetingEvent(this.meetingId);

  @override
  List<Object?> get props => [meetingId];
}

/// Event to cancel a meeting
class CancelMeetingEvent extends MeetingEvent {
  final String meetingId;
  final String? reason;

  const CancelMeetingEvent(this.meetingId, {this.reason});

  @override
  List<Object?> get props => [meetingId, reason];
}

/// Event to confirm a meeting
class ConfirmMeetingEvent extends MeetingEvent {
  final String meetingId;

  const ConfirmMeetingEvent(this.meetingId);

  @override
  List<Object?> get props => [meetingId];
}

/// Event to reschedule a meeting
class RescheduleMeetingEvent extends MeetingEvent {
  final String meetingId;
  final DateTime newDateTime;
  final int? newDurationMinutes;

  const RescheduleMeetingEvent(
    this.meetingId,
    this.newDateTime, {
    this.newDurationMinutes,
  });

  @override
  List<Object?> get props => [meetingId, newDateTime, newDurationMinutes];
}

/// Event to mark a meeting as completed
class CompleteMeetingEvent extends MeetingEvent {
  final String meetingId;

  const CompleteMeetingEvent(this.meetingId);

  @override
  List<Object?> get props => [meetingId];
}