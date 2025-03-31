import '../blocs/achievement_bloc.dart';
import '../repositories/achievement_repository.dart';

/// A helper class to check and update achievements when users perform actions
class AchievementChecker {
  final AchievementBloc _achievementBloc;
  
  AchievementChecker({
    required AchievementBloc achievementBloc,
  }) : _achievementBloc = achievementBloc;
  
  /// Check if any achievements have been unlocked based on a user action
  void checkAchievements({
    required String userId,
    required String action,
    Map<String, dynamic>? metadata,
  }) {
    _achievementBloc.add(CheckAchievementsEvent(
      userId: userId,
      action: action,
      metadata: metadata,
    ));
  }
  
  /// Helper methods for commonly used achievement checks
  
  /// Called when user logs in
  void onLogin(String userId) {
    checkAchievements(
      userId: userId,
      action: 'login',
    );
  }
  
  /// Called when user completes their profile
  void onProfileComplete(String userId) {
    checkAchievements(
      userId: userId,
      action: 'complete_profile',
    );
  }
  
  /// Called when user sends a connection request
  void onConnectionRequest(String userId, String recipientId) {
    checkAchievements(
      userId: userId,
      action: 'send_connection_request',
      metadata: {'recipientId': recipientId},
    );
  }
  
  /// Called when user accepts a connection request
  void onConnectionAccepted(String userId, String requesterId) {
    checkAchievements(
      userId: userId,
      action: 'accept_connection',
      metadata: {'requesterId': requesterId},
    );
  }
  
  /// Called when user creates a meeting
  void onMeetingCreated(String userId, String meetingId) {
    checkAchievements(
      userId: userId,
      action: 'create_meeting',
      metadata: {'meetingId': meetingId},
    );
  }
  
  /// Called when a meeting is verified via NFC
  void onMeetingVerified(String userId, String meetingId) {
    checkAchievements(
      userId: userId,
      action: 'verify_meeting',
      metadata: {'meetingId': meetingId},
    );
  }
  
  /// Called when user completes their first donation
  void onDonationComplete(String userId, double amount) {
    checkAchievements(
      userId: userId,
      action: 'donation_complete',
      metadata: {'amount': amount},
    );
  }
}