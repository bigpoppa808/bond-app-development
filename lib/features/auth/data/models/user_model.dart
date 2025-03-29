import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// User model representing a Bond app user
class UserModel extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final String? phoneNumber;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? bio;
  final List<String> interests;
  final GeoPoint? location;
  final bool isProfileComplete;
  final bool isEmailVerified;
  final DateTime createdAt;
  final DateTime lastLoginAt;
  final int tokenBalance;
  final bool isDonor;
  final String? donorTier;
  final Map<String, dynamic>? settings;

  const UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.phoneNumber,
    this.dateOfBirth,
    this.gender,
    this.bio,
    this.interests = const [],
    this.location,
    this.isProfileComplete = false,
    this.isEmailVerified = false,
    required this.createdAt,
    required this.lastLoginAt,
    this.tokenBalance = 0,
    this.isDonor = false,
    this.donorTier,
    this.settings,
  });

  /// Create a new user with default values
  factory UserModel.create({
    required String id,
    required String email,
    String? displayName,
    String? photoUrl,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: id,
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      createdAt: now,
      lastLoginAt: now,
    );
  }

  /// Create a user model from Firebase user
  factory UserModel.fromFirebaseUser(dynamic firebaseUser) {
    final now = DateTime.now();
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      phoneNumber: firebaseUser.phoneNumber,
      isEmailVerified: firebaseUser.emailVerified,
      createdAt: now,
      lastLoginAt: now,
    );
  }

  /// Create a user model from Firestore document
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      throw Exception('User data is null');
    }
    
    return UserModel(
      id: doc.id,
      email: data['email'] ?? '',
      displayName: data['displayName'],
      photoUrl: data['photoUrl'],
      phoneNumber: data['phoneNumber'],
      dateOfBirth: data['dateOfBirth'] != null 
          ? (data['dateOfBirth'] as Timestamp).toDate() 
          : null,
      gender: data['gender'],
      bio: data['bio'],
      interests: List<String>.from(data['interests'] ?? []),
      location: data['location'],
      isProfileComplete: data['isProfileComplete'] ?? false,
      isEmailVerified: data['isEmailVerified'] ?? false,
      createdAt: data['createdAt'] != null 
          ? (data['createdAt'] as Timestamp).toDate() 
          : DateTime.now(),
      lastLoginAt: data['lastLoginAt'] != null 
          ? (data['lastLoginAt'] as Timestamp).toDate() 
          : DateTime.now(),
      tokenBalance: data['tokenBalance'] ?? 0,
      isDonor: data['isDonor'] ?? false,
      donorTier: data['donorTier'],
      settings: data['settings'],
    );
  }

  /// Convert user model to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth != null ? Timestamp.fromDate(dateOfBirth!) : null,
      'gender': gender,
      'bio': bio,
      'interests': interests,
      'location': location,
      'isProfileComplete': isProfileComplete,
      'isEmailVerified': isEmailVerified,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLoginAt': Timestamp.fromDate(lastLoginAt),
      'tokenBalance': tokenBalance,
      'isDonor': isDonor,
      'donorTier': donorTier,
      'settings': settings,
    };
  }

  /// Convert user model to Algolia document
  Map<String, dynamic> toAlgolia() {
    return {
      'objectID': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'gender': gender,
      'bio': bio,
      'interests': interests,
      'isProfileComplete': isProfileComplete,
      'tokenBalance': tokenBalance,
      'isDonor': isDonor,
      'donorTier': donorTier,
      '_geoloc': location != null 
          ? {'lat': location!.latitude, 'lng': location!.longitude} 
          : null,
    };
  }

  /// Create a copy of this user with the given fields replaced
  UserModel copyWith({
    String? displayName,
    String? photoUrl,
    String? phoneNumber,
    DateTime? dateOfBirth,
    String? gender,
    String? bio,
    List<String>? interests,
    GeoPoint? location,
    bool? isProfileComplete,
    bool? isEmailVerified,
    DateTime? lastLoginAt,
    int? tokenBalance,
    bool? isDonor,
    String? donorTier,
    Map<String, dynamic>? settings,
  }) {
    return UserModel(
      id: id,
      email: email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,
      interests: interests ?? this.interests,
      location: location ?? this.location,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
      tokenBalance: tokenBalance ?? this.tokenBalance,
      isDonor: isDonor ?? this.isDonor,
      donorTier: donorTier ?? this.donorTier,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [
    id,
    email,
    displayName,
    photoUrl,
    phoneNumber,
    dateOfBirth,
    gender,
    bio,
    interests,
    location,
    isProfileComplete,
    isEmailVerified,
    createdAt,
    lastLoginAt,
    tokenBalance,
    isDonor,
    donorTier,
    settings,
  ];
}
