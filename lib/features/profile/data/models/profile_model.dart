import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:bond_app/features/auth/data/models/user_model.dart';

/// Profile model extending user information for the Bond app
class ProfileModel extends Equatable {
  final String userId;
  final String? occupation;
  final String? education;
  final List<String> languages;
  final List<String> hobbies;
  final List<String> skills;
  final Map<String, dynamic>? socialLinks;
  final List<String> photos;
  final String? relationshipStatus;
  final String? lookingFor;
  final int? height; // in cm
  final List<String> personalityTraits;
  final Map<String, dynamic> preferences;
  final bool isPublic;
  final DateTime lastUpdated;

  const ProfileModel({
    required this.userId,
    this.occupation,
    this.education,
    this.languages = const [],
    this.hobbies = const [],
    this.skills = const [],
    this.socialLinks,
    this.photos = const [],
    this.relationshipStatus,
    this.lookingFor,
    this.height,
    this.personalityTraits = const [],
    this.preferences = const {},
    this.isPublic = true,
    required this.lastUpdated,
  });

  /// Create a new profile with default values
  factory ProfileModel.create({
    required String userId,
  }) {
    return ProfileModel(
      userId: userId,
      languages: const [],
      hobbies: const [],
      skills: const [],
      photos: const [],
      personalityTraits: const [],
      preferences: const {},
      lastUpdated: DateTime.now(),
    );
  }

  /// Create a profile from a Firestore document
  factory ProfileModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    
    if (data == null) {
      throw Exception('Profile data is null');
    }
    
    return ProfileModel(
      userId: doc.id,
      occupation: data['occupation'] as String?,
      education: data['education'] as String?,
      languages: List<String>.from(data['languages'] ?? []),
      hobbies: List<String>.from(data['hobbies'] ?? []),
      skills: List<String>.from(data['skills'] ?? []),
      socialLinks: data['socialLinks'] as Map<String, dynamic>?,
      photos: List<String>.from(data['photos'] ?? []),
      relationshipStatus: data['relationshipStatus'] as String?,
      lookingFor: data['lookingFor'] as String?,
      height: data['height'] as int?,
      personalityTraits: List<String>.from(data['personalityTraits'] ?? []),
      preferences: Map<String, dynamic>.from(data['preferences'] ?? {}),
      isPublic: data['isPublic'] as bool? ?? true,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert profile to a Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'occupation': occupation,
      'education': education,
      'languages': languages,
      'hobbies': hobbies,
      'skills': skills,
      'socialLinks': socialLinks,
      'photos': photos,
      'relationshipStatus': relationshipStatus,
      'lookingFor': lookingFor,
      'height': height,
      'personalityTraits': personalityTraits,
      'preferences': preferences,
      'isPublic': isPublic,
      'lastUpdated': Timestamp.fromDate(lastUpdated),
    };
  }

  /// Create a copy of this profile with the given fields replaced with the new values
  ProfileModel copyWith({
    String? userId,
    String? occupation,
    String? education,
    List<String>? languages,
    List<String>? hobbies,
    List<String>? skills,
    Map<String, dynamic>? socialLinks,
    List<String>? photos,
    String? relationshipStatus,
    String? lookingFor,
    int? height,
    List<String>? personalityTraits,
    Map<String, dynamic>? preferences,
    bool? isPublic,
    DateTime? lastUpdated,
  }) {
    return ProfileModel(
      userId: userId ?? this.userId,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      languages: languages ?? this.languages,
      hobbies: hobbies ?? this.hobbies,
      skills: skills ?? this.skills,
      socialLinks: socialLinks ?? this.socialLinks,
      photos: photos ?? this.photos,
      relationshipStatus: relationshipStatus ?? this.relationshipStatus,
      lookingFor: lookingFor ?? this.lookingFor,
      height: height ?? this.height,
      personalityTraits: personalityTraits ?? this.personalityTraits,
      preferences: preferences ?? this.preferences,
      isPublic: isPublic ?? this.isPublic,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Create a profile from a user model
  factory ProfileModel.fromUserModel(UserModel user) {
    return ProfileModel(
      userId: user.id,
      languages: const [],
      hobbies: user.interests,
      skills: const [],
      photos: user.photoUrl != null ? [user.photoUrl!] : const [],
      personalityTraits: const [],
      preferences: const {},
      lastUpdated: DateTime.now(),
    );
  }

  /// Merge this profile with a user model
  UserModel mergeWithUser(UserModel user) {
    return user.copyWith(
      interests: hobbies,
    );
  }

  @override
  List<Object?> get props => [
        userId,
        occupation,
        education,
        languages,
        hobbies,
        skills,
        socialLinks,
        photos,
        relationshipStatus,
        lookingFor,
        height,
        personalityTraits,
        preferences,
        isPublic,
        lastUpdated,
      ];
}
