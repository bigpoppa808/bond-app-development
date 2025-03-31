import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fresh_bond_app/core/utils/error_handler.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/meeting_repository.dart';
import 'package:fresh_bond_app/features/token_economy/domain/models/achievement.dart';
import 'package:fresh_bond_app/features/token_economy/domain/models/token_balance.dart';
import 'package:fresh_bond_app/features/token_economy/domain/models/token_transaction.dart';
import 'package:fresh_bond_app/features/token_economy/domain/repositories/token_repository.dart';
import 'package:fresh_bond_app/features/discover/domain/repositories/connections_repository.dart';
import 'package:uuid/uuid.dart';

/// Implementation of the TokenRepository interface using Firestore
class TokenRepositoryImpl implements TokenRepository {
  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final MeetingRepository _meetingRepository;
  final ConnectionsRepository _connectionsRepository;
  final AppLogger _logger;
  final ErrorHandler _errorHandler;
  
  /// Constructor
  TokenRepositoryImpl({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
    required MeetingRepository meetingRepository,
    required ConnectionsRepository connectionsRepository,
    required AppLogger logger,
    required ErrorHandler errorHandler,
  }) : _firestore = firestore,
       _authRepository = authRepository,
       _meetingRepository = meetingRepository,
       _connectionsRepository = connectionsRepository,
       _logger = logger,
       _errorHandler = errorHandler;
       
  // Collection references
  CollectionReference get _balancesCollection => _firestore.collection('token_balances');
  CollectionReference get _transactionsCollection => _firestore.collection('token_transactions');
  CollectionReference get _achievementsCollection => _firestore.collection('achievements');
  CollectionReference get _userAchievementsCollection => _firestore.collection('user_achievements');

