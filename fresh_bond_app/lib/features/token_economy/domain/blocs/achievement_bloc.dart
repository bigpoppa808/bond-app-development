import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/achievement.dart';
import '../repositories/achievement_repository.dart';

part 'achievement_event.dart';
part 'achievement_state.dart';

class AchievementBloc extends Bloc<AchievementEvent, AchievementState> {
  final AchievementRepository achievementRepository;

  AchievementBloc({required this.achievementRepository})
      : super(AchievementInitial()) {
    on<FetchAchievementsEvent>(_onFetchAchievements);
    on<CheckAchievementsEvent>(_onCheckAchievements);
    on<MarkAchievementViewedEvent>(_onMarkAchievementViewed);
  }

  Future<void> _onFetchAchievements(
      FetchAchievementsEvent event, Emitter<AchievementState> emit) async {
    try {
      emit(AchievementLoading());

      final achievements = await achievementRepository.getUserAchievements(
        event.userId,
      );

      emit(AchievementsLoaded(
        achievements: achievements,
        unlockedCount: achievements.where((a) => a.unlocked).length,
        viewedCount: achievements.where((a) => a.viewed).length,
      ));
    } catch (e) {
      emit(AchievementError(
          message: 'Failed to fetch achievements: ${e.toString()}'));
    }
  }

  Future<void> _onCheckAchievements(
      CheckAchievementsEvent event, Emitter<AchievementState> emit) async {
    try {
      emit(AchievementChecking());

      final newlyUnlocked =
          await achievementRepository.checkAndUpdateAchievements(
        userId: event.userId,
        action: event.action,
        metadata: event.metadata,
      );

      if (newlyUnlocked.isNotEmpty) {
        emit(AchievementUnlocked(
          newAchievements: newlyUnlocked,
        ));
      } else {
        emit(AchievementCheckComplete());
      }
    } catch (e) {
      emit(AchievementError(
          message: 'Failed to check achievements: ${e.toString()}'));
    }
  }

  Future<void> _onMarkAchievementViewed(
      MarkAchievementViewedEvent event, Emitter<AchievementState> emit) async {
    try {
      await achievementRepository.markAchievementViewed(
        userId: event.userId,
        achievementId: event.achievementId,
      );

      // Refresh the achievements list
      add(FetchAchievementsEvent(userId: event.userId));
    } catch (e) {
      emit(AchievementError(
          message: 'Failed to mark achievement as viewed: ${e.toString()}'));
    }
  }
}
