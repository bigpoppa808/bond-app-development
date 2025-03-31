import 'package:flutter/material.dart';
import '../../../../core/design/bond_colors.dart';
import '../../../../core/design/bond_typography.dart';
import '../../../../core/design/components/bond_avatar.dart';
import '../../../../core/design/components/bond_button.dart';
import '../../../../core/design/components/bond_card.dart';
import '../../../../core/design/components/bond_badge.dart';
import '../../../../core/design/components/bond_chip.dart';
import '../../../auth/data/dummy_account_service.dart';

/// Demo home screen for testing purposes
class DemoHomeScreen extends StatelessWidget {
  const DemoHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the demo user
    final dummyService = DummyAccountService();
    final user = dummyService.getUserByEmail('demo@bond.app');
    final allUsers = dummyService.getAllUsers()
        .where((u) => u.email != 'demo@bond.app')
        .toList();

    return Scaffold(
      backgroundColor: BondColors.snow,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Bond',
          style: BondTypography.heading2(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Navigate to notifications
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: BondAvatar(
              size: BondAvatarSize.sm,
              imageUrl: user?.photoUrl,
              initials: user?.displayName.substring(0, 2) ?? 'U',
              onTap: () {
                // Navigate to profile
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome section
              Text(
                'Welcome back,',
                style: BondTypography.bodyLarge(context),
              ),
              Text(
                user?.displayName ?? 'User',
                style: BondTypography.heading1(context),
              ),
              const SizedBox(height: 24),
              
              // Stats card
              BondCard(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStat(context, 'Connections', user?.connections.toString() ?? '0'),
                      _buildStat(context, 'Pending', '3'),
                      _buildStat(context, 'Bond Score', '87'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // Suggested connections
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suggested Connections',
                    style: BondTypography.heading3(context),
                  ),
                  TextButton(
                    onPressed: () {
                      // View all
                    },
                    child: Text(
                      'View All',
                      style: BondTypography.body(context).copyWith(
                        color: BondColors.bondTeal,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Connection cards
              SizedBox(
                height: 220,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: allUsers.length,
                  itemBuilder: (context, index) {
                    final suggestedUser = allUsers[index];
                    return _buildConnectionCard(context, suggestedUser);
                  },
                ),
              ),
              const SizedBox(height: 32),
              
              // Recent activity
              Text(
                'Recent Activity',
                style: BondTypography.heading3(context),
              ),
              const SizedBox(height: 16),
              
              // Activity list
              _buildActivityItem(
                context,
                'Jordan Smith liked your post',
                '2 hours ago',
                Icons.favorite,
                BondColors.error,
              ),
              _buildActivityItem(
                context,
                'New connection request from Taylor Wong',
                '5 hours ago',
                Icons.person_add,
                BondColors.bondTeal,
              ),
              _buildActivityItem(
                context,
                'Your connection with Alex Johnson is celebrating 1 month!',
                'Yesterday',
                Icons.celebration,
                BondColors.warmthOrange,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: BondColors.bondTeal,
        unselectedItemColor: BondColors.slate,
        type: BottomNavigationBarType.fixed,
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
            icon: Icon(Icons.message),
            label: 'Messages',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: BondTypography.heading2(context),
        ),
        Text(
          label,
          style: BondTypography.bodySmall(context).copyWith(
            color: BondColors.slate,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectionCard(BuildContext context, DummyUser user) {
    return Container(
      width: 180,
      margin: const EdgeInsets.only(right: 16),
      child: BondCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              BondAvatar(
                size: BondAvatarSize.lg,
                imageUrl: user.photoUrl,
                initials: user.displayName.substring(0, 2),
              ),
              const SizedBox(height: 12),
              Text(
                user.displayName,
                style: BondTypography.heading3(context),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 4),
              if (user.interests.isNotEmpty)
                Text(
                  user.interests.first,
                  style: BondTypography.bodySmall(context).copyWith(
                    color: BondColors.slate,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              const SizedBox(height: 12),
              BondButton(
                label: 'Connect',
                variant: BondButtonVariant.secondary,
                onPressed: () {
                  // Send connection request
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivityItem(
    BuildContext context,
    String title,
    String time,
    IconData icon,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BondTypography.body(context),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: BondTypography.bodySmall(context).copyWith(
                    color: BondColors.slate,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
