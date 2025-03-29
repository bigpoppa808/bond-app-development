import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bond_app/core/theme/app_theme.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_state.dart';

/// Screen for managing profile privacy settings
class PrivacySettingsScreen extends StatefulWidget {
  /// Constructor
  const PrivacySettingsScreen({Key? key}) : super(key: key);

  @override
  State<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends State<PrivacySettingsScreen> {
  late ProfilePrivacySettings _privacySettings;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      _privacySettings = profileState.profile.privacySettings;
    } else {
      _privacySettings = ProfilePrivacySettings.defaults;
    }
  }

  void _saveSettings() {
    final profileState = context.read<ProfileBloc>().state;
    if (profileState is ProfileLoaded) {
      final updatedProfile = profileState.profile.copyWith(
        privacySettings: _privacySettings,
        lastUpdated: DateTime.now(),
      );
      
      context.read<ProfileBloc>().add(UpdateProfile(updatedProfile));
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Privacy settings updated successfully'),
              backgroundColor: Colors.green,
            ),
          );
          _hasChanges = false;
        } else if (state is ProfileError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error updating privacy settings: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Privacy Settings'),
          actions: [
            if (_hasChanges)
              TextButton(
                onPressed: _saveSettings,
                child: const Text('Save'),
              ),
          ],
        ),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            
            return ListView(
              children: [
                _buildDiscoverabilitySection(),
                const Divider(),
                _buildInfoVisibilitySection(),
                const Divider(),
                _buildLocationSection(),
                const Divider(),
                _buildDataSection(),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDiscoverabilitySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Discoverability',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Control who can find your profile',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Show in Search Results'),
            subtitle: const Text(
              'When turned off, your profile won\'t appear in search results',
            ),
            value: _privacySettings.discoverable,
            onChanged: (value) {
              setState(() {
                _privacySettings = _privacySettings.copyWith(
                  discoverable: value,
                );
                _hasChanges = true;
              });
            },
          ),
          SwitchListTile(
            title: const Text('Show Online Status'),
            subtitle: const Text(
              'Let others see when you\'re active on Bond',
            ),
            value: _privacySettings.showOnlineStatus,
            onChanged: (value) {
              setState(() {
                _privacySettings = _privacySettings.copyWith(
                  showOnlineStatus: value,
                );
                _hasChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoVisibilitySection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Information Visibility',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Control who can see your information',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          _buildPrivacySelector(
            title: 'Contact Information',
            subtitle: 'Email and phone number',
            value: _privacySettings.contactInfoPrivacy,
            onChanged: (value) {
              setState(() {
                _privacySettings = _privacySettings.copyWith(
                  contactInfoPrivacy: value,
                );
                _hasChanges = true;
              });
            },
          ),
          const SizedBox(height: 8),
          _buildPrivacySelector(
            title: 'Interests',
            subtitle: 'Your listed interests and hobbies',
            value: _privacySettings.interestsPrivacy,
            onChanged: (value) {
              setState(() {
                _privacySettings = _privacySettings.copyWith(
                  interestsPrivacy: value,
                );
                _hasChanges = true;
              });
            },
          ),
          const SizedBox(height: 8),
          _buildPrivacySelector(
            title: 'Photos',
            subtitle: 'All photos on your profile',
            value: _privacySettings.photosPrivacy,
            onChanged: (value) {
              setState(() {
                _privacySettings = _privacySettings.copyWith(
                  photosPrivacy: value,
                );
                _hasChanges = true;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Location',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Control how your location is used',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          SwitchListTile(
            title: const Text('Share My Location'),
            subtitle: const Text(
              'Allow Bond to share your location with other users for better matches',
            ),
            value: _privacySettings.showLocation,
            onChanged: (value) {
              setState(() {
                _privacySettings = _privacySettings.copyWith(
                  showLocation: value,
                );
                _hasChanges = true;
              });
            },
          ),
          const SizedBox(height: 8),
          ListTile(
            title: const Text('Advanced Location Settings'),
            subtitle: const Text(
              'Manage location tracking, permissions, and data',
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/location-privacy');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDataSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Data',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Manage your data on Bond',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
          const SizedBox(height: 16),
          ListTile(
            title: const Text('Download Your Data'),
            subtitle: const Text('Get a copy of all your Bond data'),
            trailing: const Icon(Icons.download),
            onTap: () {
              // TODO: Implement download functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('This feature is coming soon!'),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Delete Your Account'),
            subtitle: const Text(
                'Permanently delete your account and all your data'),
            trailing: const Icon(Icons.delete_forever, color: Colors.red),
            onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Delete Account?'),
                    content: const Text(
                        'This action cannot be undone. All your data will be permanently deleted.'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement account deletion
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('This feature is coming soon!'),
                            ),
                          );
                        },
                        child: const Text(
                          'Delete',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacySelector({
    required String title,
    required String subtitle,
    required PrivacyLevel value,
    required ValueChanged<PrivacyLevel> onChanged,
  }) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<PrivacyLevel>(
        value: value,
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
        items: PrivacyLevel.values.map((privacy) {
          return DropdownMenuItem<PrivacyLevel>(
            value: privacy,
            child: Text(_getPrivacyLevelText(privacy)),
          );
        }).toList(),
      ),
    );
  }

  String _getPrivacyLevelText(PrivacyLevel privacy) {
    switch (privacy) {
      case PrivacyLevel.public:
        return 'Everyone';
      case PrivacyLevel.connectionsOnly:
        return 'Connections Only';
      case PrivacyLevel.private:
        return 'Only Me';
    }
  }
}
