import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/constants.dart';
import 'package:proposal_writer/domain/entities/proposal_tone.dart';
import 'package:proposal_writer/presentation/models/mock_dashboard_data.dart';
import 'package:proposal_writer/presentation/state/home_providers.dart';
import 'package:proposal_writer/presentation/state/proposal_flow_state.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';
import 'package:proposal_writer/presentation/widgets/proposalist_components.dart';
import 'package:proposal_writer/presentation/widgets/user_profile_card.dart';

enum _HomeTab { dashboard, newProposal, clarifications, proposals, profile }

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  late final TextEditingController _projectTitleController;
  late final TextEditingController _clientProjectController;
  late final TextEditingController _promptController;
  final List<TextEditingController> _clarificationControllers = [];

  _HomeTab _selectedTab = _HomeTab.dashboard;

  @override
  void initState() {
    super.initState();
    _projectTitleController = TextEditingController(
      text: 'Website Redesign Proposal',
    );
    _clientProjectController = TextEditingController(text: 'Acme Inc.');
    _promptController = TextEditingController();
  }

  @override
  void dispose() {
    _projectTitleController.dispose();
    _clientProjectController.dispose();
    _promptController.dispose();
    _disposeClarificationControllers();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = _HomeTab.values.indexOf(_selectedTab);

    return Scaffold(
      key: const Key('proposalistShell'),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _buildSelectedTab(),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            _selectedTab = _HomeTab.values[index];
          });
        },
        destinations: const [
          NavigationDestination(
            key: Key('bottomNavDashboard'),
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          NavigationDestination(
            key: Key('bottomNavNewProposal'),
            icon: Icon(Icons.add_circle_outline),
            selectedIcon: Icon(Icons.add_circle),
            label: 'New',
          ),
          NavigationDestination(
            key: Key('bottomNavClarifications'),
            icon: Badge(
              label: Text('3'),
              child: Icon(Icons.chat_bubble_outline),
            ),
            selectedIcon: Badge(
              label: Text('3'),
              child: Icon(Icons.chat_bubble),
            ),
            label: 'Clarifications',
          ),
          NavigationDestination(
            key: Key('bottomNavProposals'),
            icon: Icon(Icons.description_outlined),
            selectedIcon: Icon(Icons.description),
            label: 'Proposals',
          ),
          NavigationDestination(
            key: Key('bottomNavProfile'),
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedTab() {
    return switch (_selectedTab) {
      _HomeTab.dashboard => _DashboardTab(
        onNewProposal: () => setState(() {
          _selectedTab = _HomeTab.newProposal;
        }),
      ),
      _HomeTab.newProposal => _NewProposalTab(
        projectTitleController: _projectTitleController,
        clientProjectController: _clientProjectController,
        promptController: _promptController,
        onGenerate: _generateProposal,
        onSaveDraft: _showDraftPlaceholder,
      ),
      _HomeTab.clarifications => _ClarificationsTab(
        clarificationControllers: _controllersForQuestionCount(
          ref.watch(
            proposalFlowProvider.select((state) => state.questions.length),
          ),
        ),
        onContinue: _submitClarifications,
      ),
      _HomeTab.proposals => _ProposalsTab(
        onNewProposal: () => setState(() {
          _selectedTab = _HomeTab.newProposal;
        }),
      ),
      _HomeTab.profile => const _ProfileTab(),
    };
  }

  Future<void> _generateProposal() async {
    FocusScope.of(context).unfocus();
    _disposeClarificationControllers();
    setState(() {
      _selectedTab = _HomeTab.proposals;
    });
    await ref
        .read(proposalFlowProvider.notifier)
        .start(
          prompt: _promptController.text.trim(),
          tone: ref.read(toneProvider),
          maxTokens: ref.read(maxTokensProvider),
        );
    if (!mounted) {
      return;
    }
    final state = ref.read(proposalFlowProvider);
    setState(() {
      _selectedTab = state.awaitingClarifications
          ? _HomeTab.clarifications
          : _HomeTab.proposals;
    });
  }

  Future<void> _submitClarifications() async {
    FocusScope.of(context).unfocus();
    final questions = ref.read(proposalFlowProvider).questions;
    final answers = _formatClarificationAnswers(questions);
    setState(() {
      _selectedTab = _HomeTab.proposals;
    });
    await ref.read(proposalFlowProvider.notifier).submitClarifications(answers);
    if (!mounted) {
      return;
    }
    final state = ref.read(proposalFlowProvider);
    if (state.awaitingClarifications) {
      setState(() {
        _selectedTab = _HomeTab.clarifications;
      });
    }
  }

  void _showDraftPlaceholder() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Draft saving is tracked in the redesign roadmap.'),
      ),
    );
  }

  List<TextEditingController> _controllersForQuestionCount(int questionCount) {
    while (_clarificationControllers.length < questionCount) {
      _clarificationControllers.add(TextEditingController());
    }
    while (_clarificationControllers.length > questionCount) {
      _clarificationControllers.removeLast().dispose();
    }
    return List<TextEditingController>.unmodifiable(_clarificationControllers);
  }

  String _formatClarificationAnswers(List<String> questions) {
    final answers = <String>[];
    for (var index = 0; index < questions.length; index++) {
      final answer = _clarificationControllers[index].text.trim();
      if (answer.isEmpty) {
        continue;
      }
      answers.add(
        'Q${index + 1}: ${questions[index]}\n'
        'A${index + 1}: $answer',
      );
    }
    return answers.join('\n\n');
  }

  void _disposeClarificationControllers() {
    for (final controller in _clarificationControllers) {
      controller.dispose();
    }
    _clarificationControllers.clear();
  }
}

