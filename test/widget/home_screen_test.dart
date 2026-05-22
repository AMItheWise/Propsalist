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
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/presentation/screens/home_screen.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';

class FakeProposalRepository implements ProposalRepository {
  FakeProposalRepository({
    required this.clarificationResult,
    this.proposalCompleter,
    this.proposalResult,
  });

  final Result<ClarificationResponse> clarificationResult;
  final Completer<Result<Proposal>>? proposalCompleter;
  final Result<Proposal>? proposalResult;

  @override
  Future<Result<ClarificationResponse>> requestClarifications({
    required String prompt,
    String? userProfileContext,
  }) async {
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
    if (proposalCompleter != null) {
      return proposalCompleter!.future;
    }
    return proposalResult ??
        const FailureResult(UnknownFailure('Missing proposal result'));
  }
}

Widget buildTestApp(ProposalRepository repository) {
  return ProviderScope(
    overrides: [
      proposalRepositoryProvider.overrideWithValue(repository),
      userProfileRepositoryProvider.overrideWithValue(
        const DisabledUserProfileRepository(),
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

    completer.complete(const Success(Proposal(content: 'Generated content')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('proposalOutput')), findsOneWidget);
    expect(find.text('Generated content'), findsOneWidget);
  });

  testWidgets('clarification questions render in the clarifications tab', (
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
    expect(find.byKey(const Key('clarificationField')), findsOneWidget);
    await scrollUntilVisible(
      tester,
      find.byKey(const Key('submitClarificationsButton')),
    );

    expect(find.byKey(const Key('submitClarificationsButton')), findsOneWidget);
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
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('settingsScreen')), findsOneWidget);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Integrations'), findsOneWidget);
  });
}
