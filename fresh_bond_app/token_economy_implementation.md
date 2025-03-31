# Bond Token Economy Implementation Plan

## Overview

This document outlines the implementation plan for Bond's token economy feature, a gamification and reward system designed to incentivize app engagement, encourage meaningful connections, and reward users for positive community contributions.

## Core Concepts

### 1. Bond Tokens

- **Definition**: Digital reward points that users earn and spend within the application
- **Characteristics**: Non-transferable, no monetary value, redeemable for in-app benefits
- **Storage**: Firebase or local database with cloud synchronization
- **Tracking**: Full transaction history for transparency

### 2. Earning Mechanisms

Users earn tokens through positive engagement:

| Activity | Token Reward | Reasoning |
|----------|-------------|-----------|
| Profile Completion | 50 tokens | Encourages comprehensive profiles |
| Verified Meeting Attendance | 20 tokens | Rewards in-person connections |
| Receiving Positive Feedback | 10 tokens | Incentivizes quality interactions |
| Multiple Meetings with Same Connection | 15 tokens (scaling) | Encourages relationship depth |
| Weekly App Usage | 5 tokens/day | Promotes regular engagement |
| Organizing Group Events | 25 tokens | Rewards community building |
| Achieving Weekly Goals | 30 tokens | Encourages consistent engagement |

### 3. Spending Mechanisms

Users spend tokens to access premium features:

| Feature | Token Cost | Value Proposition |
|---------|------------|-------------------|
| Advanced Search Filters | 25 tokens | Find more precise connections |
| Profile Highlighting | 50 tokens (weekly) | Increased visibility in discovery |
| Custom Meeting Templates | 20 tokens | Streamlined meeting creation |
| Extended Connection Radius | 30 tokens (weekly) | Discover people further away |
| Custom Status Messages | 15 tokens | Enhanced self-expression |
| Achievement Badges | Varies | Visual prestige markers |
| Feature Early Access | Varies | Try new features first |

### 4. Achievement System

Accomplishments that earn badges and tokens:

| Achievement | Requirements | Reward |
|-------------|--------------|--------|
| Connection Builder | 10 connections made | 50 tokens + Badge |
| Meeting Master | 10 verified meetings | 50 tokens + Badge |
| Feedback Champion | 10 positive ratings | 40 tokens + Badge |
| Regular | Use app 5 days in a row | 25 tokens + Badge |
| Explorer | Meet 5 different types of connections | 35 tokens + Badge |
| Community Builder | Organize 3 group events | 45 tokens + Badge |

## Technical Implementation

### Data Models

#### TokenBalance Model
```dart
class TokenBalance {
  final String userId;
  final int balance;
  final DateTime lastUpdated;
  
  const TokenBalance({
    required this.userId,
    required this.balance,
    required this.lastUpdated,
  });
  
  // Serialization methods
  Map<String, dynamic> toMap() { ... }
  factory TokenBalance.fromMap(Map<String, dynamic> map) { ... }
}
```

#### TokenTransaction Model
```dart
enum TokenTransactionType {
  earned,
  spent,
  adjusted,
}

class TokenTransaction {
  final String id;
  final String userId;
  final int amount;
  final TokenTransactionType type;
  final String description;
  final String? referenceId; // Related entity (meeting ID, etc.)
  final DateTime timestamp;
  
  const TokenTransaction({
    required this.id,
    required this.userId,
    required this.amount,
    required this.type,
    required this.description,
    this.referenceId,
    required this.timestamp,
  });
  
  // Serialization methods
  Map<String, dynamic> toMap() { ... }
  factory TokenTransaction.fromMap(Map<String, dynamic> map) { ... }
}
```

#### Achievement Model
```dart
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconAsset;
  final int tokenReward;
  final Map<String, dynamic> criteria; // Requirements to earn
  
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.tokenReward,
    required this.criteria,
  });
  
  // Serialization methods
  Map<String, dynamic> toMap() { ... }
  factory Achievement.fromMap(Map<String, dynamic> map) { ... }
}
```

#### UserAchievement Model
```dart
class UserAchievement {
  final String userId;
  final String achievementId;
  final DateTime earnedAt;
  final bool isDisplayed; // User can choose which to display
  
  const UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.earnedAt,
    this.isDisplayed = true,
  });
  
  // Serialization methods
  Map<String, dynamic> toMap() { ... }
  factory UserAchievement.fromMap(Map<String, dynamic> map) { ... }
}
```

### Repositories