class _DashboardTab extends StatelessWidget {
  const _DashboardTab({required this.onNewProposal});

  final VoidCallback onNewProposal;

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('dashboardTab'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        ProposalistHeader(
          title: 'Proposalist',
          subtitle: 'AI Proposal Studio',
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_none),
              tooltip: 'Notifications',
            ),
            const CircleAvatar(radius: 16, child: Text('R')),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.lg),
        Text(
          'Welcome back, Rebecca',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const SizedBox(height: 4),
        Text(
          "Let's create winning proposals, faster.",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: ProposalistSpacing.md),
        FilledButton.icon(
          onPressed: onNewProposal,
          icon: const Icon(Icons.add, size: 18),
          label: const Text('New Proposal'),
        ),
        const SizedBox(height: ProposalistSpacing.lg),
        Text('This Week', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ProposalistSpacing.sm),
        GridView.count(
          crossAxisCount: 2,
          childAspectRatio: 1.16,
          mainAxisSpacing: ProposalistSpacing.sm,
          crossAxisSpacing: ProposalistSpacing.sm,
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          children: [
            for (final stat in dashboardStats) _DashboardStatCard(stat: stat),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.lg),
        SectionTitle(
          title: 'Recent Proposals',
          action: TextButton(onPressed: () {}, child: const Text('View all')),
        ),
        const SizedBox(height: ProposalistSpacing.xs),
        ProposalistCard(
          padding: const EdgeInsets.symmetric(
            horizontal: ProposalistSpacing.md,
            vertical: ProposalistSpacing.xs,
          ),
          child: Column(
            children: [
              for (final proposal in mockProposals.take(5))
                MockProposalListTile(proposal: proposal),
            ],
          ),
        ),
      ],
    );
  }
}

class _DashboardStatCard extends StatelessWidget {
  const _DashboardStatCard({required this.stat});

  final DashboardStat stat;

