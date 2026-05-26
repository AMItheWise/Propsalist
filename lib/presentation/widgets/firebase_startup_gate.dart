import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/app_bootstrap.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';
import 'package:proposal_writer/presentation/widgets/proposalist_components.dart';

typedef FirebaseConfigInitializer =
    Future<EnvConfig> Function(EnvConfig config);

class FirebaseStartupGate extends ConsumerStatefulWidget {
  const FirebaseStartupGate({
    required this.child,
    this.initialize = initializeFirebaseForConfig,
    super.key,
  });

  final Widget child;
  final FirebaseConfigInitializer initialize;

  @override
  ConsumerState<FirebaseStartupGate> createState() =>
      _FirebaseStartupGateState();
}

class _FirebaseStartupGateState extends ConsumerState<FirebaseStartupGate> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future<void>.delayed(
        const Duration(milliseconds: 600),
        _initializeFirebase,
      );
    });
  }

  Future<void> _initializeFirebase() async {
    final config = ref.read(envConfigProvider);
    final initializedConfig = await widget.initialize(config);
    if (!mounted) {
      return;
    }
    ref.read(envConfigStateProvider.notifier).state = initializedConfig;
    setState(() {
      _ready = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_ready) {
      return widget.child;
    }
    return const _FirebaseStartupLoadingView();
  }
}

class _FirebaseStartupLoadingView extends StatelessWidget {
  const _FirebaseStartupLoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          key: const Key('firebaseStartupLoading'),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: const ProposalistCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: ProposalistSpacing.md),
                  Text('Preparing your workspace...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
