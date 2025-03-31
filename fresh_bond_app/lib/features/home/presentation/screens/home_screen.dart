import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/design/components/bond_avatar.dart';
import 'package:fresh_bond_app/core/design/components/bond_button.dart';
import 'package:fresh_bond_app/core/design/components/bond_card.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_spacing.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';
import 'package:fresh_bond_app/core/di/service_locator.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final authRepository = ServiceLocator.getIt<AuthRepository>();
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        // User data loaded successfully
        setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading user data: $e');
    }
  }

  void _navigateToProfile() {
    context.go('/profile');
  }
  
  void _navigateToDiscover() {
    context.go('/discover');
  }
  
  void _navigateToMessages() {
    context.go('/messages');
  }
  
  void _navigateToTokenWallet() {
    context.go('/tokens');
  }
  
  void _navigateToAchievements() {
    context.go('/achievements');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondColors.background,
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: BondColors.backgroundSecondary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: _navigateToProfile,
            tooltip: 'Profile',
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutEvent());
            },
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(BondSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome to Bond',
                style: BondTypography.heading1,
              ),
              const SizedBox(height: BondSpacing.sm),
              Text(
                'Connect with like-minded people and build meaningful relationships',
                style: BondTypography.body1,
              ),
              const SizedBox(height: BondSpacing.xl),
              
              // Quick actions
              BondCard(
                padding: const EdgeInsets.all(BondSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quick Actions',
                      style: BondTypography.heading3,
                    ),
                    const SizedBox(height: BondSpacing.md),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildQuickAction(
                          icon: Icons.explore,
                          label: 'Discover',
                          onTap: _navigateToDiscover,
                        ),
                        _buildQuickAction(
                          icon: Icons.people,
                          label: 'Connections',
                          onTap: () {},
                        ),
                        _buildQuickAction(
                          icon: Icons.chat,
                          label: 'Messages',
                          onTap: _navigateToMessages,
                        ),
                        _buildQuickAction(
                          icon: Icons.person,
                          label: 'Profile',
                          onTap: _navigateToProfile,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BondSpacing.lg),
              
              // Suggested connections
              Text(
                'Suggested Connections',
                style: BondTypography.heading2,
              ),
              const SizedBox(height: BondSpacing.md),
              SizedBox(
                height: 200,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildConnectionCard(
                      name: 'Alex Johnson',
                      bio: 'Software Engineer',
                      interests: ['Technology', 'Music', 'Travel'],
                    ),
                    _buildConnectionCard(
                      name: 'Sarah Williams',
                      bio: 'UX Designer',
                      interests: ['Design', 'Art', 'Photography'],
                    ),
                    _buildConnectionCard(
                      name: 'Michael Brown',
                      bio: 'Marketing Specialist',
                      interests: ['Marketing', 'Business', 'Networking'],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: BondSpacing.lg),
              
              // Token Economy cards
              Text(
                'Token Economy',
                style: BondTypography.heading2,
              ),
              const SizedBox(height: BondSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: _buildTokenEconomyCard(
                      title: 'Bond Tokens',
                      icon: Icons.token,
                      value: '125',
                      subtitle: 'Current Balance',
                      onTap: _navigateToTokenWallet,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  const SizedBox(width: BondSpacing.md),
                  Expanded(
                    child: _buildTokenEconomyCard(
                      title: 'Achievements',
                      icon: Icons.emoji_events,
                      value: '3/12',
                      subtitle: 'Completed',
                      onTap: _navigateToAchievements,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFF53844), Color(0xFFFF7676)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: BondSpacing.lg),
              
              // Recent activity
              Text(
                'Recent Activity',
                style: BondTypography.heading2,
              ),
              const SizedBox(height: BondSpacing.md),
              _buildActivityItem(
                avatar: 'https://i.pravatar.cc/150?img=1',
                name: 'Alex Johnson',
                action: 'connected with you',
                timeAgo: '2h ago',
              ),
              _buildActivityItem(
                avatar: 'https://i.pravatar.cc/150?img=2',
                name: 'Sarah Williams',
                action: 'viewed your profile',
                timeAgo: '4h ago',
              ),
              _buildActivityItem(
                avatar: 'https://i.pravatar.cc/150?img=3',
                name: 'Michael Brown',
                action: 'sent you a message',
                timeAgo: '1d ago',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Home is selected
        selectedItemColor: BondColors.primaryColor,
        unselectedItemColor: BondColors.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0: // Already on Home
              break;
            case 1:
              _navigateToDiscover();
              break;
            case 2:
              _navigateToMessages();
              break;
            case 3:
              _navigateToProfile();
              break;
          }
        },
      ),
    );
  }
  
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(BondSpacing.sm),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(BondSpacing.sm),
              decoration: BoxDecoration(
                color: BondColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: BondColors.primary,
                size: 24,
              ),
            ),
            const SizedBox(height: BondSpacing.xs),
            Text(
              label,
              style: BondTypography.body2,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildConnectionCard({
    required String name,
    required String bio,
    required List<String> interests,
  }) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: BondSpacing.md),
      child: BondCard(
        padding: const EdgeInsets.all(BondSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const BondAvatar(
              size: BondAvatarSize.lg,
              imageUrl: null,
            ),
            const SizedBox(height: BondSpacing.sm),
            Text(
              name,
              style: BondTypography.heading4,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BondSpacing.xs),
            Text(
              bio,
              style: BondTypography.body2,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: BondSpacing.sm),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: interests
                  .map((interest) => Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: BondColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          interest,
                          style: BondTypography.caption.copyWith(
                            color: BondColors.primary,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const Spacer(),
            BondButton(
              label: 'Connect',
              variant: BondButtonVariant.secondary,
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildActivityItem({
    required String avatar,
    required String name,
    required String action,
    required String timeAgo,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: BondSpacing.md),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(avatar),
            radius: 20,
          ),
          const SizedBox(width: BondSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: BondTypography.body2.copyWith(
                      color: BondColors.text,
                    ),
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(text: ' $action'),
                    ],
                  ),
                ),
                Text(
                  timeAgo,
                  style: BondTypography.caption.copyWith(
                    color: BondColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTokenEconomyCard({
    required String title,
    required IconData icon,
    required String value,
    required String subtitle,
    required VoidCallback onTap,
    required Gradient gradient,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(BondSpacing.md),
      child: Container(
        height: 140,
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(BondSpacing.md),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(BondSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Icon(
                    icon,
                    color: Colors.white,
                    size: 24,
                  ),
                ],
              ),
              const Spacer(),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
