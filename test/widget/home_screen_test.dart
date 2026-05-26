import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/entities/clarification_response.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_record.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/entities/user_profile.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/domain/repositories/proposal_store_repository.dart';
import 'package:proposal_writer/domain/repositories/user_profile_repository.dart';
import 'package:proposal_writer/presentation/screens/home_screen.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';

class FakeProposalRepository implements ProposalRepository {
  FakeProposalRepository({
    required this.clarificationResult,
    this.proposalCompleter,
    this.proposalResult,
    this.proposalResults,
  });

  final Result<ClarificationResponse> clarificationResult;
  final Completer<Result<Proposal>>? proposalCompleter;
  final Result<Proposal>? proposalResult;
  final List<Result<Proposal>>? proposalResults;
  int clarificationRequestCount = 0;
  int proposalRequestCount = 0;
  String? lastClarificationProfileContext;
  String? lastProposalClarificationAnswers;

  @override
  Future<Result<ClarificationResponse>> requestClarifications({
    required String prompt,
    String? userProfileContext,
  }) async {
    clarificationRequestCount += 1;
    lastClarificationProfileContext = userProfileContext;
    return clarificationResult;
  }

  @override
  Future<Result<Proposal>> generateProposal({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
    required String summary,
    String? clarificationAnswers,
    String? userProfileContext,
  }) async {
    proposalRequestCount += 1;
    lastProposalClarificationAnswers = clarificationAnswers;
    if (proposalCompleter != null) {
      return proposalCompleter!.future;
    }
    final queuedResults = proposalResults;
    if (queuedResults != null && queuedResults.isNotEmpty) {
      return queuedResults.removeAt(0);
    }
    return proposalResult ??
        const FailureResult(UnknownFailure('Missing proposal result'));
  }
}

class FakeUserProfileRepository implements UserProfileRepository {
  const FakeUserProfileRepository(this.profile);

  final UserProfile? profile;

  @override
  Future<Result<UserProfile?>> loadProfile() async => Success(profile);

  @override
  Future<Result<void>> saveProfile(UserProfile profile) async {
    return const Success(null);
  }
}

class FakeProposalStoreRepository implements ProposalStoreRepository {
  FakeProposalStoreRepository({
    this.records = const [],
    this.recentStream,
    this.draftId = 'draft-1',
  });

  final List<ProposalRecord> records;
  final Stream<List<ProposalRecord>>? recentStream;
  final String draftId;
  int createDraftCount = 0;
  int updateDraftCount = 0;
  ProposalDraftInput? lastDraftInput;
  final generatedInputs = <GeneratedProposalInput>[];
  final clarificationInputs = <ClarificationProposalInput>[];

  @override
  Stream<List<ProposalRecord>> watchRecentProposals({int limit = 20}) {
    final stream = recentStream;
    if (stream != null) {
      return stream;
    }
    return Stream<List<ProposalRecord>>.value(records.take(limit).toList());
  }

  @override
  Future<Result<ProposalRecord?>> getProposal(String id) async {
    return Success(records.where((record) => record.id == id).firstOrNull);
  }

  @override
  Future<Result<String>> createDraft(ProposalDraftInput input) async {
    createDraftCount += 1;
    lastDraftInput = input;
    return Success(draftId);
  }

  @override
  Future<Result<void>> updateDraft(String id, ProposalDraftInput input) async {
    updateDraftCount += 1;
    lastDraftInput = input;
    return const Success(null);
  }

  @override
  Future<Result<void>> saveGeneratedProposal(
    GeneratedProposalInput input,
  ) async {
    generatedInputs.add(input);
    return const Success(null);
  }

  @override
  Future<Result<void>> markNeedsClarification(
    ClarificationProposalInput input,
  ) async {
    clarificationInputs.add(input);
    return const Success(null);
  }

  @override
  Future<Result<void>> archiveProposal(String id) async {
    return const Success(null);
  }
}

Widget buildTestApp(
  ProposalRepository repository, {
  UserProfileRepository userProfileRepository =
      const DisabledUserProfileRepository(),
  ProposalStoreRepository? proposalStoreRepository,
}) {
  return ProviderScope(
    overrides: [
      proposalRepositoryProvider.overrideWithValue(repository),
      userProfileRepositoryProvider.overrideWithValue(userProfileRepository),
      proposalStoreRepositoryProvider.overrideWithValue(
        proposalStoreRepository ?? FakeProposalStoreRepository(),
      ),
    ],
    child: MaterialApp(
      theme: buildProposalistTheme(),
      home: const HomeScreen(),
    ),
  );
}

