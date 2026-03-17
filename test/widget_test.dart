import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myapp/main.dart';
 
void main() {
  testWidgets('BarberBook smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const BarberBookApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
 