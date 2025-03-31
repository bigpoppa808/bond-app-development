# Bond App

A social connection platform built with Flutter and Firebase.

## Features

- **Authentication**: Firebase Authentication for secure user login and registration
- **Messaging**: Real-time messaging between connections
- **Meetings**: Schedule and manage in-person meetings
- **NFC Verification**: Secure identity verification using NFC technology with SHA-256 hashing
- **Notifications**: Real-time notifications for app events
- **Token Economy**: Comprehensive token system with achievements and rewards
- **Design System**: Comprehensive Bond Design System with reusable components

## Firebase Setup

### Authentication

The app uses Firebase Authentication for secure user management:

#### Implementation Details
- **Repository Pattern**: Migrated from MockAuthService to FirebaseAuthService for real authentication
- **User Management**: Full support for user creation, sign-in, and profile management
- **Error Handling**: Improved error messages for authentication failures
- **State Management**: AuthBloc for managing authentication state throughout the app
- **Testing**: Development test account functionality for easier testing

#### Setup
1. Ensure you have a Firebase project created at [Firebase Console](https://console.firebase.google.com/)
2. Enable Email/Password authentication in the Authentication section
3. Update the `firebase_options.dart` file with your project credentials

### Firestore Rules

The app includes Firestore security rules in `firestore.rules`. To deploy:

```bash
firebase deploy --only firestore:rules
```

These rules ensure that:
- Users can only access their own data
- Meetings are accessible to participants
- Notifications are user-specific
- Connections are managed securely

## Development

### Getting Started

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Testing

Run tests with:
```bash
flutter test
```

## Architecture

The app follows a clean architecture approach with:

- **Domain Layer**: Business logic and models
- **Data Layer**: Repositories and data sources
- **Presentation Layer**: BLoC state management and UI components

## Bond Design System

The app implements a comprehensive design system with reusable components:

- Core components (buttons, inputs, cards, etc.)
- Advanced components (lists, tabs, dialogs, etc.)
- Consistent theming and typography

## NFC Verification System

The app implements a secure NFC verification system for in-person identity verification:

### Technical Implementation
- **Repository Pattern**: Follows clean architecture with NfcVerificationRepositoryInterface
- **State Management**: Comprehensive BLoC implementation with granular events and states
- **Security**: Uses SHA-256 hashing for secure verification payloads
- **Error Handling**: Robust error states and user-friendly error messages
- **Cross-Platform**: Graceful degradation when NFC is unavailable on the device

### iOS Configuration
The app includes necessary iOS configuration for NFC capabilities:
- Added NFCReaderUsageDescription to Info.plist
- Configured proper format capabilities for NFC tag reading

### Integration
NFC verification is integrated with the Meetings feature, allowing users to verify identities during in-person meetings.

## Token Economy System

The app implements a comprehensive token economy system to incentivize user engagement and reward positive interactions:

### Technical Implementation
- **Repository Pattern**: Follows clean architecture with TokenRepository and AchievementRepository
- **State Management**: BLoC implementation for token balance and achievements
- **Transaction History**: Complete tracking of all token earnings and expenditures
- **Achievement Framework**: Comprehensive achievement system with progress tracking

### Earning Mechanisms
Users can earn tokens through various activities:
- Profile completion
- Meeting attendance (verified via NFC)
- Receiving positive feedback
- Regular app usage
- Organizing group events
- Achieving personal goals

### Spending Mechanisms
Tokens can be spent on premium features:
- Advanced search filters
- Profile highlighting in discovery
- Premium customization options
- Access to exclusive features

### UI Integration
The token economy is integrated into the app's UI:
- Token wallet screen for managing balance and viewing transaction history
- Achievements screen for tracking progress and claiming rewards
- Home screen widgets showing current balance and achievement progress
