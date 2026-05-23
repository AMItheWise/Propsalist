import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/user_data_path_resolver.dart';
import 'package:proposal_writer/domain/entities/app_user.dart';
import 'package:proposal_writer/domain/entities/user_profile.dart';
import 'package:proposal_writer/domain/repositories/auth_repository.dart';
import 'package:proposal_writer/domain/repositories/user_profile_repository.dart';

class DisabledUserProfileRepository implements UserProfileRepository {
  const DisabledUserProfileRepository();

  @override
  Future<Result<UserProfile?>> loadProfile() async {
    return const Success(null);
  }

  @override
  Future<Result<void>> saveProfile(UserProfile profile) async {
    return const FailureResult(
      ConfigurationFailure(
        'Firestore is not configured. Add the FIREBASE_* settings first.',
      ),
    );
  }
}

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
    required UserDataPathResolver pathResolver,
    FirestoreUserProfileMigration? migration,
  }) : _firestore = firestore,
       _authRepository = authRepository,
       _pathResolver = pathResolver,
       _migration =
           migration ??
           FirestoreUserProfileMigration(
             firestore: firestore,
             pathResolver: pathResolver,
           );

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final UserDataPathResolver _pathResolver;
  final FirestoreUserProfileMigration _migration;

  @override
  Future<Result<UserProfile?>> loadProfile() async {
    final userResult = await _authRepository.ensureSignedIn();
    return userResult.when(
      success: _loadProfileForUser,
      failure: (failure) async => FailureResult(failure),
    );
  }

  Future<Result<UserProfile?>> _loadProfileForUser(AppUser user) async {
    try {
      await _migration.migrateLegacyPrimaryProfileIfNeeded(user.id);
      final document = _pathResolver.profileDocument(_firestore, user.id);
      final snapshot = await document.get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        return const Success(null);
      }

      return Success(UserProfile.fromMap(snapshot.id, data));
    } on FirebaseException catch (error) {
      return FailureResult(
        StorageFailure(
          'Failed to load the user profile from Firestore.',
          cause: error,
        ),
      );
    } catch (error) {
      return FailureResult(
        UnknownFailure(
          'Unexpected error while loading the user profile.',
          cause: error,
        ),
      );
    }
  }

  @override
  Future<Result<void>> saveProfile(UserProfile profile) async {
    final userResult = await _authRepository.ensureSignedIn();
    return userResult.when(
      success: (user) => _saveProfileForUser(user, profile),
      failure: (failure) async => FailureResult(failure),
    );
  }

  Future<Result<void>> _saveProfileForUser(
    AppUser user,
    UserProfile profile,
  ) async {
    try {
      final document = _pathResolver.profileDocument(_firestore, user.id);
      await document.set({
        ...profile.copyWith(id: document.id).toMap(),
        'ownerId': user.id,
        'schemaVersion': userDataSchemaVersion,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (error) {
      return FailureResult(
        StorageFailure(
          'Failed to save the user-owned profile to Firestore.',
          cause: error,
        ),
      );
    } catch (error) {
      return FailureResult(
        UnknownFailure(
          'Unexpected error while saving the user-owned profile.',
          cause: error,
        ),
      );
    }
  }
}

abstract class UserProfileMigration {
  Future<void> migrateLegacyPrimaryProfileIfNeeded(String userId);
}

class FirestoreUserProfileMigration implements UserProfileMigration {
  FirestoreUserProfileMigration({
    required FirebaseFirestore firestore,
    required UserDataPathResolver pathResolver,
  }) : _firestore = firestore,
       _pathResolver = pathResolver;

  final FirebaseFirestore _firestore;
  final UserDataPathResolver _pathResolver;

  @override
  Future<void> migrateLegacyPrimaryProfileIfNeeded(String userId) async {
    final scopedDocument = _pathResolver.profileDocument(_firestore, userId);
    final scopedSnapshot = await scopedDocument.get();
    if (scopedSnapshot.exists) {
      return;
    }

    final legacyDocument = _firestore
        .collection(userProfileCollection)
        .doc(defaultUserProfileDocumentId);
    final legacySnapshot = await legacyDocument.get();
    final legacyData = legacySnapshot.data();
    if (!legacySnapshot.exists || legacyData == null) {
      return;
    }

    final userDocument = _pathResolver.userDocument(_firestore, userId);
    final batch = _firestore.batch();
    await (batch
          ..set(scopedDocument, {
            ...legacyData,
            'ownerId': userId,
            'schemaVersion': userDataSchemaVersion,
            'updatedAt': FieldValue.serverTimestamp(),
          })
          ..set(userDocument, {
            'legacyProfileMigratedAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true)))
        .commit();
  }
}
