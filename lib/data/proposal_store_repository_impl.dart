import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/user_data_path_resolver.dart';
import 'package:proposal_writer/domain/entities/app_user.dart';
import 'package:proposal_writer/domain/entities/proposal_record.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/auth_repository.dart';
import 'package:proposal_writer/domain/repositories/proposal_store_repository.dart';

final mockProposalStoreRecords = [
  ProposalRecord(
    id: 'mock-website-redesign',
    ownerId: 'local-user',
    title: 'Website Redesign Proposal',
    clientName: 'Acme Inc.',
    brief: 'Refresh the marketing website with clearer conversion paths.',
    tone: ProposalTone.direct,
    maxTokens: 1200,
    status: ProposalStatus.needsClarification,
    tags: const ['demo'],
    promptSummary: 'A focused website redesign proposal.',
    clarificationQuestions: const [],
    clarificationAnswers: null,
    proposalContent: null,
    createdAt: DateTime.utc(2026, 5, 20, 9),
    updatedAt: DateTime.utc(2026, 5, 26, 10),
    generatedAt: null,
    lastOpenedAt: null,
  ),
  ProposalRecord(
    id: 'mock-mobile-app-rfp',
    ownerId: 'local-user',
    title: 'Mobile App Development RFP',
    clientName: 'Bright Labs',
    brief: 'Build a proposal for a mobile product discovery and MVP.',
    tone: ProposalTone.friendly,
    maxTokens: 1400,
    status: ProposalStatus.generated,
    tags: const ['demo'],
    promptSummary: 'A mobile app development proposal.',
    clarificationQuestions: const [],
    clarificationAnswers: null,
    proposalContent: 'Demo generated proposal content.',
    createdAt: DateTime.utc(2026, 5, 18, 8),
    updatedAt: DateTime.utc(2026, 5, 25, 10),
    generatedAt: DateTime.utc(2026, 5, 25, 10),
    lastOpenedAt: null,
  ),
  ProposalRecord(
    id: 'mock-saas-platform',
    ownerId: 'local-user',
    title: 'SaaS Platform Proposal',
    clientName: 'CloudScale',
    brief: 'Prepare a product strategy and delivery proposal.',
    tone: ProposalTone.formal,
    maxTokens: 1600,
    status: ProposalStatus.draft,
    tags: const ['demo'],
    promptSummary: null,
    clarificationQuestions: const [],
    clarificationAnswers: null,
    proposalContent: null,
    createdAt: DateTime.utc(2026, 5, 15, 8),
    updatedAt: DateTime.utc(2026, 5, 24, 10),
    generatedAt: null,
    lastOpenedAt: null,
  ),
];

class DisabledProposalStoreRepository implements ProposalStoreRepository {
  const DisabledProposalStoreRepository();

  static const _message =
      'Firestore proposal storage is not configured. Add the FIREBASE_* '
      'settings first.';

  @override
  Stream<List<ProposalRecord>> watchRecentProposals({int limit = 20}) {
    return Stream<List<ProposalRecord>>.value(const []);
  }

  @override
  Future<Result<ProposalRecord?>> getProposal(String id) async {
    return const Success(null);
  }

  @override
  Future<Result<String>> createDraft(ProposalDraftInput input) async {
    return const FailureResult(ConfigurationFailure(_message));
  }

  @override
  Future<Result<void>> updateDraft(String id, ProposalDraftInput input) async {
    return const FailureResult(ConfigurationFailure(_message));
  }

  @override
  Future<Result<void>> saveGeneratedProposal(
    GeneratedProposalInput input,
  ) async {
    return const FailureResult(ConfigurationFailure(_message));
  }

  @override
  Future<Result<void>> markNeedsClarification(
    ClarificationProposalInput input,
  ) async {
    return const FailureResult(ConfigurationFailure(_message));
  }

  @override
  Future<Result<void>> archiveProposal(String id) async {
    return const FailureResult(ConfigurationFailure(_message));
  }
}

class InMemoryProposalStoreRepository implements ProposalStoreRepository {
  InMemoryProposalStoreRepository({List<ProposalRecord> seedRecords = const []})
    : _records = {for (final record in seedRecords) record.id: record};

  final Map<String, ProposalRecord> _records;
  final StreamController<List<ProposalRecord>> _controller =
      StreamController<List<ProposalRecord>>.broadcast();
  int _idCounter = 0;

  @override
  Stream<List<ProposalRecord>> watchRecentProposals({int limit = 20}) {
    scheduleMicrotask(_emit);
    return _controller.stream.map((records) => records.take(limit).toList());
  }

  @override
  Future<Result<ProposalRecord?>> getProposal(String id) async {
    return Success(_records[id]);
  }

