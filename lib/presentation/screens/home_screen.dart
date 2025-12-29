import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/presentation/state/home_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _promptController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
  }

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = ref.watch(promptProvider);
    final tone = ref.watch(toneProvider);
    final maxTokens = ref.watch(maxTokensProvider);
    final proposalState = ref.watch(proposalGeneratorProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Proposal Writer')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextField(
                      key: const Key('promptField'),
                      controller: _promptController,
                      maxLines: 5,
                      onChanged: (value) =>
                          ref.read(promptProvider.notifier).state = value,
                      decoration: const InputDecoration(
                        labelText: 'Describe what you need',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ProposalTone>(
                      key: const Key('toneDropdown'),
                      initialValue: tone,
                      decoration: const InputDecoration(
                        labelText: 'Tone',
                        border: OutlineInputBorder(),
                      ),
                      items: ProposalTone.values
                          .map(
                            (tone) => DropdownMenuItem(
                              value: tone,
                              child: Text(tone.label),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value != null) {
                          ref.read(toneProvider.notifier).state = value;
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    Text('Max tokens: $maxTokens'),
                    Slider(
                      key: const Key('maxTokensSlider'),
                      value: maxTokens.toDouble(),
                      min: minTokens.toDouble(),
                      max: maxTokensLimit.toDouble(),
                      divisions: ((maxTokensLimit - minTokens) / 16).round(),
                      label: '$maxTokens',
                      onChanged: (value) {
                        ref.read(maxTokensProvider.notifier).state = value
                            .round();
                      },
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      key: const Key('generateButton'),
                      onPressed:
                          prompt.trim().isEmpty || proposalState.isLoading
                          ? null
                          : () => ref
                                .read(proposalGeneratorProvider.notifier)
                                .generate(
                                  prompt: prompt.trim(),
                                  tone: tone,
                                  maxTokens: maxTokens,
                                ),
                      child: const Text('Generate'),
                    ),
                    const SizedBox(height: 24),
                    if (proposalState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (proposalState.hasError)
                      Text(
                        proposalState.error.toString(),
                        key: const Key('errorText'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                    else if (proposalState.value?.isNotEmpty ?? false)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: SelectableText(
                            proposalState.value ?? '',
                            key: const Key('proposalOutput'),
                          ),
                        ),
                      )
                    else
                      const Text(
                        'Enter a prompt and generate a proposal.',
                        key: Key('emptyStateText'),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
