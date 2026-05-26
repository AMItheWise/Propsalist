import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/proposal_store_repository_impl.dart';
import 'package:proposal_writer/data/user_data_path_resolver.dart';
import 'package:proposal_writer/domain/entities/app_user.dart';
import 'package:proposal_writer/domain/entities/proposal_record.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
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

T expectSuccess<T>(Result<T> result) {
  return result.when(
    success: (data) => data,
    failure: (failure) => fail('Expected success, got ${failure.message}'),
  );
}

void main() {
  FirestoreProposalStoreRepository buildRepository(
    FakeFirebaseFirestore firestore,
  ) {
    return FirestoreProposalStoreRepository(
      firestore: firestore,
      authRepository: const FakeAuthRepository(
        AppUser(id: 'user-123', isAnonymous: true),
      ),
      pathResolver: const UserDataPathResolver(),
    );
  }

  test('createDraft stores a user-owned draft with timestamps', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = buildRepository(firestore);

    final draftId = expectSuccess(
      await repository.createDraft(
        const ProposalDraftInput(
          title: 'Website Redesign',
          clientName: 'Acme Inc.',
          brief: 'Redesign the marketing website.',
          tone: ProposalTone.direct,
          maxTokens: 1200,
        ),
      ),
    );

    final snapshot = await firestore
        .doc('users/user-123/proposals/$draftId')
        .get();
    final data = snapshot.data();

    expect(snapshot.exists, isTrue);
    expect(data?['ownerId'], 'user-123');
    expect(data?['title'], 'Website Redesign');
    expect(data?['clientName'], 'Acme Inc.');
    expect(data?['brief'], 'Redesign the marketing website.');
    expect(data?['tone'], 'direct');
    expect(data?['maxTokens'], 1200);
    expect(data?['status'], 'draft');
    expect(data?['createdAt'], isA<Timestamp>());
    expect(data?['updatedAt'], isA<Timestamp>());
    expect(data?['generatedAt'], isNull);

    final loaded = expectSuccess(await repository.getProposal(draftId));
    expect(loaded?.id, draftId);
    expect(loaded?.ownerId, 'user-123');
    expect(loaded?.status, ProposalStatus.draft);
    expect(loaded?.createdAt, isNotNull);
    expect(loaded?.updatedAt, isNotNull);
  });

  test('updateDraft reuses the existing proposal document', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = buildRepository(firestore);
    final draftId = expectSuccess(
      await repository.createDraft(
        const ProposalDraftInput(
          title: 'Initial Title',
          clientName: '',
          brief: 'Initial brief',
          tone: ProposalTone.friendly,
          maxTokens: 900,
        ),
      ),
    );

    final updateResult = await repository.updateDraft(
      draftId,
      const ProposalDraftInput(
        title: 'Updated Title',
        clientName: 'Bright Labs',
        brief: 'Updated brief',
        tone: ProposalTone.formal,
        maxTokens: 1500,
      ),
    );

    expect(updateResult, isA<Success<void>>());
    final proposals = await firestore
        .collection('users/user-123/proposals')
        .get();
    final updatedSnapshot = await firestore
        .doc('users/user-123/proposals/$draftId')
        .get();

    expect(proposals.docs, hasLength(1));
    expect(updatedSnapshot.data()?['title'], 'Updated Title');
    expect(updatedSnapshot.data()?['clientName'], 'Bright Labs');
    expect(updatedSnapshot.data()?['status'], 'draft');
  });

  test(
    'saveGeneratedProposal updates the active draft without duplicating it',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repository = buildRepository(firestore);
      final draftId = expectSuccess(
        await repository.createDraft(
          const ProposalDraftInput(
            title: 'Website Redesign',
            clientName: 'Acme Inc.',
            brief: 'Original brief',
            tone: ProposalTone.direct,
            maxTokens: 1200,
          ),
        ),
      );

      final result = await repository.saveGeneratedProposal(
        GeneratedProposalInput(
          proposalId: draftId,
          title: 'Website Redesign',
          clientName: 'Acme Inc.',
          brief: 'Original brief',
          tone: ProposalTone.direct,
          maxTokens: 1200,
          promptSummary: 'A website redesign proposal.',
          clarificationQuestions: const [],
          clarificationAnswers: null,
          proposalContent: 'Generated proposal content',
        ),
      );

      expect(result, isA<Success<void>>());
      final proposals = await firestore
          .collection('users/user-123/proposals')
          .get();
      final snapshot = await firestore
          .doc('users/user-123/proposals/$draftId')
          .get();

      expect(proposals.docs, hasLength(1));
      expect(snapshot.data()?['status'], 'generated');
      expect(snapshot.data()?['promptSummary'], 'A website redesign proposal.');
      expect(snapshot.data()?['proposalContent'], 'Generated proposal content');
      expect(snapshot.data()?['generatedAt'], isA<Timestamp>());
    },
  );

  test(
    'markNeedsClarification persists questions on the active draft',
    () async {
      final firestore = FakeFirebaseFirestore();
      final repository = buildRepository(firestore);
      final draftId = expectSuccess(
        await repository.createDraft(
          const ProposalDraftInput(
            title: 'SaaS Proposal',
            clientName: 'CloudScale',
            brief: 'Need a product proposal.',
            tone: ProposalTone.friendly,
            maxTokens: 1000,
          ),
        ),
      );

      final result = await repository.markNeedsClarification(
        ClarificationProposalInput(
          proposalId: draftId,
          title: 'SaaS Proposal',
          clientName: 'CloudScale',
          brief: 'Need a product proposal.',
          tone: ProposalTone.friendly,
          maxTokens: 1000,
          promptSummary: 'The product proposal needs more detail.',
          clarificationQuestions: const ['What is the budget?'],
          clarificationAnswers: null,
        ),
      );

      expect(result, isA<Success<void>>());
      final snapshot = await firestore
          .doc('users/user-123/proposals/$draftId')
          .get();

      expect(snapshot.data()?['status'], 'needsClarification');
      expect(snapshot.data()?['promptSummary'], contains('more detail'));
      expect(snapshot.data()?['clarificationQuestions'], [
        'What is the budget?',
      ]);
    },
  );
}
