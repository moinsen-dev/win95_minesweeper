import 'package:flutter_test/flutter_test.dart';

import 'package:minesweeper/main.dart';

void main() {
  testWidgets('Minesweeper app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MinesweeperApp());

    // Verify that the app title is shown.
    expect(find.text('Minesweeper'), findsOneWidget);
  });
}
