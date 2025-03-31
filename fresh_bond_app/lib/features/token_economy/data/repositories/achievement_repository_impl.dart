import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/error_handler.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/models/achievement.dart';
import '../../domain/repositories/achievement_repository.dart';
import '../services/achievement_service.dart';

class AchievementRepositoryImpl implements AchievementRepository {
  final FirebaseFirestore _firestore;
  final AchievementService _achievementService;
  final AppLogger _logger;
  final ErrorHandler _errorHandler;

  AchievementRepositoryImpl({
    required FirebaseFirestore firestore,
    required AchievementService achievementService,
    required AppLogger logger,
    required ErrorHandler errorHandler,
  })  : _firestore = firestore,
        _achievementService = achievementService,
        _logger = logger,
        _errorHandler = errorHandler;

  @override
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      // Get all available achievements
      final achievements = await getAllAchievements();
      
      // Get user's unlocked achievements
      final userAchievementsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();
      
      // Map user's achievements to a map for quick lookup
      final userAchievementsMap = {
        for (var doc in userAchievementsSnapshot.docs)
          doc.id: UserAchievement.fromMap(doc.data()),
      };
      
      // Create a list of user achievements with unlock status
      final result = achievements.map((achievement) {
        final userAchievement = userAchievementsMap[achievement.id];
        
        return userAchievement ??
            UserAchievement(
              userId: userId,
              achievementId: achievement.id,
              earnedAt: DateTime.now(),
              isDisplayed: false,
            );
      }).toList();
      
      return result;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get user achievements',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<List<UserAchievement>> checkAndUpdateAchievements({
    required String userId,
    required String action,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // Get all available achievements
      final achievements = await getAllAchievements();
      
      // Get user's current progress and achievements
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userProgress = userDoc.data()?['progress'] as Map<String, dynamic>? ?? {};
      
      final userAchievementsSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .get();
      
      // Map user's achievements to a set for quick lookup
      final unlockedAchievementIds = 
          userAchievementsSnapshot.docs.map((doc) => doc.id).toSet();
      
      // Check for newly unlocked achievements
      final eligible = achievements.where((achievement) {
        // Skip already unlocked achievements
        if (unlockedAchievementIds.contains(achievement.id)) {
          return false;
        }
        
        // Check if the achievement criteria are met
        return _achievementService.checkAchievementCriteria(
          achievement: achievement,
          action: action,
          userProgress: userProgress,
          metadata: metadata,
        );
      }).toList();
      
      final List<UserAchievement> newlyUnlocked = [];
      
      // Unlock eligible achievements
      for (final achievement in eligible) {
        final userAchievement = UserAchievement(
          userId: userId,
          achievementId: achievement.id,
          earnedAt: DateTime.now(),
          isDisplayed: true,
        );
        
        // Save to Firestore
        await _firestore
            .collection('users')
            .doc(userId)
            .collection('achievements')
            .doc(achievement.id)
            .set(userAchievement.toMap());
        
        // Add token reward
        if (achievement.tokenReward > 0) {
          await _firestore.runTransaction((transaction) async {
            // Get current token balance
            final userDocRef = _firestore.collection('users').doc(userId);
            final userDoc = await transaction.get(userDocRef);
            final currentBalance = userDoc.data()?['tokenBalance'] as int? ?? 0;
            
            // Update token balance
            transaction.update(userDocRef, {
              'tokenBalance': currentBalance + achievement.tokenReward,
            });
            
            // Create token transaction
            final transactionRef = _firestore
                .collection('users')
                .doc(userId)
                .collection('tokenTransactions')
                .doc();
            
            transaction.set(transactionRef, {
              'id': transactionRef.id,
              'userId': userId,
              'amount': achievement.tokenReward,
              'type': 'earned',
              'source': 'achievement_${achievement.id}',
              'metadata': {
                'achievementId': achievement.id,
                'achievementTitle': achievement.title,
              },
              'timestamp': FieldValue.serverTimestamp(),
            });
          });
        }
        
        newlyUnlocked.add(userAchievement);
      }
      
      // Update user progress
      final updatedProgress = _achievementService.updateUserProgress(
        action: action,
        currentProgress: userProgress,
        metadata: metadata,
      );
      
      if (updatedProgress != null) {
        await _firestore.collection('users').doc(userId).update({
          'progress': updatedProgress,
        });
      }
      
      return newlyUnlocked;
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to check achievements',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<void> markAchievementViewed({
    required String userId,
    required String achievementId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('achievements')
          .doc(achievementId)
          .update({'viewed': true});
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to mark achievement as viewed',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<List<Achievement>> getAllAchievements() async {
    try {
      final snapshot = await _firestore.collection('achievements').get();
      
      return snapshot.docs
          .map((doc) => Achievement.fromMap({...doc.data(), 'id': doc.id}))
          .toList();
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to get all achievements',
        error: e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  @override
  Future<void> createAchievement(Achievement achievement) async {
    try {
      final docRef = _firestore.collection('achievements').doc();
      await docRef.set({
        ...achievement.toMap(),
        'id': docRef.id,
      });
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to create achievement',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> updateAchievement(Achievement achievement) async {
    try {
      await _firestore
          .collection('achievements')
          .doc(achievement.id)
          .update(achievement.toMap());
    } catch (e, stackTrace) {
      _logger.e(
        'Failed to update achievement',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}