  @override
  Future<TokenBalance> getBalance(String userId) async {
    try {
      _logger.d('Getting token balance for user $userId');
      
      final doc = await _balancesCollection.doc(userId).get();
      
      if (doc.exists && doc.data() != null) {
        return TokenBalance.fromMap(doc.data()! as Map<String, dynamic>);
      }
      
      // If no balance exists, create a new one with zero tokens
      final newBalance = TokenBalance.empty(userId);
      await _balancesCollection.doc(userId).set(newBalance.toMap());
      
      return newBalance;
    } catch (e, stackTrace) {
      _logger.e('Error getting token balance', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<void> updateBalance(String userId, int newBalance) async {
    try {
      _logger.d('Updating token balance for user $userId to $newBalance');
      
      await _balancesCollection.doc(userId).update({
        'balance': newBalance,
        'lastUpdated': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e, stackTrace) {
      _logger.e('Error updating token balance', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<List<TokenTransaction>> getTransactions(
    String userId, {
    int limit = 20, 
    int offset = 0,
  }) async {
    try {
      _logger.d('Getting token transactions for user $userId');
      
      final query = _transactionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(limit);
          
      final snapshot = await query.get();
      
      return snapshot.docs
          .map((doc) => TokenTransaction.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Error getting token transactions', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<void> addTransaction(TokenTransaction transaction) async {
    try {
      _logger.d('Adding token transaction for user ${transaction.userId}');
      
      // First, get current balance
      final balance = await getBalance(transaction.userId);
      
      // Calculate new balance based on transaction type
      int newBalance;
      
      switch (transaction.type) {
        case TokenTransactionType.earned:
          newBalance = balance.balance + transaction.amount;
          break;
        case TokenTransactionType.spent:
          newBalance = balance.balance - transaction.amount;
          // Validate that user has enough tokens
          if (newBalance < 0) {
            throw Exception('Insufficient tokens');
          }
          break;
        case TokenTransactionType.adjusted:
          newBalance = balance.balance + transaction.amount; // Can be negative
          break;
      }
      
      // Add transaction to database
      await _transactionsCollection.doc(transaction.id).set(transaction.toMap());
      
      // Update user's balance
      await updateBalance(transaction.userId, newBalance);
    } catch (e, stackTrace) {
      _logger.e('Error adding token transaction', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }
  
  @override
  Future<void> createTransaction({
    required String userId,
    required int amount,
    required TokenTransactionType type,
    required String source,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      _logger.d('Creating token transaction for user $userId');

      final transaction = TokenTransaction(
        id: const Uuid().v4(),
        userId: userId,
        amount: amount,
        type: type,
        description: source,
        referenceId: metadata != null ? metadata.toString() : null,
        timestamp: DateTime.now(),
      );
      
      await addTransaction(transaction);
      
    } catch (e, stackTrace) {
      _logger.e('Error creating token transaction', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<List<Achievement>> getAvailableAchievements() async {
    try {
      _logger.d('Getting available achievements');
      
      final snapshot = await _achievementsCollection.get();
      
      return snapshot.docs
          .map((doc) => Achievement.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Error getting available achievements', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<List<UserAchievement>> getUserAchievements(String userId) async {
    try {
      _logger.d('Getting achievements for user $userId');
      
      final snapshot = await _userAchievementsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      return snapshot.docs
          .map((doc) => UserAchievement.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e, stackTrace) {
      _logger.e('Error getting user achievements', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<void> awardAchievement(String userId, String achievementId) async {
    try {
      _logger.d('Awarding achievement $achievementId to user $userId');
      
      // Check if already earned
      final alreadyEarned = await hasEarnedAchievement(userId, achievementId);
      if (alreadyEarned) {
        _logger.d('Achievement already earned, skipping');
        return;
      }
      
      // Get the achievement to determine token reward
      final achievement = await getAchievement(achievementId);
      if (achievement == null) {
        throw Exception('Achievement not found');
      }
      
      // Create user achievement record
      final userAchievement = UserAchievement(
        userId: userId,
        achievementId: achievementId,
        earnedAt: DateTime.now(),
      );
      
      // Generate a document ID using userId and achievementId for uniqueness
      final docId = '$userId-$achievementId';
      
      // Save the user achievement
      await _userAchievementsCollection.doc(docId).set(userAchievement.toMap());
      
      // Create a token transaction for the achievement reward
      final transaction = TokenTransaction(
        id: const Uuid().v4(),
        userId: userId,
        amount: achievement.tokenReward,
        type: TokenTransactionType.earned,
        description: 'Achievement: ${achievement.title}',
        referenceId: achievementId,
        timestamp: DateTime.now(),
      );
      
      // Add the transaction (which will also update the balance)
      await addTransaction(transaction);
    } catch (e, stackTrace) {
      _logger.e('Error awarding achievement', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<void> toggleAchievementDisplay(
    String userId,
    String achievementId,
    bool isDisplayed,
  ) async {
    try {
      _logger.d('Toggling achievement display for $achievementId to $isDisplayed');
      
      final docId = '$userId-$achievementId';
      
      await _userAchievementsCollection.doc(docId).update({
        'isDisplayed': isDisplayed,
      });
    } catch (e, stackTrace) {
      _logger.e('Error toggling achievement display', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<bool> hasEarnedAchievement(String userId, String achievementId) async {
    try {
      _logger.d('Checking if user $userId has earned achievement $achievementId');
      
      final docId = '$userId-$achievementId';
      final doc = await _userAchievementsCollection.doc(docId).get();
      
      return doc.exists;
    } catch (e, stackTrace) {
      _logger.e('Error checking earned achievement', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      _logger.d('Getting user stats for $userId');
      
      // Get meeting count
      final completedMeetingsCount = await _meetingRepository.getCompletedMeetingsCount(userId);
      
      // Get connection count
      final connectionsCount = await _connectionsRepository.getConnectionCount(userId);
      
      // Get profile completion percentage (dummy implementation)
      const profileCompletion = 0.8;
      
      // Return stats map
      return {
        'completedMeetingsCount': completedMeetingsCount,
        'connectionsCount': connectionsCount,
        'profileCompletion': profileCompletion,
        'daysActive': 5, // Placeholder
      };
    } catch (e, stackTrace) {
      _logger.e('Error getting user stats', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }

  @override
  Future<Achievement?> getAchievement(String achievementId) async {
    try {
      _logger.d('Getting achievement $achievementId');
      
      final doc = await _achievementsCollection.doc(achievementId).get();
      
      if (doc.exists && doc.data() != null) {
        return Achievement.fromMap(doc.data()! as Map<String, dynamic>);
      }
      
      return null;
    } catch (e, stackTrace) {
      _logger.e('Error getting achievement', error: e, stackTrace: stackTrace);
      throw _errorHandler.handleError(e);
    }
  }
}