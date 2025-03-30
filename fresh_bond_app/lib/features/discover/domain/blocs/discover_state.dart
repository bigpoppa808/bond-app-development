import 'package:equatable/equatable.dart';
import 'package:fresh_bond_app/features/discover/domain/models/connection_model.dart';

/// Base class for all discover states
abstract class DiscoverState extends Equatable {
  const DiscoverState();

  @override
  List<Object?> get props => [];
}

/// Initial state when bloc is first created
class DiscoverInitialState extends DiscoverState {
  const DiscoverInitialState();
}

/// Loading state while fetching data
class DiscoverLoadingState extends DiscoverState {
  const DiscoverLoadingState();
}

/// State representing successful loading of recommended connections
class RecommendedConnectionsLoadedState extends DiscoverState {
  final List<ConnectionModel> connections;

  const RecommendedConnectionsLoadedState(this.connections);

  @override
  List<Object?> get props => [connections];
}

/// State representing successful search results
class SearchResultsLoadedState extends DiscoverState {
  final List<ConnectionModel> results;
  final String query;

  const SearchResultsLoadedState(this.results, this.query);

  @override
  List<Object?> get props => [results, query];
}

/// State representing successful loading of pending requests
class PendingRequestsLoadedState extends DiscoverState {
  final List<ConnectionModel> pendingRequests;

  const PendingRequestsLoadedState(this.pendingRequests);

  @override
  List<Object?> get props => [pendingRequests];
}

/// State representing a successful connection request
class ConnectionRequestSentState extends DiscoverState {
  final String userId;

  const ConnectionRequestSentState(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// State representing a successful connection request acceptance
class ConnectionRequestAcceptedState extends DiscoverState {
  final String userId;

  const ConnectionRequestAcceptedState(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// State representing a successful connection request rejection
class ConnectionRequestRejectedState extends DiscoverState {
  final String userId;

  const ConnectionRequestRejectedState(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Error state
class DiscoverErrorState extends DiscoverState {
  final String message;

  const DiscoverErrorState(this.message);

  @override
  List<Object?> get props => [message];
}
