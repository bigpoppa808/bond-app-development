# Bond App iOS Build Transition Guide

## 1. Overview

This document provides a comprehensive guide for continuing development of the Bond App using Flutter, with specific focus on resolving the iOS build issues. It includes detailed instructions, recommendations, and next steps for a successful handoff.

## 2. Current Status

We have created a fresh Flutter project (`fresh_bond_app`) and identified which dependencies can be successfully built for iOS:

### Working Dependencies
- **Core UI Framework**: flutter, cupertino_icons, flutter_svg
- **Basic Firebase**: firebase_core
- **State Management**: flutter_bloc, bloc, equatable, get_it
- **Routing**: go_router

### Problematic Dependencies
- **Firebase Auth**: Module map issues with non-modular headers
- **Cloud Firestore**: Resource bundle conflicts and -G compiler flag issues
- Other Firebase plugins experiencing similar issues

## 3. Recommended Approach

### 3.1 Overall Strategy

1. Continue with the current Flutter project
2. Follow a modular, incremental approach to adding dependencies
3. Use alternative approaches for problematic Firebase features
4. Address iOS-specific configuration issues as needed

### 3.2 Project Setup

The project has been initialized with a proper structure for the Bond app:
- Assets directories created
- Basic dependencies configured
- iOS configuration adjustments started

## 4. Step-by-Step Implementation Plan

### 4.1 Project Structure Setup

```
lib/
├── app/
│   ├── app.dart
│   ├── router.dart
│   └── theme.dart
├── core/
│   ├── config/
│   ├── di/
│   ├── network/
│   ├── theme/
│   └── utils/
├── features/
│   ├── auth/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── profile/
│   ├── discovery/
│   ├── connections/
│   └── meetings/
├── shared/
│   ├── widgets/
│   ├── models/
│   └── constants/
└── main.dart
```

**Instructions:**
1. Create this folder structure in the `lib` directory
2. Follow feature-based architecture for clear separation of concerns
3. Use the BLoC pattern for state management as specified in the guidelines

### 4.2 Firebase Integration Alternative

Since direct Firebase plugin integration causes iOS build issues, implement a REST API approach:

**Create a Firebase API Service:**

```dart
// lib/core/network/firebase_api_service.dart

import 'package:dio/dio.dart';

class FirebaseApiService {
  final Dio _dio = Dio();
  final String baseUrl;
  final String apiKey;

  FirebaseApiService({required this.baseUrl, required this.apiKey}) {
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  // Authentication methods
  Future<Map<String, dynamic>> signInWithEmail(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/identitytoolkit/v3/relyingparty/verifyPassword?key=$apiKey',
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> signUp(String email, String password) async {
    try {
      final response = await _dio.post(
        '$baseUrl/identitytoolkit/v3/relyingparty/signupNewUser?key=$apiKey',
        data: {
          'email': email,
          'password': password,
          'returnSecureToken': true,
        },
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Firestore methods
  Future<Map<String, dynamic>> getDocument(String collection, String docId, String idToken) async {
    try {
      final response = await _dio.get(
        '$baseUrl/firestore/v1beta1/projects/{projectId}/databases/(default)/documents/$collection/$docId',
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
      return _convertFirestoreDocToMap(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> setDocument(String collection, String docId, Map<String, dynamic> data, String idToken) async {
    try {
      await _dio.patch(
        '$baseUrl/firestore/v1beta1/projects/{projectId}/databases/(default)/documents/$collection/$docId',
        data: _convertMapToFirestoreDoc(data),
        options: Options(headers: {'Authorization': 'Bearer $idToken'}),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // Helper methods
  Exception _handleError(dynamic error) {
    if (error is DioException) {
      if (error.response != null) {
        final data = error.response!.data;
        if (data != null && data['error'] != null) {
          return Exception(data['error']['message'] ?? 'Unknown error');
        }
      }
    }
    return Exception('An unexpected error occurred');
  }

  Map<String, dynamic> _convertFirestoreDocToMap(Map<String, dynamic> firestoreDoc) {
    // Implement conversion from Firestore document format to Map
    // This requires custom parsing of Firestore's JSON structure
    return {};
  }

  Map<String, dynamic> _convertMapToFirestoreDoc(Map<String, dynamic> data) {
    // Implement conversion from Map to Firestore document format
    return {};
  }
}
```

