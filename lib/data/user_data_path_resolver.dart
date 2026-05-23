import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proposal_writer/core/constants.dart';

class UserDataPathResolver {
  const UserDataPathResolver();

  String userPath(String userId) => '$usersCollection/$userId';

  String profilePath(
    String userId, {
    String profileId = defaultUserProfileDocumentId,
  }) {
    return '${userPath(userId)}/$profilesCollection/$profileId';
  }

  String proposalPath(String userId, String proposalId) {
    return '${userPath(userId)}/$proposalsCollection/$proposalId';
  }

  String settingsPath(
    String userId, {
    String settingsId = defaultSettingsDocumentId,
  }) {
    return '${userPath(userId)}/$settingsCollection/$settingsId';
  }

  DocumentReference<Map<String, dynamic>> userDocument(
    FirebaseFirestore firestore,
    String userId,
  ) {
    return firestore.doc(userPath(userId));
  }

  DocumentReference<Map<String, dynamic>> profileDocument(
    FirebaseFirestore firestore,
    String userId, {
    String profileId = defaultUserProfileDocumentId,
  }) {
    return firestore.doc(profilePath(userId, profileId: profileId));
  }

  DocumentReference<Map<String, dynamic>> proposalDocument(
    FirebaseFirestore firestore,
    String userId,
    String proposalId,
  ) {
    return firestore.doc(proposalPath(userId, proposalId));
  }

  DocumentReference<Map<String, dynamic>> settingsDocument(
    FirebaseFirestore firestore,
    String userId, {
    String settingsId = defaultSettingsDocumentId,
  }) {
    return firestore.doc(settingsPath(userId, settingsId: settingsId));
  }
}
