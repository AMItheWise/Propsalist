import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/user_profile.dart';

abstract class UserProfileRepository {
  Future<Result<UserProfile?>> loadProfile();

  Future<Result<void>> saveProfile(UserProfile profile);
}
