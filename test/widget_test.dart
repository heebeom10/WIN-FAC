import 'package:flutter_test/flutter_test.dart';

import 'package:hello_world/main.dart';

void main() {
  testWidgets('displays Hello, World!', (WidgetTester tester) async {
    await tester.pumpWidget(const HelloWorldApp());

    expect(find.text('Hello, World!'), findsOneWidget);
  });
}
