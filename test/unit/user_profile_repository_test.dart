import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/user_data_path_resolver.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/entities/app_user.dart';
import 'package:proposal_writer/domain/entities/user_profile.dart';
import 'package:proposal_writer/domain/repositories/auth_repository.dart';

class FakeAuthRepository implements AuthRepository {
  const FakeAuthRepository(this.user);

  final AppUser user;

  @override
  Future<Result<AppUser>> ensureSignedIn() async => Success(user);

  @override
  Future<Result<AppUser>> signInAnonymously() async => Success(user);

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Stream<AppUser?> watchCurrentUser() => Stream.value(user);
}

void main() {
  test('FirestoreUserProfileRepository saves and loads a profile', () async {
    final firestore = FakeFirebaseFirestore();
    const resolver = UserDataPathResolver();
    final repository = FirestoreUserProfileRepository(
      firestore: firestore,
      authRepository: const FakeAuthRepository(
        AppUser(id: 'user-123', isAnonymous: true),
      ),
      pathResolver: resolver,
      migration: FirestoreUserProfileMigration(
        firestore: firestore,
        pathResolver: resolver,
      ),
    );
    const profile = UserProfile(
      fullName: 'Jane Doe',
      email: 'jane@example.com',
      professionalTitle: 'Designer',
      about: 'Product designer with proposal writing experience.',
      cvText: 'Led discovery, design, and delivery.',
      profileImageUrl: 'https://example.com/jane.png',
      portfolioLinks: ['https://portfolio.example.com'],
      education: ['BSc Design'],
    );

    final saveResult = await repository.saveProfile(profile);
    final loadResult = await repository.loadProfile();

    expect(saveResult, isA<Success<void>>());
    expect(loadResult, isA<Success<UserProfile?>>());
    loadResult.when(
      success: (loadedProfile) {
        expect(loadedProfile, isNotNull);
        expect(loadedProfile?.fullName, profile.fullName);
        expect(loadedProfile?.portfolioLinks, profile.portfolioLinks);
        expect(loadedProfile?.education, profile.education);
      },
      failure: (_) => fail('Expected profile load to succeed'),
    );

    final scopedSnapshot = await firestore
        .doc('users/user-123/profiles/primary')
        .get();
    final legacySnapshot = await firestore.doc('user_profiles/primary').get();

    expect(scopedSnapshot.exists, isTrue);
    expect(legacySnapshot.exists, isFalse);
  });

  test('profile migration keeps an existing scoped profile', () async {
    final firestore = FakeFirebaseFirestore();
    const resolver = UserDataPathResolver();
    await firestore.doc('users/user-123/profiles/primary').set({
      'fullName': 'Current Profile',
      'email': 'current@example.com',
    });
    await firestore.doc('user_profiles/primary').set({
      'fullName': 'Legacy Profile',
      'email': 'legacy@example.com',
    });
    final repository = FirestoreUserProfileRepository(
      firestore: firestore,
      authRepository: const FakeAuthRepository(
        AppUser(id: 'user-123', isAnonymous: true),
      ),
      pathResolver: resolver,
      migration: FirestoreUserProfileMigration(
        firestore: firestore,
        pathResolver: resolver,
      ),
    );

    final loadResult = await repository.loadProfile();

    loadResult.when(
      success: (profile) {
        expect(profile?.fullName, 'Current Profile');
        expect(profile?.email, 'current@example.com');
      },
      failure: (_) => fail('Expected profile load to succeed'),
    );
    final scopedSnapshot = await firestore
        .doc('users/user-123/profiles/primary')
        .get();
    expect(scopedSnapshot.data()?['fullName'], 'Current Profile');
  });

  test('profile migration copies the legacy profile once', () async {
    final firestore = FakeFirebaseFirestore();
    const resolver = UserDataPathResolver();
    await firestore.doc('user_profiles/primary').set({
      'fullName': 'Legacy Profile',
      'email': 'legacy@example.com',
    });
    final migration = FirestoreUserProfileMigration(
      firestore: firestore,
      pathResolver: resolver,
    );
    final repository = FirestoreUserProfileRepository(
      firestore: firestore,
      authRepository: const FakeAuthRepository(
        AppUser(id: 'user-123', isAnonymous: true),
      ),
      pathResolver: resolver,
      migration: migration,
    );

    final firstLoad = await repository.loadProfile();
    await firestore.doc('user_profiles/primary').set({
      'fullName': 'Changed Legacy Profile',
      'email': 'changed@example.com',
    });
    final secondLoad = await repository.loadProfile();

    firstLoad.when(
      success: (profile) => expect(profile?.fullName, 'Legacy Profile'),
      failure: (_) => fail('Expected first load to succeed'),
    );
    secondLoad.when(
      success: (profile) => expect(profile?.fullName, 'Legacy Profile'),
      failure: (_) => fail('Expected second load to succeed'),
    );

    final userSnapshot = await firestore.doc('users/user-123').get();
    expect(userSnapshot.data()?['legacyProfileMigratedAt'], isNotNull);
  });

  test(
    'profile migration returns no profile when legacy data is absent',
    () async {
      final firestore = FakeFirebaseFirestore();
      const resolver = UserDataPathResolver();
      final repository = FirestoreUserProfileRepository(
        firestore: firestore,
        authRepository: const FakeAuthRepository(
          AppUser(id: 'user-123', isAnonymous: true),
        ),
        pathResolver: resolver,
        migration: FirestoreUserProfileMigration(
          firestore: firestore,
          pathResolver: resolver,
        ),
      );

      final loadResult = await repository.loadProfile();

      loadResult.when(
        success: (profile) => expect(profile, isNull),
        failure: (_) => fail('Expected profile load to succeed'),
      );
    },
  );
}
