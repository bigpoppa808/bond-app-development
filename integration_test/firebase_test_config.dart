import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

// This class helps manage Firebase initialization for testing
class FirebaseTestConfig {
  static Future<void> setupFirebaseForTesting() async {
    // Configure Firebase for testing
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'test-api-key',
        appId: 'test-app-id',
        messagingSenderId: 'test-messaging-sender-id',
        projectId: 'bond-dbc1d', // Using your actual project ID
      ),
    );
  }

  // Widget wrapper for integration tests
  static Widget wrapAppWithFirebase({required Widget child}) {
    return MaterialApp(
      home: FutureBuilder(
        future: setupFirebaseForTesting(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return child;
          }
          return const MaterialApp(
            home: Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          );
        },
      ),
    );
  }
}
