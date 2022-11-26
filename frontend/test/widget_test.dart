import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/widgets/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(App());

    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);
  });
}
