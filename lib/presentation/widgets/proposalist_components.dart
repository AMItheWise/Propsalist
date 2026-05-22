import 'package:flutter/material.dart';

import 'package:proposal_writer/presentation/models/mock_dashboard_data.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';

class ProposalistLogo extends StatelessWidget {
  const ProposalistLogo({super.key, this.size = 38});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [ProposalistColors.primary, Color(0xFF2563EB)],
        ),
        boxShadow: [
          BoxShadow(
            color: ProposalistColors.primary.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Center(
        child: Text(
          'P',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontSize: size * 0.62,
            fontWeight: FontWeight.w800,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class ProposalistHeader extends StatelessWidget {
  const ProposalistHeader({
    required this.title,
    required this.subtitle,
    super.key,
    this.leading,
    this.actions = const [],
  });

  final String title;
  final String subtitle;
  final Widget? leading;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          leading ?? const ProposalistLogo(),
          const SizedBox(width: ProposalistSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ...actions,
        ],
      ),
    );
  }
}

class ProposalistCard extends StatelessWidget {
  const ProposalistCard({required this.child, super.key, this.padding});

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: padding ?? const EdgeInsets.all(ProposalistSpacing.md),
        child: child,
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    required this.label,
    required this.color,
    super.key,
    this.compact = false,
  });

  final String label;
  final Color color;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 7 : 9,
        vertical: compact ? 4 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: color,
          fontSize: compact ? 10 : 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class MockProposalListTile extends StatelessWidget {
  const MockProposalListTile({required this.proposal, super.key});

  final MockProposalCard proposal;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: ProposalistColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(ProposalistRadius.sm),
            ),
            child: Center(
              child: Text(
                proposal.leading,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: ProposalistColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: ProposalistSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  proposal.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: ProposalistColors.textPrimary,
                  ),
                ),
                Text(
                  proposal.client,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: ProposalistSpacing.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: proposal.status,
                color: proposal.statusColor,
                compact: true,
              ),
              const SizedBox(height: 4),
              Text(
                proposal.updated,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
          const SizedBox(width: ProposalistSpacing.xs),
          const Icon(
            Icons.more_horiz,
            color: ProposalistColors.textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }
}

class ProgressSteps extends StatelessWidget {
  const ProgressSteps({required this.currentStep, super.key});

  final int currentStep;

  @override
  Widget build(BuildContext context) {
    const labels = ['Brief Analysis', 'Clarifications', 'Generate Proposal'];
    return Column(
      children: [
        Row(
          children: [
            for (var index = 0; index < labels.length; index++) ...[
              _StepCircle(index: index, currentStep: currentStep),
              if (index != labels.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: index < currentStep
                        ? ProposalistColors.primary
                        : ProposalistColors.border,
                  ),
                ),
            ],
          ],
        ),
        const SizedBox(height: ProposalistSpacing.xs),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            for (final label in labels)
              Expanded(
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    color: ProposalistColors.textSecondary,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _StepCircle extends StatelessWidget {
  const _StepCircle({required this.index, required this.currentStep});

  final int index;
  final int currentStep;

  @override
  Widget build(BuildContext context) {
    final completed = index < currentStep;
    final active = index == currentStep;
    final color = completed || active
        ? ProposalistColors.primary
        : ProposalistColors.border;
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(
        child: completed
            ? const Icon(Icons.check, color: Colors.white, size: 15)
            : Text(
                '${index + 1}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: active
                      ? Colors.white
                      : ProposalistColors.textSecondary,
                ),
              ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  const SectionTitle({required this.title, super.key, this.action});

  final String title;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (action != null) action!,
      ],
    );
  }
}
