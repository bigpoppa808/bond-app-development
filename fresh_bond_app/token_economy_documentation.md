# Token Economy System Documentation

## Overview

The Bond App token economy system is designed to incentivize user engagement and reward positive interactions within the platform. Users can earn tokens by completing various actions and achieve milestones through the achievement system.

## Architecture

The token economy follows clean architecture principles with three main layers:

1. **Domain Layer**: Contains the core business logic, interfaces, and models
2. **Data Layer**: Implements the repositories and services
3. **Presentation Layer**: UI components and BLoC state management

## Components

### Models

#### TokenBalance
- Represents a user's token balance
- Properties: userId, balance, lastUpdated

#### TokenTransaction
- Represents a token transaction (earning or spending)
- Types: earned, spent, adjusted
- Properties: id, userId, amount, type, description, referenceId, timestamp

#### Achievement
- Represents an achievement that can be earned
- Properties: id, title, description, iconAsset, tokenReward, criteria

#### UserAchievement
- Represents an achievement earned by a user
- Properties: userId, achievementId, earnedAt, isDisplayed, unlocked, viewed

### Repositories

#### TokenRepository
- Interface defining operations for token management
- Methods:
  - getBalance(userId)
  - updateBalance(userId, newBalance)
  - getTransactions(userId, limit, offset)
  - addTransaction(transaction)
  - createTransaction(userId, amount, type, source, metadata)
  - getAvailableAchievements()
  - getUserAchievements(userId)
  - awardAchievement(userId, achievementId)
  - toggleAchievementDisplay(userId, achievementId, isDisplayed)
  - hasEarnedAchievement(userId, achievementId)
  - getUserStats(userId)
  - getAchievement(achievementId)

#### AchievementRepository
- Interface defining operations for achievement management
- Methods:
  - getUserAchievements(userId)
  - checkAndUpdateAchievements(userId, action, metadata)
  - markAchievementViewed(userId, achievementId)
  - getAllAchievements()
  - createAchievement(achievement)
  - updateAchievement(achievement)

### Services

#### AchievementService
- Service responsible for achievement criteria checking and user progress tracking
- Methods:
  - checkAchievementCriteria(achievement, action, userProgress, metadata)
  - updateUserProgress(action, currentProgress, metadata)

#### AchievementChecker
- Helper service to check and update achievements when users perform actions
- Methods:
  - checkAchievements(userId, action, metadata)
  - onLogin(userId)
  - onProfileComplete(userId)
  - onConnectionRequest(userId, recipientId)
  - onConnectionAccepted(userId, requesterId)
  - onMeetingCreated(userId, meetingId)
  - onMeetingVerified(userId, meetingId)
  - onDonationComplete(userId, amount)

### BLoC Components

#### TokenBloc
- Responsible for managing token-related state and events
- Events:
  - FetchBalanceEvent
  - FetchTransactionsEvent
  - EarnTokensEvent
  - SpendTokensEvent
- States:
  - TokenInitial
  - TokenLoading
  - TokenProcessing
  - TokenBalanceLoaded
  - TokenTransactionsLoaded
  - TokenEarned
  - TokenSpent
  - TokenInsufficientBalance
  - TokenError

#### AchievementBloc
- Responsible for managing achievement-related state and events
- Events:
  - FetchAchievementsEvent
  - CheckAchievementsEvent
  - MarkAchievementViewedEvent
- States:
  - AchievementInitial
  - AchievementLoading
  - AchievementChecking
  - AchievementsLoaded
  - AchievementUnlocked
  - AchievementCheckComplete
  - AchievementError

### UI Screens

#### TokenWalletScreen
- Displays the user's token balance and transaction history
- Features:
  - Current balance display
  - Token earning methods information
  - Transaction history with filtering

#### AchievementsScreen
- Displays the user's earned and available achievements
- Features:
  - Achievement progress stats
  - Unlocked achievements section
  - Locked achievements section

## Token Earning Mechanisms

Users can earn tokens through the following actions:

1. **Connections**
   - Sending connection requests: 5 tokens
   - Accepting connection requests: 10 tokens
   - Reaching connection milestones (10, 25, 50): 20, 50, 100 tokens

2. **Meetings**
   - Creating a meeting: 10 tokens
   - Completing a meeting: 15 tokens
   - Verifying a meeting via NFC: 30 tokens

3. **Profile Completion**
   - Completing basic profile: 20 tokens
   - Adding profile picture: 10 tokens
   - Completing all profile fields: 30 tokens

4. **Achievements**
   - Vary based on the achievement (10-100 tokens)

5. **Daily Actions**
   - Daily login: 5 tokens
   - Weekly streak bonus: 20 tokens

## Achievement Types

Achievements are categorized as follows:

1. **Milestone Achievements**
   - Based on quantitative metrics (e.g., "Connect with 10 people")

2. **Activity Achievements**
   - Based on specific actions (e.g., "Create your first meeting")

3. **Sequential Achievements**
   - Based on repeated actions (e.g., "Log in 5 days in a row")

4. **Completion Achievements**
   - Based on completing specific features (e.g., "Complete your profile")

## Integration Points

The token economy system integrates with the following features:

1. **Authentication**: Triggers token rewards for login streaks
2. **Profile**: Rewards profile completion
3. **Connections**: Rewards connection creation and acceptance
4. **Meetings**: Rewards meeting creation and verification
5. **Notifications**: Alerts users about earned tokens and achievements
6. **Home Screen**: Displays token balance and achievement progress

## Implementation Notes

1. **Firebase Integration**
   - Token balances and transactions are stored in Firestore
   - Achievement progress is tracked in user documents

2. **Achievement Criteria**
   - Stored as JSON structures for flexibility
   - Custom logic for complex achievements

3. **Performance Considerations**
   - Achievement checks are batched when possible
   - Cached token balances for frequent UI updates

4. **Testing Strategy**
   - Unit tests for repositories and BLoCs
   - Widget tests for UI components
   - Integration tests for user flows

## Future Enhancements

1. **Token Economy Expansion**
   - Token marketplace for redeeming rewards
   - Donation matching using tokens
   - Leaderboards for top earners

2. **Achievement System Enhancements**
   - Achievement categories and tiers
   - Time-limited special achievements
   - Achievement sharing on social media
   - Customizable achievement display