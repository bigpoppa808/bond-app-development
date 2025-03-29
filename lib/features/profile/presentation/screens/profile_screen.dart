import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:bond_app/features/profile/presentation/widgets/profile_photo_grid.dart';

/// Screen that displays the user's profile information
class ProfileScreen extends StatefulWidget {
  /// Constructor
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _phoneController = TextEditingController();
  final _interestsController = TextEditingController();
  bool _isEditing = false;

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    _interestsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              if (state is ProfileLoaded) {
                return Row(
                  children: [
                    IconButton(
                      icon: Icon(_isEditing ? Icons.save : Icons.edit),
                      onPressed: () {
                        if (_isEditing) {
                          if (_formKey.currentState?.validate() ?? false) {
                            final updatedProfile = state.profile.copyWith(
                              occupation: _nameController.text,
                              bio: _bioController.text,
                              phoneNumber: _phoneController.text,
                              hobbies: _interestsController.text
                                  .split(',')
                                  .map((e) => e.trim())
                                  .where((e) => e.isNotEmpty)
                                  .toList(),
                              lastUpdated: DateTime.now(),
                            );
                            context
                                .read<ProfileBloc>()
                                .add(UpdateProfile(updatedProfile));
                          }
                        }
                        setState(() {
                          _isEditing = !_isEditing;
                          if (_isEditing) {
                            _nameController.text = state.profile.occupation ?? '';
                            _bioController.text = state.profile.bio ?? '';
                            _phoneController.text = state.profile.phoneNumber ?? '';
                            _interestsController.text =
                                state.profile.hobbies.join(', ');
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.logout),
                      onPressed: () {
                        context.read<AuthBloc>().add(const SignOutRequested());
                      },
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ProfileLoaded) {
            return _buildProfileContent(context, state.profile);
          } else if (state is ProfileError) {
            return Center(
              child: Text('Error: ${state.message}'),
            );
          } else {
            return const Center(
              child: Text('No profile data available'),
            );
          }
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileModel profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: profile.photos.isNotEmpty
                        ? NetworkImage(profile.photos.first)
                        : null,
                    child: profile.photos.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        radius: 18,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt, size: 16),
                          color: Colors.white,
                          onPressed: () {
                            // TODO: Implement photo upload
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildProfileField(
              label: 'Occupation',
              value: profile.occupation ?? '',
              controller: _nameController,
              isEditing: _isEditing,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your name';
                }
                return null;
              },
            ),
            _buildProfileField(
              label: 'Bio',
              value: profile.bio ?? '',
              controller: _bioController,
              isEditing: _isEditing,
              maxLines: 3,
            ),
            _buildProfileField(
              label: 'Phone',
              value: profile.phoneNumber ?? '',
              controller: _phoneController,
              isEditing: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            _buildProfileField(
              label: 'Interests',
              value: profile.hobbies.join(', '),
              controller: _interestsController,
              isEditing: _isEditing,
              helperText: 'Separate interests with commas',
            ),
            const SizedBox(height: 20),
            if (profile.photos.isNotEmpty || _isEditing) ...[
              Text(
                'Photos',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              ProfilePhotoGrid(
                photos: profile.photos,
                isEditable: _isEditing,
                onAddPhoto: () {
                  // TODO: Implement photo addition
                },
                onDeletePhoto: (photoUrl) {
                  // TODO: Implement photo deletion
                },
              ),
              const SizedBox(height: 24),
            ],
            _buildSettingsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField({
    required String label,
    required String value,
    required TextEditingController controller,
    required bool isEditing,
    String? helperText,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: isEditing
          ? TextFormField(
              controller: controller,
              decoration: InputDecoration(
                labelText: label,
                helperText: helperText,
                border: const OutlineInputBorder(),
              ),
              maxLines: maxLines,
              keyboardType: keyboardType,
              validator: validator,
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value.isNotEmpty ? value : 'Not specified',
                  style: TextStyle(
                    color: value.isNotEmpty ? null : Colors.grey,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSettingsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.privacy_tip),
          title: const Text('Privacy Settings'),
          subtitle: const Text('Control who can see your information'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            context.push('/privacy-settings');
          },
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notification Settings'),
          subtitle: const Text('Manage your notification preferences'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to notification settings
          },
        ),
        ListTile(
          leading: const Icon(Icons.lock),
          title: const Text('Account Settings'),
          subtitle: const Text('Manage your account and security'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            // TODO: Navigate to account settings
          },
        ),
      ],
    );
  }
}
