import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/proposal.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/domain/usecases/generate_proposal_usecase.dart';
import 'package:proposal_writer/presentation/screens/home_screen.dart';
import 'package:proposal_writer/presentation/state/home_providers.dart';

class FakeProposalRepository implements ProposalRepository {
  FakeProposalRepository({this.completer, this.result});

  final Completer<Result<Proposal>>? completer;
  final Result<Proposal>? result;

  @override
  Future<Result<Proposal>> generateProposal({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
  }) async {
    if (completer != null) {
      return completer!.future;
    }
    return result ?? const FailureResult(UnknownFailure('Missing result'));
  }
}

Widget buildTestApp(GenerateProposalUseCase useCase) {
  return ProviderScope(
    overrides: [
      generateProposalUseCaseProvider.overrideWithValue(useCase),
      proposalGeneratorProvider.overrideWith(ProposalGenerator.new),
    ],
    child: const MaterialApp(home: HomeScreen()),
  );
}

void main() {
  testWidgets('Home screen renders inputs', (tester) async {
    final useCase = GenerateProposalUseCase(
      repository: FakeProposalRepository(),
    );

    await tester.pumpWidget(buildTestApp(useCase));

    expect(find.byKey(const Key('promptField')), findsOneWidget);
    expect(find.byKey(const Key('toneDropdown')), findsOneWidget);
    expect(find.byKey(const Key('maxTokensSlider')), findsOneWidget);
    expect(find.byKey(const Key('generateButton')), findsOneWidget);
  });

  testWidgets('Generate shows loading then output', (tester) async {
    final completer = Completer<Result<Proposal>>();
    final useCase = GenerateProposalUseCase(
      repository: FakeProposalRepository(completer: completer),
    );

    await tester.pumpWidget(buildTestApp(useCase));
    await tester.enterText(
      find.byKey(const Key('promptField')),
      'Write proposal',
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete(const Success(Proposal(content: 'Generated content')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('proposalOutput')), findsOneWidget);
    expect(find.text('Generated content'), findsOneWidget);
  });

  testWidgets('Error state renders message', (tester) async {
    final useCase = GenerateProposalUseCase(
      repository: FakeProposalRepository(
        result: const FailureResult(NetworkFailure('Network down')),
      ),
    );

    await tester.pumpWidget(buildTestApp(useCase));
    await tester.enterText(find.byKey(const Key('promptField')), 'Prompt');
    await tester.pump();

    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('errorText')), findsOneWidget);
    expect(find.textContaining('Network down'), findsOneWidget);
  });
}
