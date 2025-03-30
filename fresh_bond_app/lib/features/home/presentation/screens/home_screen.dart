import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/theme.dart';
import 'package:fresh_bond_app/core/analytics/analytics_service.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_bloc.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_event.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_state.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Log screen view for analytics
    AnalyticsService.instance.logScreen('home');
  }

  void _navigateToProfile() {
    context.push('/profile');
  }
  
  void _navigateToDiscover() {
    context.push('/discover');
  }
  
  void _navigateToConnections() {
    context.push('/connections');
  }
  
  void _navigateToMessages() {
    context.push('/messages');
  }
  
  void _signOut() {
    context.read<AuthBloc>().add(const AuthSignOutEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => current is AuthUnauthenticatedState,
      listener: (context, state) {
        if (state is AuthUnauthenticatedState) {
          context.go('/login');
        }
      },
      child: Scaffold(
        backgroundColor: BondAppTheme.backgroundPrimary,
        appBar: AppBar(
          title: const Text('Home'),
          backgroundColor: BondAppTheme.backgroundSecondary,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.person),
              onPressed: _navigateToProfile,
              tooltip: 'Profile',
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: _signOut,
              tooltip: 'Sign Out',
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome section
                BlocBuilder<AuthBloc, AuthState>(
                  buildWhen: (previous, current) => current is AuthAuthenticatedState,
                  builder: (context, state) {
                    String displayName = 'Friend';
                    if (state is AuthAuthenticatedState && state.user.displayName != null) {
                      displayName = state.user.displayName!;
                    }
                    
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome, $displayName',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: BondAppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Stay connected with your loved ones',
                          style: TextStyle(
                            color: BondAppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    );
                  },
                ),
                
                const SizedBox(height: 32),
                
                // Quick actions grid
                Text(
                  'Quick Actions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BondAppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                GridView.count(
                  shrinkWrap: true,
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  children: [
                    _buildQuickActionCard(
                      context,
                      icon: Icons.people,
                      title: 'Connections',
                      description: 'View and manage your connections',
                      onTap: _navigateToConnections,
                    ),
                    _buildQuickActionCard(
                      context,
                      icon: Icons.message,
                      title: 'Messages',
                      description: 'Check your messages',
                      onTap: _navigateToMessages,
                    ),
                    _buildQuickActionCard(
                      context,
                      icon: Icons.search,
                      title: 'Discover',
                      description: 'Find new connections',
                      onTap: _navigateToDiscover,
                    ),
                    _buildQuickActionCard(
                      context,
                      icon: Icons.event,
                      title: 'Events',
                      description: 'Upcoming events',
                      onTap: () {},
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Recent activity
                Text(
                  'Recent Activity',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: BondAppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Placeholder for recent activity
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: BondAppTheme.backgroundSecondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.notifications_off,
                          color: BondAppTheme.textSecondary,
                          size: 48,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No recent activity',
                          style: TextStyle(
                            color: BondAppTheme.textSecondary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: 0, // Home is selected
          selectedItemColor: BondAppTheme.primaryColor,
          unselectedItemColor: BondAppTheme.textSecondary,
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
      ),
    );
  }
  
  Widget _buildQuickActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: BondAppTheme.backgroundSecondary,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: BondAppTheme.primaryColor,
              size: 40,
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: BondAppTheme.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
