import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bond_app/features/connections/data/models/connection_model.dart';
import 'package:bond_app/features/connections/domain/repositories/connection_repository.dart';
import 'package:bond_app/features/connections/presentation/bloc/connection_event.dart';
import 'package:bond_app/features/connections/presentation/bloc/connection_state.dart';

/// BLoC for managing connections
class ConnectionBloc extends Bloc<ConnectionEvent, ConnectionState> {
  final ConnectionRepository _connectionRepository;
  StreamSubscription? _connectionsSubscription;
  StreamSubscription? _pendingRequestsSubscription;

  /// Constructor
  ConnectionBloc({
    required ConnectionRepository connectionRepository,
  })  : _connectionRepository = connectionRepository,
        super(ConnectionInitial()) {
    on<LoadConnections>(_onLoadConnections);
    on<LoadPendingRequests>(_onLoadPendingRequests);
    on<LoadSentRequests>(_onLoadSentRequests);
    on<SendConnectionRequest>(_onSendConnectionRequest);
    on<AcceptConnectionRequest>(_onAcceptConnectionRequest);
    on<DeclineConnectionRequest>(_onDeclineConnectionRequest);
    on<BlockConnection>(_onBlockConnection);
    on<MarkConnectionReadBySender>(_onMarkConnectionReadBySender);
    on<MarkConnectionReadByReceiver>(_onMarkConnectionReadByReceiver);
    on<DeleteConnection>(_onDeleteConnection);
    on<RefreshConnections>(_onRefreshConnections);
  }

  Future<void> _onLoadConnections(
    LoadConnections event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(ConnectionsLoading());
    try {
      // Cancel any existing subscription
      await _connectionsSubscription?.cancel();
      
      // Set up a new subscription to the connections stream
      _connectionsSubscription = _connectionRepository
          .connectionsStream(event.userId)
          .listen((connections) {
        add(RefreshConnections(userId: event.userId));
      });
      
      // Load the initial connections
      final connections = await _connectionRepository.getUserConnections(event.userId);
      emit(ConnectionsLoaded(connections: connections));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to load connections: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPendingRequests(
    LoadPendingRequests event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(ConnectionsLoading());
    try {
      // Cancel any existing subscription
      await _pendingRequestsSubscription?.cancel();
      
      // Set up a new subscription to the pending requests stream
      _pendingRequestsSubscription = _connectionRepository
          .pendingRequestsStream(event.userId)
          .listen((pendingRequests) {
        add(RefreshConnections(userId: event.userId));
      });
      
      // Load the initial pending requests
      final pendingRequests = await _connectionRepository.getPendingRequests(event.userId);
      emit(PendingRequestsLoaded(pendingRequests: pendingRequests));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to load pending requests: ${e.toString()}'));
    }
  }

  Future<void> _onLoadSentRequests(
    LoadSentRequests event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(ConnectionsLoading());
    try {
      final sentRequests = await _connectionRepository.getSentRequests(event.userId);
      emit(SentRequestsLoaded(sentRequests: sentRequests));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to load sent requests: ${e.toString()}'));
    }
  }

  Future<void> _onSendConnectionRequest(
    SendConnectionRequest event,
    Emitter<ConnectionState> emit,
  ) async {
    emit(ConnectionsLoading());
    try {
      final connection = await _connectionRepository.sendConnectionRequest(
        senderId: event.senderId,
        receiverId: event.receiverId,
        message: event.message,
      );
      emit(ConnectionRequestSent(connection: connection));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to send connection request: ${e.toString()}'));
    }
  }

  Future<void> _onAcceptConnectionRequest(
    AcceptConnectionRequest event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final connection = await _connectionRepository.acceptRequest(event.connectionId);
      emit(ConnectionRequestAccepted(connection: connection));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to accept connection request: ${e.toString()}'));
    }
  }

  Future<void> _onDeclineConnectionRequest(
    DeclineConnectionRequest event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final connection = await _connectionRepository.declineRequest(event.connectionId);
      emit(ConnectionRequestDeclined(connection: connection));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to decline connection request: ${e.toString()}'));
    }
  }

  Future<void> _onBlockConnection(
    BlockConnection event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final connection = await _connectionRepository.blockConnection(event.connectionId);
      emit(ConnectionBlocked(connection: connection));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to block connection: ${e.toString()}'));
    }
  }

  Future<void> _onMarkConnectionReadBySender(
    MarkConnectionReadBySender event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final connection = await _connectionRepository.markReadBySender(event.connectionId);
      emit(ConnectionMarkedAsRead(connection: connection));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to mark connection as read: ${e.toString()}'));
    }
  }

  Future<void> _onMarkConnectionReadByReceiver(
    MarkConnectionReadByReceiver event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final connection = await _connectionRepository.markReadByReceiver(event.connectionId);
      emit(ConnectionMarkedAsRead(connection: connection));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to mark connection as read: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteConnection(
    DeleteConnection event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      await _connectionRepository.deleteConnection(event.connectionId);
      emit(ConnectionDeleted(connectionId: event.connectionId));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to delete connection: ${e.toString()}'));
    }
  }

  Future<void> _onRefreshConnections(
    RefreshConnections event,
    Emitter<ConnectionState> emit,
  ) async {
    try {
      final connections = await _connectionRepository.getUserConnections(event.userId);
      emit(ConnectionsLoaded(connections: connections));
    } catch (e) {
      emit(ConnectionError(message: 'Failed to refresh connections: ${e.toString()}'));
    }
  }

  @override
  Future<void> close() {
    _connectionsSubscription?.cancel();
    _pendingRequestsSubscription?.cancel();
    return super.close();
  }
}
