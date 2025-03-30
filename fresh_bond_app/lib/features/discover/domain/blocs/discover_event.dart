import 'package:equatable/equatable.dart';

/// Base class for all discover events
abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load recommended connections
class LoadRecommendedConnectionsEvent extends DiscoverEvent {
  const LoadRecommendedConnectionsEvent();
}

/// Event to search for connections
class SearchConnectionsEvent extends DiscoverEvent {
  final String query;

  const SearchConnectionsEvent(this.query);

  @override
  List<Object?> get props => [query];
}

/// Event to send a connection request
class SendConnectionRequestEvent extends DiscoverEvent {
  final String userId;

  const SendConnectionRequestEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to load pending connection requests
class LoadPendingRequestsEvent extends DiscoverEvent {
  const LoadPendingRequestsEvent();
}

/// Event to accept a connection request
class AcceptConnectionRequestEvent extends DiscoverEvent {
  final String userId;

  const AcceptConnectionRequestEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to reject a connection request
class RejectConnectionRequestEvent extends DiscoverEvent {
  final String userId;

  const RejectConnectionRequestEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Event to clear current search results and go back to recommendations
class ClearSearchEvent extends DiscoverEvent {
  const ClearSearchEvent();
}
