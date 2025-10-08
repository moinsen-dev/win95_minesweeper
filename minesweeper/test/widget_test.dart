import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minesweeper/main.dart';

void main() {
  setUp(() async {
    // Set up mock shared preferences
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Minesweeper app smoke test', (WidgetTester tester) async {
    // Allow timers to run during test (game timer is expected)
    await tester.runAsync(() async {
      // Build our app and trigger a frame.
      await tester.pumpWidget(const MinesweeperApp());

      // Wait for initialization
      await tester.pump(const Duration(milliseconds: 200));

      // Verify that the app title is shown.
      expect(find.text('Minesweeper'), findsOneWidget);
    });
  });
}
