import 'dart:developer' as developer;
import '../../../../core/utils/logger.dart';
import '../../domain/models/achievement.dart';

/// Service responsible for achievement criteria checking and user progress tracking
class AchievementService {
  final AppLogger _logger;

  AchievementService({required AppLogger logger}) : _logger = logger;

  /// Checks if an achievement's criteria are met based on user action and progress
  bool checkAchievementCriteria({
    required Achievement achievement,
    required String action,
    required Map<String, dynamic> userProgress,
    Map<String, dynamic>? metadata,
  }) {
    try {
      final criteria = achievement.criteria;
      
      // Check if this action is relevant for this achievement
      if (criteria['action'] != action && 
          (criteria['actions'] == null || !(criteria['actions'] as List<String>).contains(action))) {
        return false;
      }
      
      // Check count-based achievements (e.g., "Create 5 meetings")
      if (criteria.containsKey('requiredCount')) {
        final requiredCount = criteria['requiredCount'] as int;
        final countKey = criteria['countKey'] as String? ?? action;
        final currentCount = userProgress[countKey] as int? ?? 0;
        
        return currentCount >= requiredCount;
      }
      
      // Check sequence-based achievements (e.g., "Log in 5 days in a row")
      if (criteria.containsKey('sequenceType')) {
        final sequenceType = criteria['sequenceType'] as String;
        final requiredLength = criteria['requiredLength'] as int;
        
        if (sequenceType == 'daily') {
          final dailyTracker = userProgress['dailyTracker'] as Map<String, dynamic>? ?? {};
          final currentStreak = dailyTracker['currentStreak'] as int? ?? 0;
          
          return currentStreak >= requiredLength;
        }
      }
      
      // Check completion-based achievements (e.g., "Complete profile")
      if (criteria.containsKey('completionKey')) {
        final completionKey = criteria['completionKey'] as String;
        return userProgress[completionKey] == true;
      }
      
      // Check combination achievements (e.g., "Create a meeting AND make a connection")
      if (criteria.containsKey('combinations')) {
        final combinations = criteria['combinations'] as List<dynamic>;
        
        return combinations.every((combo) {
          final comboMap = combo as Map<String, dynamic>;
          final key = comboMap['key'] as String;
          final value = comboMap['value'];
          
          if (value is bool) {
            return userProgress[key] == value;
          } else if (value is int) {
            return (userProgress[key] as int? ?? 0) >= value;
          }
          
          return false;
        });
      }
      
      // For any custom achievement logic
      switch (achievement.id) {
        // Example: "Early Adopter" achievement
        case 'early_adopter':
          // Logic to check if user joined during beta period
          final joinedAt = userProgress['joinedTimestamp'] as int?;
          if (joinedAt == null) return false;
          
          final betaEndDate = DateTime(2023, 12, 31).millisecondsSinceEpoch;
          return joinedAt < betaEndDate;
          
        // Add more custom achievement logic here
          
        default:
          return false;
      }
    } catch (e) {
      developer.log('Error checking achievement criteria: $e');
      return false;
    }
  }

  /// Updates user progress based on an action
  /// Returns the updated progress map, or null if no updates were needed
  Map<String, dynamic>? updateUserProgress({
    required String action,
    required Map<String, dynamic> currentProgress,
    Map<String, dynamic>? metadata,
  }) {
    final updatedProgress = Map<String, dynamic>.from(currentProgress);
    bool progressUpdated = false;
    
    try {
      // Update count-based progress
      final countKey = '$action';
      final currentCount = updatedProgress[countKey] as int? ?? 0;
      updatedProgress[countKey] = currentCount + 1;
      progressUpdated = true;
      
      // Update daily streaks if needed
      if (['login', 'app_opened'].contains(action)) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day).millisecondsSinceEpoch;
        
        final dailyTracker = updatedProgress['dailyTracker'] as Map<String, dynamic>? ?? {};
        final lastLoginDay = dailyTracker['lastLoginDay'] as int? ?? 0;
        var currentStreak = dailyTracker['currentStreak'] as int? ?? 0;
        
        // If first login of the day
        if (lastLoginDay < today) {
          // Check if consecutive day
          final yesterday = DateTime(now.year, now.month, now.day - 1).millisecondsSinceEpoch;
          
          if (lastLoginDay >= yesterday || currentStreak == 0) {
            // Consecutive day or first login ever
            currentStreak += 1;
          } else {
            // Streak broken
            currentStreak = 1;
          }
          
          final maxStreak = dailyTracker['maxStreak'] as int? ?? 0;
          
          // Update daily tracker
          updatedProgress['dailyTracker'] = {
            'lastLoginDay': today,
            'currentStreak': currentStreak,
            'maxStreak': currentStreak > maxStreak ? currentStreak : maxStreak,
          };
          progressUpdated = true;
        }
      }
      
      // Handle specific actions
      switch (action) {
        case 'complete_profile':
          updatedProgress['profileCompleted'] = true;
          progressUpdated = true;
          break;
          
        case 'create_meeting':
          // Track first meeting created timestamp
          if (!updatedProgress.containsKey('firstMeetingCreatedAt')) {
            updatedProgress['firstMeetingCreatedAt'] = DateTime.now().millisecondsSinceEpoch;
            progressUpdated = true;
          }
          break;
          
        case 'verify_meeting':
          if (!updatedProgress.containsKey('firstMeetingVerifiedAt')) {
            updatedProgress['firstMeetingVerifiedAt'] = DateTime.now().millisecondsSinceEpoch;
            progressUpdated = true;
          }
          break;
          
        case 'send_connection_request':
          // Nothing specific beyond the count increment
          break;
          
        case 'accept_connection':
          if (!updatedProgress.containsKey('firstConnectionAt')) {
            updatedProgress['firstConnectionAt'] = DateTime.now().millisecondsSinceEpoch;
            progressUpdated = true;
          }
          break;
      }
      
      return progressUpdated ? updatedProgress : null;
    } catch (e) {
      developer.log('Error updating user progress: $e');
      return progressUpdated ? updatedProgress : null;
    }
  }
}