import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/user_data_path_resolver.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/entities/app_user.dart';
import 'package:proposal_writer/domain/repositories/auth_repository.dart';

abstract class AuthGateway {
  AppUser? get currentUser;

  Stream<AppUser?> watchCurrentUser();

  Future<AppUser> signInAnonymously();

  Future<void> signOut();
}

abstract class UserDataInitializer {
  Future<void> initialize(AppUser user);
}

class NoopUserDataInitializer implements UserDataInitializer {
  const NoopUserDataInitializer();

  @override
  Future<void> initialize(AppUser user) async {}
}

class FirebaseAuthGateway implements AuthGateway {
  FirebaseAuthGateway({required firebase_auth.FirebaseAuth auth})
    : _auth = auth;

  final firebase_auth.FirebaseAuth _auth;

  @override
  AppUser? get currentUser {
    final user = _auth.currentUser;
    return user == null ? null : _mapUser(user);
  }

  @override
  Stream<AppUser?> watchCurrentUser() {
    return _auth.authStateChanges().map((user) {
      return user == null ? null : _mapUser(user);
    });
  }

  @override
  Future<AppUser> signInAnonymously() async {
    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) {
      throw StateError('Firebase anonymous sign-in returned no user.');
    }
    return _mapUser(user);
  }

  @override
  Future<void> signOut() {
    return _auth.signOut();
  }

  AppUser _mapUser(firebase_auth.User user) {
    return AppUser(
      id: user.uid,
      isAnonymous: user.isAnonymous,
      displayName: user.displayName,
      email: user.email,
    );
  }
}

class FirebaseUserDataInitializer implements UserDataInitializer {
  FirebaseUserDataInitializer({
    required FirebaseFirestore firestore,
    required UserDataPathResolver pathResolver,
    UserProfileMigration? profileMigration,
  }) : _firestore = firestore,
       _pathResolver = pathResolver,
       _profileMigration =
           profileMigration ??
           FirestoreUserProfileMigration(
             firestore: firestore,
             pathResolver: pathResolver,
           );

  final FirebaseFirestore _firestore;
  final UserDataPathResolver _pathResolver;
  final UserProfileMigration _profileMigration;

  @override
  Future<void> initialize(AppUser user) async {
    await _ensureUserMetadata(user);
    try {
      await _profileMigration.migrateLegacyPrimaryProfileIfNeeded(user.id);
    } on FirebaseException catch (error) {
      if (error.code != 'permission-denied') {
        rethrow;
      }
    }
  }

  Future<void> _ensureUserMetadata(AppUser user) async {
    final userDocument = _pathResolver.userDocument(_firestore, user.id);
    final snapshot = await userDocument.get();
    final data = <String, Object?>{
      'updatedAt': FieldValue.serverTimestamp(),
      'authProvider': user.isAnonymous ? 'anonymous' : 'firebase',
      'schemaVersion': userDataSchemaVersion,
    };
    if (!snapshot.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
      data['legacyProfileMigratedAt'] = null;
    }
    await userDocument.set(data, SetOptions(merge: true));
  }
}

class LocalAuthRepository implements AuthRepository {
  const LocalAuthRepository();

  static const _localUser = AppUser(id: localUserId, isAnonymous: true);

  @override
  Future<Result<AppUser>> ensureSignedIn() async {
    return const Success(_localUser);
  }

  @override
  Future<Result<AppUser>> signInAnonymously() async {
    return const Success(_localUser);
  }

  @override
  Future<Result<void>> signOut() async {
    return const Success(null);
  }

  @override
  Stream<AppUser?> watchCurrentUser() {
    return Stream<AppUser?>.value(_localUser);
  }
}

class FirebaseAuthRepository implements AuthRepository {
  const FirebaseAuthRepository({
    required AuthGateway authGateway,
    required UserDataInitializer userDataInitializer,
  }) : _authGateway = authGateway,
       _userDataInitializer = userDataInitializer;

  final AuthGateway _authGateway;
  final UserDataInitializer _userDataInitializer;

  @override
  Stream<AppUser?> watchCurrentUser() {
    return _authGateway.watchCurrentUser();
  }

  @override
  Future<Result<AppUser>> ensureSignedIn() async {
    final currentUser = _authGateway.currentUser;
    if (currentUser != null) {
      return _initializeUserData(
        currentUser,
        failureMessage: 'Failed to prepare the signed-in user.',
      );
    }

    return signInAnonymously();
  }

  @override
  Future<Result<AppUser>> signInAnonymously() async {
    try {
      final user = await _authGateway.signInAnonymously();
      return _initializeUserData(
        user,
        failureMessage: 'Failed to prepare the anonymous user.',
      );
    } on FirebaseException catch (error) {
      return FailureResult(
        AuthenticationFailure(
          'Failed to complete anonymous sign-in.',
          cause: error,
        ),
      );
    } catch (error) {
      return FailureResult(
        AuthenticationFailure(
          'Failed to complete anonymous sign-in.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await _authGateway.signOut();
      return const Success(null);
    } on FirebaseException catch (error) {
      return FailureResult(
        AuthenticationFailure('Failed to sign out.', cause: error),
      );
    } catch (error) {
      return FailureResult(
        AuthenticationFailure('Failed to sign out.', cause: error),
      );
    }
  }

  Future<Result<AppUser>> _initializeUserData(
    AppUser user, {
    required String failureMessage,
  }) async {
    try {
      await _userDataInitializer.initialize(user);
      return Success(user);
    } on FirebaseException catch (error) {
      return FailureResult(AuthenticationFailure(failureMessage, cause: error));
    } catch (error) {
      return FailureResult(AuthenticationFailure(failureMessage, cause: error));
    }
  }
}
