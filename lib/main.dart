import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/presentation/screens/home_screen.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load();
  } catch (_) {}

  final config = EnvConfig.fromEnvironment(dotenv: dotenv.env);
  if (config.isFirebaseConfigured) {
    try {
      await Firebase.initializeApp(options: config.firebaseOptions);
    } catch (error) {
      debugPrint('Firebase initialization failed: $error');
    }
  }

  runApp(
    ProviderScope(
      overrides: [envConfigProvider.overrideWithValue(config)],
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
      home: const HomeScreen(),
    );
  }
}
