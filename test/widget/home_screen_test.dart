import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/entities/clarification_response.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/presentation/screens/home_screen.dart';
import 'package:proposal_writer/core/di/providers.dart';

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
        const FailureResult(UnknownFailure('Missing result'));
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
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  const clarificationResult = Success(
    ClarificationResponse(
      needsClarification: false,
      questions: [],
      summary: 'summary',
      improvedPrompt: 'prompt',
    ),
  );

  testWidgets('Home screen renders profile and proposal inputs', (
    tester,
  ) async {
    final repository = FakeProposalRepository(
      clarificationResult: clarificationResult,
      proposalResult: const Success(Proposal(content: 'Generated content')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();

    expect(find.text('User Profile'), findsOneWidget);
    expect(find.byKey(const Key('firestoreConfigHint')), findsOneWidget);
    expect(find.byKey(const Key('promptField')), findsOneWidget);
    expect(find.byKey(const Key('toneDropdown')), findsOneWidget);
    expect(find.byKey(const Key('maxTokensSlider')), findsOneWidget);
    expect(find.byKey(const Key('generateButton')), findsOneWidget);
  });

  testWidgets('Generate shows loading then output', (tester) async {
    final completer = Completer<Result<Proposal>>();
    final repository = FakeProposalRepository(
      clarificationResult: clarificationResult,
      proposalCompleter: completer,
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const Key('promptField')),
      'Write proposal',
    );
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Success(Proposal(content: 'Generated content')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('proposalOutput')), findsOneWidget);
    expect(find.text('Generated content'), findsOneWidget);
  });

  testWidgets('Error state renders message', (tester) async {
    final repository = FakeProposalRepository(
      clarificationResult: clarificationResult,
      proposalResult: const FailureResult(NetworkFailure('Network down')),
    );

    await tester.pumpWidget(buildTestApp(repository));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('promptField')), 'Prompt');
    await tester.pump();
    await tester.ensureVisible(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('errorText')), findsOneWidget);
    expect(find.textContaining('Network down'), findsOneWidget);
  });
}
