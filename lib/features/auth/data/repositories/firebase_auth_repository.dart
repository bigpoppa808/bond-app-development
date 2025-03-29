import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:bond_app/features/auth/data/models/user_model.dart';
import 'package:bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:bond_app/core/config/env_config.dart';

/// Firebase implementation of the authentication repository
class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;
  
  /// Collection reference for users in Firestore
  final CollectionReference _usersCollection;
  
  /// Constructor
  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : 
    _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
    _firestore = firestore ?? FirebaseFirestore.instance,
    _googleSignIn = googleSignIn ?? GoogleSignIn(),
    _usersCollection = (firestore ?? FirebaseFirestore.instance).collection('users');
  
  @override
  Stream<UserModel?> get user {
    return _firebaseAuth.authStateChanges().asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        return null;
      }
      
      try {
        final userDoc = await _usersCollection.doc(firebaseUser.uid).get();
        
        if (userDoc.exists) {
          return UserModel.fromFirestore(userDoc);
        } else {
          // Create a new user document if it doesn't exist
          final newUser = UserModel.fromFirebaseUser(firebaseUser);
          await _usersCollection.doc(firebaseUser.uid).set(newUser.toFirestore());
          return newUser;
        }
      } catch (e) {
        print('Error getting user data: $e');
        return UserModel.fromFirebaseUser(firebaseUser);
      }
    });
  }
  
  @override
  Stream<bool> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) => user != null);
  }
  
  @override
  Future<UserModel> signInWithEmailAndPassword(String email, String password) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('User is null after sign in');
      }
      
      // Update last login time
      final user = userCredential.user!;
      await _updateLastLogin(user.uid);
      
      // Get user data from Firestore
      final userDoc = await _usersCollection.doc(user.uid).get();
      
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      } else {
        // Create a new user document if it doesn't exist
        final newUser = UserModel.fromFirebaseUser(user);
        await _usersCollection.doc(user.uid).set(newUser.toFirestore());
        return newUser;
      }
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'user-not-found':
          throw Exception('No user found for that email.');
        case 'wrong-password':
          throw Exception('Wrong password provided.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'user-disabled':
          throw Exception('This user has been disabled.');
        default:
          throw Exception('Failed to sign in: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to sign in: $e');
    }
  }
  
  @override
  Future<UserModel> signUpWithEmailAndPassword(
    String email, 
    String password, 
    String displayName
  ) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user == null) {
        throw Exception('User is null after sign up');
      }
      
      // Update user profile
      final user = userCredential.user!;
      await user.updateDisplayName(displayName);
      
      // Create user in Firestore
      final newUser = UserModel.fromFirebaseUser(user).copyWith(
        displayName: displayName,
      );
      
      await _usersCollection.doc(user.uid).set(newUser.toFirestore());
      
      return newUser;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          throw Exception('The email address is already in use.');
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'weak-password':
          throw Exception('The password is too weak.');
        case 'operation-not-allowed':
          throw Exception('Email/password accounts are not enabled.');
        default:
          throw Exception('Failed to sign up: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to sign up: $e');
    }
  }
  
  @override
  Future<UserModel> signInWithGoogle() async {
    try {
      // Start the Google sign-in process
      final googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        throw Exception('Google sign in aborted');
      }
      
      // Get authentication details
      final googleAuth = await googleUser.authentication;
      
      // Create credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      
      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user == null) {
        throw Exception('User is null after Google sign in');
      }
      
      final user = userCredential.user!;
      
      // Check if user exists in Firestore
      final userDoc = await _usersCollection.doc(user.uid).get();
      
      if (userDoc.exists) {
        // Update last login time
        await _updateLastLogin(user.uid);
        return UserModel.fromFirestore(userDoc);
      } else {
        // Create a new user document
        final newUser = UserModel.fromFirebaseUser(user);
        await _usersCollection.doc(user.uid).set(newUser.toFirestore());
        return newUser;
      }
    } catch (e) {
      throw Exception('Failed to sign in with Google: $e');
    }
  }
  
  @override
  Future<UserModel> signInWithApple() async {
    try {
      // Start the Apple sign-in process
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      
      // Create OAuthCredential
      final oauthCredential = OAuthProvider('apple.com').credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      
      // Sign in with Firebase
      final userCredential = await _firebaseAuth.signInWithCredential(oauthCredential);
      
      if (userCredential.user == null) {
        throw Exception('User is null after Apple sign in');
      }
      
      final user = userCredential.user!;
      
      // Get full name from Apple credentials if available
      String? displayName;
      if (appleCredential.givenName != null && appleCredential.familyName != null) {
        displayName = '${appleCredential.givenName} ${appleCredential.familyName}';
      }
      
      // Check if user exists in Firestore
      final userDoc = await _usersCollection.doc(user.uid).get();
      
      if (userDoc.exists) {
        // Update last login time
        await _updateLastLogin(user.uid);
        return UserModel.fromFirestore(userDoc);
      } else {
        // Create a new user document
        final newUser = UserModel.fromFirebaseUser(user).copyWith(
          displayName: displayName ?? user.displayName,
        );
        await _usersCollection.doc(user.uid).set(newUser.toFirestore());
        return newUser;
      }
    } catch (e) {
      throw Exception('Failed to sign in with Apple: $e');
    }
  }
  
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          throw Exception('The email address is not valid.');
        case 'user-not-found':
          throw Exception('No user found for that email.');
        default:
          throw Exception('Failed to send password reset email: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to send password reset email: $e');
    }
  }
  
  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }
  
  @override
  Future<void> sendEmailVerification() async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw Exception('No user is signed in');
      }
      
      await user.sendEmailVerification();
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    }
  }
  
  @override
  Future<UserModel> updateUserProfile(UserModel user) async {
    try {
      // Update Firestore document
      await _usersCollection.doc(user.id).update(user.toFirestore());
      
      // Update Firebase Auth profile if needed
      final currentUser = _firebaseAuth.currentUser;
      
      if (currentUser != null) {
        if (user.displayName != null && user.displayName != currentUser.displayName) {
          await currentUser.updateDisplayName(user.displayName);
        }
        
        if (user.photoUrl != null && user.photoUrl != currentUser.photoURL) {
          await currentUser.updatePhotoURL(user.photoUrl);
        }
      }
      
      return user;
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }
  
  @override
  Future<void> deleteAccount() async {
    try {
      final user = _firebaseAuth.currentUser;
      
      if (user == null) {
        throw Exception('No user is signed in');
      }
      
      // Delete user document from Firestore
      await _usersCollection.doc(user.uid).delete();
      
      // Delete user from Firebase Auth
      await user.delete();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'requires-recent-login':
          throw Exception('This operation is sensitive and requires recent authentication. Log in again before retrying.');
        default:
          throw Exception('Failed to delete account: ${e.message}');
      }
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }
  
  /// Update the last login time for a user
  Future<void> _updateLastLogin(String userId) async {
    try {
      await _usersCollection.doc(userId).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login time: $e');
    }
  }
}
