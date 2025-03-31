import 'package:equatable/equatable.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';

/// Base class for all NFC verification events
abstract class NfcVerificationEvent extends Equatable {
  const NfcVerificationEvent();

  @override
  List<Object?> get props => [];
}

/// Event to initialize NFC
class InitializeNfcEvent extends NfcVerificationEvent {}

/// Event to check NFC availability
class CheckNfcAvailabilityEvent extends NfcVerificationEvent {}

/// Event to start NFC verification session
class StartNfcSessionEvent extends NfcVerificationEvent {
  final MeetingModel meeting;

  const StartNfcSessionEvent(this.meeting);

  @override
  List<Object?> get props => [meeting];
}

/// Event to stop NFC verification session
class StopNfcSessionEvent extends NfcVerificationEvent {}

/// Event to verify meeting using NFC data
class VerifyMeetingWithNfcEvent extends NfcVerificationEvent {
  final String meetingId;
  final Map<String, dynamic> nfcData;

  const VerifyMeetingWithNfcEvent({
    required this.meetingId,
    required this.nfcData,
  });

  @override
  List<Object?> get props => [meetingId, nfcData];
}

/// Event when NFC tag is detected
class NfcTagDetectedEvent extends NfcVerificationEvent {
  final Map<String, dynamic> tagData;

  const NfcTagDetectedEvent(this.tagData);

  @override
  List<Object?> get props => [tagData];
}