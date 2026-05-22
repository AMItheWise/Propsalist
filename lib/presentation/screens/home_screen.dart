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
  late final TextEditingController _clarificationController;

  _HomeTab _selectedTab = _HomeTab.dashboard;

  @override
  void initState() {
    super.initState();
    _projectTitleController = TextEditingController(
      text: 'Website Redesign Proposal',
    );
    _clientProjectController = TextEditingController(text: 'Acme Inc.');
    _promptController = TextEditingController();
    _clarificationController = TextEditingController();
  }

  @override
  void dispose() {
    _projectTitleController.dispose();
    _clientProjectController.dispose();
    _promptController.dispose();
    _clarificationController.dispose();
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
        clarificationController: _clarificationController,
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
    _clarificationController.clear();
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
    setState(() {
      _selectedTab = _HomeTab.proposals;
    });
    await ref
        .read(proposalFlowProvider.notifier)
        .submitClarifications(_clarificationController.text.trim());
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
    required this.clarificationController,
    required this.onContinue,
  });

  final TextEditingController clarificationController;
  final Future<void> Function() onContinue;

  @override
  ConsumerState<_ClarificationsTab> createState() => _ClarificationsTabState();
}

class _ClarificationsTabState extends ConsumerState<_ClarificationsTab> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(proposalFlowProvider);

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
            padding: const EdgeInsets.only(bottom: ProposalistSpacing.xs),
            child: _QuestionRow(
              index: index + 1,
              question: state.questions[index],
            ),
          ),
        const SizedBox(height: ProposalistSpacing.md),
        Text('Your Answer', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: ProposalistSpacing.xs),
        TextField(
          key: const Key('clarificationField'),
          controller: widget.clarificationController,
          maxLines: 8,
          maxLength: 2000,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(
            hintText: 'Provide as much detail as possible.',
          ),
        ),
        const SizedBox(height: ProposalistSpacing.md),
        FilledButton.icon(
          key: const Key('submitClarificationsButton'),
          onPressed:
              widget.clarificationController.text.trim().isEmpty ||
                  state.isLoading
              ? null
              : widget.onContinue,
          icon: const Icon(Icons.arrow_forward, size: 18),
          label: const Text('Continue'),
        ),
      ],
    );
  }
}

class _QuestionRow extends StatelessWidget {
  const _QuestionRow({required this.index, required this.question});

  final int index;
  final String question;

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
        children: [
          CircleAvatar(
            radius: 13,
            backgroundColor: ProposalistColors.surfaceAlt,
            child: Text(
              '$index',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: ProposalistColors.primary,
              ),
            ),
          ),
          const SizedBox(width: ProposalistSpacing.sm),
          Expanded(child: Text(question)),
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
      return _ErrorProposalView(message: state.errorMessage!);
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

class _GeneratingProposalView extends StatelessWidget {
  const _GeneratingProposalView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      key: const Key('loadingProposalState'),
      padding: const EdgeInsets.fromLTRB(20, 48, 20, 24),
      children: [
        const SizedBox(height: ProposalistSpacing.xxl),
        Center(
          child: Container(
            width: 108,
            height: 108,
            decoration: const BoxDecoration(
              color: ProposalistColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: ProposalistColors.primary,
              size: 46,
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
        const SizedBox(height: ProposalistSpacing.lg),
        const LinearProgressIndicator(value: 0.46),
        const SizedBox(height: ProposalistSpacing.lg),
        const _ChecklistItem(label: 'Analyzing your inputs', checked: true),
        const _ChecklistItem(
          label: 'Crafting proposal content',
          checked: false,
        ),
        const _ChecklistItem(
          label: 'Applying brand voice & tone',
          checked: false,
        ),
        const _ChecklistItem(label: 'Formatting and polishing', checked: false),
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

class _ErrorProposalView extends StatelessWidget {
  const _ErrorProposalView({required this.message});

  final String message;

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
                      onPressed: () {},
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
  const _ChecklistItem({required this.label, required this.checked});

  final String label;
  final bool checked;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: ProposalistSpacing.sm),
      child: Row(
        children: [
          Icon(
            checked ? Icons.check_circle : Icons.circle_outlined,
            color: checked
                ? ProposalistColors.primary
                : ProposalistColors.border,
            size: 18,
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
