# NFC Verification Feature Deployment Guide

This guide provides instructions for deploying the NFC Verification feature to production, including iOS-specific configurations required for App Store approval.

## Prerequisites

Before deploying the NFC feature, ensure you have:

1. **Apple Developer Account**: Active enrollment in the Apple Developer Program
2. **Xcode**: Latest version for iOS build generation
3. **Flutter**: Latest stable version with iOS build capability
4. **Project Repository**: Clean, up-to-date repository

## NFC Capability Setup

### 1. Entitlements Configuration

1. Open your project in Xcode:
   ```bash
   cd ios
   open Runner.xcworkspace
   ```

2. Select the Runner project in the Project Navigator
3. Select the "Runner" target
4. Go to the "Signing & Capabilities" tab
5. Click the "+" button to add a capability
6. Search for and add "Near Field Communication Tag Reading"
7. Ensure the "Tag" format is checked

### 2. Info.plist Configuration

Add the following entries to your `ios/Runner/Info.plist` file:

```xml
<key>NFCReaderUsageDescription</key>
<string>Bond App needs NFC to verify meetings with other users</string>

<key>com.apple.developer.nfc.readersession.formats</key>
<array>
    <string>TAG</string>
</array>
```

### 3. Provisioning Profile Update

1. Log in to the [Apple Developer Portal](https://developer.apple.com/)
2. Navigate to "Certificates, Identifiers & Profiles"
3. Select your app's identifier
4. Enable the "NFC Tag Reading" capability
5. Generate a new provisioning profile
6. Download and install the new provisioning profile

## Flutter Package Configuration

Ensure the `nfc_manager` package is properly added to your `pubspec.yaml`:

```yaml
dependencies:
  nfc_manager: ^3.3.0
  crypto: ^3.0.3  # Required for secure verification
```

## iOS Build Configuration

### 1. Update Build Settings

1. Set minimum iOS version to 13.0 in `ios/Flutter/AppFrameworkInfo.plist`:
   ```xml
   <key>MinimumOSVersion</key>
   <string>13.0</string>
   ```

2. Update Podfile to match:
   ```ruby
   platform :ios, '13.0'
   ```

### 2. Clean Build

Run the following commands to ensure a clean build:

```bash
flutter clean
cd ios
rm -rf Pods Podfile.lock
pod install --repo-update
cd ..
```

## Testing Before Deployment

1. **Simulator Testing**: Verify non-NFC features work correctly
2. **Physical Device Testing**: Test on physical iOS devices with NFC capability
3. **Edge Cases**: Test with different NFC tag types and error conditions
4. **Verification Flow**: Verify complete meeting verification process

## App Store Submission

When submitting to the App Store, include the following:

### 1. App Review Information

In the "App Review Information" section, include:

```
This app uses NFC for verifying in-person meetings between users. To test this feature:
1. Create a new meeting in the app
2. Go to the meeting details screen
3. Tap "Verify with NFC"
4. Hold the device near an NFC tag (or another iOS device for testing)
5. Observe the verification process and completion
```

### 2. App Store Screenshots

Include screenshots of:
- The NFC verification process
- Success and error states
- Integration with the meeting details screen

### 3. Privacy Policy Update

Update your privacy policy to include information about:
- What NFC data is collected
- How this data is used
- How long the data is stored
- How users can request deletion of this data

## Deployment Checklist

- [ ] NFC capability added to Xcode project
- [ ] Info.plist updated with required entries
- [ ] Provisioning profile updated and installed
- [ ] Podfile updated with correct iOS version
- [ ] Minimum iOS version set to 13.0
- [ ] All tests pass on physical iOS devices
- [ ] App Review Information prepared
- [ ] Privacy Policy updated
- [ ] Feature flag ready for production activation

## Fallback Strategy

If NFC verification issues occur in production:

1. Create a server-side feature flag to disable NFC verification
2. Implement UI to gracefully hide NFC options when disabled
3. Provide alternative verification method (e.g., QR code scanning)

## Monitoring

After deployment, monitor:

1. **Crash reports**: Watch for NFC-related crashes
2. **Success rate**: Track successful NFC verifications vs. attempts
3. **User feedback**: Monitor app reviews for NFC-related issues
4. **Error logs**: Analyze error patterns for improvement

## Troubleshooting Common Issues

### Issue: NFC Not Working on Some Devices

**Solution**:
- Verify device has NFC capability
- Check iOS version is 13.0+
- Ensure app has NFC permissions

### Issue: NFC Session Timing Out

**Solution**:
- Improve user guidance UI
- Add more visible feedback during scanning

### Issue: App Store Rejection

**Solution**:
- Verify Info.plist contains required entries
- Ensure privacy policy mentions NFC usage
- Provide clear testing instructions
- Include demonstration video if necessary

## Version Rollback Plan

If critical issues occur:

1. Prepare a version without NFC capability
2. Keep it ready for quick submission
3. Have a communication plan for users
4. Document rollback procedure for development team

---

By following this guide, you can successfully deploy the NFC Verification feature to the App Store and provide users with a secure, efficient way to verify in-person meetings.