import 'package:explore_world/widgets/optimized_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OptimizedNetworkImage handles infinite width without crash', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 220,
            height: 140,
            child: OptimizedNetworkImage(
              imageUrl: 'https://example.com/image.jpg',
              width: double.infinity,
              height: 110,
            ),
          ),
        ),
      ),
    );

    await tester.pump();

    expect(find.byType(OptimizedNetworkImage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