**Instructions:**
1. Add `dio: ^5.0.0` to your pubspec.yaml dependencies
2. Create appropriate repositories that use this service
3. Implement necessary data models for serialization/deserialization

### 4.3 iOS Configuration

To address iOS-specific issues:

**Update Podfile:**

```ruby
# ios/Podfile

platform :ios, '15.6'

ENV['COCOAPODS_DISABLE_STATS'] = 'true'

project 'Runner', {
  'Debug' => :debug,
  'Profile' => :release,
  'Release' => :release,
}

def flutter_root
  generated_xcode_build_settings_path = File.expand_path(File.join('..', 'Flutter', 'Generated.xcconfig'), __FILE__)
  unless File.exist?(generated_xcode_build_settings_path)
    raise "#{generated_xcode_build_settings_path} must exist. If you're running pod install manually, make sure flutter pub get is executed first"
  end

  File.foreach(generated_xcode_build_settings_path) do |line|
    matches = line.match(/FLUTTER_ROOT\=(.*)/)
    return matches[1].strip if matches
  end
  raise "FLUTTER_ROOT not found in #{generated_xcode_build_settings_path}"
end

require File.expand_path(File.join('packages', 'flutter_tools', 'bin', 'podhelper'), flutter_root)

flutter_ios_podfile_setup

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
  target 'RunnerTests' do
    inherit! :search_paths
  end
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    flutter_additional_ios_build_settings(target)
    
    target.build_configurations.each do |config|
      # Fix iOS minimum deployment target
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.6'
      
      # Disable product validation and bitcode
      config.build_settings['VALIDATE_PRODUCT'] = 'NO'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
      config.build_settings['COMPILER_INDEX_STORE_ENABLE'] = 'NO'
      
      # Remove -G flag from all build settings
      config.build_settings.keys.each do |key|
        if config.build_settings[key].is_a?(String) && config.build_settings[key].include?('-G')
          config.build_settings[key] = config.build_settings[key].gsub('-G', '')
        end
      end
    end
  end
end
```

**Create iOS Build Helper Script:**

```bash
# ios/ios_build_helper.sh

#!/bin/bash

echo "Running iOS build helper..."

# Clean environment
flutter clean
cd ios
rm -rf Pods Podfile.lock
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# Get dependencies
cd ..
flutter pub get

# Set up XCConfig files correctly
cd ios
mkdir -p Flutter

cat > Flutter/Debug.xcconfig << EOF
#include? "Generated.xcconfig"
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
EOF

cat > Flutter/Release.xcconfig << EOF
#include? "Generated.xcconfig"
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
EOF

cat > Flutter/Profile.xcconfig << EOF
#include? "Generated.xcconfig"
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.profile.xcconfig"
EOF

# Install pods
pod install

echo "iOS setup complete. Building app..."
cd ..
flutter build ios --no-codesign
```

**Instructions:**
1. Make the script executable: `chmod +x ios/ios_build_helper.sh`
2. Run this script when you need to perform a clean iOS build

### 4.4 Dependency Addition Workflow

When adding new dependencies, follow this approach:

1. Add one dependency at a time to pubspec.yaml
2. Run `flutter pub get`
3. Try building for iOS: `flutter build ios --no-codesign`
4. If build fails, either:
   - Try an alternative version of the dependency
   - Create a platform-specific implementation
   - Use an alternative approach (like REST API for Firebase services)

**Example of adding a dependency safely:**

```bash
# Add dependency
flutter pub add package_name

# Test build
flutter build ios --no-codesign

# If successful, commit the change
git add .
git commit -m "Add package_name dependency"

# If failed, remove and try alternative
flutter pub remove package_name
```

## 5. Feature Implementation Roadmap

Implement features in this order to ensure stable progress:

### 5.1 Basic App Structure
- App theme and styling
- Basic navigation
- Splash screen

### 5.2 Authentication
- Email/password auth via REST API
- User management services
- Login/signup screens

### 5.3 Profile Features
- User profile models
- Profile creation flow
- Profile editing

### 5.4 Discovery Features
- User discovery models
- Discovery screens
- Compatibility display

### 5.5 Connection Features
- Connection management
- Messaging interfaces
- Meeting scheduling

### 5.6 Advanced Features

