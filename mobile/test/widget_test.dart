import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:autolink_mobile/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: AutoLinkApp()));

    // Verify that the login screen appears
    expect(find.text('AutoLink'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
