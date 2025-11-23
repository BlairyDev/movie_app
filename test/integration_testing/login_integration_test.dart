// test/integration_testing/login_integration_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:movie_app/view/login_screen.dart';

void main() async {
  // Load dotenv
  await dotenv.load(fileName: ".env");

  testWidgets('User can login successfully', (WidgetTester tester) async {
    // Build the app
    await tester.pumpWidget(
      MaterialApp(
        home: LoginScreen(),
      ),
    );

    await tester.pumpAndSettle(); // wait for all futures/animations

    // Find fields by key
    final usernameField = find.byKey(const Key('usernameField'));
    final passwordField = find.byKey(const Key('passwordField'));
    final loginButton = find.byKey(const Key('loginButton'));

    // Enter credentials
    await tester.enterText(usernameField, 'testuser');
    await tester.enterText(passwordField, '1234');

    // Tap login button
    await tester.tap(loginButton);

    await tester.pumpAndSettle(); // wait for UI update

    // Expect success message
    expect(find.text('Login successful'), findsOneWidget);
  });
}
