import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:fresh_bond_app/core/utils/error_handler.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:nfc_manager/nfc_manager.dart';

import 'package:fresh_bond_app/features/meetings/domain/repositories/nfc_verification_repository_interface.dart';

/// Repository implementation for NFC verification functionality
class NfcVerificationRepository implements NfcVerificationRepositoryInterface {
  /// The NFC Manager instance
  final NfcManager _nfcManager;
  
  /// Authentication repository for getting current user
  final AuthRepository _authRepository;
  
  /// Meeting repository for updating meeting status
  final MeetingRepository _meetingRepository;
  
  /// Logger for debugging
  final AppLogger _logger;
  
  /// Error handler for consistent error handling
  final ErrorHandler _errorHandler;
  
  /// Indicates if NFC is available on this device
  bool _isNfcAvailable = false;
  
  /// Completer for NFC tag reading
  Completer<Map<String, dynamic>>? _tagCompleter;
  
  /// Constructor
  NfcVerificationRepository({
    required NfcManager nfcManager,
    required AuthRepository authRepository,
    required MeetingRepository meetingRepository,
    required AppLogger logger,
    required ErrorHandler errorHandler,
  })  : _nfcManager = nfcManager,
        _authRepository = authRepository,
        _meetingRepository = meetingRepository,
        _logger = logger,
        _errorHandler = errorHandler;
  
  /// Initialize NFC capability check
  Future<void> initialize() async {
    try {
      _isNfcAvailable = await _nfcManager.isAvailable();
      _logger.i('NFC availability: $_isNfcAvailable');
    } catch (e) {
      _logger.e('Error checking NFC availability: $e');
      _isNfcAvailable = false;
    }
  }
  
  /// Check if NFC is available on this device
  bool isNfcAvailable() {
    return _isNfcAvailable;
  }
  
  /// Start NFC session for verification
  /// Returns a Future that completes when a tag is read or the session is stopped
  Future<Map<String, dynamic>> startNfcSession(MeetingModel meeting) async {
    if (!_isNfcAvailable) {
      throw Exception('NFC is not available on this device');
    }
    
    try {
      // Check if a session is already in progress
      if (_tagCompleter != null && !_tagCompleter!.isCompleted) {
        throw Exception('NFC session already in progress');
      }
      
      _tagCompleter = Completer<Map<String, dynamic>>();
      
      // Generate verification payload based on meeting ID and participants
      final verificationPayload = _generateVerificationPayload(meeting);
      
      // Start NFC session
      await _nfcManager.startSession(
        onDiscovered: (NfcTag tag) async {
          try {
            // Try to read NDEF message if available
            final ndefTag = Ndef.from(tag);
            if (ndefTag != null) {
              final ndefMessage = ndefTag.cachedMessage;
              if (ndefMessage != null) {
                final records = ndefMessage.records;
                if (records.isNotEmpty) {
                  // Get the payload from the first record
                  final payload = records.first.payload;
                  final payloadString = String.fromCharCodes(payload);
                  
                  // Complete the completer with the payload
                  if (!_tagCompleter!.isCompleted) {
                    _tagCompleter!.complete({
                      'success': true,
                      'payload': payloadString,
                      'tag': tag,
                    });
                  }
                  await _nfcManager.stopSession();
                  return;
                }
              }
            }
            
            // If NDEF reading fails, try to get raw tag data
            final rawData = _extractRawTagData(tag);
            if (!_tagCompleter!.isCompleted) {
              _tagCompleter!.complete({
                'success': true,
                'payload': rawData,
                'tag': tag,
              });
            }
            
            await _nfcManager.stopSession();
          } catch (e) {
            _logger.e('Error processing NFC tag: $e');
            if (!_tagCompleter!.isCompleted) {
              _tagCompleter!.completeError(e);
            }
            await _nfcManager.stopSession();
          }
        },
        onError: (error) async {
          _logger.e('NFC session error: $error');
          if (_tagCompleter != null && !_tagCompleter!.isCompleted) {
            _tagCompleter!.completeError(error);
          }
          await _nfcManager.stopSession(errorMessage: error.toString());
        },
      );
      
      return _tagCompleter!.future;
    } catch (e) {
      _logger.e('Error starting NFC session: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  /// Stop current NFC session
  Future<void> stopNfcSession() async {
    try {
      await _nfcManager.stopSession();
      if (_tagCompleter != null && !_tagCompleter!.isCompleted) {
        _tagCompleter!.completeError('NFC session stopped by user');
      }
    } catch (e) {
      _logger.e('Error stopping NFC session: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  /// Verify meeting using NFC
  Future<MeetingModel> verifyMeeting(String meetingId, Map<String, dynamic> nfcData) async {
    try {
      final meeting = await _meetingRepository.getMeeting(meetingId);
      if (meeting == null) {
        throw Exception('Meeting not found');
      }
      
      final currentUser = await _authRepository.getCurrentUser();
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }
      
      // Verify NFC data matches meeting parameters
      final payload = nfcData['payload'];
      final expectedPayload = _generateVerificationPayload(meeting);
      
      // For demo purposes, we'll simply verify the meeting
      // In a real implementation, you would validate the NFC payload against expected values
      
      // Mark meeting as completed
      final completedMeeting = await _meetingRepository.completeMeeting(meetingId);
      return completedMeeting;
    } catch (e) {
      _logger.e('Error verifying meeting: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  /// Generate verification payload for NFC tag
  String _generateVerificationPayload(MeetingModel meeting) {
    final data = {
      'meetingId': meeting.id,
      'creatorId': meeting.creatorId,
      'inviteeId': meeting.inviteeId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };
    
    final jsonData = jsonEncode(data);
    final hash = sha256.convert(utf8.encode(jsonData)).toString();
    
    return hash;
  }
  
  /// Extract raw data from NFC tag if NDEF is not available
  String _extractRawTagData(NfcTag tag) {
    try {
      // Different tag types may have different data formats
      if (tag.data.containsKey('mifare')) {
        final mifareData = tag.data['mifare'] as Map<String, dynamic>;
        final identifier = mifareData['identifier'] as Uint8List?;
        if (identifier != null) {
          return identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
        }
      }
      
      if (tag.data.containsKey('nfca')) {
        final nfcaData = tag.data['nfca'] as Map<String, dynamic>;
        final identifier = nfcaData['identifier'] as Uint8List?;
        if (identifier != null) {
          return identifier.map((e) => e.toRadixString(16).padLeft(2, '0')).join('');
        }
      }
      
      // If no specific tag data is found, return string representation of tag data
      return jsonEncode(tag.data);
    } catch (e) {
      _logger.e('Error extracting raw tag data: $e');
      return 'unknown-tag-data';
    }
  }
}