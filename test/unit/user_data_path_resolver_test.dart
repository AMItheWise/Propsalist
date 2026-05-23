import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/data/user_data_path_resolver.dart';

void main() {
  test('resolves user-owned Firestore paths for a user id', () {
    const resolver = UserDataPathResolver();

    expect(resolver.userPath('user-123'), 'users/user-123');
    expect(resolver.profilePath('user-123'), 'users/user-123/profiles/primary');
    expect(
      resolver.proposalPath('user-123', 'proposal-456'),
      'users/user-123/proposals/proposal-456',
    );
    expect(resolver.settingsPath('user-123'), 'users/user-123/settings/app');
  });
}
