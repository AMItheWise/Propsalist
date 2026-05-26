import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'package:proposal_writer/core/env.dart';

typedef FirebaseInitializer = Future<void> Function(FirebaseOptions options);
typedef EnvironmentLoader = Future<void> Function();
typedef EnvironmentReader = Map<String, String> Function();

Future<Map<String, String>> loadEnvironmentValues({
  required EnvironmentLoader load,
  required EnvironmentReader read,
  Duration timeout = const Duration(seconds: 4),
}) async {
  try {
    await load().timeout(timeout);
    return read();
  } on TimeoutException catch (error) {
    debugPrint('Environment loading timed out: $error');
    return const {};
  } catch (error) {
    debugPrint('Environment loading failed: $error');
    return const {};
  }
}

Future<EnvConfig> initializeFirebaseForConfig(
  EnvConfig config, {
  FirebaseInitializer initialize = _initializeFirebase,
  Duration timeout = const Duration(seconds: 8),
}) async {
  final options = config.firebaseOptions;
  if (options == null) {
    return config;
  }

  try {
    await initialize(options).timeout(timeout);
    return config;
  } on FirebaseException catch (error) {
    if (error.code == 'duplicate-app') {
      return config;
    }
    debugPrint('Firebase initialization failed: $error');
    return config.withoutFirebase();
  } on TimeoutException catch (error) {
    debugPrint('Firebase initialization timed out: $error');
    return config.withoutFirebase();
  } catch (error) {
    debugPrint('Firebase initialization failed: $error');
    return config.withoutFirebase();
  }
}

Future<void> _initializeFirebase(FirebaseOptions options) async {
  await Firebase.initializeApp(options: options);
}