  @override
  Widget build(BuildContext context) {
    return ProposalistCard(
      padding: const EdgeInsets.all(ProposalistSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Text(stat.value, style: Theme.of(context).textTheme.titleLarge),
              const Spacer(),
              Icon(stat.icon, color: ProposalistColors.textPrimary, size: 18),
            ],
          ),
          const SizedBox(height: ProposalistSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(stat.label, style: Theme.of(context).textTheme.bodyMedium),
              Text(stat.helper, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _NewProposalTab extends ConsumerWidget {
  const _NewProposalTab({
    required this.projectTitleController,
    required this.clientProjectController,
    required this.promptController,
    required this.onGenerate,
    required this.onSaveDraft,
  });

  final TextEditingController projectTitleController;
  final TextEditingController clientProjectController;
  final TextEditingController promptController;
  final Future<void> Function() onGenerate;
  final VoidCallback onSaveDraft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final prompt = ref.watch(promptProvider);
    final tone = ref.watch(toneProvider);
    final maxTokens = ref.watch(maxTokensProvider);
    final proposalState = ref.watch(proposalFlowProvider);

    return ListView(
      key: const Key('newProposalTab'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const ProposalistHeader(
          title: 'New Proposal',
          subtitle: 'Add project details to get started.',
          leading: BackButton(),
          actions: [
            Icon(
              Icons.notifications_none,
              color: ProposalistColors.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.md),
        TextField(
          key: const Key('projectTitleField'),
          controller: projectTitleController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Project Title'),
        ),
        const SizedBox(height: ProposalistSpacing.md),
        TextField(
          key: const Key('clientProjectField'),
          controller: clientProjectController,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(labelText: 'Client / Project'),
        ),
        const SizedBox(height: ProposalistSpacing.md),
        TextField(
          key: const Key('promptField'),
          controller: promptController,
          maxLines: 4,
          maxLength: 5000,
          onChanged: (value) => ref.read(promptProvider.notifier).state = value,
          decoration: const InputDecoration(
            labelText: 'Project Brief',
            hintText: 'Paste the full description, RFP, or project brief.',
          ),
        ),
        const SizedBox(height: ProposalistSpacing.md),
        Text('Tone of Proposal', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: ProposalistSpacing.xs),
        Wrap(
          spacing: ProposalistSpacing.xs,
          children: [
            for (final option in ProposalTone.values)
              ChoiceChip(
                key: Key('toneChip${option.label}'),
                label: Text(option.label),
                selected: tone == option,
                selectedColor: ProposalistColors.primary,
                labelStyle: TextStyle(
                  color: tone == option
                      ? Colors.white
                      : ProposalistColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (_) {
                  ref.read(toneProvider.notifier).state = option;
                },
              ),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.md),
        Row(
          children: [
            Expanded(
              child: Text(
                'Max Tokens',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
            SizedBox(
              width: 72,
              child: TextField(
                readOnly: true,
                textAlign: TextAlign.center,
                decoration: InputDecoration(hintText: '$maxTokens'),
              ),
            ),
          ],
        ),
        Slider(
          key: const Key('maxTokensSlider'),
          value: maxTokens.toDouble(),
          min: minTokens.toDouble(),
          max: maxTokensLimit.toDouble(),
          divisions: ((maxTokensLimit - minTokens) / 50).round(),
          label: '$maxTokens',
          onChanged: (value) {
            ref.read(maxTokensProvider.notifier).state = value.round();
          },
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$minTokens', style: Theme.of(context).textTheme.bodySmall),
            Text(
              '$maxTokensLimit',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.md),
        const _InfoCallout(
          text:
              'Your selected profile (Acme Inc. Profile) will be '
              'automatically included as context.',
        ),
        const SizedBox(height: ProposalistSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                key: const Key('saveDraftButton'),
                onPressed: onSaveDraft,
                child: const Text('Save Draft'),
              ),
            ),
            const SizedBox(width: ProposalistSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                key: const Key('generateButton'),
                onPressed: prompt.trim().isEmpty || proposalState.isLoading
                    ? null
                    : onGenerate,
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Generate Proposal'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ClarificationsTab extends ConsumerStatefulWidget {
  const _ClarificationsTab({
    required this.clarificationControllers,
    required this.onContinue,
  });

  final List<TextEditingController> clarificationControllers;
  final Future<void> Function() onContinue;

  @override
  ConsumerState<_ClarificationsTab> createState() => _ClarificationsTabState();
}

class _ClarificationsTabState extends ConsumerState<_ClarificationsTab> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proposalFlowProvider);
    final allQuestionsAnswered =
        state.questions.isNotEmpty &&
        widget.clarificationControllers.length >= state.questions.length &&
        widget.clarificationControllers
            .take(state.questions.length)
            .every((controller) => controller.text.trim().isNotEmpty);

    return ListView(
      key: const Key('clarificationsTab'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const ProposalistHeader(
          title: 'Clarifications',
          subtitle: 'Step 2 of 3',
          leading: BackButton(),
          actions: [
            Icon(
              Icons.notifications_none,
              color: ProposalistColors.textPrimary,
            ),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.md),
        const ProgressSteps(currentStep: 1),
        const SizedBox(height: ProposalistSpacing.lg),
        ProposalistCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AI Summary',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ProposalistSpacing.xs),
              Text(
                state.summary ?? 'Clarification summary will appear here.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const SizedBox(height: ProposalistSpacing.md),
        Text(
          'Follow-up Questions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: ProposalistSpacing.xs),
        for (var index = 0; index < state.questions.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: ProposalistSpacing.sm),
            child: _ClarificationQuestionField(
              index: index,
              question: state.questions[index],
              controller: widget.clarificationControllers[index],
              onChanged: () => setState(() {}),
            ),
          ),
        const SizedBox(height: ProposalistSpacing.md),
        FilledButton.icon(
          key: const Key('submitClarificationsButton'),
          onPressed: !allQuestionsAnswered || state.isLoading
              ? null
              : widget.onContinue,
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('Continue'),
        ),
      ],
    );
  }
}

class _ClarificationQuestionField extends StatelessWidget {
  const _ClarificationQuestionField({
    required this.index,
    required this.question,
    required this.controller,
    required this.onChanged,
  });

  final int index;
  final String question;
  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ProposalistSpacing.md),
      decoration: BoxDecoration(
        color: ProposalistColors.surfaceAlt.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(ProposalistRadius.md),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: CircleAvatar(
              radius: 13,
              backgroundColor: ProposalistColors.surfaceAlt,
              child: Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: ProposalistColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: ProposalistSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(question),
                const SizedBox(height: ProposalistSpacing.sm),
                TextField(
                  key: Key('clarificationAnswerField$index'),
                  controller: controller,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 900,
                  onChanged: (_) => onChanged(),
                  decoration: InputDecoration(
                    hintText: 'Answer question ${index + 1}',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProposalsTab extends ConsumerWidget {
  const _ProposalsTab({required this.onNewProposal});

  final VoidCallback onNewProposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(proposalFlowProvider);
    final loading =
        state.stage == ProposalFlowStage.requestingClarifications ||
        state.stage == ProposalFlowStage.generating;

    if (loading) {
      return const _GeneratingProposalView();
    }
    if (state.errorMessage != null) {
      return _ErrorProposalView(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(proposalFlowProvider.notifier).retryGeneration(),
      );
    }
    if (state.proposal?.isNotEmpty ?? false) {
      return _FinalProposalView(proposal: state.proposal!);
    }
    return _ProposalHistoryView(onNewProposal: onNewProposal);
  }
}

class _ProposalHistoryView extends ConsumerWidget {
  const _ProposalHistoryView({required this.onNewProposal});

  final VoidCallback onNewProposal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposals = ref.watch(mockProposalCardsProvider);

    return ListView(
      key: const Key('proposalHistoryTab'),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        ProposalistHeader(
          title: 'Proposals',
          subtitle: 'Browse, filter, and manage all proposals.',
          actions: [
            IconButton(
              onPressed: onNewProposal,
              icon: const Icon(Icons.add),
              tooltip: 'New proposal',
            ),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.md),
        Row(
          children: [
            const Expanded(
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search proposals...',
                ),
              ),
            ),
            const SizedBox(width: ProposalistSpacing.xs),
            IconButton.outlined(
              onPressed: () {},
              icon: const Icon(Icons.tune),
              tooltip: 'Filters',
            ),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.sm),
        const Wrap(
          spacing: ProposalistSpacing.xs,
          runSpacing: ProposalistSpacing.xs,
          children: [
            Chip(label: Text('All')),
            Chip(label: Text('In Progress')),
            Chip(label: Text('Completed')),
            Chip(label: Text('Draft')),
            Chip(label: Text('Saved')),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.md),
        if (proposals.isEmpty)
          _EmptyProposalView(onNewProposal: onNewProposal)
        else
          ProposalistCard(
            padding: const EdgeInsets.symmetric(
              horizontal: ProposalistSpacing.md,
              vertical: ProposalistSpacing.xs,
            ),
            child: Column(
              children: [
                for (final proposal in proposals)
                  MockProposalListTile(proposal: proposal),
              ],
            ),
          ),
      ],
    );
  }
}

class _EmptyProposalView extends StatelessWidget {
  const _EmptyProposalView({required this.onNewProposal});

  final VoidCallback onNewProposal;

  @override
  Widget build(BuildContext context) {
    return ProposalistCard(
      child: Column(
        key: const Key('emptyProposalState'),
        children: [
          Container(
            width: 104,
            height: 104,
            decoration: const BoxDecoration(
              color: ProposalistColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.inventory_2_outlined,
              color: ProposalistColors.primary,
              size: 44,
            ),
          ),
          const SizedBox(height: ProposalistSpacing.md),
          Text(
            'No proposals yet',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: ProposalistSpacing.xs),
          Text(
            'Create your first proposal to get started.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: ProposalistSpacing.md),
          FilledButton.icon(
            onPressed: onNewProposal,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('New Proposal'),
          ),
          TextButton(onPressed: () {}, child: const Text('Learn how it works')),
        ],
      ),
    );
  }
}

class _GeneratingProposalView extends StatefulWidget {
  const _GeneratingProposalView();

  @override
  State<_GeneratingProposalView> createState() =>
      _GeneratingProposalViewState();
}

class _GeneratingProposalViewState extends State<_GeneratingProposalView> {
  static const _steps = [
    _ProgressStep('Analyzing your inputs', Icons.manage_search),
    _ProgressStep('Reading saved profile context', Icons.badge_outlined),
    _ProgressStep('Crafting proposal content', Icons.edit_document),
    _ProgressStep('Formatting and polishing', Icons.auto_awesome),
  ];

  Timer? _timer;
  int _activeStep = 0;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (!mounted || _activeStep >= _steps.length - 1) {
        return;
      }
      setState(() {
        _activeStep += 1;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progressValue = switch (_activeStep) {
      0 => 0.28,
      1 => 0.52,
      2 => 0.76,
      _ => 0.92,
    };
    final activeLabel = _steps[_activeStep].label;

    return ListView(
      key: const Key('loadingProposalState'),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      children: [
        const SizedBox(height: ProposalistSpacing.xxl),
        Center(
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: progressValue),
            duration: const Duration(milliseconds: 520),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) {
              return Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox.square(
                    dimension: 112,
                    child: CircularProgressIndicator(
                      value: value,
                      strokeWidth: 6,
                      backgroundColor: ProposalistColors.surfaceAlt,
                    ),
                  ),
                  child!,
                ],
              );
            },
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              child: Container(
                key: ValueKey(_activeStep),
                width: 86,
                height: 86,
                decoration: const BoxDecoration(
                  color: ProposalistColors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _steps[_activeStep].icon,
                  color: ProposalistColors.primary,
                  size: 42,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: ProposalistSpacing.lg),
        Text(
          'Generating your proposal...',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: ProposalistSpacing.xs),
        Text(
          'This usually takes 20-60 seconds.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: ProposalistSpacing.xs),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: Text(
            activeLabel,
            key: ValueKey(activeLabel),
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.labelLarge?.copyWith(color: ProposalistColors.primary),
          ),
        ),
        const SizedBox(height: ProposalistSpacing.lg),
        TweenAnimationBuilder<double>(
          tween: Tween(end: progressValue),
          duration: const Duration(milliseconds: 520),
          curve: Curves.easeOutCubic,
          builder: (context, value, _) {
            return LinearProgressIndicator(value: value);
          },
        ),
        const SizedBox(height: ProposalistSpacing.lg),
        for (var index = 0; index < _steps.length; index++)
          _ChecklistItem(
            index: index,
            label: _steps[index].label,
            checked: index <= _activeStep,
          ),
        const SizedBox(height: ProposalistSpacing.lg),
        const _InfoCallout(
          text:
              'Detailed answers and context help us create stronger, '
              'more relevant proposals.',
        ),
      ],
    );
  }
}

class _ProgressStep {
  const _ProgressStep(this.label, this.icon);

  final String label;
  final IconData icon;
}

class _ErrorProposalView extends StatelessWidget {
  const _ErrorProposalView({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      children: [
        ProposalistCard(
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: ProposalistColors.error.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: ProposalistColors.error,
                  size: 32,
                ),
              ),
              const SizedBox(height: ProposalistSpacing.md),
              Text(
                'Unable to generate proposal',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: ProposalistSpacing.xs),
              Text(
                message,
                key: const Key('errorText'),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: ProposalistSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      key: const Key('retryProposalButton'),
                      onPressed: onRetry,
                      child: const Text('Try Again'),
                    ),
                  ),
                  const SizedBox(width: ProposalistSpacing.sm),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {},
                      child: const Text('Check Settings'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FinalProposalView extends StatelessWidget {
  const _FinalProposalView({required this.proposal});

  final String proposal;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        const ProposalistHeader(
          title: 'Final Proposal',
          subtitle: 'Generated just now',
          leading: BackButton(),
        ),
        const SizedBox(height: ProposalistSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: proposal));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Proposal copied.')),
                  );
                },
                icon: const Icon(Icons.copy, size: 16),
                label: const Text('Copy'),
              ),
            ),
            const SizedBox(width: ProposalistSpacing.xs),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
            ),
            const SizedBox(width: ProposalistSpacing.xs),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.ios_share, size: 16),
                label: const Text('Export'),
              ),
            ),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.md),
        ProposalistCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const ProposalistLogo(size: 34),
                  const SizedBox(width: ProposalistSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Proposalist',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'AI Proposal Studio',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: ProposalistSpacing.lg),
              Text(
                'Website Redesign Proposal',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: ProposalistSpacing.xs),
              Text(
                'Prepared for Acme Inc.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: ProposalistSpacing.lg),
              SelectableText(
                proposal,
                key: const Key('proposalOutput'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      children: [
        ProposalistHeader(
          title: 'Profile',
          subtitle: 'Reusable proposal context.',
          actions: [
            IconButton(
              key: const Key('openSettingsButton'),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SettingsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.more_vert),
              tooltip: 'Settings',
            ),
          ],
        ),
        const SizedBox(height: ProposalistSpacing.md),
        const UserProfileCard(),
      ],
    );
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('settingsScreen'),
      appBar: AppBar(
        title: const Text('Settings'),
        leading: const BackButton(),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                Text(
                  'Configure your preferences.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: ProposalistSpacing.md),
                Text(
                  'Integrations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: ProposalistSpacing.sm),
                for (final tile in settingsTiles)
                  Padding(
                    padding: const EdgeInsets.only(
                      bottom: ProposalistSpacing.sm,
                    ),
                    child: ProposalistCard(
                      child: Row(
                        children: [
                          Icon(tile.icon, color: ProposalistColors.primary),
                          const SizedBox(width: ProposalistSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tile.title,
                                  style: Theme.of(context).textTheme.labelLarge,
                                ),
                                Text(
                                  tile.subtitle,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                          if (tile.status != null)
                            StatusBadge(
                              label: tile.status!,
                              color: ProposalistColors.success,
                              compact: true,
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ChecklistItem extends StatelessWidget {
  const _ChecklistItem({
    required this.index,
    required this.label,
    required this.checked,
  });

  final int index;
  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: Key(
        'proposalProgressStep$index${checked ? 'Completed' : 'Pending'}',
      ),
      padding: const EdgeInsets.only(bottom: ProposalistSpacing.sm),
      child: Row(
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 180),
            child: Icon(
              checked ? Icons.check_circle : Icons.circle_outlined,
              key: ValueKey(checked),
              color: checked
                  ? ProposalistColors.primary
                  : ProposalistColors.border,
              size: 18,
            ),
          ),
          const SizedBox(width: ProposalistSpacing.sm),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _InfoCallout extends StatelessWidget {
  const _InfoCallout({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(ProposalistSpacing.md),
      decoration: BoxDecoration(
        color: ProposalistColors.surfaceAlt.withValues(alpha: 0.76),
        borderRadius: BorderRadius.circular(ProposalistRadius.md),
        border: Border.all(color: const Color(0xFFE0E7FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            color: ProposalistColors.primary,
            size: 18,
          ),
          const SizedBox(width: ProposalistSpacing.sm),
          Expanded(
            child: Text(text, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
