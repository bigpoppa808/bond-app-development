import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/theme.dart';
import 'package:fresh_bond_app/core/analytics/analytics_service.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_bloc.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_event.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_state.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation setup
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );
    
    _animationController.forward();
    
    // Log screen view
    AnalyticsService.instance.logScreen('splash');
    
    // Check authentication status after a short delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        context.read<AuthBloc>().add(AuthCheckStatusEvent());
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _navigateToNextScreen(AuthState state) {
    if (state is AuthAuthenticatedState) {
      context.go('/home');
    } else if (state is AuthUnauthenticatedState) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticatedState || state is AuthUnauthenticatedState) {
          _navigateToNextScreen(state);
        }
      },
      child: Scaffold(
        backgroundColor: BondAppTheme.backgroundPrimary,
        body: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                const Icon(
                  Icons.favorite,
                  color: BondAppTheme.primaryColor,
                  size: 100,
                ),
                const SizedBox(height: 24),
                
                // App name
                Text(
                  'Bond',
                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                    color: BondAppTheme.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 8),
                Text(
                  'Connect with your loved ones',
                  style: TextStyle(
                    color: BondAppTheme.textSecondary,
                    fontSize: 16,
                  ),
                ),
                
                const SizedBox(height: 64),
                
                // Loading indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(BondAppTheme.primaryColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
