import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/di/service_locator.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

/// Shell screen that contains the bottom navigation and hosts the main app screens
class MainShell extends StatefulWidget {
  final Widget child;
  
  const MainShell({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  
  // Define the routes for each tab
  final List<String> _routes = [
    '/home',
    '/discover',
    '/messages',
    '/meetings',
    '/notifications',
    '/profile',
  ];
  
  @override
  void initState() {
    super.initState();
    // Set initial index based on current location
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final location = GoRouterState.of(context).matchedLocation;
      final index = _routes.indexOf(location);
      if (index != -1 && index != _currentIndex) {
        setState(() {
          _currentIndex = index;
        });
      }
    });
  }
  
  void _onTabTapped(int index) {
    if (index == _currentIndex) return;
    
    setState(() {
      _currentIndex = index;
    });
    
    // Navigate to the selected tab
    context.go(_routes[index]);
  }
  
  void _signOut() async {
    try {
      final authRepository = ServiceLocator.getIt<AuthRepository>();
      await authRepository.signOut();
      
      if (mounted) {
        context.go('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error signing out: ${e.toString()}'),
          backgroundColor: BondColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bond'),
        backgroundColor: BondColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Logout button for testing
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _signOut,
            tooltip: 'Sign Out',
          ),
        ],
      ),
      body: widget.child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabTapped,
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 8,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.explore_outlined),
            selectedIcon: Icon(Icons.explore),
            label: 'Discover',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_outlined),
            selectedIcon: Icon(Icons.chat),
            label: 'Messages',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Notifications',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outlined),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
