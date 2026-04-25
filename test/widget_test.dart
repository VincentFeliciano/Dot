import 'package:flutter_test/flutter_test.dart';
import 'package:dotty/main.dart';

void main() {
  testWidgets('Dotty smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DottyApp());
    expect(find.byType(DottyApp), findsOneWidget);
  });
}
