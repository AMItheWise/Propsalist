import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';
import 'package:proposal_writer/presentation/widgets/firebase_startup_gate.dart';

void main() {
  testWidgets('shows a first frame before initializing Firebase', (
    tester,
  ) async {
    var initializeCalled = false;
    final config = _config(firebaseOptions: _firebaseOptions);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [envConfigStateProvider.overrideWith((ref) => config)],
        child: MaterialApp(
          theme: buildProposalistTheme(),
          home: FirebaseStartupGate(
            initialize: (config) async {
              initializeCalled = true;
              return config.withoutFirebase();
            },
            child: const Text('Ready', key: Key('readyChild')),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('firebaseStartupLoading')), findsOneWidget);
    expect(initializeCalled, isFalse);

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 599));

    expect(initializeCalled, isFalse);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();

    expect(initializeCalled, isTrue);
    expect(find.byKey(const Key('readyChild')), findsOneWidget);
  });
}

EnvConfig _config({FirebaseOptions? firebaseOptions}) {
  return EnvConfig(
    apiKey: 'openai-key',
    model: 'gpt-test',
    baseUrl: Uri.parse('https://api.openai.com'),
    mockApi: false,
    firebaseOptions: firebaseOptions,
  );
}

const _firebaseOptions = FirebaseOptions(
  apiKey: 'firebase-key',
  appId: 'firebase-app',
  messagingSenderId: 'sender',
  projectId: 'project',
);
