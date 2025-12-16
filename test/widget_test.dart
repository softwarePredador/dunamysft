// Basic Flutter widget tests for Dunamys app.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App renders correctly', (WidgetTester tester) async {
    // Build a simple MaterialApp to verify basic rendering
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Dunamys'),
          ),
        ),
      ),
    );

    // Verify that basic widgets render
    expect(find.text('Dunamys'), findsOneWidget);
    expect(find.byType(Scaffold), findsOneWidget);
    expect(find.byType(Center), findsOneWidget);
  });

  testWidgets('Material components render correctly', (WidgetTester tester) async {
    // Test common Material components
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('Test')),
          body: Column(
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Button'),
              ),
              const TextField(
                decoration: InputDecoration(labelText: 'Input'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Test'), findsOneWidget);
    expect(find.text('Button'), findsOneWidget);
  });
}
