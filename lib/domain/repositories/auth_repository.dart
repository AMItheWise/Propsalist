import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> watchCurrentUser();

  Future<Result<AppUser>> signInAnonymously();

  Future<Result<void>> signOut();

  Future<Result<AppUser>> ensureSignedIn();
}
