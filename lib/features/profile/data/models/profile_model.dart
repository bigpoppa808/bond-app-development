import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:bond_app/features/auth/data/models/user_model.dart';

/// Enum for different privacy levels
enum PrivacyLevel {
  /// Visible to everyone
  public,
  
  /// Visible only to connections
  connectionsOnly,
  
  /// Visible only to the user
  private,
}

/// Model for user profile privacy settings
class ProfilePrivacySettings extends Equatable {
  /// Whether the profile is discoverable in search
  final bool discoverable;
  
  /// Privacy level for the user's contact information
  final PrivacyLevel contactInfoPrivacy;
  
  /// Privacy level for the user's interests
  final PrivacyLevel interestsPrivacy;
  
  /// Privacy level for the user's photos
  final PrivacyLevel photosPrivacy;
  
  /// Whether to show online status
  final bool showOnlineStatus;
  
  /// Whether to show location
  final bool showLocation;

  /// Constructor
  const ProfilePrivacySettings({
    this.discoverable = true,
    this.contactInfoPrivacy = PrivacyLevel.connectionsOnly,
    this.interestsPrivacy = PrivacyLevel.public,
    this.photosPrivacy = PrivacyLevel.public,
    this.showOnlineStatus = true,
    this.showLocation = true,
  });

  /// Factory constructor for creating a ProfilePrivacySettings from a Map
  factory ProfilePrivacySettings.fromMap(Map<String, dynamic> map) {
    return ProfilePrivacySettings(
      discoverable: map['discoverable'] ?? true,
      contactInfoPrivacy: PrivacyLevel.values.firstWhere(
        (e) => e.toString() == map['contactInfoPrivacy'],
        orElse: () => PrivacyLevel.connectionsOnly,
      ),
      interestsPrivacy: PrivacyLevel.values.firstWhere(
        (e) => e.toString() == map['interestsPrivacy'],
        orElse: () => PrivacyLevel.public,
      ),
      photosPrivacy: PrivacyLevel.values.firstWhere(
        (e) => e.toString() == map['photosPrivacy'],
        orElse: () => PrivacyLevel.public,
      ),
      showOnlineStatus: map['showOnlineStatus'] ?? true,
      showLocation: map['showLocation'] ?? true,
    );
  }

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'discoverable': discoverable,
      'contactInfoPrivacy': contactInfoPrivacy.toString(),
      'interestsPrivacy': interestsPrivacy.toString(),
      'photosPrivacy': photosPrivacy.toString(),
      'showOnlineStatus': showOnlineStatus,
      'showLocation': showLocation,
    };
  }

  /// Create a copy of this ProfilePrivacySettings with given fields replaced with new values
  ProfilePrivacySettings copyWith({
    bool? discoverable,
    PrivacyLevel? contactInfoPrivacy,
    PrivacyLevel? interestsPrivacy,
    PrivacyLevel? photosPrivacy,
    bool? showOnlineStatus,
    bool? showLocation,
  }) {
    return ProfilePrivacySettings(
      discoverable: discoverable ?? this.discoverable,
      contactInfoPrivacy: contactInfoPrivacy ?? this.contactInfoPrivacy,
      interestsPrivacy: interestsPrivacy ?? this.interestsPrivacy,
      photosPrivacy: photosPrivacy ?? this.photosPrivacy,
      showOnlineStatus: showOnlineStatus ?? this.showOnlineStatus,
      showLocation: showLocation ?? this.showLocation,
    );
  }

  /// Default privacy settings
  static ProfilePrivacySettings get defaults => const ProfilePrivacySettings();

  @override
  List<Object?> get props => [
        discoverable,
        contactInfoPrivacy,
        interestsPrivacy,
        photosPrivacy,
        showOnlineStatus,
        showLocation,
      ];
}

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
  final ProfilePrivacySettings privacySettings;
  final DateTime lastUpdated;
  final double? latitude;
  final double? longitude;
  final bool isLocationTrackingEnabled;
  final DateTime? lastLocationUpdate;

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
    this.privacySettings = const ProfilePrivacySettings(),
    required this.lastUpdated,
    this.latitude,
    this.longitude,
    this.isLocationTrackingEnabled = true,
    this.lastLocationUpdate,
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
      isPublic: true,
      privacySettings: const ProfilePrivacySettings(),
      lastUpdated: DateTime.now(),
      isLocationTrackingEnabled: true,
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
      privacySettings: data['privacySettings'] != null
          ? ProfilePrivacySettings.fromMap(data['privacySettings'])
          : ProfilePrivacySettings.defaults,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate() ?? DateTime.now(),
      latitude: data['latitude'] as double?,
      longitude: data['longitude'] as double?,
      isLocationTrackingEnabled: data['isLocationTrackingEnabled'] as bool? ?? true,
      lastLocationUpdate: (data['lastLocationUpdate'] as Timestamp?)?.toDate(),
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
      'privacySettings': privacySettings.toMap(),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'latitude': latitude,
      'longitude': longitude,
      'isLocationTrackingEnabled': isLocationTrackingEnabled,
      'lastLocationUpdate': lastLocationUpdate != null ? Timestamp.fromDate(lastLocationUpdate!) : null,
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
    ProfilePrivacySettings? privacySettings,
    DateTime? lastUpdated,
    double? latitude,
    double? longitude,
    bool? isLocationTrackingEnabled,
    DateTime? lastLocationUpdate,
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
      privacySettings: privacySettings ?? this.privacySettings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      isLocationTrackingEnabled: isLocationTrackingEnabled ?? this.isLocationTrackingEnabled,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
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
      privacySettings: const ProfilePrivacySettings(),
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
        privacySettings,
        lastUpdated,
        latitude,
        longitude,
        isLocationTrackingEnabled,
        lastLocationUpdate,
      ];
}
