# Bond App

A social connection platform built with Flutter and Firebase.

## Features

- **Authentication**: Firebase Authentication for secure user login and registration
- **Messaging**: Real-time messaging between connections
- **Meetings**: Schedule and manage in-person meetings
- **NFC Verification**: Verify identities using NFC technology
- **Notifications**: Real-time notifications for app events
- **Design System**: Comprehensive Bond Design System with reusable components

## Firebase Setup

### Authentication

The app uses Firebase Authentication for user management. To set up:

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
