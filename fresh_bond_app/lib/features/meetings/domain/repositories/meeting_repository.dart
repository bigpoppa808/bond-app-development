import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';

/// Repository interface for managing meetings
abstract class MeetingRepository {
  /// Get a specific meeting by ID
  Future<MeetingModel?> getMeeting(String meetingId);
  
  /// Get all meetings for the current user
  Future<List<MeetingModel>> getMeetingsForCurrentUser();
  
  /// Get meetings with a specific status
  Future<List<MeetingModel>> getMeetingsByStatus(MeetingStatus status);
  
  /// Get upcoming meetings for the current user
  Future<List<MeetingModel>> getUpcomingMeetings();
  
  /// Get past meetings for the current user
  Future<List<MeetingModel>> getPastMeetings();
  
  /// Create a new meeting
  Future<MeetingModel> createMeeting(MeetingModel meeting);
  
  /// Update an existing meeting
  Future<MeetingModel> updateMeeting(MeetingModel meeting);
  
  /// Delete a meeting
  Future<void> deleteMeeting(String meetingId);
  
  /// Cancel a meeting
  Future<MeetingModel> cancelMeeting(String meetingId, {String? reason});
  
  /// Confirm a meeting
  Future<MeetingModel> confirmMeeting(String meetingId);
  
  /// Reschedule a meeting
  Future<MeetingModel> rescheduleMeeting(
    String meetingId, 
    DateTime newDateTime, 
    {int? newDurationMinutes}
  );
  
  /// Mark a meeting as completed
  Future<MeetingModel> completeMeeting(String meetingId);
  
  /// Get count of completed meetings for a user
  Future<int> getCompletedMeetingsCount(String userId);
}