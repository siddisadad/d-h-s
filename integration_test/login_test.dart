import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:deshmukh_steel_e_r_p/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Test', () {
    testWidgets('Login with correct credentials redirects to dashboard', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check if we are on login screen
      expect(find.text('Secure Login'), findsOneWidget);

      // Enter credentials
      await tester.enterText(find.byType(TextField).first, 'admin@dhs.com');
      await tester.enterText(find.byType(TextField).last, 'password');
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.text('Login to ERP'));
      
      // Wait for login process and redirection
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify dashboard
      expect(find.text('DHS ERP DASHBOARD'), findsOneWidget);
    });

    testWidgets('Login with incorrect credentials shows error', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Check if we are on login screen
      expect(find.text('Secure Login'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'wrong@dhs.com');
      await tester.enterText(find.byType(TextField).last, 'wrong');
      await tester.pumpAndSettle();

      await tester.tap(find.text('Login to ERP'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    group('Reset Password Test', () {
      testWidgets('Reset password dialog shows and sends email', (tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Tap forgot password
        await tester.tap(find.text('Forgot Password?'));
        await tester.pumpAndSettle();

        // Verify dialog
        expect(find.text('Reset Password'), findsOneWidget);
        expect(find.text('Enter your email address to receive a password reset link.'), findsOneWidget);

        // Enter email
        await tester.enterText(find.byType(TextField).last, 'admin@dhs.com');
        await tester.pumpAndSettle();

        // Tap send link
        await tester.tap(find.text('Send Link'));
        await tester.pumpAndSettle(const Duration(seconds: 2));

        // Verify success message
        expect(find.text('Password reset link sent to your email'), findsOneWidget);
      });
    });
  });
}