  @override
  Future<Result<String>> createDraft(ProposalDraftInput input) async {
    final id = 'local-proposal-${++_idCounter}';
    final now = DateTime.now().toUtc();
    _records[id] = ProposalRecord(
      id: id,
      ownerId: 'local-user',
      title: _storedTitle(input.title),
      clientName: input.clientName.trim(),
      brief: input.brief.trim(),
      tone: input.tone,
      maxTokens: input.maxTokens,
      status: ProposalStatus.draft,
      tags: _cleanTags(input.tags),
      promptSummary: null,
      clarificationQuestions: const [],
      clarificationAnswers: null,
      proposalContent: null,
      createdAt: now,
      updatedAt: now,
      generatedAt: null,
      lastOpenedAt: null,
    );
    _emit();
    return Success(id);
  }

  @override
  Future<Result<void>> updateDraft(String id, ProposalDraftInput input) async {
    final existing = _records[id];
    final now = DateTime.now().toUtc();
    _records[id] = ProposalRecord(
      id: id,
      ownerId: existing?.ownerId ?? 'local-user',
      title: _storedTitle(input.title),
      clientName: input.clientName.trim(),
      brief: input.brief.trim(),
      tone: input.tone,
      maxTokens: input.maxTokens,
      status: ProposalStatus.draft,
      tags: _cleanTags(input.tags),
      promptSummary: existing?.promptSummary,
      clarificationQuestions: existing?.clarificationQuestions ?? const [],
      clarificationAnswers: existing?.clarificationAnswers,
      proposalContent: existing?.proposalContent,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      generatedAt: existing?.generatedAt,
      lastOpenedAt: existing?.lastOpenedAt,
    );
    _emit();
    return const Success(null);
  }

  @override
  Future<Result<void>> saveGeneratedProposal(
    GeneratedProposalInput input,
  ) async {
    final id = input.proposalId ?? 'local-proposal-${++_idCounter}';
    final existing = _records[id];
    final now = DateTime.now().toUtc();
    _records[id] = ProposalRecord(
      id: id,
      ownerId: existing?.ownerId ?? 'local-user',
      title: _storedTitle(input.title),
      clientName: input.clientName.trim(),
      brief: input.brief.trim(),
      tone: input.tone,
      maxTokens: input.maxTokens,
      status: ProposalStatus.generated,
      tags: _cleanTags(input.tags),
      promptSummary: input.promptSummary.trim(),
      clarificationQuestions: List<String>.unmodifiable(
        input.clarificationQuestions,
      ),
      clarificationAnswers: input.clarificationAnswers?.trim(),
      proposalContent: input.proposalContent,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      generatedAt: now,
      lastOpenedAt: existing?.lastOpenedAt,
    );
    _emit();
    return const Success(null);
  }

  @override
  Future<Result<void>> markNeedsClarification(
    ClarificationProposalInput input,
  ) async {
    final existing = _records[input.proposalId];
    final now = DateTime.now().toUtc();
    _records[input.proposalId] = ProposalRecord(
      id: input.proposalId,
      ownerId: existing?.ownerId ?? 'local-user',
      title: _storedTitle(input.title),
      clientName: input.clientName.trim(),
      brief: input.brief.trim(),
      tone: input.tone,
      maxTokens: input.maxTokens,
      status: ProposalStatus.needsClarification,
      tags: _cleanTags(input.tags),
      promptSummary: input.promptSummary.trim(),
      clarificationQuestions: List<String>.unmodifiable(
        input.clarificationQuestions,
      ),
      clarificationAnswers: input.clarificationAnswers?.trim(),
      proposalContent: existing?.proposalContent,
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      generatedAt: existing?.generatedAt,
      lastOpenedAt: existing?.lastOpenedAt,
    );
    _emit();
    return const Success(null);
  }

  @override
  Future<Result<void>> archiveProposal(String id) async {
    final existing = _records[id];
    if (existing == null) {
      return const Success(null);
    }
    final now = DateTime.now().toUtc();
    _records[id] = ProposalRecord(
      id: existing.id,
      ownerId: existing.ownerId,
      title: existing.title,
      clientName: existing.clientName,
      brief: existing.brief,
      tone: existing.tone,
      maxTokens: existing.maxTokens,
      status: ProposalStatus.archived,
      tags: existing.tags,
      promptSummary: existing.promptSummary,
      clarificationQuestions: existing.clarificationQuestions,
      clarificationAnswers: existing.clarificationAnswers,
      proposalContent: existing.proposalContent,
      createdAt: existing.createdAt,
      updatedAt: now,
      generatedAt: existing.generatedAt,
      lastOpenedAt: existing.lastOpenedAt,
    );
    _emit();
    return const Success(null);
  }

