#!/bin/bash

set -e

echo "=== Fixing Firebase build issues for newer SDK ==="
echo "Using Firebase SDK 2.x with Flutter 3.27.2+"

# Fix module map issues for Firebase dependencies
PODS_DIR="$(pwd)/Pods"

# Create a BoringSSLRPC modulemap folder if it doesn't exist
mkdir -p "$PODS_DIR/Target Support Files/BoringSSLRPC"

# Create a module map file for BoringSSLRPC
cat > "$PODS_DIR/Target Support Files/BoringSSLRPC/BoringSSLRPC.modulemap" << 'MODULEMAP'
framework module BoringSSLRPC {
  umbrella header "BoringSSL-GRPC-umbrella.h"
  export *
  module * { export * }
}
MODULEMAP
echo "Created module map for BoringSSLRPC"

# Create a dummy umbrella header if it doesn't exist
cat > "$PODS_DIR/Target Support Files/BoringSSLRPC/BoringSSL-GRPC-umbrella.h" << 'UMBRELLA'
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

FOUNDATION_EXPORT double BoringSSLRPCVersionNumber;
FOUNDATION_EXPORT const unsigned char BoringSSLRPCVersionString[];
UMBRELLA
echo "Created umbrella header for BoringSSLRPC"

# Create modulemaps for all other Firebase related targets
FIREBASE_TARGETS=(
  "FirebaseFirestore"
  "FirebaseCoreInternal"
  "FirebaseCore"
  "FirebaseAuth"
  "FirebaseFirestoreInternal"
  "FirebaseAppCheckInterop"
  "FirebaseAuthInterop"
  "FirebaseCoreExtension"
  "FirebaseSharedSwift"
  "gRPC-Core"
  "gRPC-C++"
  "abseil"
  "RecaptchaInterop"
  "GTMSessionFetcher"
  "GoogleUtilities"
  "nanopb"
  "leveldb-library"
)

for TARGET in "${FIREBASE_TARGETS[@]}"; do
  mkdir -p "$PODS_DIR/Target Support Files/$TARGET"
  cat > "$PODS_DIR/Target Support Files/$TARGET/$TARGET.modulemap" << MODULEMAP
framework module $TARGET {
  umbrella header "$TARGET-umbrella.h"
  export *
  module * { export * }
}
MODULEMAP
  echo "Created module map for $TARGET"
  
  # Also create a dummy umbrella header
  cat > "$PODS_DIR/Target Support Files/$TARGET/$TARGET-umbrella.h" << UMBRELLA
#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

FOUNDATION_EXPORT double ${TARGET}VersionNumber;
FOUNDATION_EXPORT const unsigned char ${TARGET}VersionString[];
UMBRELLA
  echo "Created umbrella header for $TARGET"
done

echo "=== Updating Xcode project settings ==="

# Update Release.xcconfig to include the Pods configuration
RELEASE_XCCONFIG="Flutter/Release.xcconfig"
if grep -q "#include \"Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig\"" "$RELEASE_XCCONFIG"; then
  echo "Pods configuration already included in $RELEASE_XCCONFIG"
else
  echo "#include \"Pods/Target Support Files/Pods-Runner/Pods-Runner.release.xcconfig\"" >> "$RELEASE_XCCONFIG"
  echo "Added Pods configuration to $RELEASE_XCCONFIG"
fi

# Update Debug.xcconfig to include the Pods configuration
DEBUG_XCCONFIG="Flutter/Debug.xcconfig"
if grep -q "#include \"Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig\"" "$DEBUG_XCCONFIG"; then
  echo "Pods configuration already included in $DEBUG_XCCONFIG"
else
  echo "#include \"Pods/Target Support Files/Pods-Runner/Pods-Runner.debug.xcconfig\"" >> "$DEBUG_XCCONFIG"
  echo "Added Pods configuration to $DEBUG_XCCONFIG"
fi

echo "=== Cleaning and reinstalling pods ==="
pod deintegrate
rm -rf Pods
pod install

echo "=== Fix complete ==="
