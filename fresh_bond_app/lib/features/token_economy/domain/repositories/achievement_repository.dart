import '../models/achievement.dart';

abstract class AchievementRepository {
  /// Gets all available achievements with their unlock status for a user
  Future<List<UserAchievement>> getUserAchievements(String userId);
  
  /// Checks if any achievements have been unlocked based on a user action
  /// Returns a list of newly unlocked achievements
  Future<List<UserAchievement>> checkAndUpdateAchievements({
    required String userId,
    required String action,
    Map<String, dynamic>? metadata,
  });
  
  /// Marks an achievement as viewed by the user
  Future<void> markAchievementViewed({
    required String userId,
    required String achievementId,
  });
  
  /// Gets all available achievements (used for admin purposes)
  Future<List<Achievement>> getAllAchievements();
  
  /// Creates a new achievement (used for admin purposes)
  Future<void> createAchievement(Achievement achievement);
  
  /// Updates an achievement (used for admin purposes)
  Future<void> updateAchievement(Achievement achievement);
}
