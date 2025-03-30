import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fresh_bond_app/core/analytics/analytics_service.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/discover/domain/blocs/discover_event.dart';
import 'package:fresh_bond_app/features/discover/domain/blocs/discover_state.dart';
import 'package:fresh_bond_app/features/discover/domain/repositories/connections_repository.dart';

/// BLoC for managing the discover feature and connections
class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  final ConnectionsRepository _connectionsRepository;
  final AppLogger _logger;

  DiscoverBloc({
    required ConnectionsRepository connectionsRepository,
    required AppLogger logger,
  })  : _connectionsRepository = connectionsRepository,
        _logger = logger,
        super(const DiscoverInitialState()) {
    // Register event handlers
    on<LoadRecommendedConnectionsEvent>(_onLoadRecommendedConnections);
    on<SearchConnectionsEvent>(_onSearchConnections);
    on<SendConnectionRequestEvent>(_onSendConnectionRequest);
    on<LoadPendingRequestsEvent>(_onLoadPendingRequests);
    on<AcceptConnectionRequestEvent>(_onAcceptConnectionRequest);
    on<RejectConnectionRequestEvent>(_onRejectConnectionRequest);
    on<ClearSearchEvent>(_onClearSearch);
  }

  /// Handle loading recommended connections
  Future<void> _onLoadRecommendedConnections(
    LoadRecommendedConnectionsEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    try {
      _logger.d('Loading recommended connections');
      emit(const DiscoverLoadingState());
      
      final connections = await _connectionsRepository.getRecommendedConnections();
      
      emit(RecommendedConnectionsLoadedState(connections));
      
      // Track analytics
      AnalyticsService.instance.logEvent('view_recommended_connections', 
        parameters: {'count': connections.length});
    } catch (e) {
      _logger.e('Error loading recommended connections', error: e);
      emit(DiscoverErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error loading recommended connections: ${e.toString()}');
    }
  }

  /// Handle searching for connections
  Future<void> _onSearchConnections(
    SearchConnectionsEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    try {
      if (event.query.isEmpty) {
        add(const LoadRecommendedConnectionsEvent());
        return;
      }
      
      _logger.d('Searching for connections with query: ${event.query}');
      emit(const DiscoverLoadingState());
      
      final results = await _connectionsRepository.searchConnections(event.query);
      
      emit(SearchResultsLoadedState(results, event.query));
      
      // Track analytics
      AnalyticsService.instance.logEvent('search_connections', 
        parameters: {'query': event.query, 'results_count': results.length});
    } catch (e) {
      _logger.e('Error searching for connections', error: e);
      emit(DiscoverErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error searching connections: ${e.toString()}');
    }
  }

  /// Handle sending a connection request
  Future<void> _onSendConnectionRequest(
    SendConnectionRequestEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    try {
      _logger.d('Sending connection request to user: ${event.userId}');
      
      final success = await _connectionsRepository.sendConnectionRequest(event.userId);
      
      if (success) {
        emit(ConnectionRequestSentState(event.userId));
        
        // Refresh connections list
        add(const LoadRecommendedConnectionsEvent());
        
        // Track analytics
        AnalyticsService.instance.logEvent('send_connection_request', 
          parameters: {'user_id': event.userId});
      } else {
        emit(const DiscoverErrorState('Failed to send connection request'));
      }
    } catch (e) {
      _logger.e('Error sending connection request', error: e);
      emit(DiscoverErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error sending connection request: ${e.toString()}');
    }
  }

  /// Handle loading pending connection requests
  Future<void> _onLoadPendingRequests(
    LoadPendingRequestsEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    try {
      _logger.d('Loading pending connection requests');
      emit(const DiscoverLoadingState());
      
      final pendingRequests = await _connectionsRepository.getPendingRequests();
      
      emit(PendingRequestsLoadedState(pendingRequests));
      
      // Track analytics
      AnalyticsService.instance.logEvent('view_pending_requests', 
        parameters: {'count': pendingRequests.length});
    } catch (e) {
      _logger.e('Error loading pending requests', error: e);
      emit(DiscoverErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error loading pending requests: ${e.toString()}');
    }
  }

  /// Handle accepting a connection request
  Future<void> _onAcceptConnectionRequest(
    AcceptConnectionRequestEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    try {
      _logger.d('Accepting connection request from user: ${event.userId}');
      
      final success = await _connectionsRepository.acceptConnectionRequest(event.userId);
      
      if (success) {
        emit(ConnectionRequestAcceptedState(event.userId));
        
        // Refresh pending requests
        add(const LoadPendingRequestsEvent());
        
        // Track analytics
        AnalyticsService.instance.logEvent('accept_connection_request', 
          parameters: {'user_id': event.userId});
      } else {
        emit(const DiscoverErrorState('Failed to accept connection request'));
      }
    } catch (e) {
      _logger.e('Error accepting connection request', error: e);
      emit(DiscoverErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error accepting connection request: ${e.toString()}');
    }
  }

  /// Handle rejecting a connection request
  Future<void> _onRejectConnectionRequest(
    RejectConnectionRequestEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    try {
      _logger.d('Rejecting connection request from user: ${event.userId}');
      
      final success = await _connectionsRepository.rejectConnectionRequest(event.userId);
      
      if (success) {
        emit(ConnectionRequestRejectedState(event.userId));
        
        // Refresh pending requests
        add(const LoadPendingRequestsEvent());
        
        // Track analytics
        AnalyticsService.instance.logEvent('reject_connection_request', 
          parameters: {'user_id': event.userId});
      } else {
        emit(const DiscoverErrorState('Failed to reject connection request'));
      }
    } catch (e) {
      _logger.e('Error rejecting connection request', error: e);
      emit(DiscoverErrorState(e.toString()));
      
      // Track error
      AnalyticsService.instance.logError('Error rejecting connection request: ${e.toString()}');
    }
  }

  /// Handle clearing search results
  void _onClearSearch(
    ClearSearchEvent event,
    Emitter<DiscoverState> emit,
  ) {
    _logger.d('Clearing search results');
    add(const LoadRecommendedConnectionsEvent());
  }
}
