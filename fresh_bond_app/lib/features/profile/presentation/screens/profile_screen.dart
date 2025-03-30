import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/app/theme.dart';
import 'package:fresh_bond_app/core/analytics/analytics_service.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_bloc.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_event.dart';
import 'package:fresh_bond_app/features/auth/domain/blocs/auth_state.dart';
import 'package:fresh_bond_app/features/auth/domain/models/user_model.dart';
import 'package:fresh_bond_app/shared/widgets/bond_button.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _bioController = TextEditingController();
    
    // Load user data
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticatedState) {
      _nameController.text = authState.user.displayName ?? '';
      // In a real implementation, bio would be loaded from the user data
      _bioController.text = 'I love using the Bond app!';
    }
    
    // Log screen view
    AnalyticsService.instance.logScreen('profile');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      // In a real implementation, this would update the profile in a repository
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: BondAppTheme.successColor,
        ),
      );
      
      _toggleEdit();
      
      // Log event
      AnalyticsService.instance.logEvent('profile_updated');
    }
  }

  void _signOut() {
    context.read<AuthBloc>().add(const AuthSignOutEvent());
    AnalyticsService.instance.logEvent('sign_out');
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthUnauthenticatedState) {
          context.go('/login');
        }
      },
      builder: (context, state) {
        UserModel? user;
        if (state is AuthAuthenticatedState) {
          user = state.user;
        }
        
        return Scaffold(
          backgroundColor: BondAppTheme.backgroundPrimary,
          appBar: AppBar(
            title: const Text('Profile'),
            backgroundColor: BondAppTheme.backgroundSecondary,
            elevation: 0,
            actions: [
              IconButton(
                icon: Icon(_isEditing ? Icons.close : Icons.edit),
                onPressed: _isEditing ? _toggleEdit : _toggleEdit,
                tooltip: _isEditing ? 'Cancel' : 'Edit Profile',
              ),
            ],
          ),
          body: SafeArea(
            child: user == null
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(24.0),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Profile picture
                          Hero(
                            tag: 'profile_picture',
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: BondAppTheme.primaryColor.withOpacity(0.1),
                              child: Icon(
                                Icons.person,
                                size: 60,
                                color: BondAppTheme.primaryColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Change profile picture button (disabled in editing mode)
                          if (_isEditing)
                            TextButton.icon(
                              onPressed: () {
                                // This would open a picture selector in a real implementation
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Feature coming soon'),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.camera_alt),
                              label: const Text('Change Picture'),
                              style: TextButton.styleFrom(
                                foregroundColor: BondAppTheme.primaryColor,
                              ),
                            ),
                          const SizedBox(height: 24),
                          
                          // Name field
                          if (_isEditing)
                            TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Name',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            )
                          else
                            Text(
                              _nameController.text.isNotEmpty
                                  ? _nameController.text
                                  : 'No name set',
                              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: BondAppTheme.textPrimary,
                              ),
                            ),
                          const SizedBox(height: 8),
                          
                          // Email (always read-only)
                          Text(
                            user.email,
                            style: TextStyle(
                              color: BondAppTheme.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 32),
                          
                          // Bio section
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              'About',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: BondAppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          if (_isEditing)
                            TextFormField(
                              controller: _bioController,
                              decoration: const InputDecoration(
                                labelText: 'Bio',
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.description_outlined),
                              ),
                              maxLines: 3,
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: BondAppTheme.backgroundSecondary,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                _bioController.text.isNotEmpty
                                    ? _bioController.text
                                    : 'No bio added yet',
                                style: TextStyle(
                                  color: _bioController.text.isNotEmpty
                                      ? BondAppTheme.textPrimary
                                      : BondAppTheme.textSecondary,
                                ),
                              ),
                            ),
                          const SizedBox(height: 32),
                          
                          // Action buttons
                          if (_isEditing)
                            BondButton(
                              text: 'Save Changes',
                              onPressed: _saveProfile,
                            )
                          else
                            Column(
                              children: [
                                // Settings section
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    'Settings',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: BondAppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                // Settings list
                                _buildSettingsItem(
                                  icon: Icons.notifications_outlined,
                                  title: 'Notifications',
                                  onTap: () {
                                    // Would navigate to notifications settings
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Feature coming soon'),
                                      ),
                                    );
                                  },
                                ),
                                _buildSettingsItem(
                                  icon: Icons.lock_outline,
                                  title: 'Privacy',
                                  onTap: () {
                                    // Would navigate to privacy settings
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Feature coming soon'),
                                      ),
                                    );
                                  },
                                ),
                                _buildSettingsItem(
                                  icon: Icons.help_outline,
                                  title: 'Help & Support',
                                  onTap: () {
                                    // Would navigate to help/support
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Feature coming soon'),
                                      ),
                                    );
                                  },
                                ),
                                _buildSettingsItem(
                                  icon: Icons.info_outline,
                                  title: 'About',
                                  onTap: () {
                                    // Would navigate to about screen
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Feature coming soon'),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(height: 16),
                                
                                // Sign out button
                                BondButton(
                                  text: 'Sign Out',
                                  onPressed: _signOut,
                                  type: BondButtonType.outline,
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
          ),
        );
      },
    );
  }
  
  Widget _buildSettingsItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: BondAppTheme.primaryColor),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }
}
