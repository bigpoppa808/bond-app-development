import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/design/bond_colors.dart';
import '../../../../core/design/bond_design_system.dart';
import '../../../../core/design/components/bond_button.dart';
import '../../../../core/design/components/bond_card.dart';
import '../../../../core/design/theme/bond_spacing.dart';
import '../../../../core/di/service_locator.dart';
import '../../domain/blocs/achievement_bloc.dart';
import '../../domain/models/achievement.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({Key? key}) : super(key: key);

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  late AchievementBloc _achievementBloc;
  
  @override
  void initState() {
    super.initState();
    _achievementBloc = ServiceLocator.achievementBloc;
    
    // Get current user ID and fetch achievements
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await ServiceLocator.authRepository.getCurrentUser();
      if (user != null && user.id.isNotEmpty) {
        _achievementBloc.add(FetchAchievementsEvent(userId: user.id));
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Achievements'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: BlocProvider.value(
        value: _achievementBloc,
        child: BlocBuilder<AchievementBloc, AchievementState>(
          builder: (context, state) {
            if (state is AchievementInitial || state is AchievementLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (state is AchievementError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: BondSpacing.md),
                    BondButton(
                      label: 'Retry',
                      onPressed: () async {
                        final user = await ServiceLocator.authRepository.getCurrentUser();
                        final userId = user?.id ?? '';
                        if (userId.isNotEmpty) {
                          _achievementBloc.add(FetchAchievementsEvent(userId: userId));
                        }
                      },
                      variant: BondButtonVariant.secondary,
                    ),
                  ],
                ),
              );
            }
            
            if (state is AchievementsLoaded) {
              final achievements = state.achievements;
              
              if (achievements.isEmpty) {
                return _buildEmptyState();
              }
              
              // Separate unlocked from locked achievements
              final unlockedAchievements = achievements.where((a) => a.unlocked).toList();
              final lockedAchievements = achievements.where((a) => !a.unlocked).toList();
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(BondSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildAchievementStats(state),
                    const SizedBox(height: BondSpacing.lg),
                    if (unlockedAchievements.isNotEmpty) ...[
                      const Text(
                        'Unlocked Achievements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: BondSpacing.md),
                      ...unlockedAchievements.map(_buildAchievementCard),
                      const SizedBox(height: BondSpacing.lg),
                    ],
                    if (lockedAchievements.isNotEmpty) ...[
                      const Text(
                        'Locked Achievements',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: BondSpacing.md),
                      ...lockedAchievements.map(_buildAchievementCard),
                    ],
                  ],
                ),
              );
            }
            
            return const Center(
              child: Text('Something went wrong. Please try again.'),
            );
          },
        ),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events_outlined,
            size: 64,
            color: Colors.grey,
          ),
          const SizedBox(height: BondSpacing.md),
          Text(
            'No achievements yet',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: BondSpacing.sm),
          Text(
            'Start using the app to unlock achievements',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  Widget _buildAchievementStats(AchievementsLoaded state) {
    return BondCard(
      child: Padding(
        padding: const EdgeInsets.all(BondSpacing.md),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildStatItem(
              label: 'Total',
              value: state.achievements.length.toString(),
              icon: Icons.emoji_events,
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            _buildStatItem(
              label: 'Unlocked',
              value: state.unlockedCount.toString(),
              icon: Icons.lock_open,
              color: Colors.green,
            ),
            Container(
              height: 40,
              width: 1,
              color: Colors.grey[300],
            ),
            _buildStatItem(
              label: 'Locked',
              value: (state.achievements.length - state.unlockedCount).toString(),
              icon: Icons.lock,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    Color? color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color ?? Colors.blue,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
  
  Widget _buildAchievementCard(UserAchievement achievement) {
    final isUnlocked = achievement.unlocked;
    final dateFormat = DateFormat('MMM d, yyyy');
    final formattedDate = isUnlocked
        ? dateFormat.format(achievement.unlockedAt!)
        : '';
    
    return BondCard(
      padding: const EdgeInsets.all(BondSpacing.md),
      child: Padding(
        padding: const EdgeInsets.all(BondSpacing.md),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: isUnlocked ? Colors.blue.withOpacity(0.2) : Colors.grey[200],
                borderRadius: BorderRadius.circular(BondSpacing.md),
              ),
              child: Icon(
                Icons.emoji_events,
                color: isUnlocked ? Colors.blue : Colors.grey,
                size: 32,
              ),
            ),
            const SizedBox(width: BondSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    achievement.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    achievement.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  if (isUnlocked)
                    Text(
                      'Unlocked on $formattedDate',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: BondSpacing.md),
            if (!isUnlocked)
              const Icon(
                Icons.lock,
                color: Colors.grey,
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: BondSpacing.md,
                  vertical: BondSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(BondSpacing.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.token,
                      size: 16,
                      color: Colors.blue,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '+${achievement.tokenReward}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}