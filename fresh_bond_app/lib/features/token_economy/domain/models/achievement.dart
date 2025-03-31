import 'package:equatable/equatable.dart';

/// Model representing an achievement in the token economy system
class Achievement extends Equatable {
  /// Unique ID of the achievement
  final String id;
  
  /// Title of the achievement
  final String title;
  
  /// Description of the achievement
  final String description;
  
  /// Path to the icon asset
  final String iconAsset;
  
  /// Number of tokens rewarded for earning this achievement
  final int tokenReward;
  
  /// Requirements to earn this achievement (stored as key-value pairs)
  final Map<String, dynamic> criteria;

  /// Creates a new achievement
  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconAsset,
    required this.tokenReward,
    required this.criteria,
  });

  /// Creates a copy of this achievement with the given fields replaced
  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconAsset,
    int? tokenReward,
    Map<String, dynamic>? criteria,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconAsset: iconAsset ?? this.iconAsset,
      tokenReward: tokenReward ?? this.tokenReward,
      criteria: criteria ?? this.criteria,
    );
  }

  /// Converts this object to a map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'iconAsset': iconAsset,
      'tokenReward': tokenReward,
      'criteria': criteria,
    };
  }

  /// Creates an achievement from a map
  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as String,
      title: map['title'] as String,
      description: map['description'] as String,
      iconAsset: map['iconAsset'] as String,
      tokenReward: map['tokenReward'] as int,
      criteria: Map<String, dynamic>.from(map['criteria'] as Map),
    );
  }

  @override
  List<Object> get props => [id, title, description, iconAsset, tokenReward, criteria];
}

/// Model representing a user's earned achievement
class UserAchievement extends Equatable {
  /// The user ID who earned the achievement
  final String userId;
  
  /// The ID of the earned achievement
  final String achievementId;
  
  /// When the achievement was earned
  final DateTime earnedAt;
  
  /// Whether this achievement is displayed on the user's profile
  final bool isDisplayed;
  
  /// The title of the achievement
  final String? title;
  
  /// The description of the achievement
  final String? description;
  
  /// The path to the icon asset
  final String? iconAsset;
  
  /// Number of tokens rewarded for earning this achievement
  final int? tokenReward;
  
  /// Whether the achievement is unlocked
  final bool unlocked;
  
  /// When the achievement was unlocked
  final DateTime? unlockedAt;
  
  /// Whether the achievement has been viewed
  final bool viewed;

  /// Creates a new user achievement
  const UserAchievement({
    required this.userId,
    required this.achievementId,
    required this.earnedAt,
    this.isDisplayed = true,
    this.title,
    this.description,
    this.iconAsset,
    this.tokenReward,
    this.unlocked = false,
    this.unlockedAt,
    this.viewed = false,
  });

  /// Creates a copy of this user achievement with the given fields replaced
  UserAchievement copyWith({
    String? userId,
    String? achievementId,
    DateTime? earnedAt,
    bool? isDisplayed,
    String? title,
    String? description,
    String? iconAsset,
    int? tokenReward,
    bool? unlocked,
    DateTime? unlockedAt,
    bool? viewed,
  }) {
    return UserAchievement(
      userId: userId ?? this.userId,
      achievementId: achievementId ?? this.achievementId,
      earnedAt: earnedAt ?? this.earnedAt,
      isDisplayed: isDisplayed ?? this.isDisplayed,
      title: title ?? this.title,
      description: description ?? this.description,
      iconAsset: iconAsset ?? this.iconAsset,
      tokenReward: tokenReward ?? this.tokenReward,
      unlocked: unlocked ?? this.unlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
      viewed: viewed ?? this.viewed,
    );
  }

  /// Converts this object to a map
  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'achievementId': achievementId,
      'earnedAt': earnedAt.millisecondsSinceEpoch,
      'isDisplayed': isDisplayed,
      'title': title,
      'description': description,
      'iconAsset': iconAsset,
      'tokenReward': tokenReward,
      'unlocked': unlocked,
      'unlockedAt': unlockedAt?.millisecondsSinceEpoch,
      'viewed': viewed,
    };
  }

  /// Creates a user achievement from a map
  factory UserAchievement.fromMap(Map<String, dynamic> map) {
    return UserAchievement(
      userId: map['userId'] as String,
      achievementId: map['achievementId'] as String,
      earnedAt: DateTime.fromMillisecondsSinceEpoch(map['earnedAt'] as int),
      isDisplayed: map['isDisplayed'] as bool? ?? true,
      title: map['title'] as String?,
      description: map['description'] as String?,
      iconAsset: map['iconAsset'] as String?,
      tokenReward: map['tokenReward'] as int?,
      unlocked: map['unlocked'] as bool? ?? false,
      unlockedAt: map['unlockedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(map['unlockedAt'] as int) : null,
      viewed: map['viewed'] as bool? ?? false,
    );
  }

  @override
  List<Object?> get props => [
    userId, 
    achievementId, 
    earnedAt, 
    isDisplayed, 
    title, 
    description, 
    iconAsset, 
    tokenReward, 
    unlocked, 
    unlockedAt, 
    viewed
  ];
}