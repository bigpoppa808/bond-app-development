import 'package:flutter/material.dart';

/// A service that provides dummy account data for demo purposes
class DummyAccountService {
  // Singleton instance
  static final DummyAccountService _instance = DummyAccountService._internal();
  factory DummyAccountService() => _instance;
  DummyAccountService._internal();

  // Dummy user data
  final Map<String, DummyUser> _users = {
    'demo@bond.app': DummyUser(
      id: 'demo-user-1',
      email: 'demo@bond.app',
      password: 'password123',
      displayName: 'Alex Johnson',
      photoUrl: 'https://i.pravatar.cc/150?u=demo-user-1',
      bio: 'Passionate about connecting with others and building meaningful relationships.',
      interests: ['Photography', 'Travel', 'Cooking', 'Reading'],
      connections: 12,
    ),
    'test@bond.app': DummyUser(
      id: 'demo-user-2',
      email: 'test@bond.app',
      password: 'test123',
      displayName: 'Jordan Smith',
      photoUrl: 'https://i.pravatar.cc/150?u=demo-user-2',
      bio: 'Looking to expand my network and create lasting bonds with like-minded individuals.',
      interests: ['Fitness', 'Technology', 'Music', 'Art'],
      connections: 8,
    ),
  };

  // Login with email and password
  Future<DummyUser?> login(String email, String password) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final user = _users[email];
    if (user != null && user.password == password) {
      return user;
    }
    return null;
  }

  // Register a new user
  Future<DummyUser> register({
    required String email,
    required String password,
    required String displayName,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    
    final newUser = DummyUser(
      id: 'user-${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      password: password,
      displayName: displayName,
      photoUrl: 'https://i.pravatar.cc/150?u=${DateTime.now().millisecondsSinceEpoch}',
      bio: '',
      interests: [],
      connections: 0,
    );
    
    _users[email] = newUser;
    return newUser;
  }

  // Get user by email
  DummyUser? getUserByEmail(String email) {
    return _users[email];
  }

  // Get all users (for demo purposes)
  List<DummyUser> getAllUsers() {
    return _users.values.toList();
  }
}

/// Model class for dummy user data
class DummyUser {
  final String id;
  final String email;
  final String password;
  final String displayName;
  final String photoUrl;
  final String bio;
  final List<String> interests;
  final int connections;

  DummyUser({
    required this.id,
    required this.email,
    required this.password,
    required this.displayName,
    required this.photoUrl,
    required this.bio,
    required this.interests,
    required this.connections,
  });

  // Convert to a map for storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'bio': bio,
      'interests': interests,
      'connections': connections,
    };
  }

  // Create a copy with updated fields
  DummyUser copyWith({
    String? displayName,
    String? photoUrl,
    String? bio,
    List<String>? interests,
    int? connections,
  }) {
    return DummyUser(
      id: id,
      email: email,
      password: password,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      connections: connections ?? this.connections,
    );
  }
}