#### TokenRepository Interface
```dart
abstract class TokenRepository {
  // Balance operations
  Future<TokenBalance> getBalance(String userId);
  Future<void> updateBalance(String userId, int newBalance);
  
  // Transaction operations
  Future<List<TokenTransaction>> getTransactions(String userId, {int limit = 20, int offset = 0});
  Future<void> addTransaction(TokenTransaction transaction);
  
  // Achievement operations
  Future<List<Achievement>> getAvailableAchievements();
  Future<List<UserAchievement>> getUserAchievements(String userId);
  Future<void> awardAchievement(String userId, String achievementId);
  Future<void> toggleAchievementDisplay(String userId, String achievementId, bool isDisplayed);
}
```

#### TokenRepositoryImpl
Implementation using Firebase or local database with appropriate error handling and offline support.

### BLoC Components

#### TokenBloc
```dart
// Events
abstract class TokenEvent {}
class FetchBalanceEvent extends TokenEvent {}
class FetchTransactionsEvent extends TokenEvent {}
class EarnTokensEvent extends TokenEvent {
  final int amount;
  final String description;
  final String? referenceId;
  
  EarnTokensEvent({
    required this.amount,
    required this.description,
    this.referenceId,
  });
}
class SpendTokensEvent extends TokenEvent {
  final int amount;
  final String description;
  final String? referenceId;
  
  SpendTokensEvent({
    required this.amount,
    required this.description,
    this.referenceId,
  });
}

// States
abstract class TokenState {}
class TokenInitialState extends TokenState {}
class TokenLoadingState extends TokenState {}
class TokenBalanceLoadedState extends TokenState {
  final TokenBalance balance;
  TokenBalanceLoadedState(this.balance);
}
class TokenTransactionsLoadedState extends TokenState {
  final List<TokenTransaction> transactions;
  TokenTransactionsLoadedState(this.transactions);
}
class TokenErrorState extends TokenState {
  final String message;
  TokenErrorState(this.message);
}
class TokenEarnedState extends TokenState {
  final int amount;
  final int newBalance;
  TokenEarnedState(this.amount, this.newBalance);
}
class TokenSpentState extends TokenState {
  final int amount;
  final int newBalance;
  TokenSpentState(this.amount, this.newBalance);
}
class InsufficientTokensState extends TokenState {
  final int currentBalance;
  final int amountNeeded;
  InsufficientTokensState(this.currentBalance, this.amountNeeded);
}
```

#### AchievementBloc
```dart
// Events
abstract class AchievementEvent {}
class FetchAchievementsEvent extends AchievementEvent {}
class CheckAchievementsEvent extends AchievementEvent {}
class ToggleAchievementDisplayEvent extends AchievementEvent {
  final String achievementId;
  final bool isDisplayed;
  
  ToggleAchievementDisplayEvent({
    required this.achievementId,
    required this.isDisplayed,
  });
}

// States
abstract class AchievementState {}
class AchievementInitialState extends AchievementState {}
class AchievementLoadingState extends AchievementState {}
class AchievementsLoadedState extends AchievementState {
  final List<Achievement> availableAchievements;
  final List<UserAchievement> earnedAchievements;
  
  AchievementsLoadedState({
    required this.availableAchievements,
    required this.earnedAchievements,
  });
}
class AchievementEarnedState extends AchievementState {
  final Achievement achievement;
  final int tokenReward;
  
  AchievementEarnedState({
    required this.achievement,
    required this.tokenReward,
  });
}
class AchievementErrorState extends AchievementState {
  final String message;
  AchievementErrorState(this.message);
}
```

### Services

