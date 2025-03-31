import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';

/// Repository interface for NFC verification functionality
abstract class NfcVerificationRepositoryInterface {
  /// Initialize NFC capability check
  Future<void> initialize();
  
  /// Check if NFC is available on this device
  bool isNfcAvailable();
  
  /// Start NFC session for verification
  /// Returns a Future that completes when a tag is read or the session is stopped
  Future<Map<String, dynamic>> startNfcSession(MeetingModel meeting);
  
  /// Stop current NFC session
  Future<void> stopNfcSession();
  
  /// Verify meeting using NFC
  Future<MeetingModel> verifyMeeting(String meetingId, Map<String, dynamic> nfcData);
}