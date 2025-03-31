#\!/bin/bash

# Fix module map issues for Firebase dependencies
PODS_DIR="$(pwd)/Pods"
mkdir -p "$PODS_DIR/Target Support Files/BoringSSLRPC"

# Create a module map file for BoringSSLRPC
cat > "$PODS_DIR/Target Support Files/BoringSSLRPC/BoringSSLRPC.modulemap" << 'MODULEMAP'
framework module BoringSSLRPC {
  umbrella header "BoringSSLRPC-umbrella.h"
  export *
  module * { export * }
}
MODULEMAP

echo "Created module map for BoringSSLRPC"
chmod +x "$PODS_DIR/Target Support Files/BoringSSLRPC/BoringSSLRPC.modulemap"

# Create a module map file for FirebaseFirestore if needed
if [ \! -f "$PODS_DIR/Target Support Files/FirebaseFirestore/FirebaseFirestore.modulemap" ]; then
  mkdir -p "$PODS_DIR/Target Support Files/FirebaseFirestore"
  cat > "$PODS_DIR/Target Support Files/FirebaseFirestore/FirebaseFirestore.modulemap" << 'MODULEMAP'
framework module FirebaseFirestore {
  umbrella header "FirebaseFirestore-umbrella.h"
  export *
  module * { export * }
}
MODULEMAP
  echo "Created module map for FirebaseFirestore"
  chmod +x "$PODS_DIR/Target Support Files/FirebaseFirestore/FirebaseFirestore.modulemap"
fi

# Make them all executable just in case
chmod +x "$PODS_DIR/Target Support Files"/*/*.modulemap 2>/dev/null || true
