import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bond_app/core/theme/app_theme.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/connections/data/models/connection_model.dart';
import 'package:bond_app/features/connections/presentation/bloc/connection_bloc.dart';
import 'package:bond_app/features/connections/presentation/bloc/connection_event.dart';
import 'package:bond_app/features/connections/presentation/bloc/connection_state.dart';
import 'package:bond_app/features/connections/presentation/widgets/connection_list_item.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_state.dart';

/// Screen for displaying and managing user connections
class ConnectionsScreen extends StatefulWidget {
  /// Constructor
  const ConnectionsScreen({Key? key}) : super(key: key);

  @override
  State<ConnectionsScreen> createState() => _ConnectionsScreenState();
}

class _ConnectionsScreenState extends State<ConnectionsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _currentUserId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Get the current user ID from the auth state
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.uid;
      
      // Load connections for the current user
      if (_currentUserId != null) {
        context.read<ConnectionBloc>().add(LoadConnections(userId: _currentUserId!));
        context.read<ConnectionBloc>().add(LoadPendingRequests(userId: _currentUserId!));
        context.read<ConnectionBloc>().add(LoadSentRequests(userId: _currentUserId!));
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Connections'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Connections'),
            Tab(text: 'Requests'),
            Tab(text: 'Sent'),
          ],
        ),
      ),
      body: _currentUserId == null
          ? const Center(child: Text('Please sign in to view your connections'))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildConnectionsTab(),
                _buildRequestsTab(),
                _buildSentTab(),
              ],
            ),
    );
  }

  Widget _buildConnectionsTab() {
    return BlocBuilder<ConnectionBloc, ConnectionState>(
      builder: (context, state) {
        if (state is ConnectionsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ConnectionsLoaded) {
          final acceptedConnections = state.connections
              .where((connection) => connection.isAccepted)
              .toList();
          
          if (acceptedConnections.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No connections yet',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Start connecting with people to build your network',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to discovery screen
                      Navigator.pushNamed(context, '/discovery');
                    },
                    child: const Text('Discover People'),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: acceptedConnections.length,
            itemBuilder: (context, index) {
              final connection = acceptedConnections[index];
              return ConnectionListItem(
                connection: connection,
                currentUserId: _currentUserId!,
                onTap: () {
                  // Navigate to the connection's profile
                  Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: connection.getOtherUserId(_currentUserId!),
                  );
                },
              );
            },
          );
        } else if (state is ConnectionError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildRequestsTab() {
    return BlocBuilder<ConnectionBloc, ConnectionState>(
      builder: (context, state) {
        if (state is ConnectionsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is PendingRequestsLoaded) {
          if (state.pendingRequests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.mail_outline, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No pending requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When someone sends you a connection request, it will appear here',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: state.pendingRequests.length,
            itemBuilder: (context, index) {
              final request = state.pendingRequests[index];
              return _buildRequestItem(request);
            },
          );
        } else if (state is ConnectionError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildSentTab() {
    return BlocBuilder<ConnectionBloc, ConnectionState>(
      builder: (context, state) {
        if (state is ConnectionsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is SentRequestsLoaded) {
          if (state.sentRequests.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.send_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No sent requests',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When you send a connection request, it will appear here',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 24),
                ],
              ),
            );
          }
          
          return ListView.builder(
            itemCount: state.sentRequests.length,
            itemBuilder: (context, index) {
              final request = state.sentRequests[index];
              return ConnectionListItem(
                connection: request,
                currentUserId: _currentUserId!,
                showStatus: true,
                onTap: () {
                  // Navigate to the connection's profile
                  Navigator.pushNamed(
                    context,
                    '/profile',
                    arguments: request.getOtherUserId(_currentUserId!),
                  );
                },
              );
            },
          );
        } else if (state is ConnectionError) {
          return Center(child: Text('Error: ${state.message}'));
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildRequestItem(ConnectionModel request) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        ProfileModel? senderProfile;
        
        if (state is ProfileLoaded) {
          // Try to find the sender's profile in the loaded profiles
          // This assumes that the ProfileBloc has loaded the profiles of connection requesters
          senderProfile = state.profiles.firstWhere(
            (profile) => profile.userId == request.senderId,
            orElse: () => ProfileModel.empty(),
          );
        }
        
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundImage: senderProfile?.profilePictureUrl != null
                          ? NetworkImage(senderProfile!.profilePictureUrl!)
                          : null,
                      child: senderProfile?.profilePictureUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            senderProfile?.displayName ?? 'Unknown User',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          if (request.message != null && request.message!.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                request.message!,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton(
                      onPressed: () {
                        context.read<ConnectionBloc>().add(
                              DeclineConnectionRequest(
                                connectionId: request.senderId + request.receiverId,
                              ),
                            );
                      },
                      child: const Text('Decline'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ConnectionBloc>().add(
                              AcceptConnectionRequest(
                                connectionId: request.senderId + request.receiverId,
                              ),
                            );
                      },
                      child: const Text('Accept'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
