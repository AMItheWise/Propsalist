import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:proposal_writer/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Generate proposal in mock mode', (tester) async {
    await app.main();
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('bottomNavNewProposal')));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('promptField')),
      'Create a proposal',
    );
    await tester.pump();

    await tester.scrollUntilVisible(
      find.byKey(const Key('generateButton')),
      360,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('generateButton')));
    await tester.pump();
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.byKey(const Key('proposalOutput')), findsOneWidget);
    expect(find.textContaining('[MOCK]'), findsOneWidget);
  });
}
