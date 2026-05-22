import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/entities/clarification_response.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/presentation/screens/home_screen.dart';
import 'package:proposal_writer/presentation/state/home_providers.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';

class GoldenProposalRepository implements ProposalRepository {
  GoldenProposalRepository({
    required this.clarificationResult,
    required this.proposalResult,
    this.proposalCompleter,
  });

  final Result<ClarificationResponse> clarificationResult;
  final Result<Proposal> proposalResult;
  final Completer<Result<Proposal>>? proposalCompleter;

  @override
  Future<Result<Proposal>> generateProposal({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
    required String summary,
    String? clarificationAnswers,
    String? userProfileContext,
  }) async {
    if (proposalCompleter != null) {
      return proposalCompleter!.future;
    }
    return proposalResult;
  }

  @override
  Future<Result<ClarificationResponse>> requestClarifications({
    required String prompt,
    String? userProfileContext,
  }) async {
    return clarificationResult;
  }
}

Widget buildGoldenApp(
  ProposalRepository repository, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: [
      proposalRepositoryProvider.overrideWithValue(repository),
      userProfileRepositoryProvider.overrideWithValue(
        const DisabledUserProfileRepository(),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      theme: buildProposalistTheme(),
      home: const HomeScreen(),
    ),
  );
}

Future<void> pumpAtSize(
  WidgetTester tester,
  Size size,
  ProposalRepository repository, {
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(buildGoldenApp(repository, overrides: overrides));
  await tester.pumpAndSettle();
}

Future<void> openNewProposal(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
  await tester.pumpAndSettle();
}

Future<void> scrollTo(WidgetTester tester, Finder finder) async {
  await tester.scrollUntilVisible(
    finder,
    360,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    final loader = FontLoader('Inter')
      ..addFont(rootBundle.load('assets/fonts/Inter-Regular.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-Medium.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-SemiBold.ttf'))
      ..addFont(rootBundle.load('assets/fonts/Inter-Bold.ttf'));
    await loader.load();

    final materialIconsLoader = FontLoader('MaterialIcons')
      ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
    await materialIconsLoader.load();
  });

  const completedClarification = Success(
    ClarificationResponse(
      needsClarification: false,
      questions: [],
      summary: 'summary',
      improvedPrompt: 'improved prompt',
    ),
  );
  const generatedProposal = Success(
    Proposal(
      content:
          '1. Executive Summary\n\n'
          'We propose a focused redesign that improves usability, clarity, '
          'and conversion across the SaaS platform.\n\n'
          '2. Understanding Your Needs\n\n'
          'The work will align dashboard, analytics, reports, and settings '
          'into a consistent product experience.',
    ),
  );

  testWidgets('dashboard at 390x844', (tester) async {
    await pumpAtSize(
      tester,
      const Size(390, 844),
      GoldenProposalRepository(
        clarificationResult: completedClarification,
        proposalResult: generatedProposal,
      ),
    );

    await expectLater(
      find.byKey(const Key('proposalistShell')),
      matchesGoldenFile('goldens/mobile_dashboard_390.png'),
    );
  });

  testWidgets('new proposal at 360x800', (tester) async {
    await pumpAtSize(
      tester,
      const Size(360, 800),
      GoldenProposalRepository(
        clarificationResult: completedClarification,
        proposalResult: generatedProposal,
      ),
    );
    await openNewProposal(tester);

    await expectLater(
      find.byKey(const Key('proposalistShell')),
      matchesGoldenFile('goldens/mobile_new_proposal_360.png'),
    );
  });

  testWidgets('clarifications at 390x844', (tester) async {
    await pumpAtSize(
      tester,
      const Size(390, 844),
      GoldenProposalRepository(
        clarificationResult: const Success(
          ClarificationResponse(
            needsClarification: true,
            questions: [
              'Who are the primary user personas for this platform?',
              'Do you have any existing brand guidelines?',
              'What is your preferred timeline?',
            ],
            summary: 'The project needs a mobile-first SaaS redesign.',
            improvedPrompt: '',
          ),
        ),
        proposalResult: generatedProposal,
      ),
    );
    await openNewProposal(tester);
    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollTo(tester, find.byKey(const Key('generateButton')));
    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('proposalistShell')),
      matchesGoldenFile('goldens/mobile_clarifications_390.png'),
    );
  });

  testWidgets('final proposal at 430x932', (tester) async {
    await pumpAtSize(
      tester,
      const Size(430, 932),
      GoldenProposalRepository(
        clarificationResult: completedClarification,
        proposalResult: generatedProposal,
      ),
    );
    await openNewProposal(tester);
    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollTo(tester, find.byKey(const Key('generateButton')));
    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('proposalistShell')),
      matchesGoldenFile('goldens/mobile_final_proposal_430.png'),
    );
  });

  testWidgets('proposal history at 390x844', (tester) async {
    await pumpAtSize(
      tester,
      const Size(390, 844),
      GoldenProposalRepository(
        clarificationResult: completedClarification,
        proposalResult: generatedProposal,
      ),
    );
    await tester.tap(find.byKey(const Key('bottomNavProposals')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('proposalistShell')),
      matchesGoldenFile('goldens/mobile_proposal_history_390.png'),
    );
  });

  testWidgets('profile overview at 390x844', (tester) async {
    await pumpAtSize(
      tester,
      const Size(390, 844),
      GoldenProposalRepository(
        clarificationResult: completedClarification,
        proposalResult: generatedProposal,
      ),
    );
    await tester.tap(find.byKey(const Key('bottomNavProfile')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('proposalistShell')),
      matchesGoldenFile('goldens/mobile_profile_390.png'),
    );
  });

  testWidgets('settings placeholder at 390x844', (tester) async {
    await pumpAtSize(
      tester,
      const Size(390, 844),
      GoldenProposalRepository(
        clarificationResult: completedClarification,
        proposalResult: generatedProposal,
      ),
    );
    await tester.tap(find.byKey(const Key('bottomNavProfile')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('openSettingsButton')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('settingsScreen')),
      matchesGoldenFile('goldens/mobile_settings_390.png'),
    );
  });

  testWidgets('error state at 360x800', (tester) async {
    await pumpAtSize(
      tester,
      const Size(360, 800),
      GoldenProposalRepository(
        clarificationResult: completedClarification,
        proposalResult: const FailureResult(NetworkFailure('Network down')),
      ),
    );
    await openNewProposal(tester);
    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollTo(tester, find.byKey(const Key('generateButton')));
    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(const Key('proposalistShell')),
      matchesGoldenFile('goldens/mobile_error_360.png'),
    );
  });

  testWidgets('loading state at 390x844', (tester) async {
    await pumpAtSize(
      tester,
      const Size(390, 844),
      GoldenProposalRepository(
        clarificationResult: completedClarification,
        proposalResult: generatedProposal,
        proposalCompleter: Completer<Result<Proposal>>(),
      ),
    );
    await openNewProposal(tester);
    await tester.enterText(find.byKey(const Key('promptField')), 'Proposal');
    await scrollTo(tester, find.byKey(const Key('generateButton')));
    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pump();

    await expectLater(
      find.byKey(const Key('proposalistShell')),
      matchesGoldenFile('goldens/mobile_loading_390.png'),
    );
  });

  testWidgets('empty proposal state at 430x932', (tester) async {
    await pumpAtSize(
      tester,
      const Size(430, 932),
      GoldenProposalRepository(
        clarificationResult: completedClarification,
        proposalResult: generatedProposal,
      ),
      overrides: [mockProposalCardsProvider.overrideWithValue(const [])],
    );
    await tester.tap(find.byKey(const Key('bottomNavProposals')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('emptyProposalState')), findsOneWidget);
    await expectLater(
      find.byKey(const Key('proposalistShell')),
      matchesGoldenFile('goldens/mobile_empty_state_430.png'),
    );
  });
}
