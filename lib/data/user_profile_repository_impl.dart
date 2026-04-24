import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/user_profile.dart';
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
  FirestoreUserProfileRepository({required FirebaseFirestore firestore})
    : _document = firestore
          .collection(userProfileCollection)
          .doc(defaultUserProfileDocumentId);

  final DocumentReference<Map<String, dynamic>> _document;

  @override
  Future<Result<UserProfile?>> loadProfile() async {
    try {
      final snapshot = await _document.get();
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
    try {
      await _document.set({
        ...profile.copyWith(id: _document.id).toMap(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return const Success(null);
    } on FirebaseException catch (error) {
      return FailureResult(
        StorageFailure(
          'Failed to save the user profile to Firestore.',
          cause: error,
        ),
      );
    } catch (error) {
      return FailureResult(
        UnknownFailure(
          'Unexpected error while saving the user profile.',
          cause: error,
        ),
      );
    }
  }
}
