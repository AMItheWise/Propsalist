import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/env.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/auth_repository_impl.dart';
import 'package:proposal_writer/data/openai_client.dart';
import 'package:proposal_writer/data/openai_mock_client.dart';
import 'package:proposal_writer/data/proposal_repository_impl.dart';
import 'package:proposal_writer/data/proposal_store_repository_impl.dart';
import 'package:proposal_writer/data/user_data_path_resolver.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/entities/app_user.dart';
import 'package:proposal_writer/domain/repositories/auth_repository.dart';
import 'package:proposal_writer/domain/repositories/proposal_repository.dart';
import 'package:proposal_writer/domain/repositories/proposal_store_repository.dart';
import 'package:proposal_writer/domain/repositories/user_profile_repository.dart';
import 'package:proposal_writer/domain/usecases/proposal_flow_usecase.dart';
import 'package:proposal_writer/domain/usecases/user_profile_usecase.dart';

final envConfigStateProvider = StateProvider<EnvConfig>((ref) {
  return EnvConfig.fromEnvironment(dotenv: _safeDotenvValues());
});

final envConfigProvider = Provider<EnvConfig>((ref) {
  return ref.watch(envConfigStateProvider);
});

final dioProvider = Provider<Dio>((ref) {
  final config = ref.watch(envConfigProvider);
  return Dio(
    BaseOptions(
      baseUrl: config.baseUrl.toString(),
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(minutes: 5),
      sendTimeout: const Duration(seconds: 30),
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

final userDataPathResolverProvider = Provider<UserDataPathResolver>((ref) {
  return const UserDataPathResolver();
});

final proposalStoreRepositoryProvider = Provider<ProposalStoreRepository>((
  ref,
) {
  final config = ref.watch(envConfigProvider);
  if (!config.isFirebaseConfigured) {
    return config.mockApi
        ? InMemoryProposalStoreRepository(seedRecords: mockProposalStoreRecords)
        : const DisabledProposalStoreRepository();
  }

  return FirestoreProposalStoreRepository(
    firestore: FirebaseFirestore.instance,
    authRepository: ref.watch(authRepositoryProvider),
    pathResolver: ref.watch(userDataPathResolverProvider),
  );
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final config = ref.watch(envConfigProvider);
  if (!config.isFirebaseConfigured) {
    return const LocalAuthRepository();
  }

  final firestore = FirebaseFirestore.instance;
  final pathResolver = ref.watch(userDataPathResolverProvider);
  return FirebaseAuthRepository(
    authGateway: FirebaseAuthGateway(auth: FirebaseAuth.instance),
    userDataInitializer: FirebaseUserDataInitializer(
      firestore: firestore,
      pathResolver: pathResolver,
    ),
  );
});

final authBootstrapProvider = FutureProvider<Result<AppUser>>((ref) {
  return ref.watch(authRepositoryProvider).ensureSignedIn();
});

final userProfileRepositoryProvider = Provider<UserProfileRepository>((ref) {
  final config = ref.watch(envConfigProvider);
  if (!config.isFirebaseConfigured) {
    return const DisabledUserProfileRepository();
  }

  final firestore = FirebaseFirestore.instance;
  final pathResolver = ref.watch(userDataPathResolverProvider);
  return FirestoreUserProfileRepository(
    firestore: firestore,
    authRepository: ref.watch(authRepositoryProvider),
    pathResolver: pathResolver,
  );
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
