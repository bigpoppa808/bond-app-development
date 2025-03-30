import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fresh_bond_app/core/utils/logger.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_bloc.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_event.dart';
import 'package:fresh_bond_app/features/notifications/domain/blocs/notification_state.dart';
import 'package:fresh_bond_app/features/notifications/domain/models/notification_model.dart';
import 'package:fresh_bond_app/features/notifications/domain/repositories/notification_repository.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

// Generate mock classes
@GenerateMocks([NotificationRepository])
import 'notification_bloc_test.mocks.dart';

void main() {
  late NotificationBloc notificationBloc;
  late MockNotificationRepository mockRepository;
  late AppLogger logger;

  // Sample notifications for testing
  final List<NotificationModel> mockNotifications = [
    NotificationModel(
      id: '1',
      title: 'Test Notification 1',
      body: 'This is a test notification',
      type: NotificationType.connectionRequest,
      createdAt: DateTime.now(),
      userId: 'user1',
      isRead: false,
    ),
    NotificationModel(
      id: '2',
      title: 'Test Notification 2',
      body: 'This is another test notification',
      type: NotificationType.message,
      createdAt: DateTime.now(),
      userId: 'user2',
      isRead: true,
    ),
  ];

  setUp(() {
    mockRepository = MockNotificationRepository();
    logger = AppLogger.instance;
    notificationBloc = NotificationBloc(
      notificationRepository: mockRepository,
      logger: logger,
    );
  });

  tearDown(() {
    notificationBloc.close();
  });

  group('NotificationBloc', () {
    test('initial state should be NotificationInitialState', () {
      expect(notificationBloc.state, isA<NotificationInitialState>());
    });

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoadingState, NotificationsLoadedState] when LoadAllNotificationsEvent is added',
      build: () {
        when(mockRepository.getAllNotifications())
            .thenAnswer((_) async => mockNotifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(const LoadAllNotificationsEvent()),
      expect: () => [
        isA<NotificationLoadingState>(),
        isA<NotificationsLoadedState>(),
      ],
      verify: (_) {
        verify(mockRepository.getAllNotifications()).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoadingState, UnreadNotificationsLoadedState] when LoadUnreadNotificationsEvent is added',
      build: () {
        when(mockRepository.getUnreadNotifications())
            .thenAnswer((_) async => mockNotifications.where((n) => !n.isRead).toList());
        return notificationBloc;
      },
      act: (bloc) => bloc.add(const LoadUnreadNotificationsEvent()),
      expect: () => [
        isA<NotificationLoadingState>(),
        isA<UnreadNotificationsLoadedState>(),
      ],
      verify: (_) {
        verify(mockRepository.getUnreadNotifications()).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationMarkedAsReadState] when MarkNotificationAsReadEvent is added',
      build: () {
        when(mockRepository.markAsRead('1'))
            .thenAnswer((_) async => true);
        when(mockRepository.getAllNotifications())
            .thenAnswer((_) async => mockNotifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(const MarkNotificationAsReadEvent('1')),
      expect: () => [
        isA<NotificationMarkedAsReadState>(),
        isA<NotificationLoadingState>(),
        isA<NotificationsLoadedState>(),
      ],
      verify: (_) {
        verify(mockRepository.markAsRead('1')).called(1);
        verify(mockRepository.getAllNotifications()).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [AllNotificationsMarkedAsReadState] when MarkAllNotificationsAsReadEvent is added',
      build: () {
        when(mockRepository.markAllAsRead())
            .thenAnswer((_) async => true);
        when(mockRepository.getAllNotifications())
            .thenAnswer((_) async => mockNotifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(const MarkAllNotificationsAsReadEvent()),
      expect: () => [
        isA<AllNotificationsMarkedAsReadState>(),
        isA<NotificationLoadingState>(),
        isA<NotificationsLoadedState>(),
      ],
      verify: (_) {
        verify(mockRepository.markAllAsRead()).called(1);
        verify(mockRepository.getAllNotifications()).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationDeletedState] when DeleteNotificationEvent is added',
      build: () {
        when(mockRepository.deleteNotification('1'))
            .thenAnswer((_) async => true);
        when(mockRepository.getAllNotifications())
            .thenAnswer((_) async => mockNotifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(const DeleteNotificationEvent('1')),
      expect: () => [
        isA<NotificationDeletedState>(),
        isA<NotificationLoadingState>(),
        isA<NotificationsLoadedState>(),
      ],
      verify: (_) {
        verify(mockRepository.deleteNotification('1')).called(1);
        verify(mockRepository.getAllNotifications()).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [AllNotificationsDeletedState] when DeleteAllNotificationsEvent is added',
      build: () {
        when(mockRepository.deleteAllNotifications())
            .thenAnswer((_) async => true);
        when(mockRepository.getAllNotifications())
            .thenAnswer((_) async => mockNotifications);
        return notificationBloc;
      },
      act: (bloc) => bloc.add(const DeleteAllNotificationsEvent()),
      expect: () => [
        isA<AllNotificationsDeletedState>(),
        isA<NotificationLoadingState>(),
        isA<NotificationsLoadedState>(),
      ],
      verify: (_) {
        verify(mockRepository.deleteAllNotifications()).called(1);
        verify(mockRepository.getAllNotifications()).called(1);
      },
    );

    blocTest<NotificationBloc, NotificationState>(
      'emits [NotificationLoadingState, NotificationErrorState] when LoadAllNotificationsEvent is added and repository throws',
      build: () {
        when(mockRepository.getAllNotifications())
            .thenThrow(Exception('Failed to load notifications'));
        return notificationBloc;
      },
      act: (bloc) => bloc.add(const LoadAllNotificationsEvent()),
      expect: () => [
        isA<NotificationLoadingState>(),
        isA<NotificationErrorState>(),
      ],
      verify: (_) {
        verify(mockRepository.getAllNotifications()).called(1);
      },
    );
  });
}