Future<void> scrollUntilVisible(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    360,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void setMobileViewport(WidgetTester tester) {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

ProposalRecord proposalRecord({
  String id = 'proposal-1',
  String title = 'Stored Proposal',
  String clientName = 'Stored Client',
  ProposalStatus status = ProposalStatus.generated,
}) {
  return ProposalRecord(
    id: id,
    ownerId: 'user-123',
    title: title,
    clientName: clientName,
    brief: 'Stored brief',
    tone: ProposalTone.direct,
    maxTokens: 1200,
    status: status,
    tags: const [],
    promptSummary: 'Stored summary',
    clarificationQuestions: const [],
    clarificationAnswers: null,
    proposalContent: 'Stored content',
    createdAt: DateTime.utc(2026, 5, 20),
    updatedAt: DateTime.utc(2026, 5, 26),
    generatedAt: DateTime.utc(2026, 5, 26),
    lastOpenedAt: null,
  );
}

void main() {
  const completedClarification = Success(
    ClarificationResponse(
      needsClarification: false,
      questions: [],
      summary: 'summary',
      improvedPrompt: 'improved prompt',
    ),
  );

  testWidgets('renders the redesigned mobile dashboard shell', (tester) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('proposalistShell')), findsOneWidget);
    expect(find.byKey(const Key('dashboardTab')), findsOneWidget);
    expect(find.text('Welcome back, Rebecca'), findsOneWidget);
    await scrollUntilVisible(tester, find.text('Recent Proposals'));

    expect(find.text('Recent Proposals'), findsOneWidget);
    expect(find.byKey(const Key('bottomNavNewProposal')), findsOneWidget);
  });

  testWidgets('new proposal tab renders mobile mockup controls', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('newProposalTab')), findsOneWidget);
    expect(find.byKey(const Key('projectTitleField')), findsOneWidget);
    expect(find.byKey(const Key('clientProjectField')), findsOneWidget);
    expect(find.byKey(const Key('promptField')), findsOneWidget);
    expect(find.byKey(const Key('toneChipDirect')), findsOneWidget);
    await scrollUntilVisible(tester, find.byKey(const Key('maxTokensSlider')));

    expect(find.byKey(const Key('maxTokensSlider')), findsOneWidget);
    expect(find.byKey(const Key('saveDraftButton')), findsOneWidget);
    expect(find.byKey(const Key('generateButton')), findsOneWidget);
  });

  testWidgets('save draft button is disabled for an empty form', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    final button = tester.widget<OutlinedButton>(
      find.byKey(const Key('saveDraftButton')),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('save draft creates a persisted draft', (tester) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );
    final proposalStoreRepository = FakeProposalStoreRepository();

    await tester.pumpWidget(
      buildTestApp(
        repository,
        proposalStoreRepository: proposalStoreRepository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('projectTitleField')),
      'Website Redesign',
    );
    await tester.enterText(
      find.byKey(const Key('clientProjectField')),
      'Acme Inc.',
    );
    await tester.enterText(
      find.byKey(const Key('promptField')),
      'Redesign the marketing website.',
    );
    await scrollUntilVisible(tester, find.byKey(const Key('saveDraftButton')));
    await tester.tap(find.byKey(const Key('saveDraftButton')));
    await tester.pumpAndSettle();

    expect(proposalStoreRepository.createDraftCount, 1);
    expect(proposalStoreRepository.lastDraftInput?.title, 'Website Redesign');
    expect(proposalStoreRepository.lastDraftInput?.clientName, 'Acme Inc.');
    expect(
      proposalStoreRepository.lastDraftInput?.brief,
      'Redesign the marketing website.',
    );
    expect(find.text('Draft saved'), findsOneWidget);
  });

  testWidgets('generation saves draft first and persists generated proposal', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );
    final proposalStoreRepository = FakeProposalStoreRepository();

    await tester.pumpWidget(
      buildTestApp(
        repository,
        proposalStoreRepository: proposalStoreRepository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('projectTitleField')),
      'Website Redesign',
    );
    await tester.enterText(
      find.byKey(const Key('clientProjectField')),
      'Acme Inc.',
    );
    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollUntilVisible(tester, find.byKey(const Key('generateButton')));
    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    expect(proposalStoreRepository.createDraftCount, 1);
    expect(proposalStoreRepository.generatedInputs, hasLength(1));
    expect(
      proposalStoreRepository.generatedInputs.single.proposalId,
      'draft-1',
    );
    expect(
      proposalStoreRepository.generatedInputs.single.proposalContent,
      'Generated content',
    );
    expect(find.byKey(const Key('proposalOutput')), findsOneWidget);
  });

  testWidgets('proposals tab shows repository data', (tester) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );
    final proposalStoreRepository = FakeProposalStoreRepository(
      records: [
        proposalRecord(
          title: 'Repository Backed Proposal',
          clientName: 'Bright Labs',
          status: ProposalStatus.draft,
        ),
      ],
    );

    await tester.pumpWidget(
      buildTestApp(
        repository,
        proposalStoreRepository: proposalStoreRepository,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavProposals')));
    await tester.pumpAndSettle();

    expect(find.text('Repository Backed Proposal'), findsOneWidget);
    expect(find.text('Bright Labs'), findsOneWidget);
    expect(
      find.byKey(const Key('proposalRecordTileproposal-1')),
      findsOneWidget,
    );
    expect(find.text('Draft'), findsWidgets);
  });

  testWidgets('proposals tab shows empty, loading, and error states', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(
      buildTestApp(
        repository,
        proposalStoreRepository: FakeProposalStoreRepository(),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavProposals')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('emptyProposalState')), findsOneWidget);

    final loadingController = StreamController<List<ProposalRecord>>();
    addTearDown(loadingController.close);
    await tester.pumpWidget(
      buildTestApp(
        repository,
        proposalStoreRepository: FakeProposalStoreRepository(
          recentStream: loadingController.stream,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('bottomNavProposals')));
    await tester.pump(const Duration(milliseconds: 360));
    expect(find.byKey(const Key('proposalHistoryLoading')), findsOneWidget);

    await tester.pumpWidget(
      buildTestApp(
        repository,
        proposalStoreRepository: FakeProposalStoreRepository(
          recentStream: Stream<List<ProposalRecord>>.error(
            Exception('store failed'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavProposals')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('proposalHistoryError')), findsOneWidget);
    expect(find.textContaining('store failed'), findsOneWidget);
  });

  testWidgets('bottom navigation animates between tabs', (tester) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pump(const Duration(milliseconds: 80));

    expect(find.byKey(const Key('proposalistTabSwitcher')), findsOneWidget);
    expect(find.byKey(const Key('dashboardTab')), findsOneWidget);
    expect(find.byKey(const Key('newProposalTab')), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dashboardTab')), findsNothing);
    expect(find.byKey(const Key('newProposalTab')), findsOneWidget);
  });

  testWidgets('generate flow shows loading then final proposal output', (
    tester,
  ) async {
    setMobileViewport(tester);
    final completer = Completer<Result<Proposal>>();
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalCompleter: completer,
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('promptField')),
      'Write a website redesign proposal',
    );
    await scrollUntilVisible(tester, find.byKey(const Key('generateButton')));

    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pump();

    expect(find.byKey(const Key('loadingProposalState')), findsOneWidget);
    expect(find.text('Generating your proposal...'), findsOneWidget);
    expect(
      find.byKey(const Key('proposalProgressStep0Completed')),
      findsOneWidget,
    );

    completer.complete(const Success(Proposal(content: 'Generated content')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('proposalOutput')), findsOneWidget);
    expect(find.text('Generated content'), findsOneWidget);
  });

  testWidgets('generation progress advances while waiting for OpenAI', (
    tester,
  ) async {
    setMobileViewport(tester);
    final completer = Completer<Result<Proposal>>();
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalCompleter: completer,
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollUntilVisible(tester, find.byKey(const Key('generateButton')));

    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pump(const Duration(milliseconds: 360));
    expect(find.byKey(const Key('loadingProposalState')), findsOneWidget);

    for (var second = 0; second < 4; second++) {
      await tester.pump(const Duration(seconds: 1));
    }

    expect(
      find.byKey(const Key('proposalProgressStep1Completed')),
      findsOneWidget,
    );
    expect(
      find.byKey(const Key('proposalProgressStep2Pending')),
      findsOneWidget,
    );

    completer.complete(const Success(Proposal(content: 'Generated content')));
    await tester.pumpAndSettle();
  });

  testWidgets('clarification questions render with separate answer fields', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: const Success(
        ClarificationResponse(
          needsClarification: true,
          questions: [
            'Who are the primary users?',
            'Do you have brand guidelines?',
          ],
          summary: 'The project needs more detail.',
          improvedPrompt: '',
        ),
      ),
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollUntilVisible(tester, find.byKey(const Key('generateButton')));

    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('clarificationsTab')), findsOneWidget);
    expect(find.text('Who are the primary users?'), findsOneWidget);
    expect(find.byKey(const Key('clarificationAnswerField0')), findsOneWidget);
    expect(find.byKey(const Key('clarificationAnswerField1')), findsOneWidget);
    expect(find.byKey(const Key('clarificationField')), findsNothing);
    await scrollUntilVisible(
      tester,
      find.byKey(const Key('submitClarificationsButton')),
    );

    expect(find.byKey(const Key('submitClarificationsButton')), findsOneWidget);
  });

  testWidgets('clarification answers generate without asking again', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: const Success(
        ClarificationResponse(
          needsClarification: true,
          questions: ['What is the client budget?', 'When is the deadline?'],
          summary: 'The proposal needs client budget detail.',
          improvedPrompt: '',
        ),
      ),
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollUntilVisible(tester, find.byKey(const Key('generateButton')));
    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('clarificationAnswerField0')),
      'The client budget is 5000 USD.',
    );
    await tester.enterText(
      find.byKey(const Key('clarificationAnswerField1')),
      'The deadline is next Friday.',
    );
    await scrollUntilVisible(
      tester,
      find.byKey(const Key('submitClarificationsButton')),
    );
    await tester.tap(find.byKey(const Key('submitClarificationsButton')));
    await tester.pumpAndSettle();

    expect(repository.clarificationRequestCount, 1);
    expect(repository.proposalRequestCount, 1);
    expect(
      repository.lastProposalClarificationAnswers,
      'Q1: What is the client budget?\n'
      'A1: The client budget is 5000 USD.\n\n'
      'Q2: When is the deadline?\n'
      'A2: The deadline is next Friday.',
    );
    expect(find.byKey(const Key('proposalOutput')), findsOneWidget);
  });

  testWidgets('saved profile context is attached to the first prompt', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(
      buildTestApp(
        repository,
        userProfileRepository: const FakeUserProfileRepository(
          UserProfile(
            fullName: 'Rebecca Moore',
            email: 'rebecca@example.com',
            professionalTitle: 'Proposal Strategist',
            about: 'Writes enterprise proposals.',
            cvText: '',
            profileImageUrl: '',
            portfolioLinks: ['https://portfolio.example.com'],
            education: [],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollUntilVisible(tester, find.byKey(const Key('generateButton')));
    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    expect(
      repository.lastClarificationProfileContext,
      contains('Rebecca Moore'),
    );
    expect(
      repository.lastClarificationProfileContext,
      contains('https://portfolio.example.com'),
    );
  });

  testWidgets('proposal errors use the redesigned recovery state', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const FailureResult(NetworkFailure('Network down')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollUntilVisible(tester, find.byKey(const Key('generateButton')));

    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('errorText')), findsOneWidget);
    expect(find.text('Unable to generate proposal'), findsOneWidget);
    expect(find.textContaining('Network down'), findsOneWidget);
  });

  testWidgets('try again retries the last failed proposal generation', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResults: [
        const FailureResult(NetworkFailure('The OpenAI request timed out.')),
        const Success(Proposal(content: 'Generated after retry')),
      ],
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollUntilVisible(tester, find.byKey(const Key('generateButton')));
    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    expect(find.text('Unable to generate proposal'), findsOneWidget);

    await tester.tap(find.byKey(const Key('retryProposalButton')));
    await tester.pumpAndSettle();

    expect(repository.proposalRequestCount, 2);
    expect(find.text('Generated after retry'), findsOneWidget);
  });

  testWidgets('profile tab exposes profile sections and settings placeholder', (
    tester,
  ) async {
    setMobileViewport(tester);
    final repository = FakeProposalRepository(
      clarificationResult: completedClarification,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('bottomNavProfile')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('profileTab')), findsOneWidget);
    expect(find.text('Profile Overview'), findsOneWidget);
    expect(find.text('Basic Information'), findsOneWidget);
    expect(find.byKey(const Key('firestoreConfigHint')), findsOneWidget);

    await tester.tap(find.byKey(const Key('openSettingsButton')));
    await tester.pump(const Duration(milliseconds: 80));

    expect(
      find.byKey(const Key('proposalistPageTransition'), skipOffstage: false),
      findsOneWidget,
    );

    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settingsScreen')), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Integrations'), findsOneWidget);
  });
}
