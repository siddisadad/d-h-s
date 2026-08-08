import 'package:flutter_test/flutter_test.dart';
import 'package:deshmukh_steel_e_r_p/features/sales/domain/entities/sales_invoice.dart';
import 'package:deshmukh_steel_e_r_p/features/sales/domain/entities/invoice_item.dart';

void main() {
  group('SalesInvoice', () {
    test('grandTotal calculation should be correct', () {
      final items = [
        InvoiceItem(
          name: 'Product 1',
          sku: 'P1',
          price: 100.0,
          qty: 2,
          gstRate: 18.0,
        ),
        InvoiceItem(
          name: 'Product 2',
          sku: 'P2',
          price: 50.0,
          qty: 1,
          gstRate: 12.0,
        ),
      ];

      final invoice = SalesInvoice(
        id: '1',
        customerId: 'C1',
        customerName: 'Customer 1',
        date: DateTime.now(),
        items: items,
        discount: 10.0,
      );

      // Subtotal = (100 * 2) + (50 * 1) = 200 + 50 = 250
      // GST = (200 * 0.18) + (50 * 0.12) = 36 + 6 = 42
      // Grand Total = 250 + 42 - 10 = 282
      expect(invoice.subtotal, 250.0);
      expect(invoice.totalGst, 42.0);
      expect(invoice.grandTotal, 282.0);
    });
  });
}
