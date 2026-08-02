import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/sales/domain/entities/sales_invoice.dart';

part 'pdf_service.g.dart';

@riverpod
class PdfService extends _$PdfService {
  @override
  void build() {}

  Future<Uint8List> generateInvoice(SalesInvoice invoice) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('DESHMUKH', style: pw.TextStyle(font: boldFont, fontSize: 24, color: PdfColor.fromInt(0xFF0F4C81))),
                      pw.Text('HARDWARE & STEEL', style: pw.TextStyle(font: font, fontSize: 12, color: PdfColors.grey700)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('INVOICE', style: pw.TextStyle(font: boldFont, fontSize: 20)),
                      pw.Text('# ${invoice.id}', style: pw.TextStyle(font: font, fontSize: 12)),
                      pw.Text('Date: ${invoice.date.toString().split(' ')[0]}', style: pw.TextStyle(font: font, fontSize: 10)),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 32),
              
              // Bill To
              pw.Text('BILL TO:', style: pw.TextStyle(font: boldFont, fontSize: 10)),
              pw.Text(invoice.customerName, style: pw.TextStyle(font: font, fontSize: 14)),
              pw.SizedBox(height: 24),

              // Items Table
              pw.Table(
                border: const pw.TableBorder(bottom: pw.BorderSide(color: PdfColors.grey300, width: 0.5)),
                children: [
                  // Table Header
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey100),
                    children: [
                      _tableCell('Item Description', bold: true),
                      _tableCell('Qty', bold: true, align: pw.TextAlign.center),
                      _tableCell('Price', bold: true, align: pw.TextAlign.right),
                      _tableCell('Subtotal', bold: true, align: pw.TextAlign.right),
                    ],
                  ),
                  // Table Rows
                  ...invoice.items.map((item) => pw.TableRow(
                    children: [
                      _tableCell(item.name),
                      _tableCell(item.qty.toString(), align: pw.TextAlign.center),
                      _tableCell('₹${item.price.toStringAsFixed(2)}', align: pw.TextAlign.right),
                      _tableCell('₹${item.subtotal.toStringAsFixed(2)}', align: pw.TextAlign.right),
                    ],
                  )),
                ],
              ),
              
              pw.SizedBox(height: 24),
              
              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.end,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      _totalRow('Subtotal:', '₹${invoice.subtotal.toStringAsFixed(2)}'),
                      _totalRow('Total GST:', '₹${invoice.totalGst.toStringAsFixed(2)}'),
                      if (invoice.discount > 0)
                        _totalRow('Discount:', '- ₹${invoice.discount.toStringAsFixed(2)}'),
                      pw.Divider(color: PdfColors.grey400),
                      pw.Row(
                        children: [
                          pw.Text('Grand Total: ', style: pw.TextStyle(font: boldFont, fontSize: 14)),
                          pw.Text('₹${invoice.grandTotal.toStringAsFixed(2)}', 
                            style: pw.TextStyle(font: boldFont, fontSize: 14, color: PdfColor.fromInt(0xFF0F4C81))),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              
              pw.Spacer(),
              
              // Footer
              pw.Center(
                child: pw.Text('Thank you for your business!', style: pw.TextStyle(font: font, fontSize: 10, color: PdfColors.grey500)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateThermalReceipt(SalesInvoice invoice) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Column(
                  children: [
                    pw.Text('DESHMUKH', style: pw.TextStyle(font: boldFont, fontSize: 16)),
                    pw.Text('HARDWARE & STEEL', style: pw.TextStyle(font: font, fontSize: 10)),
                    pw.Text('--------------------------------', style: pw.TextStyle(font: font)),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),

              // Invoice Info
              pw.Text('Inv #: ${invoice.id}', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Date: ${invoice.date.toString().split(' ')[0]}', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.Text('Customer: ${invoice.customerName}', style: pw.TextStyle(font: font, fontSize: 9)),
              pw.SizedBox(height: 8),
              pw.Text('--------------------------------', style: pw.TextStyle(font: font)),

              // Items
              pw.Column(
                children: invoice.items.map((item) => pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text(item.name, style: pw.TextStyle(font: font, fontSize: 9)),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('${item.qty} x ₹${item.price.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 9)),
                          pw.Text('₹${item.subtotal.toStringAsFixed(2)}', style: pw.TextStyle(font: boldFont, fontSize: 9)),
                        ],
                      ),
                    ],
                  ),
                )).toList(),
              ),

              pw.SizedBox(height: 8),
              pw.Text('--------------------------------', style: pw.TextStyle(font: font)),

              // Totals
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('Subtotal:', style: pw.TextStyle(font: font, fontSize: 9)),
                  pw.Text('₹${invoice.subtotal.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 9)),
                ],
              ),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GST:', style: pw.TextStyle(font: font, fontSize: 9)),
                  pw.Text('₹${invoice.totalGst.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 9)),
                ],
              ),
              if (invoice.discount > 0)
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Discount:', style: pw.TextStyle(font: font, fontSize: 9)),
                    pw.Text('- ₹${invoice.discount.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 9)),
                  ],
                ),
              pw.SizedBox(height: 4),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL:', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                  pw.Text('₹${invoice.grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                ],
              ),

              pw.SizedBox(height: 16),
              pw.Center(
                child: pw.Text('Thank you! Visit again.', style: pw.TextStyle(font: font, fontSize: 8)),
              ),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _tableCell(String text, {bool bold = false, pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(8),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 10), textAlign: align),
    );
  }

  pw.Widget _totalRow(String label, String value) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(label, style: const pw.TextStyle(fontSize: 10)),
          pw.SizedBox(width: 24),
          pw.Text(value, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }
}
