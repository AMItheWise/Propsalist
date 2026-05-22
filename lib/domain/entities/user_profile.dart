import 'package:proposal_writer/core/constants.dart';

class UserProfile {
  const UserProfile({
    required this.fullName,
    required this.email,
    required this.professionalTitle,
    required this.about,
    required this.cvText,
    required this.profileImageUrl,
    required this.portfolioLinks,
    required this.education,
    this.id = defaultUserProfileDocumentId,
  });

  factory UserProfile.empty() => const UserProfile(
    fullName: '',
    email: '',
    professionalTitle: '',
    about: '',
    cvText: '',
    profileImageUrl: '',
    portfolioLinks: [],
    education: [],
  );

  factory UserProfile.fromMap(String id, Map<String, dynamic> data) {
    return UserProfile(
      id: id,
      fullName: (data['fullName'] as String? ?? '').trim(),
      email: (data['email'] as String? ?? '').trim(),
      professionalTitle: (data['professionalTitle'] as String? ?? '').trim(),
      about: (data['about'] as String? ?? '').trim(),
      cvText: (data['cvText'] as String? ?? '').trim(),
      profileImageUrl: (data['profileImageUrl'] as String? ?? '').trim(),
      portfolioLinks: _parseStringList(data['portfolioLinks']),
      education: _parseStringList(data['education']),
    );
  }

  final String id;
  final String fullName;
  final String email;
  final String professionalTitle;
  final String about;
  final String cvText;
  final String profileImageUrl;
  final List<String> portfolioLinks;
  final List<String> education;

  bool get isEmpty =>
      fullName.isEmpty &&
      email.isEmpty &&
      professionalTitle.isEmpty &&
      about.isEmpty &&
      cvText.isEmpty &&
      profileImageUrl.isEmpty &&
      portfolioLinks.isEmpty &&
      education.isEmpty;

  UserProfile copyWith({
    String? id,
    String? fullName,
    String? email,
    String? professionalTitle,
    String? about,
    String? cvText,
    String? profileImageUrl,
    List<String>? portfolioLinks,
    List<String>? education,
  }) {
    return UserProfile(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      professionalTitle: professionalTitle ?? this.professionalTitle,
      about: about ?? this.about,
      cvText: cvText ?? this.cvText,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      portfolioLinks: portfolioLinks ?? this.portfolioLinks,
      education: education ?? this.education,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'fullName': fullName.trim(),
      'email': email.trim(),
      'professionalTitle': professionalTitle.trim(),
      'about': about.trim(),
      'cvText': cvText.trim(),
      'profileImageUrl': profileImageUrl.trim(),
      'portfolioLinks': portfolioLinks
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
      'education': education
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList(),
    };
  }

  String toPromptContext() {
    final buffer = StringBuffer();

    void writeField(String label, String value, {int? maxLength}) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) {
        return;
      }
      final boundedValue = maxLength == null || trimmed.length <= maxLength
          ? trimmed
          : '${trimmed.substring(0, maxLength)}...';
      buffer.writeln('$label: $boundedValue');
    }

    writeField('Full name', fullName);
    writeField('Email', email);
    writeField('Professional title', professionalTitle);
    writeField('Profile summary', about, maxLength: 1200);
    writeField('CV / resume', cvText, maxLength: 3000);
    writeField('Profile image URL', profileImageUrl);

    if (portfolioLinks.isNotEmpty) {
      buffer.writeln('Portfolio links: ${portfolioLinks.join(', ')}');
    }
    if (education.isNotEmpty) {
      buffer.writeln('Education: ${education.join(' | ')}');
    }

    return buffer.toString().trim();
  }

  static List<String> _parseStringList(dynamic rawValue) {
    if (rawValue is! List<dynamic>) {
      return const [];
    }
    return rawValue
        .whereType<String>()
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList();
  }
}
