import 'package:fresh_bond_app/features/token_economy/domain/models/achievement.dart';
import 'package:fresh_bond_app/features/token_economy/domain/models/token_balance.dart';
import 'package:fresh_bond_app/features/token_economy/domain/models/token_transaction.dart';

/// Repository interface for token economy functionality
abstract class TokenRepository {
  /// Get the token balance for a user
  Future<TokenBalance> getBalance(String userId);
  
  /// Update the token balance for a user
  Future<void> updateBalance(String userId, int newBalance);
  
  /// Get a list of token transactions for a user with pagination
  Future<List<TokenTransaction>> getTransactions(
    String userId, {
    int limit = 20,
    int offset = 0,
  });
  
  /// Add a new token transaction
  Future<void> addTransaction(TokenTransaction transaction);
  
  /// Create and add a new token transaction with the provided details
  Future<void> createTransaction({
    required String userId,
    required int amount,
    required TokenTransactionType type,
    required String source,
    Map<String, dynamic>? metadata,
  });
  
  /// Get all available achievements
  Future<List<Achievement>> getAvailableAchievements();
  
  /// Get achievements earned by a user
  Future<List<UserAchievement>> getUserAchievements(String userId);
  
  /// Award an achievement to a user
  Future<void> awardAchievement(String userId, String achievementId);
  
  /// Toggle whether an achievement is displayed on a user's profile
  Future<void> toggleAchievementDisplay(
    String userId,
    String achievementId,
    bool isDisplayed,
  );
  
  /// Check if a user has earned a specific achievement
  Future<bool> hasEarnedAchievement(String userId, String achievementId);
  
  /// Get user stats needed for achievement criteria checking
  /// Returns a map of stat name to value
  Future<Map<String, dynamic>> getUserStats(String userId);
  
  /// Get a specific achievement by ID
  Future<Achievement?> getAchievement(String achievementId);
}