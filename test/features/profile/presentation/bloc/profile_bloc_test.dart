import 'package:bloc_test/bloc_test.dart';
import 'package:bond_app/features/profile/data/models/profile_model.dart';
import 'package:bond_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:bond_app/features/profile/presentation/bloc/profile_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockProfileRepository extends Mock implements ProfileRepository {}
class FakeProfileModel extends Fake implements ProfileModel {}

void main() {
  late ProfileBloc profileBloc;
  late MockProfileRepository mockProfileRepository;

  setUp(() {
    mockProfileRepository = MockProfileRepository();
    profileBloc = ProfileBloc(profileRepository: mockProfileRepository);
    registerFallbackValue(FakeProfileModel());
  });

  tearDown(() {
    profileBloc.close();
  });

  group('ProfileBloc', () {
    final testUserId = 'test_user_id';
    final testProfile = ProfileModel.create(userId: testUserId).copyWith(
      occupation: 'Software Engineer',
      education: 'Computer Science',
      languages: ['English', 'Spanish'],
      hobbies: ['Coding', 'Reading'],
      skills: ['Flutter', 'Dart'],
      isPublic: true,
      lastUpdated: DateTime(2023, 1, 1),
    );

    test('initial state is ProfileInitial', () {
      expect(profileBloc.state, isA<ProfileInitial>());
    });

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileLoaded] when LoadProfile is added and successful',
      build: () {
        when(() => mockProfileRepository.getProfile(testUserId))
            .thenAnswer((_) async => testProfile);
        return profileBloc;
      },
      act: (bloc) => bloc.add(LoadProfile(testUserId)),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.getProfile(testUserId)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when LoadProfile is added and profile not found',
      build: () {
        when(() => mockProfileRepository.getProfile(testUserId))
            .thenAnswer((_) async => null);
        return profileBloc;
      },
      act: (bloc) => bloc.add(LoadProfile(testUserId)),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.getProfile(testUserId)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when LoadProfile is added and repository throws',
      build: () {
        when(() => mockProfileRepository.getProfile(testUserId))
            .thenThrow(Exception('Test error'));
        return profileBloc;
      },
      act: (bloc) => bloc.add(LoadProfile(testUserId)),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.getProfile(testUserId)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileCreating, ProfileCreated, ProfileLoaded] when CreateProfile is added and successful',
      build: () {
        when(() => mockProfileRepository.createProfile(any()))
            .thenAnswer((_) async => testProfile);
        return profileBloc;
      },
      act: (bloc) => bloc.add(CreateProfile(testProfile)),
      expect: () => [
        isA<ProfileCreating>(),
        isA<ProfileCreated>(),
        isA<ProfileLoaded>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.createProfile(any())).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileCreating, ProfileError] when CreateProfile is added and repository throws',
      build: () {
        when(() => mockProfileRepository.createProfile(any()))
            .thenThrow(Exception('Test error'));
        return profileBloc;
      },
      act: (bloc) => bloc.add(CreateProfile(testProfile)),
      expect: () => [
        isA<ProfileCreating>(),
        isA<ProfileError>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.createProfile(any())).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileUpdating, ProfileUpdated, ProfileLoaded] when UpdateProfile is added and successful',
      build: () {
        when(() => mockProfileRepository.updateProfile(any()))
            .thenAnswer((_) async => testProfile);
        return profileBloc;
      },
      act: (bloc) => bloc.add(UpdateProfile(testProfile)),
      expect: () => [
        isA<ProfileUpdating>(),
        isA<ProfileUpdated>(),
        isA<ProfileLoaded>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.updateProfile(any())).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileUpdating, ProfileError] when UpdateProfile is added and repository throws',
      build: () {
        when(() => mockProfileRepository.updateProfile(any()))
            .thenThrow(Exception('Test error'));
        return profileBloc;
      },
      act: (bloc) => bloc.add(UpdateProfile(testProfile)),
      expect: () => [
        isA<ProfileUpdating>(),
        isA<ProfileError>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.updateProfile(any())).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileDeleting, ProfileDeleted, ProfileInitial] when DeleteProfile is added and successful',
      build: () {
        when(() => mockProfileRepository.deleteProfile(testUserId))
            .thenAnswer((_) async => {});
        return profileBloc;
      },
      act: (bloc) => bloc.add(DeleteProfile(testUserId)),
      expect: () => [
        isA<ProfileDeleting>(),
        isA<ProfileDeleted>(),
        isA<ProfileInitial>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.deleteProfile(testUserId)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileDeleting, ProfileError] when DeleteProfile is added and repository throws',
      build: () {
        when(() => mockProfileRepository.deleteProfile(testUserId))
            .thenThrow(Exception('Test error'));
        return profileBloc;
      },
      act: (bloc) => bloc.add(DeleteProfile(testUserId)),
      expect: () => [
        isA<ProfileDeleting>(),
        isA<ProfileError>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.deleteProfile(testUserId)).called(1);
      },
    );

    final testPhotoUrl = 'https://example.com/photo.jpg';
    final testFilePath = '/path/to/photo.jpg';

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfilePhotoUploading, ProfilePhotoUploaded] when UploadProfilePhoto is added and successful',
      build: () {
        when(() => mockProfileRepository.uploadProfilePhoto(testUserId, testFilePath))
            .thenAnswer((_) async => testPhotoUrl);
        when(() => mockProfileRepository.getProfile(testUserId))
            .thenAnswer((_) async => testProfile);
        return profileBloc;
      },
      act: (bloc) => bloc.add(UploadProfilePhoto(testUserId, testFilePath)),
      expect: () => [
        isA<ProfilePhotoUploading>(),
        isA<ProfilePhotoUploaded>(),
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.uploadProfilePhoto(testUserId, testFilePath)).called(1);
        verify(() => mockProfileRepository.getProfile(testUserId)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfilePhotoUploading, ProfileError] when UploadProfilePhoto is added and repository throws',
      build: () {
        when(() => mockProfileRepository.uploadProfilePhoto(testUserId, testFilePath))
            .thenThrow(Exception('Test error'));
        return profileBloc;
      },
      act: (bloc) => bloc.add(UploadProfilePhoto(testUserId, testFilePath)),
      expect: () => [
        isA<ProfilePhotoUploading>(),
        isA<ProfileError>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.uploadProfilePhoto(testUserId, testFilePath)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfilePhotoDeleting, ProfilePhotoDeleted] when DeleteProfilePhoto is added and successful',
      build: () {
        when(() => mockProfileRepository.deleteProfilePhoto(testUserId, testPhotoUrl))
            .thenAnswer((_) async => {});
        when(() => mockProfileRepository.getProfile(testUserId))
            .thenAnswer((_) async => testProfile);
        return profileBloc;
      },
      act: (bloc) => bloc.add(DeleteProfilePhoto(testUserId, testPhotoUrl)),
      expect: () => [
        isA<ProfilePhotoDeleting>(),
        isA<ProfilePhotoDeleted>(),
        isA<ProfileLoading>(),
        isA<ProfileLoaded>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.deleteProfilePhoto(testUserId, testPhotoUrl)).called(1);
        verify(() => mockProfileRepository.getProfile(testUserId)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfilePhotoDeleting, ProfileError] when DeleteProfilePhoto is added and repository throws',
      build: () {
        when(() => mockProfileRepository.deleteProfilePhoto(testUserId, testPhotoUrl))
            .thenThrow(Exception('Test error'));
        return profileBloc;
      },
      act: (bloc) => bloc.add(DeleteProfilePhoto(testUserId, testPhotoUrl)),
      expect: () => [
        isA<ProfilePhotoDeleting>(),
        isA<ProfileError>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.deleteProfilePhoto(testUserId, testPhotoUrl)).called(1);
      },
    );

    final testInterests = ['Coding', 'Reading'];
    final testProfiles = [testProfile];

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfilesLoaded] when LoadProfilesByInterests is added and successful',
      build: () {
        when(() => mockProfileRepository.getProfilesByInterests(testInterests, limit: 10))
            .thenAnswer((_) async => testProfiles);
        return profileBloc;
      },
      act: (bloc) => bloc.add(LoadProfilesByInterests(testInterests)),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfilesLoaded>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.getProfilesByInterests(testInterests, limit: 10)).called(1);
      },
    );

    blocTest<ProfileBloc, ProfileState>(
      'emits [ProfileLoading, ProfileError] when LoadProfilesByInterests is added and repository throws',
      build: () {
        when(() => mockProfileRepository.getProfilesByInterests(testInterests, limit: 10))
            .thenThrow(Exception('Test error'));
        return profileBloc;
      },
      act: (bloc) => bloc.add(LoadProfilesByInterests(testInterests)),
      expect: () => [
        isA<ProfileLoading>(),
        isA<ProfileError>(),
      ],
      verify: (_) {
        verify(() => mockProfileRepository.getProfilesByInterests(testInterests, limit: 10)).called(1);
      },
    );
  });
}
