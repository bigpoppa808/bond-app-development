import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/design/components/bond_button.dart';
import 'package:fresh_bond_app/core/design/components/bond_input.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_spacing.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';
import 'package:fresh_bond_app/core/di/service_locator.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'test@bond.app');
  final _passwordController = TextEditingController(text: 'Test123!');
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepository = ServiceLocator.getIt<AuthRepository>();
      await authRepository.signIn(
        _emailController.text.trim(),
        _passwordController.text,
      );
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _createTestAccount() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final authRepository = ServiceLocator.getIt<AuthRepository>();
      await authRepository.signIn('test@bond.app', 'Test123!');
      
      if (mounted) {
        context.go('/home');
      }
    } catch (e) {
      // If login fails, try to create a test account
      try {
        final authRepository = ServiceLocator.getIt<AuthRepository>();
        await authRepository.signUp('test@bond.app', 'Test123!');
        
        if (mounted) {
          context.go('/home');
        }
      } catch (e) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(BondSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and app name
                  const Center(
                    child: Icon(
                      Icons.favorite_rounded,
                      color: BondColors.primary,
                      size: 80,
                    ),
                  ),
                  const SizedBox(height: BondSpacing.md),
                  Center(
                    child: Text(
                      'Bond',
                      style: BondTypography.heading1.copyWith(
                        color: BondColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: BondSpacing.xl),
                  
                  // Login form
                  BondInput(
                    controller: _emailController,
                    label: 'Email',
                    placeholder: 'Enter your email',
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: const Icon(Icons.email_outlined),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: BondSpacing.md),
                  BondInput(
                    controller: _passwordController,
                    label: 'Password',
                    placeholder: 'Enter your password',
                    obscureText: true,
                    prefixIcon: const Icon(Icons.lock_outline),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: BondSpacing.sm),
                  
                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: BondTypography.body2.copyWith(
                          color: BondColors.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: BondSpacing.md),
                  
                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(BondSpacing.sm),
                      decoration: BoxDecoration(
                        color: BondColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: BondTypography.body2.copyWith(
                          color: BondColors.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: BondSpacing.md),
                  ],
                  
                  // Login button
                  BondButton(
                    label: 'Login',
                    onPressed: _isLoading ? null : _login,
                    isLoading: _isLoading,
                    fullWidth: true,
                  ),
                  const SizedBox(height: BondSpacing.md),
                  
                  // Test account button
                  BondButton(
                    label: 'Use Test Account',
                    onPressed: _isLoading ? null : _createTestAccount,
                    isLoading: _isLoading,
                    fullWidth: true,
                    variant: BondButtonVariant.secondary,
                  ),
                  const SizedBox(height: BondSpacing.xl),
                  
                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Don\'t have an account?',
                        style: BondTypography.body2,
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Navigate to sign up screen
                        },
                        child: Text(
                          'Sign Up',
                          style: BondTypography.body2.copyWith(
                            color: BondColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
