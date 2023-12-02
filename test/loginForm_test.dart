import 'package:finance_ap_asg/Widgets/loginForm.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';


void main() {
  testWidgets('LoginForm widget test', (WidgetTester tester) async {
    // Create TextEditingController instances
    final TextEditingController usernameController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    // Build our app and trigger a frame
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LoginForm(
            usernameController: usernameController,
            passwordController: passwordController,
          ),
        ),
      ),
    );

    // Verify that TextFormField widgets are rendered
    expect(find.byType(TextFormField), findsNWidgets(2));

    // Enter text into the username TextFormField
    await tester.enterText(find.widgetWithText(TextFormField, 'Username'), 'testuser');

    // Enter text into the password TextFormField
    await tester.enterText(find.widgetWithText(TextFormField, 'Password'), 'testpassword');

    // Verify that the entered text is correct
    expect(usernameController.text, 'testuser');
    expect(passwordController.text, 'testpassword');
  });
}
