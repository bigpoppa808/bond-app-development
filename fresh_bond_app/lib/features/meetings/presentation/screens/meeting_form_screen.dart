import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/design/components/bond_button.dart';
import 'package:fresh_bond_app/core/design/components/bond_input.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/discover/domain/models/connection_model.dart';
import 'package:fresh_bond_app/features/discover/domain/repositories/connections_repository.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_event.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_state.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

/// Screen for creating or editing a meeting
class MeetingFormScreen extends StatefulWidget {
  /// Meeting to edit, or null for creating a new meeting
  final MeetingModel? meetingToEdit;
  
  /// Connection ID for pre-populated invitee
  final String? connectionId;

  /// Constructor
  const MeetingFormScreen({
    Key? key,
    this.meetingToEdit,
    this.connectionId,
  }) : super(key: key);

  @override
  State<MeetingFormScreen> createState() => _MeetingFormScreenState();
}

class _MeetingFormScreenState extends State<MeetingFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  // Form values
  DateTime _scheduledTime = DateTime.now().add(const Duration(days: 1));
  int _durationMinutes = 60;
  String? _inviteeId;
  List<String> _topics = [];
  
  // Current user ID
  String? _currentUserId;
  
  // Available connections
  List<ConnectionModel> _connections = [];
  bool _isLoadingConnections = false;
  
  // Tag input controller
  final _topicController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _initializeForm();
    _loadCurrentUser();
    _loadConnections();
  }
  
  Future<void> _loadCurrentUser() async {
    final user = await context.read<AuthRepository>().getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _currentUserId = user.id;
      });
    }
  }
  
  Future<void> _loadConnections() async {
    setState(() {
      _isLoadingConnections = true;
    });
    
    try {
      final connections = await context.read<ConnectionsRepository>().getConnections();
      
      if (mounted) {
        setState(() {
          _connections = connections;
          _isLoadingConnections = false;
          
          // If connection ID is provided, use it
          if (widget.connectionId != null) {
            _inviteeId = widget.connectionId;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingConnections = false;
        });
        _showSnackBar('Failed to load connections: $e', isError: true);
      }
    }
  }
  
  void _initializeForm() {
    // If editing an existing meeting, populate the form
    if (widget.meetingToEdit != null) {
      _titleController.text = widget.meetingToEdit!.title;
      _descriptionController.text = widget.meetingToEdit!.description;
      _locationController.text = widget.meetingToEdit!.location;
      _scheduledTime = widget.meetingToEdit!.scheduledTime;
      _durationMinutes = widget.meetingToEdit!.durationMinutes;
      _inviteeId = widget.meetingToEdit!.inviteeId;
      _topics = List.from(widget.meetingToEdit!.topics);
    }
  }
  
  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.meetingToEdit != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Meeting' : 'Create Meeting'),
        centerTitle: true,
        elevation: 0,
      ),
      body: BlocConsumer<MeetingBloc, MeetingState>(
        listener: (context, state) {
          if (state is MeetingCreatedState) {
            _showSnackBar('Meeting created successfully');
            Navigator.of(context).pop();
          } else if (state is MeetingUpdatedState) {
            _showSnackBar('Meeting updated successfully');
            Navigator.of(context).pop();
          } else if (state is MeetingErrorState) {
            _showSnackBar('Error: ${state.message}', isError: true);
          }
        },
        builder: (context, state) {
          final isLoading = state is MeetingLoadingState;
          
          return Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title input
                      TextFormField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter meeting title',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a title';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Description input
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          hintText: 'Enter meeting description',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a description';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      // Location input
                      TextFormField(
                        controller: _locationController,
                        decoration: const InputDecoration(
                          labelText: 'Location',
                          hintText: 'Enter meeting location',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      
                      // Date and time picker
                      Text(
                        'Date and Time',
                        style: BondTypography.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ListTile(
                        title: const Text('Date'),
                        subtitle: Text(
                          DateFormat('MMM d, yyyy').format(_scheduledTime),
                        ),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: _scheduledTime,
                            firstDate: DateTime.now(),
                            lastDate: DateTime.now().add(const Duration(days: 365)),
                          );
                          
                          if (date != null) {
                            setState(() {
                              _scheduledTime = DateTime(
                                date.year,
                                date.month,
                                date.day,
                                _scheduledTime.hour,
                                _scheduledTime.minute,
                              );
                            });
                          }
                        },
                      ),
                      ListTile(
                        title: const Text('Time'),
                        subtitle: Text(
                          DateFormat('h:mm a').format(_scheduledTime),
                        ),
                        trailing: const Icon(Icons.access_time),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_scheduledTime),
                          );
                          
                          if (time != null) {
                            setState(() {
                              _scheduledTime = DateTime(
                                _scheduledTime.year,
                                _scheduledTime.month,
                                _scheduledTime.day,
                                time.hour,
                                time.minute,
                              );
                            });
                          }
                        },
                      ),
                      
                      // Duration selector
                      ListTile(
                        title: const Text('Duration'),
                        subtitle: Text('$_durationMinutes minutes'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: _durationMinutes <= 15
                                  ? null
                                  : () {
                                      setState(() {
                                        _durationMinutes -= 15;
                                      });
                                    },
                            ),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  _durationMinutes += 15;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // Invitee selector
                      Text(
                        'Invitee',
                        style: BondTypography.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      if (_isLoadingConnections)
                        const Center(
                          child: CircularProgressIndicator(),
                        )
                      else if (_connections.isEmpty)
                        const Text(
                          'You have no connections yet. Add connections to create meetings.',
                          style: TextStyle(fontStyle: FontStyle.italic),
                        )
                      else
                        DropdownButtonFormField<String>(
                          decoration: const InputDecoration(
                            labelText: 'Select Invitee',
                            border: OutlineInputBorder(),
                          ),
                          value: _inviteeId,
                          items: _connections.map((connection) {
                            return DropdownMenuItem<String>(
                              value: connection.id,
                              child: Text(connection.name),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _inviteeId = value;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select an invitee';
                            }
                            return null;
                          },
                        ),
                      const SizedBox(height: 24),
                      
                      // Topics
                      Text(
                        'Topics (Optional)',
                        style: BondTypography.subtitle1.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _topicController,
                              decoration: const InputDecoration(
                                labelText: 'Add Topic',
                                hintText: 'Enter a topic and press +',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              final topic = _topicController.text.trim();
                              if (topic.isNotEmpty) {
                                setState(() {
                                  _topics.add(topic);
                                  _topicController.clear();
                                });
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _topics.map((topic) {
                          return Chip(
                            label: Text(topic),
                            backgroundColor: BondColors.primary.withOpacity(0.1),
                            labelStyle: BondTypography.body2.copyWith(
                              color: BondColors.primary,
                            ),
                            deleteIcon: const Icon(
                              Icons.close,
                              size: 16,
                            ),
                            onDeleted: () {
                              setState(() {
                                _topics.remove(topic);
                              });
                            },
                          );
                        }).toList(),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Submit button
                      BondButton(
                        label: isEditing ? 'Update Meeting' : 'Create Meeting',
                        onPressed: isLoading ? null : _submitForm,
                        useGradient: true,
                        variant: BondButtonVariant.primary,
                        fullWidth: true,
                      ),
                      
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              
              // Loading overlay
              if (isLoading)
                Container(
                  color: Colors.black.withOpacity(0.3),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
  
  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      if (_currentUserId == null) {
        _showSnackBar('You must be signed in to create a meeting', isError: true);
        return;
      }
      
      // Build the meeting model
      final now = DateTime.now();
      final meetingModel = MeetingModel(
        id: widget.meetingToEdit?.id ?? const Uuid().v4(),
        title: _titleController.text,
        description: _descriptionController.text,
        location: _locationController.text,
        scheduledTime: _scheduledTime,
        durationMinutes: _durationMinutes,
        creatorId: _currentUserId!,
        inviteeId: _inviteeId!,
        status: widget.meetingToEdit?.status ?? MeetingStatus.pending,
        createdAt: widget.meetingToEdit?.createdAt ?? now,
        updatedAt: now,
        topics: _topics,
      );
      
      // Dispatch the appropriate event
      if (widget.meetingToEdit != null) {
        context.read<MeetingBloc>().add(UpdateMeetingEvent(meetingModel));
      } else {
        context.read<MeetingBloc>().add(CreateMeetingEvent(meetingModel));
      }
    }
  }
  
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? BondColors.error : BondColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}