import 'package:equatable/equatable.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';

/// Base class for all NFC verification states
abstract class NfcVerificationState extends Equatable {
  const NfcVerificationState();

  @override
  List<Object?> get props => [];
}

/// Initial state
class NfcVerificationInitialState extends NfcVerificationState {
  const NfcVerificationInitialState();
}

/// State when NFC is initializing
class NfcInitializingState extends NfcVerificationState {
  const NfcInitializingState();
}

/// State when NFC is available
class NfcAvailableState extends NfcVerificationState {
  const NfcAvailableState();
}

/// State when NFC is not available
class NfcNotAvailableState extends NfcVerificationState {
  final String message;

  const NfcNotAvailableState(this.message);

  @override
  List<Object?> get props => [message];
}

/// State when NFC session is in progress
class NfcSessionInProgressState extends NfcVerificationState {
  final MeetingModel meeting;

  const NfcSessionInProgressState(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// State when NFC tag is detected
class NfcTagDetectedState extends NfcVerificationState {
  final Map<String, dynamic> tagData;
  final MeetingModel meeting;

  const NfcTagDetectedState({
    required this.tagData,
    required this.meeting,
  });

  @override
  List<Object?> get props => [tagData, meeting];
}

/// State when meeting verification is in progress
class VerifyingMeetingState extends NfcVerificationState {
  final String meetingId;

  const VerifyingMeetingState(this.meetingId);

  @override
  List<Object?> get props => [meetingId];
}

/// State when meeting verification is successful
class MeetingVerifiedState extends NfcVerificationState {
  final MeetingModel meeting;

  const MeetingVerifiedState(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// Error state
class NfcVerificationErrorState extends NfcVerificationState {
  final String message;

  const NfcVerificationErrorState(this.message);

  @override
  List<Object?> get props => [message];
}