#### 5.6.1 NFC Verification Feature
- Implemented NFC scanning for meeting verification
- Uses `nfc_manager` package (`^3.3.0`)
- Requires iOS-specific configuration:
  - Add `NFCReaderUsageDescription` to Info.plist
  - Add `com.apple.developer.nfc.readersession.formats` capability with `TAG` value
  - Requires iOS 13.0+
  - Supports reading NDEF tags
- Key components:
  - `NfcVerificationRepository`: Handles NFC operations
  - `NfcVerificationBloc`: Manages NFC scanning state
  - `NfcVerificationScreen`: UI for scanning process
  - Integration with meetings feature for verification

#### 5.6.2 Token Economy (To Be Implemented)
- Digital token system for app engagement
- Reward mechanism for completed meetings
- Integration with verification system

#### 5.6.3 Donor Management (To Be Implemented)
- Donor profiles and management
- Donation tracking and insights
- Integration with token economy

## 6. Testing Guidelines

### 6.1 iOS-Specific Testing

Given the iOS build challenges, implement a robust testing strategy:

1. **Simulator Testing First**: Test initial builds on iOS simulators
2. **Device Testing**: Verify functionality on physical iOS devices
3. **CI Configuration**: Set up CI/CD pipeline with iOS-specific checks

### 6.2 Cross-Platform Testing

Ensure feature parity across platforms:

1. Test each feature on both iOS and Android
2. Verify consistent design and functionality
3. Test responsive layouts for different screen sizes

## 7. Alternative Solutions if Issues Persist

If the recommended approach faces continued challenges:

### 7.1 Platform Channels

Use platform channels to implement native iOS code where needed:

```dart
// Example platform channel for iOS-specific functionality
import 'package:flutter/services.dart';

class NativeAuthService {
  static const platform = MethodChannel('com.bondapp/auth');

  Future<Map<String, dynamic>> signIn(String email, String password) async {
    try {
      final result = await platform.invokeMethod('signIn', {
        'email': email,
        'password': password,
      });
      return Map<String, dynamic>.from(result);
    } on PlatformException catch (e) {
      throw Exception('Failed to sign in: ${e.message}');
    }
  }
}
```

### 7.2 Server-Side Integration

If Firebase plugins consistently cause issues:

1. Create a lightweight server (Node.js/Express)
2. Implement Firebase Admin SDK on the server
3. Create RESTful endpoints for app to consume
4. Use simple HTTP requests from Flutter

## 8. Handoff Checklist

Before handing off the project, ensure:

- [ ] Project structure is properly set up
- [ ] All working dependencies are documented
- [ ] iOS build process is documented and tested
- [ ] Alternative implementation approaches are provided for problematic areas
- [ ] Testing processes are documented
- [ ] Development roadmap is clear
- [ ] Known issues and workarounds are documented

## 9. Common Issues and Solutions

### Firebase Module Map Issues

**Issue**: Missing module map file for BoringSSLRPC
**Solution**: Create the necessary module map files manually:

```bash
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

### Resource Bundle Conflicts

**Issue**: Multiple commands produce same resource bundle
**Solution**: Remove or create empty versions of the conflicting files:

```bash
find ios/Pods -name "*ResourceBundle*Info.plist" -delete
```

### XCConfig Integration Issues

**Issue**: CocoaPods did not set the base configuration of your project
**Solution**: Ensure proper inclusion of config files:

```bash
sed -i '' '1i\
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig"
' ios/Flutter/Debug.xcconfig

sed -i '' '1i\
#include? "Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig"
' ios/Flutter/Release.xcconfig
```

## 10. Resources and References

- [Flutter Firebase REST API Documentation](https://firebase.google.com/docs/reference/rest/auth)
- [Flutter Platform Channels](https://docs.flutter.dev/platform-integration/platform-channels)
- [CocoaPods Troubleshooting Guide](https://guides.cocoapods.org/using/troubleshooting.html)
- [Bond App Technical Stack Documentation](../docs/bond-tech-stack-doc.md)
- [Bond App Requirements](../docs/bond-project-requirements.md)

---

By following this guide, you should be able to continue development of the Bond App using Flutter while working around the iOS build issues. The recommended approach leverages the existing architecture and codebase while providing alternatives for problematic dependencies.