  void _emit() {
    if (_controller.isClosed) {
      return;
    }
    final records = _records.values.toList()
      ..sort((a, b) {
        final bDate =
            b.updatedAt ??
            b.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final aDate =
            a.updatedAt ??
            a.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    _controller.add(records);
  }
}

class FirestoreProposalStoreRepository implements ProposalStoreRepository {
  FirestoreProposalStoreRepository({
    required FirebaseFirestore firestore,
    required AuthRepository authRepository,
    required UserDataPathResolver pathResolver,
  }) : _firestore = firestore,
       _authRepository = authRepository,
       _pathResolver = pathResolver;

  final FirebaseFirestore _firestore;
  final AuthRepository _authRepository;
  final UserDataPathResolver _pathResolver;

  @override
  Stream<List<ProposalRecord>> watchRecentProposals({int limit = 20}) async* {
    final user = await _signedInUserOrThrow();
    yield* _proposalCollection(user.id)
        .orderBy('updatedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map(_recordFromSnapshot).toList();
        });
  }

  @override
  Future<Result<ProposalRecord?>> getProposal(String id) async {
    final userResult = await _authRepository.ensureSignedIn();
    return userResult.when(
      success: (user) async {
        try {
          final snapshot = await _proposalCollection(user.id).doc(id).get();
          if (!snapshot.exists || snapshot.data() == null) {
            return const Success(null);
          }
          return Success(_recordFromSnapshot(snapshot));
        } on FirebaseException catch (error) {
          return FailureResult(
            StorageFailure('Failed to load the proposal.', cause: error),
          );
        } catch (error) {
          return FailureResult(
            UnknownFailure(
              'Unexpected error while loading the proposal.',
              cause: error,
            ),
          );
        }
      },
      failure: (failure) async => FailureResult(failure),
    );
  }

  @override
  Future<Result<String>> createDraft(ProposalDraftInput input) async {
    final userResult = await _authRepository.ensureSignedIn();
    return userResult.when(
      success: (user) async {
        try {
          final document = _proposalCollection(user.id).doc();
          await document.set({
            ..._draftMap(user.id, input),
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'generatedAt': null,
            'lastOpenedAt': null,
          });
          return Success(document.id);
        } on FirebaseException catch (error) {
          return FailureResult(
            StorageFailure('Failed to save the draft proposal.', cause: error),
          );
        } catch (error) {
          return FailureResult(
            UnknownFailure(
              'Unexpected error while saving the draft proposal.',
              cause: error,
            ),
          );
        }
      },
      failure: (failure) async => FailureResult(failure),
    );
  }

  @override
  Future<Result<void>> updateDraft(String id, ProposalDraftInput input) async {
    final userResult = await _authRepository.ensureSignedIn();
    return userResult.when(
      success: (user) async {
        try {
          await _proposalCollection(user.id).doc(id).set({
            ..._draftMap(user.id, input),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return const Success(null);
        } on FirebaseException catch (error) {
          return FailureResult(
            StorageFailure(
              'Failed to update the draft proposal.',
              cause: error,
            ),
          );
        } catch (error) {
          return FailureResult(
            UnknownFailure(
              'Unexpected error while updating the draft proposal.',
              cause: error,
            ),
          );
        }
      },
      failure: (failure) async => FailureResult(failure),
    );
  }

  @override
  Future<Result<void>> saveGeneratedProposal(
    GeneratedProposalInput input,
  ) async {
    final userResult = await _authRepository.ensureSignedIn();
    return userResult.when(
      success: (user) async {
        try {
          final document = input.proposalId == null
              ? _proposalCollection(user.id).doc()
              : _proposalCollection(user.id).doc(input.proposalId);
          final snapshot = await document.get();
          await document.set({
            ..._generatedMap(user.id, input),
            if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
            'generatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return const Success(null);
        } on FirebaseException catch (error) {
          return FailureResult(
            StorageFailure(
              'Generated proposal was created, but saving it failed.',
              cause: error,
            ),
          );
        } catch (error) {
          return FailureResult(
            UnknownFailure(
              'Generated proposal was created, but saving it failed.',
              cause: error,
            ),
          );
        }
      },
      failure: (failure) async => FailureResult(failure),
    );
  }

  @override
  Future<Result<void>> markNeedsClarification(
    ClarificationProposalInput input,
  ) async {
    final userResult = await _authRepository.ensureSignedIn();
    return userResult.when(
      success: (user) async {
        try {
          await _proposalCollection(user.id).doc(input.proposalId).set({
            ..._clarificationMap(user.id, input),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return const Success(null);
        } on FirebaseException catch (error) {
          return FailureResult(
            StorageFailure(
              'Clarification questions were created, but saving them failed.',
              cause: error,
            ),
          );
        } catch (error) {
          return FailureResult(
            UnknownFailure(
              'Clarification questions were created, but saving them failed.',
              cause: error,
            ),
          );
        }
      },
      failure: (failure) async => FailureResult(failure),
    );
  }

  @override
  Future<Result<void>> archiveProposal(String id) async {
    final userResult = await _authRepository.ensureSignedIn();
    return userResult.when(
      success: (user) async {
        try {
          await _proposalCollection(user.id).doc(id).set({
            'status': ProposalStatus.archived.value,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
          return const Success(null);
        } on FirebaseException catch (error) {
          return FailureResult(
            StorageFailure('Failed to archive the proposal.', cause: error),
          );
        } catch (error) {
          return FailureResult(
            UnknownFailure(
              'Unexpected error while archiving the proposal.',
              cause: error,
            ),
          );
        }
      },
      failure: (failure) async => FailureResult(failure),
    );
  }

  Future<AppUser> _signedInUserOrThrow() async {
    final result = await _authRepository.ensureSignedIn();
    return result.when(
      success: (user) => user,
      failure: (failure) => throw StateError(failure.message),
    );
  }

  CollectionReference<Map<String, dynamic>> _proposalCollection(String userId) {
    return _firestore.collection('${_pathResolver.userPath(userId)}/proposals');
  }

  Map<String, Object?> _draftMap(String userId, ProposalDraftInput input) {
    return {
      'ownerId': userId,
      'title': _storedTitle(input.title),
      'clientName': input.clientName.trim(),
      'brief': input.brief.trim(),
      'tone': input.tone.name,
      'maxTokens': input.maxTokens,
      'status': ProposalStatus.draft.value,
      'tags': _cleanTags(input.tags),
    };
  }

  Map<String, Object?> _generatedMap(
    String userId,
    GeneratedProposalInput input,
  ) {
    return {
      'ownerId': userId,
      'title': _storedTitle(input.title),
      'clientName': input.clientName.trim(),
      'brief': input.brief.trim(),
      'tone': input.tone.name,
      'maxTokens': input.maxTokens,
      'status': ProposalStatus.generated.value,
      'tags': _cleanTags(input.tags),
      'promptSummary': input.promptSummary.trim(),
      'clarificationQuestions': _cleanTags(input.clarificationQuestions),
      'clarificationAnswers': input.clarificationAnswers?.trim(),
      'proposalContent': input.proposalContent,
    };
  }

  Map<String, Object?> _clarificationMap(
    String userId,
    ClarificationProposalInput input,
  ) {
    return {
      'ownerId': userId,
      'title': _storedTitle(input.title),
      'clientName': input.clientName.trim(),
      'brief': input.brief.trim(),
      'tone': input.tone.name,
      'maxTokens': input.maxTokens,
      'status': ProposalStatus.needsClarification.value,
      'tags': _cleanTags(input.tags),
      'promptSummary': input.promptSummary.trim(),
      'clarificationQuestions': _cleanTags(input.clarificationQuestions),
      'clarificationAnswers': input.clarificationAnswers?.trim(),
    };
  }

  ProposalRecord _recordFromSnapshot(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? const <String, dynamic>{};
    return ProposalRecord(
      id: snapshot.id,
      ownerId: data['ownerId'] as String? ?? '',
      title: data['title'] as String? ?? 'Untitled Proposal',
      clientName: data['clientName'] as String? ?? '',
      brief: data['brief'] as String? ?? '',
      tone: _toneFromValue(data['tone'] as String?),
      maxTokens: data['maxTokens'] as int? ?? 0,
      status: ProposalStatus.fromValue(data['status'] as String?),
      tags: _stringList(data['tags']),
      promptSummary: data['promptSummary'] as String?,
      clarificationQuestions: _stringList(data['clarificationQuestions']),
      clarificationAnswers: data['clarificationAnswers'] as String?,
      proposalContent: data['proposalContent'] as String?,
      createdAt: _dateTimeFromFirestore(data['createdAt']),
      updatedAt: _dateTimeFromFirestore(data['updatedAt']),
      generatedAt: _dateTimeFromFirestore(data['generatedAt']),
      lastOpenedAt: _dateTimeFromFirestore(data['lastOpenedAt']),
    );
  }
}

String _storedTitle(String title) {
  final trimmed = title.trim();
  return trimmed.isEmpty ? 'Untitled Proposal' : trimmed;
}

List<String> _cleanTags(List<String> values) {
  return List<String>.unmodifiable(
    values.map((value) => value.trim()).where((value) => value.isNotEmpty),
  );
}

List<String> _stringList(Object? value) {
  if (value is! List) {
    return const [];
  }
  return List<String>.unmodifiable(
    value.whereType<String>().map((item) => item.trim()),
  );
}

DateTime? _dateTimeFromFirestore(Object? value) {
  if (value is Timestamp) {
    return value.toDate();
  }
  if (value is DateTime) {
    return value;
  }
  return null;
}

ProposalTone _toneFromValue(String? value) {
  return ProposalTone.values.firstWhere(
    (tone) => tone.name == value,
    orElse: () => ProposalTone.direct,
  );
}
