part of 'achievement_bloc.dart';

abstract class AchievementState extends Equatable {
  const AchievementState();
  
  @override
  List<Object> get props => [];
}

class AchievementInitial extends AchievementState {}

class AchievementLoading extends AchievementState {}

class AchievementChecking extends AchievementState {}

class AchievementsLoaded extends AchievementState {
  final List<UserAchievement> achievements;
  final int unlockedCount;
  final int viewedCount;

  const AchievementsLoaded({
    required this.achievements,
    required this.unlockedCount,
    required this.viewedCount,
  });

  @override
  List<Object> get props => [achievements, unlockedCount, viewedCount];
}

class AchievementUnlocked extends AchievementState {
  final List<UserAchievement> newAchievements;

  const AchievementUnlocked({
    required this.newAchievements,
  });

  @override
  List<Object> get props => [newAchievements];
}

class AchievementCheckComplete extends AchievementState {}

class AchievementError extends AchievementState {
  final String message;

  const AchievementError({required this.message});

  @override
  List<Object> get props => [message];
}
