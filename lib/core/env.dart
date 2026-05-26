import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:proposal_writer/core/constants.dart';

class EnvConfig {
  const EnvConfig({
    required this.apiKey,
    required this.model,
    required this.baseUrl,
    required this.mockApi,
    required this.firebaseOptions,
  });

  factory EnvConfig.fromEnvironment({Map<String, String> dotenv = const {}}) {
    const apiKeyDefine = String.fromEnvironment('OPENAI_API_KEY');
    const modelDefine = String.fromEnvironment('OPENAI_MODEL');
    const baseUrlDefine = String.fromEnvironment('OPENAI_BASE_URL');
    const mockDefine = bool.fromEnvironment('MOCK_API');

    final apiKey = apiKeyDefine.isNotEmpty
        ? apiKeyDefine
        : (dotenv['OPENAI_API_KEY'] ?? '');
    final model = modelDefine.isNotEmpty
        ? modelDefine
        : (dotenv['OPENAI_MODEL'] ?? defaultOpenAiModel);
    final baseUrlValue = baseUrlDefine.isNotEmpty
        ? baseUrlDefine
        : (dotenv['OPENAI_BASE_URL'] ?? defaultOpenAiBaseUrl);
    final mockApi = mockDefine || (dotenv['MOCK_API']?.toLowerCase() == 'true');

    return EnvConfig(
      apiKey: apiKey,
      model: model,
      baseUrl: Uri.parse(baseUrlValue),
      mockApi: mockApi,
      firebaseOptions: _firebaseOptionsFromEnvironment(dotenv),
    );
  }

  final String apiKey;
  final String model;
  final Uri baseUrl;
  final bool mockApi;
  final FirebaseOptions? firebaseOptions;

  bool get isFirebaseConfigured => firebaseOptions != null;

  EnvConfig withoutFirebase() {
    return EnvConfig(
      apiKey: apiKey,
      model: model,
      baseUrl: baseUrl,
      mockApi: mockApi,
      firebaseOptions: null,
    );
  }
}

const _firebaseApiKeyDefine = String.fromEnvironment('FIREBASE_API_KEY');
const _firebaseProjectIdDefine = String.fromEnvironment('FIREBASE_PROJECT_ID');
const _firebaseMessagingSenderIdDefine = String.fromEnvironment(
  'FIREBASE_MESSAGING_SENDER_ID',
);
const _firebaseAppIdDefine = String.fromEnvironment('FIREBASE_APP_ID');
const _firebaseWebAppIdDefine = String.fromEnvironment('FIREBASE_WEB_APP_ID');
const _firebaseAndroidAppIdDefine = String.fromEnvironment(
  'FIREBASE_ANDROID_APP_ID',
);
const _firebaseIosAppIdDefine = String.fromEnvironment('FIREBASE_IOS_APP_ID');
const _firebaseMacosAppIdDefine = String.fromEnvironment(
  'FIREBASE_MACOS_APP_ID',
);
const _firebaseWindowsAppIdDefine = String.fromEnvironment(
  'FIREBASE_WINDOWS_APP_ID',
);
const _firebaseStorageBucketDefine = String.fromEnvironment(
  'FIREBASE_STORAGE_BUCKET',
);
const _firebaseAuthDomainDefine = String.fromEnvironment(
  'FIREBASE_AUTH_DOMAIN',
);
const _firebaseMeasurementIdDefine = String.fromEnvironment(
  'FIREBASE_MEASUREMENT_ID',
);

FirebaseOptions? _firebaseOptionsFromEnvironment(Map<String, String> dotenv) {
  final apiKey = _firstNonEmpty([
    _firebaseApiKeyDefine,
    dotenv['FIREBASE_API_KEY'] ?? '',
  ]);
  final projectId = _firstNonEmpty([
    _firebaseProjectIdDefine,
    dotenv['FIREBASE_PROJECT_ID'] ?? '',
  ]);
  final messagingSenderId = _firstNonEmpty([
    _firebaseMessagingSenderIdDefine,
    dotenv['FIREBASE_MESSAGING_SENDER_ID'] ?? '',
  ]);
  final appId = _firstNonEmpty([
    if (kIsWeb) ...[
      _firebaseWebAppIdDefine,
      dotenv['FIREBASE_WEB_APP_ID'] ?? '',
    ] else
      ...switch (defaultTargetPlatform) {
        TargetPlatform.android => [
          _firebaseAndroidAppIdDefine,
          dotenv['FIREBASE_ANDROID_APP_ID'] ?? '',
        ],
        TargetPlatform.iOS => [
          _firebaseIosAppIdDefine,
          dotenv['FIREBASE_IOS_APP_ID'] ?? '',
        ],
        TargetPlatform.macOS => [
          _firebaseMacosAppIdDefine,
          dotenv['FIREBASE_MACOS_APP_ID'] ?? '',
        ],
        TargetPlatform.windows => [
          _firebaseWindowsAppIdDefine,
          dotenv['FIREBASE_WINDOWS_APP_ID'] ?? '',
        ],
        TargetPlatform.linux => const <String>[],
        TargetPlatform.fuchsia => const <String>[],
      },
    _firebaseAppIdDefine,
    dotenv['FIREBASE_APP_ID'] ?? '',
  ]);

  if (apiKey.isEmpty ||
      projectId.isEmpty ||
      messagingSenderId.isEmpty ||
      appId.isEmpty) {
    return null;
  }

  final storageBucket = _firstNonEmpty([
    _firebaseStorageBucketDefine,
    dotenv['FIREBASE_STORAGE_BUCKET'] ?? '',
  ]);
  final authDomain = _firstNonEmpty([
    _firebaseAuthDomainDefine,
    dotenv['FIREBASE_AUTH_DOMAIN'] ?? '',
  ]);
  final measurementId = _firstNonEmpty([
    _firebaseMeasurementIdDefine,
    dotenv['FIREBASE_MEASUREMENT_ID'] ?? '',
  ]);

  return FirebaseOptions(
    apiKey: apiKey,
    appId: appId,
    messagingSenderId: messagingSenderId,
    projectId: projectId,
    storageBucket: storageBucket.isEmpty ? null : storageBucket,
    authDomain: authDomain.isEmpty ? null : authDomain,
    measurementId: measurementId.isEmpty ? null : measurementId,
  );
}

String _firstNonEmpty(List<String> values) {
  for (final value in values) {
    if (value.trim().isNotEmpty) {
      return value.trim();
    }
  }
  return '';
}
