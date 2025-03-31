import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

/// A mock authentication service for testing
class MockAuthService {
  // Singleton instance
  static final MockAuthService _instance = MockAuthService._internal();
  factory MockAuthService() => _instance;
  MockAuthService._internal();

  // Mock user data
  final Map<String, MockUser> _users = {
    'test@bond.app': MockUser(
      uid: 'test-user-123',
      email: 'test@bond.app',
      displayName: 'Test User',
      password: 'Test123!',
    ),
  };

  // Auth state controller
  final StreamController<MockUser?> _authStateController = 
      StreamController<MockUser?>.broadcast();
  
  // Current user
  MockUser? _currentUser;
  MockUser? get currentUser => _currentUser;

  // Auth state changes stream
  Stream<MockUser?> get authStateChanges => _authStateController.stream;

  // Login with email and password
  Future<MockUser?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final user = _users[email];
    if (user != null && user.password == password) {
      _currentUser = user;
      _authStateController.add(user);
      print('Mock login successful: ${user.displayName}');
      return user;
    }
    
    print('Mock login failed: Invalid credentials');
    throw FirebaseAuthException(
      code: 'invalid-credential',
      message: 'The email or password is incorrect.',
    );
  }

  // Sign in with email and password (alias for login)
  Future<MockUser?> signIn(String email, String password) async {
    return login(email, password);
  }

  // Check if user is signed in
  Future<bool> isSignedIn() async {
    return _currentUser != null;
  }

  // Register a new user
  Future<MockUser?> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    if (_users.containsKey(email)) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use.',
      );
    }
    
    final newUser = MockUser(
      uid: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: displayName,
      password: password,
    );
    
    _users[email] = newUser;
    _currentUser = newUser;
    _authStateController.add(newUser);
    
    print('Mock register successful: $displayName');
    return newUser;
  }

  // Sign up with email and password (alias for register)
  Future<MockUser?> signUp(String email, String password, String displayName) async {
    return register(email: email, password: password, displayName: displayName);
  }

  // Sign out
  Future<void> signOut() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 300));
    
    _currentUser = null;
    _authStateController.add(null);
    print('Mock sign out successful');
  }

  // Create or get test account
  Future<MockUser?> createTestAccount() async {
    const email = 'test@bond.app';
    const password = 'Test123!';
    
    try {
      return await login(email, password);
    } catch (e) {
      // If login fails, create the test account
      return register(
        email: email,
        password: password,
        displayName: 'Test User',
      );
    }
  }

  // Get user data
  Future<Map<String, dynamic>?> getUserData(String uid) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final user = _users.values.firstWhere(
      (user) => user.uid == uid,
      orElse: () => throw Exception('User not found'),
    );
    
    return {
      'email': user.email,
      'displayName': user.displayName,
      'photoUrl': user.photoURL,
      'bio': 'This is a mock user bio for testing.',
      'interests': ['Technology', 'Design', 'Travel'],
      'connections': 42,
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!_users.containsKey(email)) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found with this email.',
      );
    }
    
    print('Mock password reset email sent to: $email');
  }
}

/// Mock user class that mimics Firebase User
class MockUser {
  final String uid;
  final String email;
  final String displayName;
  final String password;
  final String? photoURL;

  MockUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.password,
    this.photoURL,
  });

  @override
  String toString() => 'MockUser(email: $email, displayName: $displayName)';
}
