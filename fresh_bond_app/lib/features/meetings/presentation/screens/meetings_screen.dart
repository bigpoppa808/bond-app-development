import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_bloc.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_event.dart';
import 'package:fresh_bond_app/features/meetings/domain/blocs/meeting_state.dart';
import 'package:fresh_bond_app/features/meetings/domain/models/meeting_model.dart';
import 'package:fresh_bond_app/features/meetings/presentation/widgets/meeting_card.dart';
import 'package:fresh_bond_app/features/meetings/presentation/widgets/meeting_filter_chip.dart';
import 'package:intl/intl.dart';

/// Screen for displaying and managing meetings
class MeetingsScreen extends StatefulWidget {
  /// Constructor
  const MeetingsScreen({Key? key}) : super(key: key);

  @override
  State<MeetingsScreen> createState() => _MeetingsScreenState();
}

class _MeetingsScreenState extends State<MeetingsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
    
    // Load meetings on initial load
    _loadMeetings();
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabChange);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      _loadMeetings();
    }
  }

  void _loadMeetings() {
    if (_tabController.index == 0) {
      context.read<MeetingBloc>().add(const LoadUpcomingMeetingsEvent());
    } else {
      context.read<MeetingBloc>().add(const LoadPastMeetingsEvent());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meetings'),
        centerTitle: true,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
          labelColor: BondColors.primary,
          unselectedLabelColor: BondColors.textSecondary,
          indicatorColor: BondColors.primary,
          indicatorSize: TabBarIndicatorSize.label,
        ),
      ),
      body: BlocBuilder<MeetingBloc, MeetingState>(
        builder: (context, state) {
          // Handle different states
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
                    onPressed: _loadMeetings,
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Upcoming meetings tab
              _buildUpcomingMeetingsTab(state),
              
              // Past meetings tab
              _buildPastMeetingsTab(state),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to create meeting screen
          Navigator.of(context).pushNamed('/meetings/create');
        },
        child: const Icon(Icons.add),
        tooltip: 'Create Meeting',
      ),
    );
  }

  Widget _buildUpcomingMeetingsTab(MeetingState state) {
    final meetings = state is UpcomingMeetingsLoadedState
        ? state.meetings
        : <MeetingModel>[];
    
    if (meetings.isEmpty) {
      return _buildEmptyState(
        'No upcoming meetings',
        'Schedule a meeting by tapping the + button',
        Icons.calendar_today,
      );
    }
    
    return Column(
      children: [
        // Filter chips
        _buildFilterChips(),
        
        // Meetings list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: meetings.length,
            itemBuilder: (context, index) {
              final meeting = meetings[index];
              return MeetingCard(
                meeting: meeting,
                isUpcoming: true,
                onTap: () {
                  // Navigate to meeting details
                  Navigator.of(context).pushNamed(
                    '/meetings/details',
                    arguments: meeting.id,
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPastMeetingsTab(MeetingState state) {
    final meetings = state is PastMeetingsLoadedState
        ? state.meetings
        : <MeetingModel>[];
    
    if (meetings.isEmpty) {
      return _buildEmptyState(
        'No past meetings',
        'Your completed meetings will appear here',
        Icons.history,
      );
    }
    
    // Group meetings by month
    final groupedMeetings = <String, List<MeetingModel>>{};
    final dateFormat = DateFormat('MMMM yyyy');
    
    for (final meeting in meetings) {
      final monthYear = dateFormat.format(meeting.scheduledTime);
      if (!groupedMeetings.containsKey(monthYear)) {
        groupedMeetings[monthYear] = [];
      }
      groupedMeetings[monthYear]!.add(meeting);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedMeetings.length,
      itemBuilder: (context, index) {
        final monthYear = groupedMeetings.keys.elementAt(index);
        final monthMeetings = groupedMeetings[monthYear]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                monthYear,
                style: BondTypography.subtitle1.copyWith(
                  color: BondColors.textSecondary,
                ),
              ),
            ),
            ...monthMeetings.map((meeting) => MeetingCard(
              meeting: meeting,
              isUpcoming: false,
              onTap: () {
                // Navigate to meeting details
                Navigator.of(context).pushNamed(
                  '/meetings/details',
                  arguments: meeting.id,
                );
              },
            )),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 56,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
        children: [
          MeetingFilterChip(
            label: 'All',
            isSelected: true,
            onSelected: (selected) {
              if (selected) {
                context.read<MeetingBloc>().add(const LoadUpcomingMeetingsEvent());
              }
            },
          ),
          const SizedBox(width: 8),
          MeetingFilterChip(
            label: 'Pending',
            isSelected: false,
            onSelected: (selected) {
              if (selected) {
                context.read<MeetingBloc>().add(
                  const LoadMeetingsByStatusEvent(MeetingStatus.pending),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          MeetingFilterChip(
            label: 'Confirmed',
            isSelected: false,
            onSelected: (selected) {
              if (selected) {
                context.read<MeetingBloc>().add(
                  const LoadMeetingsByStatusEvent(MeetingStatus.confirmed),
                );
              }
            },
          ),
          const SizedBox(width: 8),
          MeetingFilterChip(
            label: 'Rescheduled',
            isSelected: false,
            onSelected: (selected) {
              if (selected) {
                context.read<MeetingBloc>().add(
                  const LoadMeetingsByStatusEvent(MeetingStatus.rescheduled),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, String subtitle, IconData icon) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 72,
              color: BondColors.slate,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: BondTypography.heading3,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: BondTypography.body1.copyWith(
                color: BondColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}