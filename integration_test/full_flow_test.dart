import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:deshmukh_steel_e_r_p/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('End-to-End ERP Flow', () {
    testWidgets('Full sequence: Login -> Inventory -> New Sale', (tester) async {
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
      expect(find.text('Welcome back, Admin'), findsOneWidget);

      // 4. Navigate to Inventory
      await tester.tap(find.text('Inventory'));
      await tester.pumpAndSettle();
      expect(find.text('PRODUCT INVENTORY'), findsOneWidget);

      // 5. Back to Dashboard
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 6. Navigate to New Sale
      await tester.tap(find.text('New Sale'));
      await tester.pumpAndSettle();
      expect(find.text('NEW SALES INVOICE'), findsOneWidget);

      // 7. Select Customer
      await tester.tap(find.text('Select Customer'));
      await tester.pumpAndSettle();
      expect(find.text('SELECT CUSTOMER'), findsOneWidget);
      
      // Select first customer in mock list
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // 8. Add Product
      await tester.tap(find.text('Add Item'));
      await tester.pumpAndSettle();
      expect(find.text('ADD PRODUCT'), findsOneWidget);
      
      // Select first product
      await tester.tap(find.byType(ListTile).first);
      await tester.pumpAndSettle();

      // 9. Verify Totals
      expect(find.text('GRAND TOTAL'), findsOneWidget);
      
      // 10. Generate Invoice
      await tester.tap(find.text('GENERATE FINAL INVOICE'));
      await tester.pumpAndSettle();
      
      // Verify SnackBar
      expect(find.text('Invoice Created!'), findsOneWidget);
    });
  });
}
