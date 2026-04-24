import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/data/openai_client.dart';
import 'package:proposal_writer/data/openai_mock_client.dart';
import 'package:proposal_writer/data/proposal_repository_impl.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/domain/repositories/user_profile_repository.dart';
import 'package:proposal_writer/domain/usecases/proposal_flow_usecase.dart';
import 'package:proposal_writer/domain/usecases/user_profile_usecase.dart';

final envConfigProvider = Provider<EnvConfig>((ref) {
  return EnvConfig.fromEnvironment(dotenv: _safeDotenvValues());
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(envConfigProvider);
  return Dio(
    BaseOptions(
      baseUrl: config.baseUrl.toString(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 120),
    ),
  );
});

final openAiClientProvider = Provider<OpenAIClient>((ref) {
  final config = ref.watch(envConfigProvider);
  if (config.mockApi) {
    return MockOpenAIClient(config: config);
  }

  final dio = ref.watch(dioProvider);
  return DioOpenAIClient(dio: dio, config: config);
});

final proposalRepositoryProvider = Provider<ProposalRepository>((ref) {
  return ProposalRepositoryImpl(
    client: ref.watch(openAiClientProvider),
    config: ref.watch(envConfigProvider),
  );
});

final proposalFlowUseCaseProvider = Provider<ProposalFlowUseCase>((ref) {
  return ProposalFlowUseCase(repository: ref.watch(proposalRepositoryProvider));
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final config = ref.watch(envConfigProvider);
  if (!config.isFirebaseConfigured) {
    return const DisabledUserProfileRepository();
  }

  return FirestoreUserProfileRepository(firestore: FirebaseFirestore.instance);
});

final userProfileUseCaseProvider = Provider<UserProfileUseCase>((ref) {
  return UserProfileUseCase(
    repository: ref.watch(userProfileRepositoryProvider),
  );
});

Map<String, String> _safeDotenvValues() {
  try {
    return dotenv.env;
  } catch (_) {
    return const {};
  }
}
