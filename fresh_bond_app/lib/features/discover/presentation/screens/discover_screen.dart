import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/design/theme/bond_colors.dart';
import 'package:fresh_bond_app/core/design/theme/bond_spacing.dart';
import 'package:fresh_bond_app/core/design/theme/bond_typography.dart';
import 'package:fresh_bond_app/features/discover/domain/blocs/discover_bloc.dart';
import 'package:fresh_bond_app/features/discover/domain/blocs/discover_event.dart';
import 'package:fresh_bond_app/features/discover/domain/blocs/discover_state.dart';
import 'package:fresh_bond_app/features/discover/domain/models/connection_model.dart';
import 'package:fresh_bond_app/features/discover/presentation/widgets/connection_card.dart';
import 'package:fresh_bond_app/features/discover/presentation/widgets/pending_request_card.dart';
import 'package:go_router/go_router.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Load initial data
    _loadInitialData();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }
  
  void _loadInitialData() {
    context.read<DiscoverBloc>().add(const LoadRecommendedConnectionsEvent());
    context.read<DiscoverBloc>().add(const LoadPendingRequestsEvent());
  }
  
  void _searchConnections() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<DiscoverBloc>().add(SearchConnectionsEvent(query));
    }
  }

  void _clearSearch() {
    _searchController.clear();
    context.read<DiscoverBloc>().add(const ClearSearchEvent());
  }
  
  void _sendConnectionRequest(String userId) {
    context.read<DiscoverBloc>().add(SendConnectionRequestEvent(userId));
  }
  
  void _acceptConnectionRequest(String userId) {
    context.read<DiscoverBloc>().add(AcceptConnectionRequestEvent(userId));
  }
  
  void _rejectConnectionRequest(String userId) {
    context.read<DiscoverBloc>().add(RejectConnectionRequestEvent(userId));
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BondColors.background,
      appBar: AppBar(
        title: const Text('Discover'),
        backgroundColor: BondColors.backgroundSecondary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Discover People'),
            Tab(text: 'Pending Requests'),
          ],
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            // Discover People Tab
            _buildDiscoverTab(),
            // Pending Requests Tab
            _buildPendingRequestsTab(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildDiscoverTab() {
    return Column(
      children: [
        // Search bar
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for people',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
            onSubmitted: (_) => _searchConnections(),
            textInputAction: TextInputAction.search,
          ),
        ),
        
        // Results
        Expanded(
          child: BlocConsumer<DiscoverBloc, DiscoverState>(
            listener: (context, state) {
              if (state is ConnectionRequestSentState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Connection request sent!'),
                    backgroundColor: BondColors.success,
                  ),
                );
              } else if (state is DiscoverErrorState) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: BondColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is DiscoverLoadingState) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is RecommendedConnectionsLoadedState) {
                return _buildConnectionsList(
                  state.connections,
                  title: 'Recommended for You',
                );
              } else if (state is SearchResultsLoadedState) {
                return _buildConnectionsList(
                  state.results,
                  title: 'Search results for "${state.query}"',
                  isSearchResult: true,
                );
              } else if (state is DiscoverErrorState) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: BondColors.error,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Error: ${state.message}',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadInitialData,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              } else {
                return const Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildPendingRequestsTab() {
    return BlocConsumer<DiscoverBloc, DiscoverState>(
      listener: (context, state) {
        if (state is ConnectionRequestAcceptedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Connection request accepted!'),
              backgroundColor: BondColors.success,
            ),
          );
        } else if (state is ConnectionRequestRejectedState) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Connection request rejected'),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is PendingRequestsLoadedState) {
          if (state.pendingRequests.isEmpty) {
            return _buildEmptyPendingRequestsState();
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.pendingRequests.length,
            itemBuilder: (context, index) {
              final request = state.pendingRequests[index];
              return PendingRequestCard(
                connection: request,
                onAccept: () => _acceptConnectionRequest(request.id),
                onReject: () => _rejectConnectionRequest(request.id),
              );
            },
          );
        } else if (state is DiscoverLoadingState) {
          return const Center(child: CircularProgressIndicator());
        } else {
          // Load pending requests if not already loaded
          if (!(state is PendingRequestsLoadedState)) {
            context.read<DiscoverBloc>().add(const LoadPendingRequestsEvent());
          }
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
  
  Widget _buildEmptyPendingRequestsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.mark_email_read,
            color: BondColors.textSecondary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
            'No pending requests',
            style: TextStyle(
              color: BondColors.textSecondary,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyConnectionsState({bool isSearchResult = false}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isSearchResult ? Icons.search_off : Icons.people_outline,
            color: BondColors.textSecondary,
            size: 64,
          ),
          const SizedBox(height: 16),
          Text(
              isSearchResult
                  ? 'No results found'
                  : 'No recommendations available',
              style: TextStyle(
                color: BondColors.textSecondary,
                fontSize: 18,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildConnectionsList(
    List<ConnectionModel> connections, {
    required String title,
    bool isSearchResult = false,
  }) {
    if (connections.isEmpty) {
      return _buildEmptyConnectionsState(isSearchResult: isSearchResult);
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: connections.length + 1, // +1 for the header
      itemBuilder: (context, index) {
        if (index == 0) {
          // Header
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              title,
              style: BondTypography.heading2.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }
        
        final connection = connections[index - 1];
        return ConnectionCard(
          connection: connection,
          onConnect: connection.isConnected 
              ? null 
              : () => _sendConnectionRequest(connection.id),
          onViewProfile: () {
            // Would navigate to profile view in a real implementation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Viewing ${connection.name}\'s profile'),
              ),
            );
          },
        );
      },
    );
  }
}