#### AchievementService
```dart
class AchievementService {
  final TokenRepository _tokenRepository;
  final AuthRepository _authRepository;
  final MeetingRepository _meetingRepository;
  final ConnectionsRepository _connectionsRepository;
  
  // Constructor with dependency injection
  
  // Check if user has earned new achievements
  Future<List<Achievement>> checkForNewAchievements() async {
    final userId = await _getCurrentUserId();
    final earnedAchievements = <Achievement>[];
    
    // Get all available achievements and check each one
    final availableAchievements = await _tokenRepository.getAvailableAchievements();
    final userAchievements = await _tokenRepository.getUserAchievements(userId);
    
    // Get user stats needed for achievement checks
    final meetingCount = await _meetingRepository.getMeetingCount(userId);
    final connectionCount = await _connectionsRepository.getConnectionCount(userId);
    // ... other stats
    
    // Check each achievement
    for (final achievement in availableAchievements) {
      // Skip already earned achievements
      if (userAchievements.any((a) => a.achievementId == achievement.id)) {
        continue;
      }
      
      // Check criteria based on achievement type
      bool isEarned = false;
      
      switch (achievement.id) {
        case 'connection_builder':
          isEarned = connectionCount >= 10;
          break;
        case 'meeting_master':
          isEarned = meetingCount >= 10;
          break;
        // ... other achievement checks
      }
      
      // Award achievement if earned
      if (isEarned) {
        await _tokenRepository.awardAchievement(userId, achievement.id);
        
        // Add tokens for the achievement
        await _tokenRepository.addTransaction(
          TokenTransaction(
            id: generateUuid(),
            userId: userId,
            amount: achievement.tokenReward,
            type: TokenTransactionType.earned,
            description: 'Achievement: ${achievement.title}',
            timestamp: DateTime.now(),
          ),
        );
        
        // Update user balance
        final currentBalance = await _tokenRepository.getBalance(userId);
        await _tokenRepository.updateBalance(
          userId, 
          currentBalance.balance + achievement.tokenReward,
        );
        
        earnedAchievements.add(achievement);
      }
    }
    
    return earnedAchievements;
  }
  
  // Helper methods
  Future<String> _getCurrentUserId() async {
    final user = await _authRepository.getCurrentUser();
    if (user == null) {
      throw Exception('User not authenticated');
    }
    return user.id;
  }
}
```

## UI Components

### TokenBalanceCard
Displays current token balance with visual treatments:

```dart
class TokenBalanceCard extends StatelessWidget {
  final int balance;
  final VoidCallback onTap;
  
  const TokenBalanceCard({
    Key? key,
    required this.balance,
    required this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BondCard(
      onTap: onTap,
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Token icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: BondColors.primaryGradient,
            ),
            child: const Icon(
              Icons.token,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // Balance information
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bond Tokens',
                  style: BondTypography.subtitle1,
                ),
                Text(
                  balance.toString(),
                  style: BondTypography.heading2,
                ),
              ],
            ),
          ),
          
          // Arrow icon
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
```

### TokenTransactionList
Displays transaction history:

```dart
class TokenTransactionList extends StatelessWidget {
  final List<TokenTransaction> transactions;
  final bool isLoading;
  
  const TokenTransactionList({
    Key? key,
    required this.transactions,
    this.isLoading = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (transactions.isEmpty) {
      return const BondEmptyState(
        title: 'No Transactions Yet',
        message: 'Your token activity will appear here',
        illustrationAsset: 'assets/illustrations/empty_states/transactions.svg',
      );
    }
    
    return ListView.builder(
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return TokenTransactionItem(transaction: transaction);
      },
    );
  }
}
```

### AchievementGrid
Displays earned and available achievements:

```dart
class AchievementGrid extends StatelessWidget {
  final List<Achievement> availableAchievements;
  final List<UserAchievement> earnedAchievements;
  final Function(String) onAchievementTap;
  
  const AchievementGrid({
    Key? key,
    required this.availableAchievements,
    required this.earnedAchievements,
    required this.onAchievementTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: availableAchievements.length,
      itemBuilder: (context, index) {
        final achievement = availableAchievements[index];
        final isEarned = earnedAchievements.any(
          (earned) => earned.achievementId == achievement.id
        );
        
        return AchievementItem(
          achievement: achievement,
          isEarned: isEarned,
          onTap: () => onAchievementTap(achievement.id),
        );
      },
    );
  }
}
```

### Token Purchase Confirmation Dialog
Used when spending tokens:

```dart
class TokenPurchaseDialog extends StatelessWidget {
  final String featureName;
  final int tokenCost;
  final int currentBalance;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;
  
  const TokenPurchaseDialog({
    Key? key,
    required this.featureName,
    required this.tokenCost,
    required this.currentBalance,
    required this.onConfirm,
    required this.onCancel,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final bool canAfford = currentBalance >= tokenCost;
    
    return BondDialog(
      title: 'Unlock $featureName',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'This feature costs $tokenCost tokens',
            style: BondTypography.body1,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.token),
              const SizedBox(width: 8),
              Text(
                'Current Balance: $currentBalance',
                style: BondTypography.body2,
              ),
            ],
          ),
          if (!canAfford) ...[
            const SizedBox(height: 16),
            Text(
              'Insufficient tokens. Keep engaging to earn more!',
              style: BondTypography.body2.copyWith(
                color: BondColors.error,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
      actions: [
        BondButton(
          label: 'Cancel',
          variant: BondButtonVariant.tertiary,
          onPressed: onCancel,
        ),
        BondButton(
          label: 'Confirm',
          variant: BondButtonVariant.primary,
          onPressed: canAfford ? onConfirm : null,
        ),
      ],
    );
  }
}
```

