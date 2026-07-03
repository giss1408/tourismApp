import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:explore_world/widgets/search_widget.dart';

void main() {
  testWidgets('SearchWidget renders with hint text', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SearchWidget(hintText: 'Search destinations...'),
        ),
      ),
    );

    expect(find.byType(SearchWidget), findsOneWidget);
    expect(find.text('Search destinations...'), findsOneWidget);
  });
}
