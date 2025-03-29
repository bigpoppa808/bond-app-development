import 'package:flutter/material.dart';
import 'package:bond_app/features/connections/data/models/connection_model.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:timeago/timeago.dart' as timeago;

/// A list item widget for displaying a connection
class ConnectionListItem extends StatelessWidget {
  /// The connection to display
  final ConnectionModel connection;
  
  /// The current user's ID
  final String currentUserId;
  
  /// Whether to show the connection status
  final bool showStatus;
  
  /// Callback when the item is tapped
  final VoidCallback? onTap;

  /// Constructor
  const ConnectionListItem({
    Key? key,
    required this.connection,
    required this.currentUserId,
    this.showStatus = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get the other user's ID (not the current user)
    final otherUserId = connection.getOtherUserId(currentUserId);
    
    // Load the other user's profile if not already loaded
    _loadProfileIfNeeded(context, otherUserId);
    
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        ProfileModel? otherUserProfile;
        
        if (state is ProfileLoaded) {
          // Try to find the other user's profile in the loaded profiles
          otherUserProfile = state.profiles.firstWhere(
            (profile) => profile.userId == otherUserId,
            orElse: () => ProfileModel.empty(),
          );
        }
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Profile picture
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: otherUserProfile?.profilePictureUrl != null
                        ? NetworkImage(otherUserProfile!.profilePictureUrl!)
                        : null,
                    child: otherUserProfile?.profilePictureUrl == null
                        ? const Icon(Icons.person)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherUserProfile?.displayName ?? 'Loading...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (otherUserProfile?.bio != null && otherUserProfile!.bio!.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              otherUserProfile.bio!,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        if (showStatus && connection.status != ConnectionStatus.accepted)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: _buildStatusChip(connection.status),
                          ),
                      ],
                    ),
                  ),
                  // Last updated time
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        timeago.format(connection.updatedAt),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (!connection.isSenderRead && connection.senderId == currentUserId ||
                          !connection.isReceiverRead && connection.receiverId == currentUserId)
                        Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  /// Build a chip displaying the connection status
  Widget _buildStatusChip(ConnectionStatus status) {
    Color chipColor;
    String statusText;
    
    switch (status) {
      case ConnectionStatus.pending:
        chipColor = Colors.orange;
        statusText = 'Pending';
        break;
      case ConnectionStatus.accepted:
        chipColor = Colors.green;
        statusText = 'Connected';
        break;
      case ConnectionStatus.declined:
        chipColor = Colors.red;
        statusText = 'Declined';
        break;
      case ConnectionStatus.blocked:
        chipColor = Colors.grey;
        statusText = 'Blocked';
        break;
    }
    
    return Chip(
      label: Text(
        statusText,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
      backgroundColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
    );
  }

  /// Load the profile if it's not already loaded
  void _loadProfileIfNeeded(BuildContext context, String userId) {
    final profileState = context.read<ProfileBloc>().state;
    
    if (profileState is ProfileLoaded) {
      // Check if the profile is already loaded
      final isProfileLoaded = profileState.profiles.any(
        (profile) => profile.userId == userId,
      );
      
      if (!isProfileLoaded) {
        // Load the profile if not already loaded
        context.read<ProfileBloc>().add(LoadProfile(userId: userId));
      }
    } else {
      // If the profile state is not loaded, load the profile
      context.read<ProfileBloc>().add(LoadProfile(userId: userId));
    }
  }
}
