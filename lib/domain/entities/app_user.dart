class AppUser {
  const AppUser({
    required this.id,
    required this.isAnonymous,
    this.displayName,
    this.email,
  });

  final String id;
  final bool isAnonymous;
  final String? displayName;
  final String? email;
}
