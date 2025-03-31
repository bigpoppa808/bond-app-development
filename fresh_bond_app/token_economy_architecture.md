# Token Economy Architecture

## Overview

The Bond App token economy system is designed to incentivize user engagement and reward positive interactions. This document outlines the technical architecture and implementation details of the token economy system.

## Architecture

The token economy system follows the clean architecture pattern used throughout the Bond App:

### Domain Layer

#### Models
- **TokenBalance**: Represents a user's current token balance
- **TokenTransaction**: Represents a token earning or spending transaction
- **Achievement**: Represents a user achievement with progress tracking

#### Repositories (Interfaces)
- **TokenRepository**: Interface for managing token balances and transactions
- **AchievementRepository**: Interface for managing achievements and progress

#### BLoCs
- **TokenBloc**: Manages token-related state and events
  - Events: LoadBalance, AddTokens, SpendTokens, LoadTransactions
  - States: Loading, Loaded, Error states for different operations
- **AchievementBloc**: Manages achievement-related state and events
  - Events: LoadAchievements, UpdateProgress, ClaimReward
  - States: Loading, Loaded, Error states for different operations

### Data Layer

#### Repositories (Implementations)
- **TokenRepositoryImpl**: Implements TokenRepository using Firestore
- **AchievementRepositoryImpl**: Implements AchievementRepository using Firestore

#### Services
- **AchievementService**: Service for checking achievement criteria and progress

### Presentation Layer

#### Screens
- **TokenWalletScreen**: Displays token balance and transaction history
- **AchievementsScreen**: Displays achievements and progress

#### Components
- **TokenBalanceCard**: Displays current token balance
- **TransactionItem**: Displays individual token transactions
- **AchievementCard**: Displays achievement with progress indicator

## Integration Points

The token economy system integrates with several other features:

1. **Authentication**: Token balances are associated with user accounts
2. **Meetings**: Tokens are earned for attending meetings (verified via NFC)
3. **Connections**: Tokens are earned for making new connections
4. **Profile**: Tokens are earned for completing profile information

## Database Schema

### Firestore Collections

#### tokens/{userId}
- balance: number
- lastUpdated: timestamp

#### tokenTransactions/{transactionId}
- userId: string
- amount: number
- type: string (earn/spend)
- reason: string
- timestamp: timestamp

#### achievements/{achievementId}
- title: string
- description: string
- tokenReward: number
- criteria: map
- icon: string

#### userAchievements/{userId}_{achievementId}
- userId: string
- achievementId: string
- progress: number
- completed: boolean
- claimed: boolean
- completedDate: timestamp

## Security Rules

Firestore security rules ensure that users can only access their own token data:

```
match /tokens/{userId} {
  allow read, write: if request.auth != null && request.auth.uid == userId;
}

match /tokenTransactions/{transactionId} {
  allow read: if request.auth != null && resource.data.userId == request.auth.uid;
  allow write: if false; // Only backend can write transactions
}

match /userAchievements/{userAchievementId} {
  allow read: if request.auth != null && 
    userAchievementId.split('_')[0] == request.auth.uid;
  allow write: if false; // Only backend can update achievements
}
```

## Future Enhancements

1. **Token Marketplace**: Allow users to spend tokens on virtual goods
2. **Advanced Achievement System**: Multi-tier achievements with increasing rewards
3. **Social Features**: Leaderboards and social sharing of achievements
4. **Analytics Integration**: Track token economy metrics for optimization
