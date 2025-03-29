import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../core/config/env_config.dart';

/// A service class to manage Firebase initialization and provide access to Firebase services
class FirebaseService {
  static FirebaseService? _instance;
  
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  
  FirebaseAuth get auth => _auth;
  FirebaseFirestore get firestore => _firestore;
  FirebaseStorage get storage => _storage;
  
  FirebaseService._({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : 
    _auth = auth,
    _firestore = firestore,
    _storage = storage;
  
  /// Initialize Firebase with the stored credentials
  static Future<FirebaseService> initialize() async {
    if (_instance != null) return _instance!;
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: '', // Will be set in firebase_options.dart by FlutterFire CLI
        appId: '', // Will be set in firebase_options.dart by FlutterFire CLI
        messagingSenderId: '', // Will be set in firebase_options.dart by FlutterFire CLI
        projectId: EnvConfig.firebaseProjectId,
        storageBucket: '${EnvConfig.firebaseProjectId}.appspot.com',
      ),
    );
    
    // Create instance with default Firebase services
    _instance = FirebaseService._(
      auth: FirebaseAuth.instance,
      firestore: FirebaseFirestore.instance,
      storage: FirebaseStorage.instance,
    );
    
    return _instance!;
  }
  
  /// Load Firebase service account for admin operations (server-side only)
  static Map<String, dynamic> loadServiceAccount() {
    try {
      final file = File(EnvConfig.firebaseServiceAccountPath);
      if (!file.existsSync()) {
        throw Exception('Firebase service account file not found at ${EnvConfig.firebaseServiceAccountPath}');
      }
      
      final String contents = file.readAsStringSync();
      return json.decode(contents) as Map<String, dynamic>;
    } catch (e) {
      throw Exception('Failed to load Firebase service account: $e');
    }
  }
}
