import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proposal_writer/core/di/providers.dart';
import 'package:proposal_writer/core/failures.dart';
import 'package:proposal_writer/core/result.dart';
import 'package:proposal_writer/domain/entities/app_user.dart';
import 'package:proposal_writer/domain/repositories/auth_repository.dart';
import 'package:proposal_writer/presentation/theme/proposalist_theme.dart';
import 'package:proposal_writer/presentation/widgets/auth_bootstrap_gate.dart';

class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository(this._result);

  final Future<Result<AppUser>> _result;

  @override
  Future<Result<AppUser>> ensureSignedIn() => _result;

  @override
  Future<Result<AppUser>> signInAnonymously() => _result;

  @override
  Future<Result<void>> signOut() async => const Success(null);

  @override
  Stream<AppUser?> watchCurrentUser() => const Stream.empty();
}

Widget buildTestApp(AuthRepository authRepository) {
  return ProviderScope(
    overrides: [authRepositoryProvider.overrideWithValue(authRepository)],
    child: MaterialApp(
      theme: buildProposalistTheme(),
      home: const AuthBootstrapGate(
        child: Text('Signed-in shell', key: Key('signedInShell')),
      ),
    ),
  );
}

void main() {
  testWidgets('shows loading while anonymous sign-in is pending', (
    tester,
  ) async {
    final completer = Completer<Result<AppUser>>();

    await tester.pumpWidget(buildTestApp(FakeAuthRepository(completer.future)));
    await tester.pump();

    expect(find.byKey(const Key('authBootstrapLoading')), findsOneWidget);
    expect(find.byKey(const Key('signedInShell')), findsNothing);
  });

  testWidgets('shows an auth error when anonymous sign-in fails', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        FakeAuthRepository(
          Future.value(
            const FailureResult(AuthenticationFailure('Auth is unavailable')),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('authBootstrapError')), findsOneWidget);
    expect(find.text('Unable to start your session'), findsOneWidget);
    expect(find.textContaining('Auth is unavailable'), findsOneWidget);
  });

  testWidgets('renders the shell after anonymous sign-in succeeds', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildTestApp(
        FakeAuthRepository(
          Future.value(
            const Success(AppUser(id: 'user-123', isAnonymous: true)),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('signedInShell')), findsOneWidget);
  });
}
