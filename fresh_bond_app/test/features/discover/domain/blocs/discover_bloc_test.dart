import 'package:flutter_test/flutter_test.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/discover/domain/blocs/discover_bloc.dart';
import 'package:fresh_bond_app/features/discover/domain/blocs/discover_event.dart';
import 'package:fresh_bond_app/features/discover/domain/blocs/discover_state.dart';
import 'package:fresh_bond_app/features/discover/domain/models/connection_model.dart';
import 'package:fresh_bond_app/features/discover/domain/repositories/connections_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'discover_bloc_test.mocks.dart';

@GenerateMocks([ConnectionsRepository, AppLogger])
void main() {
  late MockConnectionsRepository mockConnectionsRepository;
  late MockAppLogger mockLogger;
  late DiscoverBloc discoverBloc;

  setUp(() {
    mockConnectionsRepository = MockConnectionsRepository();
    mockLogger = MockAppLogger();
    discoverBloc = DiscoverBloc(
      connectionsRepository: mockConnectionsRepository,
      logger: mockLogger,
    );
  });

  tearDown(() {
    discoverBloc.close();
  });

  test('initial state should be DiscoverInitialState', () {
    expect(discoverBloc.state, isA<DiscoverInitialState>());
  });

  group('LoadRecommendedConnectionsEvent', () {
    final mockConnections = [
      ConnectionModel(
        id: '1',
        name: 'John Doe',
        bio: 'Software Engineer',
        type: ConnectionType.friend,
        isConnected: false,
        mutualConnections: [],
      ),
      ConnectionModel(
        id: '2',
        name: 'Jane Smith',
        bio: 'Product Manager',
        type: ConnectionType.colleague,
        isConnected: false,
        mutualConnections: ['Mike', 'Sarah'],
      ),
    ];

    blocTest<DiscoverBloc, DiscoverState>(
      'emits [DiscoverLoadingState, RecommendedConnectionsLoadedState] when successful',
      build: () {
        when(mockConnectionsRepository.getRecommendedConnections())
            .thenAnswer((_) async => mockConnections);
        return discoverBloc;
      },
      act: (bloc) => bloc.add(const LoadRecommendedConnectionsEvent()),
      expect: () => [
        isA<DiscoverLoadingState>(),
        isA<RecommendedConnectionsLoadedState>(),
      ],
      verify: (_) {
        verify(mockConnectionsRepository.getRecommendedConnections()).called(1);
        verify(mockLogger.d(any)).called(1);
      },
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'emits [DiscoverLoadingState, DiscoverErrorState] when exception occurs',
      build: () {
        when(mockConnectionsRepository.getRecommendedConnections())
            .thenThrow(Exception('Network error'));
        return discoverBloc;
      },
      act: (bloc) => bloc.add(const LoadRecommendedConnectionsEvent()),
      expect: () => [
        isA<DiscoverLoadingState>(),
        isA<DiscoverErrorState>(),
      ],
      verify: (_) {
        verify(mockConnectionsRepository.getRecommendedConnections()).called(1);
        verify(mockLogger.e(any, error: anyNamed('error'))).called(1);
      },
    );
  });

  group('SearchConnectionsEvent', () {
    final mockSearchResults = [
      ConnectionModel(
        id: '2',
        name: 'Jane Smith',
        bio: 'Product Manager',
        type: ConnectionType.colleague,
        isConnected: false,
        mutualConnections: ['Mike', 'Sarah'],
      ),
    ];

    blocTest<DiscoverBloc, DiscoverState>(
      'emits [DiscoverLoadingState, SearchResultsLoadedState] when successful',
      build: () {
        when(mockConnectionsRepository.searchConnections('Jane'))
            .thenAnswer((_) async => mockSearchResults);
        return discoverBloc;
      },
      act: (bloc) => bloc.add(const SearchConnectionsEvent('Jane')),
      expect: () => [
        isA<DiscoverLoadingState>(),
        isA<SearchResultsLoadedState>(),
      ],
      verify: (_) {
        verify(mockConnectionsRepository.searchConnections('Jane')).called(1);
        verify(mockLogger.d(any)).called(1);
      },
    );

    blocTest<DiscoverBloc, DiscoverState>(
      'calls LoadRecommendedConnectionsEvent when query is empty',
      build: () {
        when(mockConnectionsRepository.getRecommendedConnections())
            .thenAnswer((_) async => []);
        return discoverBloc;
      },
      act: (bloc) => bloc.add(const SearchConnectionsEvent('')),
      verify: (_) {
        verify(mockConnectionsRepository.getRecommendedConnections()).called(1);
      },
    );
  });

  group('SendConnectionRequestEvent', () {
    blocTest<DiscoverBloc, DiscoverState>(
      'emits [ConnectionRequestSentState] when successful and refreshes connections',
      build: () {
        when(mockConnectionsRepository.sendConnectionRequest('1'))
            .thenAnswer((_) async => true);
        when(mockConnectionsRepository.getRecommendedConnections())
            .thenAnswer((_) async => []);
        return discoverBloc;
      },
      act: (bloc) => bloc.add(const SendConnectionRequestEvent('1')),
      expect: () => [
        isA<ConnectionRequestSentState>(),
        isA<DiscoverLoadingState>(),
        isA<RecommendedConnectionsLoadedState>(),
      ],
      verify: (_) {
        verify(mockConnectionsRepository.sendConnectionRequest('1')).called(1);
        verify(mockConnectionsRepository.getRecommendedConnections()).called(1);
        verify(mockLogger.d(any)).called(2);
      },
    );
  });

  // Tests for other events would follow a similar pattern
}
