import 'package:flutter/material.dart';
import 'package:fresh_bond_app/core/design/components/bond_card.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:intl/intl.dart';

/// Card widget for displaying meeting information
class MeetingCard extends StatelessWidget {
  /// Meeting data to display
  final MeetingModel meeting;
  
  /// Whether this is an upcoming meeting
  final bool isUpcoming;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Constructor
  const MeetingCard({
    Key? key,
    required this.meeting,
    this.isUpcoming = true,
    this.onTap,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    // Format date and time
    final dateFormat = DateFormat('E, MMM d, yyyy');
    final timeFormat = DateFormat('h:mm a');
    final formattedDate = dateFormat.format(meeting.scheduledTime);
    final formattedTime = timeFormat.format(meeting.scheduledTime);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: GestureDetector(
        onTap: onTap,
        child: BondCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Meeting header with status badge
              Row(
                children: [
                  Expanded(
                    child: Text(
                      meeting.title,
                      style: BondTypography.subtitle1.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  _buildStatusBadge(meeting.status),
                ],
              ),
              const SizedBox(height: 8),
              
              // Meeting description
              Text(
                meeting.description,
                style: BondTypography.body2,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              
              // Meeting time info
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    size: 16,
                    color: BondColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedDate,
                    style: BondTypography.body2,
                  ),
                  const SizedBox(width: 16),
                  const Icon(
                    Icons.access_time,
                    size: 16,
                    color: BondColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formattedTime,
                    style: BondTypography.body2,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Meeting location
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: BondColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      meeting.location,
                      style: BondTypography.body2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Action buttons for upcoming meetings
              if (isUpcoming) _buildActionButtons(context),
            ],
          ),
        ),
      ),
    );
  }
  
  /// Build the status badge based on meeting status
  Widget _buildStatusBadge(MeetingStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        label,
        style: BondTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  
  /// Build action buttons for upcoming meetings
  Widget _buildActionButtons(BuildContext context) {
    // Only show action buttons for pending or confirmed meetings
    if (meeting.status != MeetingStatus.pending && 
        meeting.status != MeetingStatus.confirmed &&
        meeting.status != MeetingStatus.rescheduled) {
      return const SizedBox.shrink();
    }
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (meeting.status == MeetingStatus.pending)
          TextButton(
            onPressed: () {
              // Handle confirming meeting
            },
            child: const Text('Confirm'),
          ),
        TextButton(
          onPressed: () {
            // Handle rescheduling meeting
          },
          child: const Text('Reschedule'),
        ),
        TextButton(
          onPressed: () {
            // Handle canceling meeting
            _showCancelDialog(context);
          },
          style: TextButton.styleFrom(
            foregroundColor: BondColors.error,
          ),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
  
  /// Show dialog for canceling a meeting
  void _showCancelDialog(BuildContext context) {
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
                Navigator.of(context).pop(reason);
                // TODO: Implement cancel meeting with reason
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
}