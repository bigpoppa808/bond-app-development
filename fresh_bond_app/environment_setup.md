# Bond App Environment Setup Guide

This document outlines how to set up the development environment for the Bond App project and test iOS builds safely.

## Prerequisites

- Flutter SDK (version 3.0.0 or higher)
- Dart SDK (included with Flutter)
- Xcode (14.0 or higher for iOS development)
- Android Studio / IntelliJ IDEA / VS Code
- CocoaPods (for iOS dependencies)
- Git

## Setting Up Development Environment

### 1. Flutter Installation

1. Download Flutter from [flutter.dev](https://flutter.dev/docs/get-started/install)
2. Add Flutter to your PATH
3. Run `flutter doctor` to verify the installation:

```bash
flutter doctor
```

Fix any issues identified by the Flutter doctor.

### 2. IDE Setup

#### VS Code Setup:
1. Install VS Code from [code.visualstudio.com](https://code.visualstudio.com/)
2. Install Flutter extension
3. Install Dart extension

#### Android Studio Setup:
1. Install Android Studio from [developer.android.com](https://developer.android.com/studio)
2. Install Flutter and Dart plugins from Preferences > Plugins

### 3. Clone the Project

```bash
git clone [repository-url]
cd fresh_bond_app
```

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. iOS-Specific Setup

1. Install CocoaPods if not already installed:
```bash
sudo gem install cocoapods
```

2. Make sure Xcode command line tools are installed:
```bash
xcode-select --install
```

3. Open the iOS project in Xcode to ensure settings are applied:
```bash
open ios/Runner.xcworkspace
```

4. In Xcode, make sure you have a Development Team selected in the Signing & Capabilities section.

## Safe iOS Build Process

To safely build the iOS app while avoiding the issues described in the transition guide, follow this process:

### 1. Incremental Dependency Testing

After adding any new dependency, test the iOS build immediately:

```bash
# After adding a dependency
flutter pub get
cd ios && pod install && cd ..
flutter build ios --no-codesign
```

### 2. Using the iOS Build Helper

We've created a helper script to streamline the iOS build process. Use it when you need to perform a clean build:

```bash
cd ios
chmod +x ios_build_helper.sh
./ios_build_helper.sh
```

### 3. Troubleshooting Common Issues

If you encounter iOS build issues:

#### Module Map Issues

```bash
# Create missing module maps
mkdir -p ios/Pods/Target\ Support\ Files/BoringSSLRPC
echo 'framework module BoringSSL {
  umbrella header "umbrella.h"
  export *
  module * { export * }
}' > ios/Pods/Target\ Support\ Files/BoringSSLRPC/BoringSSLRPC.modulemap

mkdir -p ios/Pods/BoringSSLRPC/include
echo '#ifndef boringsslrpc_umbrella_h
#define boringsslrpc_umbrella_h
// Placeholder header
#endif /* boringsslrpc_umbrella_h */' > ios/Pods/BoringSSLRPC/include/umbrella.h
```

#### Resource Bundle Conflicts

```bash
# Remove conflicting resource bundles
find ios/Pods -name "*ResourceBundle*Info.plist" -delete
```

#### XCConfig Issues

```bash
# Fix XCConfig files
cd ios
echo '#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"' > Flutter/Debug.xcconfig
echo '#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"' > Flutter/Release.xcconfig
echo '#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig"' > Flutter/Profile.xcconfig
```

## Testing Workflow

### 1. Unit Tests

Run the unit tests with coverage:

```bash
flutter test --coverage
```

### 2. Widget Tests

Run the widget tests:

```bash
flutter test --tags=widget
```

### 3. Integration Tests

Run the integration tests:

```bash
flutter test integration_test
```

### 4. iOS-Specific Tests

Test specifically for iOS:

```bash
flutter test --platform=ios
```

### 5. Manual Testing on Simulators

Test on iOS simulator:

```bash
flutter run -d "iPhone 14 Pro"
```

Replace "iPhone 14 Pro" with your simulator name.

## Continuous Integration Setup

### Setting up GitHub Actions

1. Create a `.github/workflows` directory in your project:

```bash
mkdir -p .github/workflows
```

2. Create a workflow file for CI (e.g., `ci.yml`):

```yaml
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3

      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
          channel: 'stable'

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze project source
        run: flutter analyze

      - name: Run tests
        run: flutter test

      - name: Build iOS
        run: |
          cd ios
          pod install
          cd ..
          flutter build ios --no-codesign
```

## Firebase Configuration

### Setting up Firebase REST API

1. Create a new Firebase project in the [Firebase Console](https://console.firebase.google.com/)

2. Add your iOS app to the project:
   - iOS bundle ID should match your app's bundle ID (e.g., `com.example.bondApp`)
   - Download the `GoogleService-Info.plist` file and add it to the `ios/Runner` directory

3. Enable Authentication services:
   - Go to Firebase Console > Authentication > Sign-in method
   - Enable Email/Password authentication

4. Get your Web API Key:
   - Go to Project Settings > General
   - Find your Web API Key

5. Create a configuration file:

```dart
// lib/core/config/env_config.dart
class EnvConfig {
  static const String firebaseApiUrl = 'https://identitytoolkit.googleapis.com';
  static const String firebaseApiKey = 'YOUR-API-KEY';
  static const String firebaseDatabaseUrl = 'https://YOUR-PROJECT-ID.firebaseio.com';
}
```

## Development Guidelines

### Coding Standards

Follow the official [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style) and the project-specific guidelines in `bond-frontend-guidelines.md`.

### Branch Strategy

1. Use feature branches for all new features:
   ```
   git checkout -b feature/feature-name
   ```

2. Use bugfix branches for fixes:
   ```
   git checkout -b bugfix/bug-description
   ```

3. Create pull requests to the main branch

### Commit Messages

Follow the conventional commits format:
- `feat: add new feature`
- `fix: resolve issue with X`
- `docs: update documentation`
- `refactor: improve code structure`
- `test: add tests for X`

## Deployment

### TestFlight Deployment

1. Ensure you have the required certificates and provisioning profiles in your Apple Developer account.

2. Configure app signing in Xcode:
   - Open `ios/Runner.xcworkspace`
   - Select the Runner project
   - Go to Signing & Capabilities
   - Select your Team and set the Bundle Identifier

3. Build the IPA:
   ```bash
   flutter build ios
   ```

4. Open the build in Xcode:
   ```bash
   open build/ios/archive/Runner.xcarchive
   ```

5. Use Xcode's Organizer to upload to TestFlight

## Common Issues and Solutions

### Flutter Package Version Conflicts

If you encounter package version conflicts:

```bash
flutter pub upgrade --major-versions
```

### iOS Build "Multiple commands produce" Error

This error occurs when multiple targets try to produce the same output file:

1. Clean the build folders:
   ```bash
   flutter clean
   cd ios && pod deintegrate && pod install && cd ..
   ```

2. Remove the problematic resource bundle plist files as described in the troubleshooting section.

### iOS Simulator Not Showing in Device List

If iOS simulators aren't showing:

```bash
xcrun simctl list
flutter config --enable-ios
flutter devices
```

## Resources

- [Flutter Documentation](https://flutter.dev/docs)
- [Dart Documentation](https://dart.dev/guides)
- [Firebase REST API Documentation](https://firebase.google.com/docs/reference/rest/auth)
- [CocoaPods Troubleshooting Guide](https://guides.cocoapods.org/using/troubleshooting.html)
- [Bond App Transition Guide](./bond_app_transition_guide.md)
- [Implementation Starter Guide](./implementation_starter.md)

---

This setup guide should help you get started with the Bond App project quickly while avoiding common pitfalls, especially with iOS builds.