## Screens Implementation

### TokenWalletScreen
Main screen for token management:

```dart
class TokenWalletScreen extends StatelessWidget {
  const TokenWalletScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TokenBloc(
        tokenRepository: context.read<TokenRepository>(),
      )..add(FetchBalanceEvent())
        ..add(FetchTransactionsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Token Wallet'),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () => _showTokenInfoDialog(context),
            ),
          ],
        ),
        body: BlocBuilder<TokenBloc, TokenState>(
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<TokenBloc>()
                  ..add(FetchBalanceEvent())
                  ..add(FetchTransactionsEvent());
              },
              child: CustomScrollView(
                slivers: [
                  // Header with balance
                  SliverToBoxAdapter(
                    child: _buildBalanceHeader(context, state),
                  ),
                  
                  // Section header for history
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Transaction History',
                        style: BondTypography.heading3,
                      ),
                    ),
                  ),
                  
                  // Transaction list
                  SliverFillRemaining(
                    child: _buildTransactionsList(context, state),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildBalanceHeader(BuildContext context, TokenState state) {
    int balance = 0;
    bool isLoading = false;
    
    if (state is TokenBalanceLoadedState) {
      balance = state.balance.balance;
    } else if (state is TokenLoadingState) {
      isLoading = true;
    }
    
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: BoxDecoration(
        gradient: BondColors.primaryGradient,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Current Balance',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          isLoading
              ? const CircularProgressIndicator(color: Colors.white)
              : Text(
                  balance.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
          const SizedBox(height: 16),
          BondButton(
            label: 'View Achievements',
            variant: BondButtonVariant.secondary,
            onPressed: () => Navigator.pushNamed(context, '/achievements'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTransactionsList(BuildContext context, TokenState state) {
    if (state is TokenTransactionsLoadedState) {
      return TokenTransactionList(transactions: state.transactions);
    }
    
    if (state is TokenLoadingState) {
      return const Center(child: CircularProgressIndicator());
    }
    
    return const Center(child: Text('No transactions found'));
  }
  
  void _showTokenInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => BondDialog(
        title: 'About Bond Tokens',
        content: const Text(
          'Bond Tokens are rewards for your engagement in the app. '
          'Earn tokens by meeting people, completing your profile, and more. '
          'Spend tokens to unlock premium features.',
        ),
        actions: [
          BondButton(
            label: 'Got it',
            variant: BondButtonVariant.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
```

### AchievementsScreen
Screen for displaying and managing achievements:

