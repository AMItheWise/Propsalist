import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/domain/entities/user_profile.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';
import 'package:proposal_writer/presentation/widgets/proposalist_components.dart';

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
          _message = 'Profile saved to your user-owned Firestore path.';
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

  @override
  Widget build(BuildContext context) {
    final isFirestoreConfigured = ref
        .watch(envConfigProvider)
        .isFirebaseConfigured;
    final profile = _buildProfile();
    final messageColor = _messageIsError
        ? Theme.of(context).colorScheme.error
        : ProposalistColors.success;

    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      key: const Key('profileTab'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ProfileOverview(profile: profile),
        const SizedBox(height: ProposalistSpacing.md),
        _BasicInfoSection(
          fullNameController: _fullNameController,
          emailController: _emailController,
          titleController: _titleController,
          aboutController: _aboutController,
          profileImageController: _profileImageController,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: ProposalistSpacing.md),
        _CvSection(controller: _cvController, onChanged: () => setState(() {})),
        const SizedBox(height: ProposalistSpacing.md),
        _ListTextSection(
          title: 'Portfolio Links',
          helper: 'One link per line. These appear in proposal context.',
          controller: _portfolioController,
          icon: Icons.link,
          maxLines: 4,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: ProposalistSpacing.md),
        _ListTextSection(
          title: 'Education',
          helper: 'One education entry per line.',
          controller: _educationController,
          icon: Icons.school_outlined,
          maxLines: 4,
          onChanged: () => setState(() {}),
        ),
        const SizedBox(height: ProposalistSpacing.md),
        _ContextPreview(profile: profile),
        const SizedBox(height: ProposalistSpacing.md),
        if (!isFirestoreConfigured)
          Text(
            'Firestore is not configured yet. Add the FIREBASE_* values from '
            'README to enable user-owned profile persistence.',
            key: const Key('firestoreConfigHint'),
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        if (_message != null) ...[
          const SizedBox(height: ProposalistSpacing.sm),
          Text(
            _message!,
            key: const Key('profileMessage'),
            style: TextStyle(color: messageColor),
          ),
        ],
        const SizedBox(height: ProposalistSpacing.md),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _isSaving ? null : _loadProfile,
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reload'),
              ),
            ),
            const SizedBox(width: ProposalistSpacing.sm),
            Expanded(
              child: FilledButton.icon(
                key: const Key('saveProfileButton'),
                onPressed: _isSaving || !isFirestoreConfigured
                    ? null
                    : _saveProfile,
                icon: Icon(_isSaving ? Icons.sync : Icons.check, size: 18),
                label: Text(_isSaving ? 'Saving' : 'Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileOverview extends StatelessWidget {
  const _ProfileOverview({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final displayName = profile.fullName.isEmpty
        ? 'Rahul Sharma'
        : profile.fullName;
    final title = profile.professionalTitle.isEmpty
        ? 'Senior Flutter Developer'
        : profile.professionalTitle;
    final email = profile.email.isEmpty
        ? 'rahul.sharma@example.com'
        : profile.email;
    final initial = displayName.trim().isEmpty
        ? 'P'
        : displayName.trim().substring(0, 1).toUpperCase();

    return ProposalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Profile Overview'),
          const SizedBox(height: ProposalistSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 36,
                backgroundColor: ProposalistColors.surfaceAlt,
                child: Text(
                  initial,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: ProposalistColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: ProposalistSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(email, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: ProposalistSpacing.xs),
                    Text(title, style: Theme.of(context).textTheme.bodyMedium),
                    Text(
                      'Cross-Platform - Firebase - AI Integrations',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: ProposalistSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profile Completeness',
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
              const SizedBox(width: ProposalistSpacing.xs),
              Text('92%', style: Theme.of(context).textTheme.labelLarge),
            ],
          ),
          const SizedBox(height: ProposalistSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: const LinearProgressIndicator(
              value: 0.92,
              minHeight: 6,
              color: ProposalistColors.primary,
              backgroundColor: ProposalistColors.surfaceAlt,
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicInfoSection extends StatelessWidget {
  const _BasicInfoSection({
    required this.fullNameController,
    required this.emailController,
    required this.titleController,
    required this.aboutController,
    required this.profileImageController,
    required this.onChanged,
  });

  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController titleController;
  final TextEditingController aboutController;
  final TextEditingController profileImageController;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ProposalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(title: 'Basic Information'),
          const SizedBox(height: ProposalistSpacing.md),
          _ProfileField(
            label: 'Full Name',
            controller: fullNameController,
            hintText: 'Rahul Sharma',
            onChanged: onChanged,
          ),
          const SizedBox(height: ProposalistSpacing.sm),
          _ProfileField(
            label: 'Email',
            controller: emailController,
            hintText: 'rahul.sharma@example.com',
            keyboardType: TextInputType.emailAddress,
            onChanged: onChanged,
          ),
          const SizedBox(height: ProposalistSpacing.sm),
          _ProfileField(
            label: 'Professional Title',
            controller: titleController,
            hintText: 'Senior Flutter Developer',
            onChanged: onChanged,
          ),
          const SizedBox(height: ProposalistSpacing.sm),
          _ProfileField(
            label: 'About',
            controller: aboutController,
            hintText: 'A concise professional summary.',
            maxLines: 5,
            onChanged: onChanged,
          ),
          const SizedBox(height: ProposalistSpacing.sm),
          _ProfileField(
            label: 'Profile Image URL',
            controller: profileImageController,
            hintText: 'https://...',
            keyboardType: TextInputType.url,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _CvSection extends StatelessWidget {
  const _CvSection({required this.controller, required this.onChanged});

  final TextEditingController controller;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final words = controller.text
        .split(RegExp(r'\s+'))
        .where((value) => value.trim().isNotEmpty)
        .length;
    return ProposalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            title: 'CV / Resume',
            action: Text(
              'Words: $words',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          const SizedBox(height: ProposalistSpacing.md),
          TextField(
            controller: controller,
            maxLines: 9,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(
              hintText: 'Paste your markdown-friendly resume context here.',
            ),
          ),
        ],
      ),
    );
  }
}

class _ListTextSection extends StatelessWidget {
  const _ListTextSection({
    required this.title,
    required this.helper,
    required this.controller,
    required this.icon,
    required this.maxLines,
    required this.onChanged,
  });

  final String title;
  final String helper;
  final TextEditingController controller;
  final IconData icon;
  final int maxLines;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return ProposalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(
            title: title,
            action: Icon(icon, color: ProposalistColors.primary, size: 20),
          ),
          const SizedBox(height: ProposalistSpacing.xs),
          Text(helper, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: ProposalistSpacing.md),
          TextField(
            controller: controller,
            maxLines: maxLines,
            onChanged: (_) => onChanged(),
            decoration: const InputDecoration(hintText: 'One item per line'),
          ),
        ],
      ),
    );
  }
}

class _ContextPreview extends StatelessWidget {
  const _ContextPreview({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final contextText = profile.toPromptContext().isEmpty
        ? '{\n  "profile": "Add profile details to preview context."\n}'
        : profile.toPromptContext();
    return ProposalistCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SectionTitle(title: 'Prompt Context Preview'),
          const SizedBox(height: ProposalistSpacing.xs),
          Text(
            'This context is injected into proposal generation.',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: ProposalistSpacing.md),
          Container(
            padding: const EdgeInsets.all(ProposalistSpacing.md),
            decoration: BoxDecoration(
              color: ProposalistColors.background,
              borderRadius: BorderRadius.circular(ProposalistRadius.md),
              border: Border.all(color: ProposalistColors.border),
            ),
            child: SelectableText(
              contextText,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: ProposalistColors.primaryDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileField extends StatelessWidget {
  const _ProfileField({
    required this.label,
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.maxLines = 1,
    this.keyboardType,
  });

  final String label;
  final TextEditingController controller;
  final VoidCallback onChanged;
  final String? hintText;
  final int maxLines;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: (_) => onChanged(),
      decoration: InputDecoration(labelText: label, hintText: hintText),
    );
  }
}
