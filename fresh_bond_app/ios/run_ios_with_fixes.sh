#!/bin/bash

# Script to run iOS app with all necessary fixes applied

# Display message
echo "===== Bond App iOS Runner ====="
echo "This script will:"
echo "1. Clean the project"
echo "2. Apply fixes to Firebase module maps"
echo "3. Run the app on iOS simulator"
echo "============================="

# Navigate to project root
cd "$(dirname "$0")/.."

# Clean project
echo "Cleaning project..."
flutter clean
flutter pub get

# Apply module map fixes
echo "Applying Firebase module map fixes..."
cd ios
chmod +x fix_firebase_build.sh
./fix_firebase_build.sh
cd ..

# Run app on iOS simulator
echo "Running app on iOS simulator..."
flutter run -d iPhone

echo "Done!"