```dart
class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AchievementBloc(
        tokenRepository: context.read<TokenRepository>(),
        achievementService: context.read<AchievementService>(),
      )..add(FetchAchievementsEvent())
        ..add(CheckAchievementsEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Achievements'),
        ),
        body: BlocConsumer<AchievementBloc, AchievementState>(
          listener: (context, state) {
            if (state is AchievementEarnedState) {
              _showAchievementEarnedDialog(context, state);
            }
          },
          builder: (context, state) {
            if (state is AchievementLoadingState) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is AchievementsLoadedState) {
              return CustomScrollView(
                slivers: [
                  // Header
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        'Your accomplishments are recognized with these achievements',
                        style: BondTypography.body1,
                      ),
                    ),
                  ),
                  
                  // Earned Achievements section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Earned Achievements',
                        style: BondTypography.heading3,
                      ),
                    ),
                  ),
                  
                  // Earned achievements grid
                  SliverToBoxAdapter(
                    child: _buildEarnedAchievementsSection(
                      context,
                      state.availableAchievements,
                      state.earnedAchievements,
                    ),
                  ),
                  
                  // Available Achievements section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Available Achievements',
                        style: BondTypography.heading3,
                      ),
                    ),
                  ),
                  
                  // Available achievements grid
                  SliverToBoxAdapter(
                    child: _buildAvailableAchievementsSection(
                      context,
                      state.availableAchievements,
                      state.earnedAchievements,
                    ),
                  ),
                ],
              );
            }
            
            return const Center(child: Text('No achievements found'));
          },
        ),
      ),
    );
  }
  
  Widget _buildEarnedAchievementsSection(
    BuildContext context,
    List<Achievement> availableAchievements,
    List<UserAchievement> earnedAchievements,
  ) {
    if (earnedAchievements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'Complete actions in the app to earn achievements',
          style: BondTypography.body2,
        ),
      );
    }
    
    // Filter available achievements to only show earned ones
    final earnedIds = earnedAchievements.map((e) => e.achievementId).toSet();
    final earnedAchievementDetails = availableAchievements
        .where((a) => earnedIds.contains(a.id))
        .toList();
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AchievementGrid(
        availableAchievements: earnedAchievementDetails,
        earnedAchievements: earnedAchievements,
        onAchievementTap: (id) => _showAchievementDetails(
          context,
          earnedAchievementDetails.firstWhere((a) => a.id == id),
          true,
        ),
      ),
    );
  }
  
  Widget _buildAvailableAchievementsSection(
    BuildContext context,
    List<Achievement> availableAchievements,
    List<UserAchievement> earnedAchievements,
  ) {
    // Filter out already earned achievements
    final earnedIds = earnedAchievements.map((e) => e.achievementId).toSet();
    final unearnedAchievements = availableAchievements
        .where((a) => !earnedIds.contains(a.id))
        .toList();
    
    if (unearnedAchievements.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'You\'ve earned all available achievements!',
          style: BondTypography.body2,
        ),
      );
    }
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: AchievementGrid(
        availableAchievements: unearnedAchievements,
        earnedAchievements: earnedAchievements,
        onAchievementTap: (id) => _showAchievementDetails(
          context,
          unearnedAchievements.firstWhere((a) => a.id == id),
          false,
        ),
      ),
    );
  }
  
  void _showAchievementDetails(
    BuildContext context,
    Achievement achievement,
    bool isEarned,
  ) {
    showDialog(
      context: context,
      builder: (context) => BondDialog(
        title: achievement.title,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              achievement.iconAsset,
              width: 80,
              height: 80,
            ),
            const SizedBox(height: 16),
            Text(
              achievement.description,
              style: BondTypography.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Reward: ${achievement.tokenReward} tokens',
              style: BondTypography.body2.copyWith(
                color: BondColors.success,
              ),
            ),
            if (!isEarned) ...[
              const SizedBox(height: 16),
              Text(
                'Requirements to earn:',
                style: BondTypography.subtitle2,
              ),
              const SizedBox(height: 8),
              // Display achievement criteria
              // This would be specific to each achievement type
            ],
          ],
        ),
        actions: [
          BondButton(
            label: 'Close',
            variant: BondButtonVariant.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
  
  void _showAchievementEarnedDialog(
    BuildContext context,
    AchievementEarnedState state,
  ) {
    showDialog(
      context: context,
      builder: (context) => BondDialog(
        title: 'Achievement Unlocked!',
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              state.achievement.iconAsset,
              width: 100,
              height: 100,
            ),
            const SizedBox(height: 16),
            Text(
              state.achievement.title,
              style: BondTypography.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              state.achievement.description,
              style: BondTypography.body1,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'You earned ${state.tokenReward} tokens!',
              style: BondTypography.subtitle1.copyWith(
                color: BondColors.success,
              ),
            ),
          ],
        ),
        actions: [
          BondButton(
            label: 'Awesome!',
            variant: BondButtonVariant.primary,
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}
```

## Integration Points

### 1. Profile Completion
```dart
// In ProfileScreen after user updates profile
if (profileCompletion >= 0.9 && !hasReceivedProfileCompletionReward) {
  context.read<TokenBloc>().add(
    EarnTokensEvent(
      amount: 50,
      description: 'Profile completion reward',
    ),
  );
  // Update user metadata to indicate reward received
  await userRepository.updateUserMetadata(
    userId, 
    {'hasReceivedProfileCompletionReward': true},
  );
}
```

### 2. Meeting Verification
```dart
// In NfcVerificationScreen after successful verification
if (state is MeetingVerifiedState) {
  // Award tokens for verified meeting
  context.read<TokenBloc>().add(
    EarnTokensEvent(
      amount: 20,
      description: 'Verified meeting attendance',
      referenceId: widget.meetingId,
    ),
  );
  
  // Check for achievements
  context.read<AchievementBloc>().add(CheckAchievementsEvent());
}
```

