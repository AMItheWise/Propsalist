import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';

final promptProvider = StateProvider<String>((ref) => '');
final toneProvider = StateProvider<ProposalTone>((ref) => ProposalTone.direct);
final maxTokensProvider = StateProvider<int>((ref) => defaultMaxTokens);

class ProposalGenerator extends AsyncNotifier<String?> {
  @override
  Future<String?> build() async => null;

  Future<void> generate({
    required String prompt,
    required ProposalTone tone,
    required int maxTokens,
  }) async {
    state = const AsyncLoading();
    final useCase = ref.read(generateProposalUseCaseProvider);
    final result = await useCase(
      prompt: prompt,
      tone: tone,
      maxTokens: maxTokens,
    );
    state = result.when(
      success: (proposal) => AsyncData(proposal.content),
      failure: (failure) => AsyncError(failure.message, StackTrace.current),
    );
  }
}

final proposalGeneratorProvider =
    AsyncNotifierProvider<ProposalGenerator, String?>(ProposalGenerator.new);
