import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/auth_repository_impl.dart';
import 'package:proposal_writer/data/user_data_path_resolver.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/entities/app_user.dart';

class FakeAuthGateway implements AuthGateway {
  FakeAuthGateway({this.currentUser, this.signInUser, this.signInError});

  @override
  AppUser? currentUser;

  AppUser? signInUser;
  Exception? signInError;
  int signInCount = 0;
  int signOutCount = 0;

  final _users = const Stream<AppUser?>.empty();

  @override
  Stream<AppUser?> watchCurrentUser() => _users;

  @override
  Future<AppUser> signInAnonymously() async {
    signInCount += 1;
    final error = signInError;
    if (error != null) {
      throw error;
    }
    final user =
        signInUser ?? const AppUser(id: 'anon-user', isAnonymous: true);
    currentUser = user;
    return user;
  }

  @override
  Future<void> signOut() async {
    signOutCount += 1;
    currentUser = null;
  }
}

class RecordingUserDataInitializer implements UserDataInitializer {
  AppUser? initializedUser;
  Exception? error;

  @override
  Future<void> initialize(AppUser user) async {
    final thrown = error;
    if (thrown != null) {
      throw thrown;
    }
    initializedUser = user;
  }
}

class ThrowingUserProfileMigration implements UserProfileMigration {
  const ThrowingUserProfileMigration(this.error);

  final FirebaseException error;

  @override
  Future<void> migrateLegacyPrimaryProfileIfNeeded(String userId) async {
    throw error;
  }
}

void main() {
  group('LocalAuthRepository', () {
    test('exposes a deterministic local user', () async {
      const repository = LocalAuthRepository();

      final result = await repository.ensureSignedIn();

      expect(result, isA<Success<AppUser>>());
      result.when(
        success: (user) {
          expect(user.id, 'local-user');
          expect(user.isAnonymous, isTrue);
        },
        failure: (_) => fail('Expected local user'),
      );
    });
  });

  group('FirebaseAuthRepository', () {
    test('returns the current user without signing in again', () async {
      const user = AppUser(id: 'existing-user', isAnonymous: true);
      final gateway = FakeAuthGateway(currentUser: user);
      final initializer = RecordingUserDataInitializer();
      final repository = FirebaseAuthRepository(
        authGateway: gateway,
        userDataInitializer: initializer,
      );

      final result = await repository.ensureSignedIn();

      expect(result, isA<Success<AppUser>>());
      expect(gateway.signInCount, 0);
      expect(initializer.initializedUser, user);
    });

    test('signs in anonymously when there is no current user', () async {
      const user = AppUser(id: 'new-user', isAnonymous: true);
      final gateway = FakeAuthGateway(signInUser: user);
      final initializer = RecordingUserDataInitializer();
      final repository = FirebaseAuthRepository(
        authGateway: gateway,
        userDataInitializer: initializer,
      );

      final result = await repository.ensureSignedIn();

      expect(result, isA<Success<AppUser>>());
      expect(gateway.signInCount, 1);
      expect(initializer.initializedUser, user);
    });

    test('maps anonymous sign-in failures to AuthenticationFailure', () async {
      final gateway = FakeAuthGateway(signInError: Exception('denied'));
      final repository = FirebaseAuthRepository(
        authGateway: gateway,
        userDataInitializer: const NoopUserDataInitializer(),
      );

      final result = await repository.ensureSignedIn();

      expect(result, isA<FailureResult<AppUser>>());
      result.when(
        success: (_) => fail('Expected auth failure'),
        failure: (failure) {
          expect(failure, isA<AuthenticationFailure>());
          expect(failure.message, contains('anonymous sign-in'));
        },
      );
    });
  });

  group('FirebaseUserDataInitializer', () {
    test('continues when legacy profile read is denied by rules', () async {
      final firestore = FakeFirebaseFirestore();
      final initializer = FirebaseUserDataInitializer(
        firestore: firestore,
        pathResolver: const UserDataPathResolver(),
        profileMigration: ThrowingUserProfileMigration(
          FirebaseException(
            plugin: 'cloud_firestore',
            code: 'permission-denied',
          ),
        ),
      );

      await initializer.initialize(
        const AppUser(id: 'user-123', isAnonymous: true),
      );

      final userSnapshot = await firestore.doc('users/user-123').get();
      expect(userSnapshot.exists, isTrue);
      expect(userSnapshot.data()?['authProvider'], 'anonymous');
    });
  });
}