### 3. Premium Feature Purchase
```dart
// When user tries to enable advanced search filters
void _enableAdvancedFilters() {
  final tokenCost = 25;
  
  showDialog(
    context: context,
    builder: (context) => BlocBuilder<TokenBloc, TokenState>(
      builder: (context, state) {
        int balance = 0;
        if (state is TokenBalanceLoadedState) {
          balance = state.balance.balance;
        }
        
        return TokenPurchaseDialog(
          featureName: 'Advanced Filters',
          tokenCost: tokenCost,
          currentBalance: balance,
          onCancel: () => Navigator.pop(context),
          onConfirm: () {
            Navigator.pop(context);
            
            // Spend tokens
            context.read<TokenBloc>().add(
              SpendTokensEvent(
                amount: tokenCost,
                description: 'Advanced filters purchase',
              ),
            );
            
            // Enable feature
            setState(() {
              _advancedFiltersEnabled = true;
            });
          },
        );
      },
    ),
  );
}
```

## Testing Strategy

### Unit Tests
```dart
void main() {
  group('TokenBloc', () {
    late TokenBloc tokenBloc;
    late MockTokenRepository mockTokenRepository;
    
    setUp(() {
      mockTokenRepository = MockTokenRepository();
      tokenBloc = TokenBloc(tokenRepository: mockTokenRepository);
    });
    
    tearDown(() {
      tokenBloc.close();
    });
    
    test('initial state is TokenInitialState', () {
      expect(tokenBloc.state, isA<TokenInitialState>());
    });
    
    blocTest<TokenBloc, TokenState>(
      'emits [TokenLoadingState, TokenBalanceLoadedState] when FetchBalanceEvent is added',
      build: () {
        when(mockTokenRepository.getBalance(any))
            .thenAnswer((_) async => TokenBalance(
                  userId: 'user1',
                  balance: 100,
                  lastUpdated: DateTime.now(),
                ));
        return tokenBloc;
      },
      act: (bloc) => bloc.add(FetchBalanceEvent()),
      expect: () => [
        isA<TokenLoadingState>(),
        isA<TokenBalanceLoadedState>(),
      ],
      verify: (_) {
        verify(mockTokenRepository.getBalance(any)).called(1);
      },
    );
    
    // Additional tests for earn, spend, etc.
  });
}
```

### Widget Tests
```dart
void main() {
  group('TokenWalletScreen', () {
    testWidgets('displays current balance', (WidgetTester tester) async {
      // Arrange
      final mockTokenBloc = MockTokenBloc();
      whenListen(
        mockTokenBloc,
        Stream.fromIterable([
          TokenLoadingState(),
          TokenBalanceLoadedState(
            TokenBalance(
              userId: 'user1',
              balance: 150,
              lastUpdated: DateTime.now(),
            ),
          ),
        ]),
        initialState: TokenInitialState(),
      );
      
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider<TokenBloc>.value(
            value: mockTokenBloc,
            child: const TokenWalletScreen(),
          ),
        ),
      );
      
      // Wait for animations
      await tester.pumpAndSettle();
      
      // Assert
      expect(find.text('150'), findsOneWidget);
    });
    
    // Additional widget tests
  });
}
```

## Analytics Integration

Track token-related events:

```dart
class TokenEventAnalytics {
  final AnalyticsService _analytics;
  
  TokenEventAnalytics(this._analytics);
  
  void trackTokensEarned(int amount, String source) {
    _analytics.logEvent(
      'tokens_earned',
      parameters: {
        'amount': amount,
        'source': source,
      },
    );
  }
  
  void trackTokensSpent(int amount, String feature) {
    _analytics.logEvent(
      'tokens_spent',
      parameters: {
        'amount': amount,
        'feature': feature,
      },
    );
  }
  
  void trackAchievementEarned(String achievementId) {
    _analytics.logEvent(
      'achievement_earned',
      parameters: {
        'achievement_id': achievementId,
      },
    );
  }
}
```

## Implementation Timeline

### Week 1: Data Layer
- Implement data models
- Create repository contracts and implementations
- Unit tests for data layer

### Week 2: Business Logic
- Implement TokenBloc
- Implement AchievementBloc
- Create AchievementService
- Integration tests for token earning/spending

### Week 3: UI Components
- Create token wallet screen
- Implement achievements screen
- Build reusable token components
- Widget tests for UI components

### Week 4: Integration
- Connect token earning to features
- Implement premium feature purchases
- Add achievement tracking
- End-to-end testing

## Conclusion

This token economy implementation provides a comprehensive user engagement and reward system that encourages positive behavior in the Bond app. By gamifying the experience, users are incentivized to build meaningful connections, verify meetings, and engage regularly with the platform.

The system's flexibility allows for future expansion with new achievements, earning mechanisms, and premium features without significant architectural changes.