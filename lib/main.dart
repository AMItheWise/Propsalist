import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/app_bootstrap.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/presentation/screens/home_screen.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';
import 'package:proposal_writer/presentation/widgets/auth_bootstrap_gate.dart';
import 'package:proposal_writer/presentation/widgets/firebase_startup_gate.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final environment = await loadEnvironmentValues(
    load: dotenv.load,
    read: () => dotenv.env,
  );
  final config = EnvConfig.fromEnvironment(dotenv: environment);

  runApp(
    ProviderScope(
      overrides: [envConfigStateProvider.overrideWith((ref) => config)],
      child: const ProposalWriterApp(),
    ),
  );
}

class ProposalWriterApp extends StatelessWidget {
  const ProposalWriterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proposal Writer',
      theme: buildProposalistTheme(),
      home: const FirebaseStartupGate(
        child: AuthBootstrapGate(child: HomeScreen()),
      ),
    );
  }
}
