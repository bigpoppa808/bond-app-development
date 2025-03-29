import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:bond_app/core/managers/location_manager.dart';
import 'package:bond_app/core/services/location_tracking_service.dart';
import 'package:get_it/get_it.dart';
import 'package:geolocator/geolocator.dart';

/// Screen for managing location privacy settings
class LocationPrivacyScreen extends StatefulWidget {
  const LocationPrivacyScreen({Key? key}) : super(key: key);

  @override
  State<LocationPrivacyScreen> createState() => _LocationPrivacyScreenState();
}

class _LocationPrivacyScreenState extends State<LocationPrivacyScreen> {
  final LocationManager _locationManager = GetIt.I<LocationManager>();
  final LocationTrackingService _locationTrackingService = GetIt.I<LocationTrackingService>();
  
  bool _isLocationServiceEnabled = false;
  bool _hasLocationPermission = false;
  
  @override
  void initState() {
    super.initState();
    _checkLocationStatus();
  }
  
  Future<void> _checkLocationStatus() async {
    final serviceEnabled = await _locationManager.isLocationServiceEnabled();
    final hasPermission = await _locationManager.checkPermission() != LocationPermission.denied &&
                          await _locationManager.checkPermission() != LocationPermission.deniedForever;
    
    setState(() {
      _isLocationServiceEnabled = serviceEnabled;
      _hasLocationPermission = hasPermission;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Privacy'),
        elevation: 0,
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileUpdated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location settings updated')),
            );
          } else if (state is ProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        builder: (context, state) {
          if (state is ProfileLoaded) {
            final profile = state.profile;
            
            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Location services status card
                Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location Services Status',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildStatusRow(
                          'Location Services',
                          _isLocationServiceEnabled,
                          onTap: () async {
                            await Geolocator.openLocationSettings();
                            await _checkLocationStatus();
                          },
                        ),
                        const Divider(),
                        _buildStatusRow(
                          'Location Permission',
                          _hasLocationPermission,
                          onTap: () async {
                            await _locationManager.requestPermission();
                            await _checkLocationStatus();
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Location tracking settings card
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Location Tracking Settings',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SwitchListTile(
                          title: const Text('Enable Location Tracking'),
                          subtitle: const Text(
                            'Allow the app to track your location in the background for discovery features',
                          ),
                          value: profile.isLocationTrackingEnabled,
                          onChanged: (value) {
                            final updatedProfile = profile.copyWith(
                              isLocationTrackingEnabled: value,
                            );
                            context.read<ProfileBloc>().add(
                              UpdateProfile(updatedProfile),
                            );
                            
                            if (value) {
                              _locationTrackingService.startTracking(profile.userId);
                            } else {
                              _locationTrackingService.stopTracking();
                            }
                          },
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Show Location on Profile'),
                          subtitle: const Text(
                            'Allow other users to see your approximate location',
                          ),
                          value: profile.privacySettings.showLocation,
                          onChanged: (value) {
                            final updatedPrivacySettings = profile.privacySettings.copyWith(
                              showLocation: value,
                            );
                            final updatedProfile = profile.copyWith(
                              privacySettings: updatedPrivacySettings,
                            );
                            context.read<ProfileBloc>().add(
                              UpdateProfile(updatedProfile),
                            );
                          },
                        ),
                        const Divider(),
                        SwitchListTile(
                          title: const Text('Discoverable'),
                          subtitle: const Text(
                            'Allow other users to find you in discovery',
                          ),
                          value: profile.privacySettings.discoverable,
                          onChanged: (value) {
                            final updatedPrivacySettings = profile.privacySettings.copyWith(
                              discoverable: value,
                            );
                            final updatedProfile = profile.copyWith(
                              privacySettings: updatedPrivacySettings,
                            );
                            context.read<ProfileBloc>().add(
                              UpdateProfile(updatedProfile),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Update location button
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final position = await _locationManager.getCurrentPosition();
                    if (position != null) {
                      context.read<ProfileBloc>().add(
                        UpdateProfileLocation(position),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Location updated')),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Failed to get current location')),
                      );
                    }
                  },
                  icon: const Icon(Icons.my_location),
                  label: const Text('Update My Location Now'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                ),
                
                // Location data management
                const SizedBox(height: 24),
                const Text(
                  'Location Data Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListTile(
                  title: const Text('Delete Location Data'),
                  subtitle: const Text('Remove your saved location data from our servers'),
                  trailing: const Icon(Icons.delete_outline),
                  onTap: () {
                    _showDeleteLocationDataDialog(context, profile);
                  },
                ),
                
                // Information section
                const SizedBox(height: 24),
                const Text(
                  'About Location Services',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Your location data is used to help you connect with people nearby. '
                      'We only share your approximate location with other users if you enable '
                      '"Show Location on Profile". You can disable location tracking at any time.\n\n'
                      'When location tracking is enabled, we periodically update your location '
                      'to provide you with the best discovery experience.',
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }
          
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
  
  Widget _buildStatusRow(String title, bool isEnabled, {required Function() onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: isEnabled ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                isEnabled ? 'Enabled' : 'Disabled',
                style: TextStyle(
                  color: isEnabled ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 8),
              TextButton(
                onPressed: onTap,
                child: Text(isEnabled ? 'Settings' : 'Enable'),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  void _showDeleteLocationDataDialog(BuildContext context, dynamic profile) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Location Data'),
        content: const Text(
          'Are you sure you want to delete your location data? '
          'This will remove your location from our servers and you will no longer '
          'appear in location-based discovery until you update your location again.'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              final updatedProfile = profile.copyWith(
                latitude: null,
                longitude: null,
                lastLocationUpdate: null,
              );
              context.read<ProfileBloc>().add(
                UpdateProfile(updatedProfile),
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Location data deleted')),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
