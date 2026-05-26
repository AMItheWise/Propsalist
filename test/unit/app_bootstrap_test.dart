import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/app_bootstrap.dart';
import 'package:proposal_writer/core/env.dart';

void main() {
  test(
    'environment loading returns empty values when loading times out',
    () async {
      final values = await loadEnvironmentValues(
        load: () => Completer<void>().future,
        read: () => {'OPENAI_MODEL': 'gpt-test'},
        timeout: const Duration(milliseconds: 1),
      );

      expect(values, isEmpty);
    },
  );

  test('disables Firebase when initialization times out', () async {
    final config = _config(firebaseOptions: _firebaseOptions);
    final result = await initializeFirebaseForConfig(
      config,
      initialize: (_) => Completer<void>().future,
      timeout: const Duration(milliseconds: 1),
    );

    expect(result.isFirebaseConfigured, isFalse);
    expect(result.apiKey, config.apiKey);
    expect(result.model, config.model);
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
