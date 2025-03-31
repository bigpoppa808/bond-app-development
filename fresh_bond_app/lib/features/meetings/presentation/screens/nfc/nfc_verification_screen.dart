import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/design/components/bond_button.dart';
import 'package:fresh_bond_app/core/design/components/bond_card.dart';
import 'package:fresh_bond_app/core/design/components/bond_progress_indicator.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_event.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/nfc_verification/nfc_verification_state.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:go_router/go_router.dart';

/// Screen for NFC verification of meetings
class NfcVerificationScreen extends StatefulWidget {
  /// The meeting ID to verify
  final String meetingId;
  
  /// The meeting data to verify
  final MeetingModel meeting;

  /// Constructor
  const NfcVerificationScreen({
    Key? key,
    required this.meetingId,
    required this.meeting,
  }) : super(key: key);

  @override
  State<NfcVerificationScreen> createState() => _NfcVerificationScreenState();
}

class _NfcVerificationScreenState extends State<NfcVerificationScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize NFC when screen loads
    context.read<NfcVerificationBloc>().add(InitializeNfcEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Verify Meeting'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Stop NFC session before navigating back
            context.read<NfcVerificationBloc>().add(StopNfcSessionEvent());
            context.pop();
          },
        ),
      ),
      body: BlocConsumer<NfcVerificationBloc, NfcVerificationState>(
        listener: (context, state) {
          if (state is NfcVerificationErrorState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is MeetingVerifiedState) {
            // Show success and navigate back to meeting details
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Meeting verified successfully!')),
            );
            Future.delayed(const Duration(seconds: 2), () {
              context.pop(true); // Return true to indicate successful verification
            });
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildNfcStatusCard(context, state),
                const SizedBox(height: 24),
                _buildMeetingInfoCard(context),
                const SizedBox(height: 24),
                _buildActionButtons(context, state),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNfcStatusCard(BuildContext context, NfcVerificationState state) {
    String title = 'NFC Verification';
    String message = 'Initializing NFC...';
    IconData icon = Icons.nfc;
    Color iconColor = Colors.blue;
    bool showProgress = true;

    if (state is NfcAvailableState) {
      title = 'NFC Ready';
      message = 'Tap the Start Verification button to begin.';
      showProgress = false;
    } else if (state is NfcNotAvailableState) {
      title = 'NFC Not Available';
      message = state.message;
      icon = Icons.error_outline;
      iconColor = Colors.red;
      showProgress = false;
    } else if (state is NfcSessionInProgressState) {
      title = 'Scanning for NFC';
      message = 'Hold your device near the other participant\'s device.';
      showProgress = true;
    } else if (state is NfcTagDetectedState) {
      title = 'NFC Tag Detected';
      message = 'Verifying meeting information...';
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
      showProgress = true;
    } else if (state is VerifyingMeetingState) {
      title = 'Verifying Meeting';
      message = 'Please wait while we verify the meeting...';
      showProgress = true;
    } else if (state is MeetingVerifiedState) {
      title = 'Meeting Verified!';
      message = 'The meeting has been successfully verified.';
      icon = Icons.verified;
      iconColor = Colors.green;
      showProgress = false;
    } else if (state is NfcVerificationErrorState) {
      title = 'Verification Error';
      message = state.message;
      icon = Icons.error_outline;
      iconColor = Colors.red;
      showProgress = false;
    }

    return BondCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 64,
              color: iconColor,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            if (showProgress) ...[  
              const SizedBox(height: 16),
              const BondProgressIndicator(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeetingInfoCard(BuildContext context) {
    return BondCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Meeting Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Title', widget.meeting.title),
            _buildInfoRow('Date', _formatDate(widget.meeting.scheduledTime)),
            _buildInfoRow('Time', _formatTime(widget.meeting.scheduledTime)),
            _buildInfoRow('Location', widget.meeting.location),
            _buildInfoRow('Duration', '${widget.meeting.durationMinutes} minutes'),
            _buildInfoRow('Status', widget.meeting.status.name.toUpperCase()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, NfcVerificationState state) {
    if (state is NfcNotAvailableState) {
      return BondButton(
        label: 'Back',
        onPressed: () => context.pop(),
      );
    }

    if (state is NfcSessionInProgressState) {
      return BondButton(
        label: 'Cancel Verification',
        variant: BondButtonVariant.secondary,
        onPressed: () {
          context.read<NfcVerificationBloc>().add(StopNfcSessionEvent());
        },
      );
    }

    if (state is NfcTagDetectedState) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BondButton(
            label: 'Verify Meeting',
            onPressed: () {
              context.read<NfcVerificationBloc>().add(
                    VerifyMeetingWithNfcEvent(
                      meetingId: widget.meetingId,
                      nfcData: state.tagData,
                    ),
                  );
            },
          ),
          const SizedBox(height: 8),
          BondButton(
            label: 'Cancel',
            variant: BondButtonVariant.secondary,
            onPressed: () {
              context.read<NfcVerificationBloc>().add(StopNfcSessionEvent());
            },
          ),
        ],
      );
    }

    if (state is MeetingVerifiedState) {
      return BondButton(
        label: 'Back to Meeting',
        onPressed: () => context.pop(true),
      );
    }

    // Default case for NfcAvailableState or other states
    return BondButton(
      label: 'Start Verification',
      onPressed: state is NfcAvailableState
          ? () {
              context
                  .read<NfcVerificationBloc>()
                  .add(StartNfcSessionEvent(widget.meeting));
            }
          : null,
    );
  }

  String _formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
