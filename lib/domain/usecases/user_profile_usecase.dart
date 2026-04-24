import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/user_profile.dart';
import 'package:proposal_writer/domain/repositories/user_profile_repository.dart';

class UserProfileUseCase {
  const UserProfileUseCase({required UserProfileRepository repository})
    : _repository = repository;

  final UserProfileRepository _repository;

  Future<Result<UserProfile?>> loadProfile() {
    return _repository.loadProfile();
  }

  Future<Result<void>> saveProfile(UserProfile profile) {
    return _repository.saveProfile(profile);
  }
}
