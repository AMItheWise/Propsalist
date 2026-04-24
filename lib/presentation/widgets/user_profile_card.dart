import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/domain/entities/user_profile.dart';

class UserProfileCard extends ConsumerStatefulWidget {
  const UserProfileCard({super.key});

  @override
  ConsumerState<UserProfileCard> createState() => _UserProfileCardState();
}

class _UserProfileCardState extends ConsumerState<UserProfileCard> {
  late final TextEditingController _fullNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _titleController;
  late final TextEditingController _aboutController;
  late final TextEditingController _cvController;
  late final TextEditingController _portfolioController;
  late final TextEditingController _educationController;
  late final TextEditingController _profileImageController;

  var _isLoading = true;
  var _isSaving = false;
  String? _message;
  bool _messageIsError = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _titleController = TextEditingController();
    _aboutController = TextEditingController();
    _cvController = TextEditingController();
    _portfolioController = TextEditingController();
    _educationController = TextEditingController();
    _profileImageController = TextEditingController();
    Future<void>.microtask(_loadProfile);
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _titleController.dispose();
    _aboutController.dispose();
    _cvController.dispose();
    _portfolioController.dispose();
    _educationController.dispose();
    _profileImageController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    setState(() {
      _isLoading = true;
      _message = null;
      _messageIsError = false;
    });

    final result = await ref.read(userProfileUseCaseProvider).loadProfile();
    if (!mounted) {
      return;
    }

    result.when(
      success: (profile) {
        _hydrateForm(profile ?? UserProfile.empty());
        setState(() {
          _isLoading = false;
        });
      },
      failure: (failure) {
        _hydrateForm(UserProfile.empty());
        setState(() {
          _isLoading = false;
          _message = failure.message;
          _messageIsError = true;
        });
      },
    );
  }

  void _hydrateForm(UserProfile profile) {
    _fullNameController.text = profile.fullName;
    _emailController.text = profile.email;
    _titleController.text = profile.professionalTitle;
    _aboutController.text = profile.about;
    _cvController.text = profile.cvText;
    _portfolioController.text = profile.portfolioLinks.join('\n');
    _educationController.text = profile.education.join('\n');
    _profileImageController.text = profile.profileImageUrl;
  }

  UserProfile _buildProfile() {
    List<String> linesFrom(TextEditingController controller) {
      return controller.text
          .split('\n')
          .map((value) => value.trim())
          .where((value) => value.isNotEmpty)
          .toList();
    }

    return UserProfile(
      fullName: _fullNameController.text.trim(),
      email: _emailController.text.trim(),
      professionalTitle: _titleController.text.trim(),
      about: _aboutController.text.trim(),
      cvText: _cvController.text.trim(),
      profileImageUrl: _profileImageController.text.trim(),
      portfolioLinks: linesFrom(_portfolioController),
      education: linesFrom(_educationController),
    );
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isSaving = true;
      _message = null;
      _messageIsError = false;
    });

    final result = await ref
        .read(userProfileUseCaseProvider)
        .saveProfile(_buildProfile());

    if (!mounted) {
      return;
    }

    result.when(
      success: (_) {
        setState(() {
          _isSaving = false;
          _message = 'Profile saved to Firestore.';
          _messageIsError = false;
        });
      },
      failure: (failure) {
        setState(() {
          _isSaving = false;
          _message = failure.message;
          _messageIsError = true;
        });
      },
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isFirestoreConfigured = ref
        .watch(envConfigProvider)
        .isFirebaseConfigured;
    final messageColor = _messageIsError
        ? Theme.of(context).colorScheme.error
        : Theme.of(context).colorScheme.primary;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'User Profile',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Save your CV, bio, portfolio links, education, and profile picture URL in Firestore. Saved profile details are added to proposal generation.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (!isFirestoreConfigured) ...[
              const SizedBox(height: 12),
              Text(
                'Firestore is not configured yet. Add the FIREBASE_* values from README before saving.',
                key: const Key('firestoreConfigHint'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ],
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              _buildField(
                label: 'Full name',
                controller: _fullNameController,
                hintText: 'Jane Doe',
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Email',
                controller: _emailController,
                hintText: 'jane@example.com',
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Professional title',
                controller: _titleController,
                hintText: 'Product Designer',
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Short bio / info',
                controller: _aboutController,
                maxLines: 3,
                hintText: 'A short professional summary.',
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'CV / resume',
                controller: _cvController,
                maxLines: 6,
                hintText: 'Paste the important CV content here.',
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Portfolio links',
                controller: _portfolioController,
                maxLines: 4,
                hintText: 'One link per line',
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Education',
                controller: _educationController,
                maxLines: 4,
                hintText: 'One entry per line',
              ),
              const SizedBox(height: 12),
              _buildField(
                label: 'Profile picture URL',
                controller: _profileImageController,
                hintText: 'https://...',
                keyboardType: TextInputType.url,
              ),
              const SizedBox(height: 12),
              if (_message != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    _message!,
                    key: const Key('profileMessage'),
                    style: TextStyle(color: messageColor),
                  ),
                ),
              Row(
                children: [
                  OutlinedButton(
                    onPressed: _isSaving ? null : _loadProfile,
                    child: const Text('Reload'),
                  ),
                  const SizedBox(width: 12),
                  FilledButton(
                    key: const Key('saveProfileButton'),
                    onPressed: _isSaving || !isFirestoreConfigured
                        ? null
                        : _saveProfile,
                    child: Text(_isSaving ? 'Saving...' : 'Save profile'),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
