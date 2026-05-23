import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';
import 'package:proposal_writer/presentation/widgets/proposalist_components.dart';

class AuthBootstrapGate extends ConsumerWidget {
  const AuthBootstrapGate({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bootstrap = ref.watch(authBootstrapProvider);
    return bootstrap.when(
      loading: () => const _AuthLoadingView(),
      error: (error, _) => _AuthErrorView(message: error.toString()),
      data: (result) {
        return result.when(
          success: (_) => child,
          failure: (failure) => _AuthErrorView(message: failure.message),
        );
      },
    );
  }
}

class _AuthLoadingView extends StatelessWidget {
  const _AuthLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          key: const Key('authBootstrapLoading'),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: const ProposalistCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: ProposalistSpacing.md),
                  Text('Starting your session...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthErrorView extends StatelessWidget {
  const _AuthErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          key: const Key('authBootstrapError'),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: ProposalistCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: ProposalistColors.error.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.lock_outline,
                      color: ProposalistColors.error,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: ProposalistSpacing.md),
                  Text(
                    'Unable to start your session',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: ProposalistSpacing.xs),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
