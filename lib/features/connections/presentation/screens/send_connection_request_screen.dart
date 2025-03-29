import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:bond_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:bond_app/features/connections/presentation/bloc/connection_bloc.dart';
import 'package:bond_app/features/connections/presentation/bloc/connection_event.dart';
import 'package:bond_app/features/connections/presentation/bloc/connection_state.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';

/// Screen for sending a connection request to another user
class SendConnectionRequestScreen extends StatefulWidget {
  /// The profile of the user to send a request to
  final ProfileModel receiverProfile;

  /// Constructor
  const SendConnectionRequestScreen({
    Key? key,
    required this.receiverProfile,
  }) : super(key: key);

  @override
  State<SendConnectionRequestScreen> createState() => _SendConnectionRequestScreenState();
}

class _SendConnectionRequestScreenState extends State<SendConnectionRequestScreen> {
  final _messageController = TextEditingController();
  String? _currentUserId;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    
    // Get the current user ID from the auth state
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      _currentUserId = authState.user.uid;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendConnectionRequest() {
    if (_currentUserId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must be signed in to send a connection request'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    setState(() {
      _isSending = true;
    });
    
    context.read<ConnectionBloc>().add(
      SendConnectionRequest(
        senderId: _currentUserId!,
        receiverId: widget.receiverProfile.userId,
        message: _messageController.text.trim().isNotEmpty
            ? _messageController.text.trim()
            : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Connection Request'),
      ),
      body: BlocListener<ConnectionBloc, ConnectionState>(
        listener: (context, state) {
          if (state is ConnectionRequestSent) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Connection request sent successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          } else if (state is ConnectionError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isSending = false;
            });
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Receiver profile card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundImage: widget.receiverProfile.profilePictureUrl != null
                            ? NetworkImage(widget.receiverProfile.profilePictureUrl!)
                            : null,
                        child: widget.receiverProfile.profilePictureUrl == null
                            ? const Icon(Icons.person, size: 30)
                            : null,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.receiverProfile.displayName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            if (widget.receiverProfile.bio != null &&
                                widget.receiverProfile.bio!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Text(
                                  widget.receiverProfile.bio!,
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
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Message input
              const Text(
                'Add a personal message (optional)',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _messageController,
                maxLines: 4,
                maxLength: 200,
                decoration: const InputDecoration(
                  hintText: 'Write a message to introduce yourself...',
                  border: OutlineInputBorder(),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Send button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSending ? null : _sendConnectionRequest,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isSending
                      ? const CircularProgressIndicator()
                      : const Text('Send Connection Request'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
