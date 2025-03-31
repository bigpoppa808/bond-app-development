import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/bond_colors.dart';
import '../../../../core/design/bond_typography.dart';
import '../../../../core/design/components/bond_button.dart';
import '../../../../core/design/components/bond_input.dart';
import '../../data/dummy_account_service.dart';

/// Demo login screen for testing purposes
class DemoLoginScreen extends StatefulWidget {
  const DemoLoginScreen({Key? key}) : super(key: key);

  @override
  State<DemoLoginScreen> createState() => _DemoLoginScreenState();
}

class _DemoLoginScreenState extends State<DemoLoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late GlobalKey<FormState> _formKey;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: 'demo@bond.app');
    _passwordController = TextEditingController(text: 'password123');
    _formKey = GlobalKey<FormState>();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email and password';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final dummyService = DummyAccountService();
      final user = await dummyService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (user != null) {
        if (!mounted) return;
        
        // Navigate to home screen on successful login using GoRouter
        GoRouter.of(context).go('/demo-home');
        
        // Show a welcome toast
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome back, ${user.displayName}!'),
            backgroundColor: BondColors.bondTeal,
          ),
        );
      } else {
        setState(() {
          _errorMessage = 'Invalid email or password';
        });
      }
    } on Exception catch (e) {
      setState(() {
        _errorMessage = 'An error occurred. Please try again.';
      });
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
      backgroundColor: BondColors.snow,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo and title
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 80,
                          color: BondColors.bondTeal,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Bond',
                          style: BondTypography.display(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connect with purpose',
                          style: BondTypography.body(context).copyWith(
                            color: BondColors.slate,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Demo account notice
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: BondColors.bondTeal.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Demo Account',
                          style: BondTypography.heading3(context),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Use the pre-filled credentials to log in with a demo account.',
                          style: BondTypography.body(context),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: BondColors.error.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: BondTypography.body(context).copyWith(
                          color: BondColors.error,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Email input
                  BondInput(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    errorText: _emailController.text.isEmpty ? 'Please enter your email' : null,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password input
                  BondInput(
                    controller: _passwordController,
                    label: 'Password',
                    obscureText: true,
                    errorText: _passwordController.text.isEmpty ? 'Please enter your password' : null,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login button
                  BondButton(
                    label: 'Log In',
                    onPressed: _isLoading ? null : _login,
                    isLoading: _isLoading,
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Register link
                  Center(
                    child: TextButton(
                      onPressed: () {
                        GoRouter.of(context).go('/register');
                      },
                      child: Text(
                        'Don\'t have an account? Sign up',
                        style: BondTypography.body(context).copyWith(
                          color: BondColors.bondTeal,
                        ),
                      ),
                    ),
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
