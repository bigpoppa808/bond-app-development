import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/design/components/bond_button.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';
import 'package:fresh_bond_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_event.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_state.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:fresh_bond_app/features/meetings/domain/repositories/nfc_verification_repository_interface.dart';
import 'package:fresh_bond_app/features/meetings/presentation/screens/nfc/nfc_verification_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Screen for displaying meeting details
class MeetingDetailsScreen extends StatefulWidget {
  /// ID of the meeting to display
  final String meetingId;

  /// Constructor
  const MeetingDetailsScreen({
    Key? key,
    required this.meetingId,
  }) : super(key: key);

  @override
  State<MeetingDetailsScreen> createState() => _MeetingDetailsScreenState();
}

class _MeetingDetailsScreenState extends State<MeetingDetailsScreen> {
  String? _currentUserId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMeeting();
    _getCurrentUser();
    _checkNfcAvailability();
  }
  
  /// Check if NFC is available
  bool _isNfcAvailable = false;
  
  void _checkNfcAvailability() {
    final nfcRepository = context.read<NfcVerificationRepositoryInterface>();
    _isNfcAvailable = nfcRepository.isNfcAvailable();
  }

  Future<void> _getCurrentUser() async {
    final user = await context.read<AuthRepository>().getCurrentUser();
    if (user != null && mounted) {
      setState(() {
        _currentUserId = user.id;
      });
    }
  }

  void _loadMeeting() {
    context.read<MeetingBloc>().add(LoadMeetingEvent(widget.meetingId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Details'),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Handle sharing meeting details
            },
            tooltip: 'Share Meeting',
          ),
        ],
      ),
      body: BlocConsumer<MeetingBloc, MeetingState>(
        listener: (context, state) {
          if (state is MeetingCanceledState) {
            _showSnackBar('Meeting canceled successfully');
            Navigator.of(context).pop();
          } else if (state is MeetingConfirmedState) {
            _showSnackBar('Meeting confirmed');
          } else if (state is MeetingRescheduledState) {
            _showSnackBar('Meeting rescheduled');
          } else if (state is MeetingCompletedState) {
            _showSnackBar('Meeting marked as completed');
          } else if (state is MeetingErrorState) {
            _showSnackBar('Error: ${state.message}', isError: true);
          }
        },
        builder: (context, state) {
          if (state is MeetingLoadingState) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is MeetingErrorState) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: BondColors.error),
                  const SizedBox(height: 16),
                  Text(
                    'Something went wrong',
                    style: BondTypography.heading4,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: BondTypography.body2,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadMeeting,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          if (state is MeetingLoadedState) {
            return _buildMeetingDetails(state.meeting);
          }
          
          return const Center(
            child: Text('Meeting not found'),
          );
        },
      ),
    );
  }

  Widget _buildMeetingDetails(MeetingModel meeting) {
    // Format date and time
    final dateFormat = DateFormat('EEEE, MMMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = dateFormat.format(meeting.scheduledTime);
    final formattedTime = timeFormat.format(meeting.scheduledTime);
    final formattedEndTime = timeFormat.format(
      meeting.scheduledTime.add(Duration(minutes: meeting.durationMinutes)),
    );
    
    final bool isCreator = _currentUserId == meeting.creatorId;
    final bool isPending = meeting.status == MeetingStatus.pending;
    final bool isUpcoming = meeting.scheduledTime.isAfter(DateTime.now()) &&
        (meeting.status == MeetingStatus.pending ||
            meeting.status == MeetingStatus.confirmed ||
            meeting.status == MeetingStatus.rescheduled);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meeting title and status
          Row(
            children: [
              Expanded(
                child: Text(
                  meeting.title,
                  style: BondTypography.heading3,
                ),
              ),
              _buildStatusChip(meeting.status),
            ],
          ),
          const SizedBox(height: 24),
          
          // Meeting date and time
          _buildDetailItem(
            icon: Icons.calendar_today,
            title: 'Date',
            content: formattedDate,
          ),
          _buildDetailItem(
            icon: Icons.access_time,
            title: 'Time',
            content: '$formattedTime - $formattedEndTime',
          ),
          _buildDetailItem(
            icon: Icons.hourglass_bottom,
            title: 'Duration',
            content: '${meeting.durationMinutes} minutes',
          ),
          _buildDetailItem(
            icon: Icons.location_on,
            title: 'Location',
            content: meeting.location,
          ),
          
          // Meeting description
          const SizedBox(height: 24),
          Text(
            'Description',
            style: BondTypography.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            meeting.description,
            style: BondTypography.body1,
          ),
          
          // Meeting notes (if any)
          if (meeting.notes != null && meeting.notes!.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Notes',
              style: BondTypography.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              meeting.notes!,
              style: BondTypography.body1,
            ),
          ],
          
          // Topics
          if (meeting.topics.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Topics',
              style: BondTypography.subtitle1.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: meeting.topics.map((topic) => Chip(
                label: Text(topic),
                backgroundColor: BondColors.primary.withOpacity(0.1),
                labelStyle: BondTypography.body2.copyWith(
                  color: BondColors.primary,
                ),
              )).toList(),
            ),
          ],
          
          // Creator and invitee information
          const SizedBox(height: 24),
          Text(
            'Participants',
            style: BondTypography.subtitle1.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Creator ID: ${meeting.creatorId}',
                    style: BondTypography.body2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    isCreator ? 'You' : 'Creator',
                    style: BondTypography.caption,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const CircleAvatar(
                radius: 20,
                backgroundColor: BondColors.secondary,
                child: Icon(Icons.person),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Invitee ID: ${meeting.inviteeId}',
                    style: BondTypography.body2.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    !isCreator ? 'You' : 'Invitee',
                    style: BondTypography.caption,
                  ),
                ],
              ),
            ],
          ),
          
          // Action buttons
          if (isUpcoming) ...[
            const SizedBox(height: 32),
            _buildActionButtons(meeting, isCreator, isPending),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 24,
            color: BondColors.primary,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: BondTypography.caption.copyWith(
                    color: BondColors.textSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  content,
                  style: BondTypography.body1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(MeetingStatus status) {
    // Define colors and labels for each status
    late final Color color;
    late final String label;
    
    switch (status) {
      case MeetingStatus.pending:
        color = BondColors.warning;
        label = 'Pending';
        break;
      case MeetingStatus.confirmed:
        color = BondColors.success;
        label = 'Confirmed';
        break;
      case MeetingStatus.completed:
        color = BondColors.info;
        label = 'Completed';
        break;
      case MeetingStatus.canceled:
        color = BondColors.error;
        label = 'Canceled';
        break;
      case MeetingStatus.rescheduled:
        color = BondColors.secondary;
        label = 'Rescheduled';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: BondTypography.button.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildActionButtons(MeetingModel meeting, bool isCreator, bool isPending) {
    return Column(
      children: [
        if (isPending && !isCreator)
          BondButton(
            label: 'Confirm Meeting',
            onPressed: () => _confirmMeeting(meeting.id),
            useGradient: true,
            variant: BondButtonVariant.primary,
            fullWidth: true,
          ),
        const SizedBox(height: 16),
        BondButton(
          label: 'Reschedule',
          onPressed: () => _showRescheduleDialog(meeting),
          variant: BondButtonVariant.secondary,
          fullWidth: true,
        ),
        const SizedBox(height: 16),
        BondButton(
          label: 'Cancel Meeting',
          onPressed: () => _showCancelDialog(meeting.id),
          variant: BondButtonVariant.tertiary,
          fullWidth: true,
        ),
        if (isCreator && meeting.status == MeetingStatus.confirmed) ...[
          const SizedBox(height: 16),
          BondButton(
            label: 'Mark as Completed',
            onPressed: () => _completeMeeting(meeting.id),
            variant: BondButtonVariant.primary,
            fullWidth: true,
          ),
          if (_isNfcAvailable) ...[
            const SizedBox(height: 16),
            BondButton(
              label: 'Verify with NFC',
              icon: Icons.nfc,
              onPressed: () => _navigateToNfcVerification(meeting),
              variant: BondButtonVariant.primary,
              useGradient: true,
              fullWidth: true,
            ),
          ],
        ],
      ],
    );
  }

  void _confirmMeeting(String meetingId) {
    setState(() {
      _isLoading = true;
    });
    context.read<MeetingBloc>().add(ConfirmMeetingEvent(meetingId));
  }

  void _completeMeeting(String meetingId) {
    setState(() {
      _isLoading = true;
    });
    context.read<MeetingBloc>().add(CompleteMeetingEvent(meetingId));
  }

  void _showCancelDialog(String meetingId) {
    showDialog(
      context: context,
      builder: (context) {
        String? reason;
        
        return AlertDialog(
          title: const Text('Cancel Meeting'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Are you sure you want to cancel this meeting?'),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Reason (optional)',
                  hintText: 'Enter reason for cancellation',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (value) {
                  reason = value;
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('NO'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  _isLoading = true;
                });
                context.read<MeetingBloc>().add(
                  CancelMeetingEvent(meetingId, reason: reason),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: BondColors.error,
              ),
              child: const Text('YES, CANCEL'),
            ),
          ],
        );
      },
    );
  }

  void _showRescheduleDialog(MeetingModel meeting) {
    // Default to current date/time +1 day
    DateTime newDateTime = DateTime.now().add(const Duration(days: 1));
    int durationMinutes = meeting.durationMinutes;
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Reschedule Meeting'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ListTile(
                    title: const Text('Date'),
                    subtitle: Text(
                      DateFormat('MMM d, yyyy').format(newDateTime),
                    ),
                    trailing: const Icon(Icons.calendar_today),
                    onTap: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: newDateTime,
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      
                      if (date != null) {
                        setState(() {
                          newDateTime = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            newDateTime.hour,
                            newDateTime.minute,
                          );
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Time'),
                    subtitle: Text(
                      DateFormat('h:mm a').format(newDateTime),
                    ),
                    trailing: const Icon(Icons.access_time),
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(newDateTime),
                      );
                      
                      if (time != null) {
                        setState(() {
                          newDateTime = DateTime(
                            newDateTime.year,
                            newDateTime.month,
                            newDateTime.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: const Text('Duration (minutes)'),
                    subtitle: Text('$durationMinutes minutes'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: durationMinutes <= 15
                              ? null
                              : () {
                                  setState(() {
                                    durationMinutes -= 15;
                                  });
                                },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            setState(() {
                              durationMinutes += 15;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    setState(() {
                      _isLoading = true;
                    });
                    context.read<MeetingBloc>().add(
                      RescheduleMeetingEvent(
                        meeting.id,
                        newDateTime,
                        newDurationMinutes: durationMinutes,
                      ),
                    );
                  },
                  child: const Text('RESCHEDULE'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Navigate to NFC verification screen
  void _navigateToNfcVerification(MeetingModel meeting) async {
    // Create a NFC verification bloc to provide to the screen
    final nfcBloc = NfcVerificationBloc(
      nfcRepository: context.read<NfcVerificationRepositoryInterface>(),
    );
    
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => BlocProvider.value(
          value: nfcBloc,
          child: NfcVerificationScreen(
            meetingId: meeting.id,
            meeting: meeting,
          ),
        ),
      ),
    );
    
    // If verification was successful, reload the meeting
    if (result == true) {
      _loadMeeting();
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