import 'package:bloc/bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_event.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_state.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/nfc_verification_repository_interface.dart';

/// BLoC for managing NFC verification operations
class NfcVerificationBloc
    extends Bloc<NfcVerificationEvent, NfcVerificationState> {
  /// Repository for NFC verification
  final NfcVerificationRepositoryInterface _nfcRepository;

  /// Constructor
  NfcVerificationBloc({required NfcVerificationRepositoryInterface nfcRepository})
      : _nfcRepository = nfcRepository,
        super(const NfcVerificationInitialState()) {
    on<InitializeNfcEvent>(_onInitializeNfc);
    on<CheckNfcAvailabilityEvent>(_onCheckNfcAvailability);
    on<StartNfcSessionEvent>(_onStartNfcSession);
    on<StopNfcSessionEvent>(_onStopNfcSession);
    on<VerifyMeetingWithNfcEvent>(_onVerifyMeetingWithNfc);
    on<NfcTagDetectedEvent>(_onNfcTagDetected);
  }

  /// Handle initializing NFC
  Future<void> _onInitializeNfc(
    InitializeNfcEvent event,
    Emitter<NfcVerificationState> emit,
  ) async {
    try {
      emit(const NfcInitializingState());
      await _nfcRepository.initialize();
      if (_nfcRepository.isNfcAvailable()) {
        emit(const NfcAvailableState());
      } else {
        emit(const NfcNotAvailableState('NFC is not available on this device'));
      }
    } catch (e) {
      emit(NfcVerificationErrorState('Failed to initialize NFC: ${e.toString()}'));
    }
  }

  /// Handle checking NFC availability
  Future<void> _onCheckNfcAvailability(
    CheckNfcAvailabilityEvent event,
    Emitter<NfcVerificationState> emit,
  ) async {
    try {
      if (_nfcRepository.isNfcAvailable()) {
        emit(const NfcAvailableState());
      } else {
        emit(const NfcNotAvailableState('NFC is not available on this device'));
      }
    } catch (e) {
      emit(NfcVerificationErrorState('Failed to check NFC availability: ${e.toString()}'));
    }
  }

  /// Handle starting NFC session
  Future<void> _onStartNfcSession(
    StartNfcSessionEvent event,
    Emitter<NfcVerificationState> emit,
  ) async {
    try {
      if (!_nfcRepository.isNfcAvailable()) {
        emit(const NfcNotAvailableState('NFC is not available on this device'));
        return;
      }

      emit(NfcSessionInProgressState(event.meeting));
      
      final nfcData = await _nfcRepository.startNfcSession(event.meeting);
      
      add(NfcTagDetectedEvent(nfcData));
    } catch (e) {
      emit(NfcVerificationErrorState('Failed to start NFC session: ${e.toString()}'));
    }
  }

  /// Handle stopping NFC session
  Future<void> _onStopNfcSession(
    StopNfcSessionEvent event,
    Emitter<NfcVerificationState> emit,
  ) async {
    try {
      await _nfcRepository.stopNfcSession();
      emit(const NfcAvailableState());
    } catch (e) {
      emit(NfcVerificationErrorState('Failed to stop NFC session: ${e.toString()}'));
    }
  }

  /// Handle verifying meeting with NFC
  Future<void> _onVerifyMeetingWithNfc(
    VerifyMeetingWithNfcEvent event,
    Emitter<NfcVerificationState> emit,
  ) async {
    try {
      emit(VerifyingMeetingState(event.meetingId));
      
      final verifiedMeeting = await _nfcRepository.verifyMeeting(
        event.meetingId,
        event.nfcData,
      );
      
      emit(MeetingVerifiedState(verifiedMeeting));
    } catch (e) {
      emit(NfcVerificationErrorState('Failed to verify meeting: ${e.toString()}'));
    }
  }

  /// Handle NFC tag detection
  Future<void> _onNfcTagDetected(
    NfcTagDetectedEvent event,
    Emitter<NfcVerificationState> emit,
  ) async {
    try {
      // Get the current state to extract the meeting
      if (state is NfcSessionInProgressState) {
        final meeting = (state as NfcSessionInProgressState).meeting;
        emit(NfcTagDetectedState(
          tagData: event.tagData,
          meeting: meeting,
        ));
      } else {
        emit(NfcVerificationErrorState('NFC tag detected but no active session'));
      }
    } catch (e) {
      emit(NfcVerificationErrorState('Failed to process NFC tag: ${e.toString()}'));
    }
  }
}