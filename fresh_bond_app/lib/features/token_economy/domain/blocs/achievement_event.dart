part of 'achievement_bloc.dart';

abstract class AchievementEvent extends Equatable {
  const AchievementEvent();

  @override
  List<Object> get props => [];
}

class FetchAchievementsEvent extends AchievementEvent {
  final String userId;

  const FetchAchievementsEvent({required this.userId});

  @override
  List<Object> get props => [userId];
}

class CheckAchievementsEvent extends AchievementEvent {
  final String userId;
  final String action;
  final Map<String, dynamic>? metadata;

  const CheckAchievementsEvent({
    required this.userId,
    required this.action,
    this.metadata,
  });

  @override
  List<Object> get props => [userId, action];
}

class MarkAchievementViewedEvent extends AchievementEvent {
  final String userId;
  final String achievementId;

  const MarkAchievementViewedEvent({
    required this.userId,
    required this.achievementId,
  });

  @override
  List<Object> get props => [userId, achievementId];
}
