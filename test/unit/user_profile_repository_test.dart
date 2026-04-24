import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/data/user_profile_repository_impl.dart';
import 'package:proposal_writer/domain/entities/user_profile.dart';

void main() {
  test('FirestoreUserProfileRepository saves and loads a profile', () async {
    final firestore = FakeFirebaseFirestore();
    final repository = FirestoreUserProfileRepository(firestore: firestore);
    const profile = UserProfile(
      fullName: 'Jane Doe',
      email: 'jane@example.com',
      professionalTitle: 'Designer',
      about: 'Product designer with proposal writing experience.',
      cvText: 'Led discovery, design, and delivery.',
      profileImageUrl: 'https://example.com/jane.png',
      portfolioLinks: ['https://portfolio.example.com'],
      education: ['BSc Design'],
    );

    final saveResult = await repository.saveProfile(profile);
    final loadResult = await repository.loadProfile();

    expect(saveResult, isA<Success<void>>());
    expect(loadResult, isA<Success<UserProfile?>>());
    loadResult.when(
      success: (loadedProfile) {
        expect(loadedProfile, isNotNull);
        expect(loadedProfile?.fullName, profile.fullName);
        expect(loadedProfile?.portfolioLinks, profile.portfolioLinks);
        expect(loadedProfile?.education, profile.education);
      },
      failure: (_) => fail('Expected profile load to succeed'),
    );
  });
}
