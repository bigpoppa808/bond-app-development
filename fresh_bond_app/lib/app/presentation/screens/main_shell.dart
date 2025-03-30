import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/theme.dart';
import 'package:fresh_bond_app/core/analytics/analytics_service.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_bloc.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_event.dart';
import 'package:fresh_bond_app/features/discover/presentation/screens/discover_screen.dart';
import 'package:fresh_bond_app/features/home/presentation/screens/home_screen.dart';
import 'package:fresh_bond_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:go_router/go_router.dart';

/// Shell screen that contains the bottom navigation and hosts the main app screens
class MainShell extends StatefulWidget {
  final int initialIndex;
  
  const MainShell({
    super.key,
    this.initialIndex = 0,
  });

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int _currentIndex;
  
  // Define the screens
  final List<Widget> _screens = [
    const HomeScreen(),
    const DiscoverScreen(),
    const ProfileScreen(),
  ];
  
  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        selectedItemColor: BondAppTheme.primaryColor,
        unselectedItemColor: BondAppTheme.textSecondary,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'Discover',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
  
  void _onTabTapped(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      
      // Track screen view
      AnalyticsService.instance.logScreen(_getScreenName(index));
      
      // Update the URL to reflect the current tab
      _updateRoute(index);
    }
  }
  
  String _getScreenName(int index) {
    switch (index) {
      case 0:
        return 'home';
      case 1:
        return 'discover';
      case 2:
        return 'profile';
      default:
        return 'unknown';
    }
  }
  
  void _updateRoute(int index) {
    final String path;
    switch (index) {
      case 0:
        path = '/home';
        break;
      case 1:
        path = '/discover';
        break;
      case 2:
        path = '/profile';
        break;
      default:
        path = '/home';
    }
    
    // Update URL without triggering a new navigation
    context.go(path);
  }
}
