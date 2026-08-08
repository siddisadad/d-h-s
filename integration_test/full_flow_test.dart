import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:deshmukh_steel_e_r_p/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End ERP Flow', () {
    testWidgets('Full sequence: Login -> Inventory -> New Sale with Credit Limit Warning', (tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Directly on Login
      expect(find.text('Secure Login'), findsOneWidget);

      // 2. Perform Login
      await tester.enterText(find.byType(TextField).at(0), 'admin');
      await tester.enterText(find.byType(TextField).at(1), 'password');
      await tester.tap(find.text('Login to ERP'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // 3. Verify Dashboard
      expect(find.text('DHS ERP DASHBOARD'), findsOneWidget);

      // 4. Navigate to New Sale
      await tester.tap(find.text('New Sale'));
      await tester.pumpAndSettle();
      expect(find.text('NEW SALES INVOICE'), findsOneWidget);

      // 5. Select Customer with Low Credit Limit (Deshmukh Builders)
      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Deshmukh Builders'));
      await tester.pumpAndSettle();

      // 6. Add expensive items to trigger Credit Limit Warning
      // Deshmukh Builders has balance -12000, creditLimit 10000.
      // 6 drills @ 4250 = 25500 + GST > 22000
      for (int i = 0; i < 6; i++) {
        await tester.tap(find.text('Add Item'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Bosch Professional Drill 750W'));
        await tester.pumpAndSettle();
      }

      // 7. Verify HSN codes are visible in the item list
      expect(find.textContaining('HSN: 8467'), findsWidgets);

      // 8. Generate Invoice and check for Warning Dialog
      await tester.tap(find.text('GENERATE FINAL INVOICE & QUICK PRINT'));
      await tester.pumpAndSettle();

      expect(find.text('Credit Limit Exceeded'), findsOneWidget);
      expect(find.textContaining('exceeds their credit limit of ₹10000.00'), findsOneWidget);

      // 9. Proceed anyway
      await tester.tap(find.text('Proceed Anyway'));
      await tester.pumpAndSettle();

      // Verify SnackBar
      expect(find.text('Invoice Created & Sent to Printer!'), findsOneWidget);
    });
  });
}
