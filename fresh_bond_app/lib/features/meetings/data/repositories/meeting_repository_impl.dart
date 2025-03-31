import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_bond_app/core/utils/error_handler.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/meeting_repository.dart';

/// Implementation of the meeting repository using Firebase Firestore
class MeetingRepositoryImpl implements MeetingRepository {
  /// Firestore instance
  final FirebaseFirestore _firestore;
  
  /// Authentication repository for getting the current user
  final AuthRepository _authRepository;
  
  /// Logger for debugging
  final AppLogger _logger;
  
  /// Error handler for consistent error handling
  final ErrorHandler _errorHandler;
  
  /// Firestore collection name for meetings
  static const String _collectionName = 'meetings';
  
  /// Constructor
  MeetingRepositoryImpl({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
    required AppLogger logger,
    required ErrorHandler errorHandler,
  })  : _firestore = firestore,
        _authRepository = authRepository,
        _logger = logger,
        _errorHandler = errorHandler;
        
  /// Get a reference to the meetings collection
  CollectionReference<Map<String, dynamic>> get _meetingsCollection => 
      _firestore.collection(_collectionName);
      
  /// Get the current user ID
  Future<String> _getCurrentUserId() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }
  
  @override
  Future<MeetingModel?> getMeeting(String meetingId) async {
    try {
      final currentUserId = await _getCurrentUserId();
      final docSnapshot = await _meetingsCollection.doc(meetingId).get();
      
      if (!docSnapshot.exists) {
        return null;
      }
      
      final data = docSnapshot.data()!;
      
      // Check if the current user is a participant
      if (data['creatorId'] != currentUserId && data['inviteeId'] != currentUserId) {
        throw Exception('User not authorized to access this meeting');
      }
      
      return MeetingModel.fromJson({
        'id': docSnapshot.id,
        ...data,
      });
    } catch (e) {
      _logger.e('Error getting meeting: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<List<MeetingModel>> getMeetingsForCurrentUser() async {
    try {
      final currentUserId = await _getCurrentUserId();
      
      // Query meetings where user is either creator or invitee
      final querySnapshot = await _meetingsCollection
          .where(Filter.or(
            Filter('creatorId', isEqualTo: currentUserId),
            Filter('inviteeId', isEqualTo: currentUserId),
          ))
          .orderBy('scheduledTime', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return MeetingModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      _logger.e('Error getting meetings for current user: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<List<MeetingModel>> getMeetingsByStatus(MeetingStatus status) async {
    try {
      final currentUserId = await _getCurrentUserId();
      
      // Query meetings with specified status where user is participant
      final querySnapshot = await _meetingsCollection
          .where(Filter.or(
            Filter('creatorId', isEqualTo: currentUserId),
            Filter('inviteeId', isEqualTo: currentUserId),
          ))
          .where('status', isEqualTo: status.name)
          .orderBy('scheduledTime', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return MeetingModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      _logger.e('Error getting meetings by status: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<List<MeetingModel>> getUpcomingMeetings() async {
    try {
      final currentUserId = await _getCurrentUserId();
      final now = DateTime.now();
      
      // Query meetings where scheduled time is in the future
      final querySnapshot = await _meetingsCollection
          .where(Filter.or(
            Filter('creatorId', isEqualTo: currentUserId),
            Filter('inviteeId', isEqualTo: currentUserId),
          ))
          .where('scheduledTime', isGreaterThanOrEqualTo: now.toIso8601String())
          .where('status', whereIn: [
            MeetingStatus.pending.name,
            MeetingStatus.confirmed.name,
          ])
          .orderBy('scheduledTime')
          .get();
      
      return querySnapshot.docs.map((doc) {
        return MeetingModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      _logger.e('Error getting upcoming meetings: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<List<MeetingModel>> getPastMeetings() async {
    try {
      final currentUserId = await _getCurrentUserId();
      final now = DateTime.now();
      
      // Query meetings where scheduled time is in the past
      final querySnapshot = await _meetingsCollection
          .where(Filter.or(
            Filter('creatorId', isEqualTo: currentUserId),
            Filter('inviteeId', isEqualTo: currentUserId),
          ))
          .where('scheduledTime', isLessThan: now.toIso8601String())
          .orderBy('scheduledTime', descending: true)
          .get();
      
      return querySnapshot.docs.map((doc) {
        return MeetingModel.fromJson({
          'id': doc.id,
          ...doc.data(),
        });
      }).toList();
    } catch (e) {
      _logger.e('Error getting past meetings: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<MeetingModel> createMeeting(MeetingModel meeting) async {
    try {
      final currentUserId = await _getCurrentUserId();
      
      // Ensure the creator is the current user
      if (meeting.creatorId != currentUserId) {
        throw Exception('Current user must be the creator of the meeting');
      }
      
      final now = DateTime.now();
      
      // Prepare the meeting data
      final meetingData = {
        ...meeting.toJson(),
        'createdAt': now.toIso8601String(),
        'updatedAt': now.toIso8601String(),
      };
      
      // Remove the ID as it will be generated by Firestore
      meetingData.remove('id');
      
      // Add the meeting to Firestore
      final docRef = await _meetingsCollection.add(meetingData);
      
      // Return the created meeting with the generated ID
      return MeetingModel.fromJson({
        'id': docRef.id,
        ...meetingData,
      });
    } catch (e) {
      _logger.e('Error creating meeting: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<MeetingModel> updateMeeting(MeetingModel meeting) async {
    try {
      final currentUserId = await _getCurrentUserId();
      
      // Check if the meeting exists and user is authorized
      final existingMeeting = await getMeeting(meeting.id);
      if (existingMeeting == null) {
        throw Exception('Meeting not found');
      }
      
      // Ensure the user is a participant in the meeting
      if (existingMeeting.creatorId != currentUserId && 
          existingMeeting.inviteeId != currentUserId) {
        throw Exception('User not authorized to update this meeting');
      }
      
      // Prepare the update data
      final now = DateTime.now();
      final updateData = {
        ...meeting.toJson(),
        'updatedAt': now.toIso8601String(),
      };
      
      // Remove the ID as it's part of the document path
      updateData.remove('id');
      
      // Update the meeting in Firestore
      await _meetingsCollection.doc(meeting.id).update(updateData);
      
      // Return the updated meeting
      return meeting.copyWith(updatedAt: now);
    } catch (e) {
      _logger.e('Error updating meeting: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<void> deleteMeeting(String meetingId) async {
    try {
      final currentUserId = await _getCurrentUserId();
      
      // Check if the meeting exists and user is authorized
      final existingMeeting = await getMeeting(meetingId);
      if (existingMeeting == null) {
        throw Exception('Meeting not found');
      }
      
      // Only the creator can delete a meeting
      if (existingMeeting.creatorId != currentUserId) {
        throw Exception('Only the creator can delete this meeting');
      }
      
      // Delete the meeting from Firestore
      await _meetingsCollection.doc(meetingId).delete();
    } catch (e) {
      _logger.e('Error deleting meeting: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<MeetingModel> cancelMeeting(String meetingId, {String? reason}) async {
    try {
      final currentUserId = await _getCurrentUserId();
      
      // Check if the meeting exists and user is authorized
      final existingMeeting = await getMeeting(meetingId);
      if (existingMeeting == null) {
        throw Exception('Meeting not found');
      }
      
      // Ensure the user is a participant in the meeting
      if (existingMeeting.creatorId != currentUserId && 
          existingMeeting.inviteeId != currentUserId) {
        throw Exception('User not authorized to cancel this meeting');
      }
      
      // Cannot cancel a meeting that is already completed or canceled
      if (existingMeeting.status == MeetingStatus.completed || 
          existingMeeting.status == MeetingStatus.canceled) {
        throw Exception('Cannot cancel a meeting that is already ${existingMeeting.status.name}');
      }
      
      // Update the meeting status to canceled
      final now = DateTime.now();
      final updateData = {
        'status': MeetingStatus.canceled.name,
        'updatedAt': now.toIso8601String(),
        if (reason != null) 'notes': reason,
      };
      
      await _meetingsCollection.doc(meetingId).update(updateData);
      
      // Return the updated meeting
      return existingMeeting.copyWith(
        status: MeetingStatus.canceled,
        updatedAt: now,
        notes: reason ?? existingMeeting.notes,
      );
    } catch (e) {
      _logger.e('Error canceling meeting: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<MeetingModel> confirmMeeting(String meetingId) async {
    try {
      final currentUserId = await _getCurrentUserId();
      
      // Check if the meeting exists and user is authorized
      final existingMeeting = await getMeeting(meetingId);
      if (existingMeeting == null) {
        throw Exception('Meeting not found');
      }
      
      // Only the invitee can confirm a meeting
      if (existingMeeting.inviteeId != currentUserId) {
        throw Exception('Only the invitee can confirm this meeting');
      }
      
      // Cannot confirm a meeting that is not pending
      if (existingMeeting.status != MeetingStatus.pending) {
        throw Exception('Can only confirm meetings that are pending');
      }
      
      // Update the meeting status to confirmed
      final now = DateTime.now();
      final updateData = {
        'status': MeetingStatus.confirmed.name,
        'updatedAt': now.toIso8601String(),
      };
      
      await _meetingsCollection.doc(meetingId).update(updateData);
      
      // Return the updated meeting
      return existingMeeting.copyWith(
        status: MeetingStatus.confirmed,
        updatedAt: now,
      );
    } catch (e) {
      _logger.e('Error confirming meeting: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<MeetingModel> rescheduleMeeting(
    String meetingId, 
    DateTime newDateTime, 
    {int? newDurationMinutes}
  ) async {
    try {
      final currentUserId = await _getCurrentUserId();
      
      // Check if the meeting exists and user is authorized
      final existingMeeting = await getMeeting(meetingId);
      if (existingMeeting == null) {
        throw Exception('Meeting not found');
      }
      
      // Ensure the user is a participant in the meeting
      if (existingMeeting.creatorId != currentUserId && 
          existingMeeting.inviteeId != currentUserId) {
        throw Exception('User not authorized to reschedule this meeting');
      }
      
      // Cannot reschedule a meeting that is completed or canceled
      if (existingMeeting.status == MeetingStatus.completed || 
          existingMeeting.status == MeetingStatus.canceled) {
        throw Exception('Cannot reschedule a meeting that is already ${existingMeeting.status.name}');
      }
      
      // Update the meeting with new schedule
      final now = DateTime.now();
      final updateData = {
        'scheduledTime': newDateTime.toIso8601String(),
        'status': MeetingStatus.rescheduled.name,
        'updatedAt': now.toIso8601String(),
      };
      
      if (newDurationMinutes != null) {
        updateData['durationMinutes'] = newDurationMinutes.toString();
      }
      
      await _meetingsCollection.doc(meetingId).update(updateData);
      
      // Return the updated meeting
      return existingMeeting.copyWith(
        scheduledTime: newDateTime,
        durationMinutes: newDurationMinutes ?? existingMeeting.durationMinutes,
        status: MeetingStatus.rescheduled,
        updatedAt: now,
      );
    } catch (e) {
      _logger.e('Error rescheduling meeting: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<MeetingModel> completeMeeting(String meetingId) async {
    try {
      final currentUserId = await _getCurrentUserId();
      
      // Check if the meeting exists and user is authorized
      final existingMeeting = await getMeeting(meetingId);
      if (existingMeeting == null) {
        throw Exception('Meeting not found');
      }
      
      // Only the creator can mark a meeting as completed
      if (existingMeeting.creatorId != currentUserId) {
        throw Exception('Only the creator can mark this meeting as completed');
      }
      
      // Cannot complete a meeting that is not confirmed or rescheduled
      if (existingMeeting.status != MeetingStatus.confirmed && 
          existingMeeting.status != MeetingStatus.rescheduled) {
        throw Exception('Can only complete meetings that are confirmed or rescheduled');
      }
      
      // Update the meeting status to completed
      final now = DateTime.now();
      final updateData = {
        'status': MeetingStatus.completed.name,
        'updatedAt': now.toIso8601String(),
      };
      
      await _meetingsCollection.doc(meetingId).update(updateData);
      
      // Return the updated meeting
      return existingMeeting.copyWith(
        status: MeetingStatus.completed,
        updatedAt: now,
      );
    } catch (e) {
      _logger.e('Error completing meeting: $e');
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<int> getCompletedMeetingsCount(String userId) async {
    try {
      _logger.d('Getting completed meetings count for user: $userId');
      
      final snapshot = await _meetingsCollection
          .where('participants', arrayContains: userId)
          .where('status', isEqualTo: MeetingStatus.completed.name)
          .count()
          .get();
      
      return snapshot.count ?? 0;
    } catch (e, stackTrace) {
      _logger.e('Error getting completed meetings count', error: e, stackTrace: stackTrace);
      return 0; // Return 0 instead of throwing to avoid crashing the app
    }
  }
}