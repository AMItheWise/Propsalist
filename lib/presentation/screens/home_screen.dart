import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  late final TextEditingController _clarificationController;

  @override
  void initState() {
    super.initState();
    _promptController = TextEditingController();
    _clarificationController = TextEditingController();
  }

  @override
  void dispose() {
    _promptController.dispose();
    _clarificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prompt = ref.watch(promptProvider);
    final tone = ref.watch(toneProvider);
    final maxTokens = ref.watch(maxTokensProvider);
    final proposalState = ref.watch(proposalFlowProvider);

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
                          : () {
                              _clarificationController.clear();
                              ref
                                  .read(proposalFlowProvider.notifier)
                                  .start(
                                    prompt: prompt.trim(),
                                    tone: tone,
                                    maxTokens: maxTokens,
                                  );
                            },
                      child: const Text('Generate'),
                    ),
                    const SizedBox(height: 24),
                    if (proposalState.isLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (proposalState.errorMessage != null)
                      Text(
                        proposalState.errorMessage ?? '',
                        key: const Key('errorText'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      )
                    else if (proposalState.awaitingClarifications)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Please clarify:',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                              const SizedBox(height: 12),
                              for (final question in proposalState.questions)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: Text('• $question'),
                                ),
                              const SizedBox(height: 8),
                              TextField(
                                key: const Key('clarificationField'),
                                controller: _clarificationController,
                                maxLines: 4,
                                onChanged: (_) => setState(() {}),
                                decoration: const InputDecoration(
                                  labelText: 'Your answers',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                              const SizedBox(height: 12),
                              FilledButton(
                                key: const Key('submitClarificationsButton'),
                                onPressed:
                                    _clarificationController.text.trim().isEmpty
                                    ? null
                                    : () => ref
                                          .read(proposalFlowProvider.notifier)
                                          .submitClarifications(
                                            _clarificationController.text
                                                .trim(),
                                          ),
                                child: const Text('Continue'),
                              ),
                            ],
                          ),
                        ),
                      )
                    else if (proposalState.proposal?.isNotEmpty ?? false)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Proposal',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleMedium,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.content_copy),
                                    tooltip: 'Copy proposal',
                                    onPressed: () {
                                      final proposal =
                                          proposalState.proposal ?? '';
                                      Clipboard.setData(
                                        ClipboardData(text: proposal),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text('Proposal copied.'),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              SelectableText(
                                proposalState.proposal ?? '',
                                key: const Key('proposalOutput'),
                              ),
                            ],
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
