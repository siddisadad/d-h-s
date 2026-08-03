import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../features/sales/domain/entities/sales_invoice.dart';
import '../../features/sales/domain/entities/sales_quotation.dart';
import '../../features/sales/domain/entities/sales_return.dart';

part 'pdf_service.g.dart';

@riverpod
class PdfService extends _$PdfService {
  static const _brandColor = PdfColor.fromInt(0xFF0F4C81);
  static const _accentColor = PdfColor.fromInt(0xFFF59E0B);
  
  // Business Details
  static const _businessName = 'DESHMUKH HARDWARE & STEEL';
  static const _businessAddress = 'Sr No 42, Near Industrial Estate, Hadapsar, Pune - 411028';
  static const _businessGstin = '27AAACD1234A1Z5';
  static const _businessContact = '+91 98765 43210 | support@deshmukhsteel.com';

  @override
  void build() {}

  Future<Uint8List> generateInvoice(SalesInvoice invoice) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(boldFont, font, 'TAX INVOICE', invoice.id, invoice.date),
          pw.SizedBox(height: 24),
          _buildBillTo(boldFont, font, invoice.customerName),
          pw.SizedBox(height: 24),
          _buildItemsTable(boldFont, font, invoice.items),
          pw.SizedBox(height: 24),
          _buildTotals(boldFont, font, invoice.subtotal, invoice.totalGst, invoice.discount, invoice.grandTotal),
          pw.SizedBox(height: 40),
          _buildTermsAndSignature(boldFont, font),
        ],
        footer: (context) => _buildFooter(font),
      ),
    );

    return pdf.save();
  }

  Future<Uint8List> generateQuotation(SalesQuotation quotation) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          _buildHeader(boldFont, font, 'PROPOSAL / QUOTATION', quotation.id, quotation.date),
          pw.SizedBox(height: 12),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: const pw.BoxDecoration(color: _accentColor),
            child: pw.Text(
              'VALID UNTIL: ${quotation.expiryDate.toString().split(' ')[0].toUpperCase()}',
              style: pw.TextStyle(font: boldFont, fontSize: 10, color: PdfColors.white),
            ),
          ),
          pw.SizedBox(height: 24),
          _buildBillTo(boldFont, font, quotation.customerName),
          pw.SizedBox(height: 24),
          _buildItemsTable(boldFont, font, quotation.items),
          pw.SizedBox(height: 24),
          _buildTotals(boldFont, font, quotation.subtotal, quotation.totalGst, quotation.discount, quotation.grandTotal),
          pw.SizedBox(height: 40),
          _buildTermsAndSignature(boldFont, font, isQuotation: true),
        ],
        footer: (context) => _buildFooter(font),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(pw.Font bold, pw.Font normal, String title, String id, DateTime date) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(_businessName, style: pw.TextStyle(font: bold, fontSize: 18, color: _brandColor)),
            pw.SizedBox(height: 4),
            pw.Text(_businessAddress, style: pw.TextStyle(font: normal, fontSize: 9, color: PdfColors.grey700)),
            pw.Text('GSTIN: $_businessGstin', style: pw.TextStyle(font: bold, fontSize: 9)),
            pw.Text('Contact: $_businessContact', style: pw.TextStyle(font: normal, fontSize: 9)),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(title, style: pw.TextStyle(font: bold, fontSize: 16, color: _brandColor)),
            pw.SizedBox(height: 4),
            pw.Text('Reference: #$id', style: pw.TextStyle(font: bold, fontSize: 10)),
            pw.Text('Date: ${date.toString().split(' ')[0]}', style: pw.TextStyle(font: normal, fontSize: 10)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildBillTo(pw.Font bold, pw.Font normal, String customerName) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('BILL TO:', style: pw.TextStyle(font: bold, fontSize: 9, color: PdfColors.grey600)),
        pw.SizedBox(height: 4),
        pw.Text(customerName, style: pw.TextStyle(font: bold, fontSize: 13)),
        pw.Text('GSTIN: 27XXXXX0000X1Z', style: pw.TextStyle(font: normal, fontSize: 9)), // Placeholder for customer GST
      ],
    );
  }

  pw.Widget _buildItemsTable(pw.Font bold, pw.Font normal, List<dynamic> items) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey100),
          children: [
            _cell('SR.', bold: true, flex: 1),
            _cell('DESCRIPTION', bold: true, flex: 6),
            _cell('QTY', bold: true, align: pw.TextAlign.center, flex: 2),
            _cell('RATE', bold: true, align: pw.TextAlign.right, flex: 3),
            _cell('AMOUNT', bold: true, align: pw.TextAlign.right, flex: 3),
          ],
        ),
        ...items.asMap().entries.map((e) {
          final i = e.key + 1;
          final item = e.value;
          return pw.TableRow(
            children: [
              _cell(i.toString(), flex: 1),
              _cell(item.name, flex: 6),
              _cell(item.qty.toString(), align: pw.TextAlign.center, flex: 2),
              _cell('₹${item.price.toStringAsFixed(2)}', align: pw.TextAlign.right, flex: 3),
              _cell('₹${item.subtotal.toStringAsFixed(2)}', align: pw.TextAlign.right, flex: 3),
            ],
          );
        }),
      ],
    );
  }

  pw.Widget _buildTotals(pw.Font bold, pw.Font normal, double subtotal, double gst, double discount, double grandTotal) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            _totalLine('Subtotal', subtotal, normal),
            _totalLine('GST (18%)', gst, normal),
            if (discount > 0) _totalLine('Discount', -discount, normal),
            pw.Divider(color: PdfColors.grey400, thickness: 1, height: 16),
            pw.Row(
              children: [
                pw.Text('GRAND TOTAL', style: pw.TextStyle(font: bold, fontSize: 14)),
                pw.SizedBox(width: 40),
                pw.Text('₹${grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(font: bold, fontSize: 14, color: _brandColor)),
              ],
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildTermsAndSignature(pw.Font bold, pw.Font normal, {bool isQuotation = false}) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      crossAxisAlignment: pw.CrossAxisAlignment.end,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('TERMS & CONDITIONS:', style: pw.TextStyle(font: bold, fontSize: 8)),
            pw.SizedBox(height: 4),
            pw.Text('1. Goods once sold will not be taken back.', style: pw.TextStyle(font: normal, fontSize: 7)),
            pw.Text('2. Interest @ 18% p.a. will be charged if not paid within due date.', style: pw.TextStyle(font: normal, fontSize: 7)),
            pw.Text('3. Subject to Pune jurisdiction only.', style: pw.TextStyle(font: normal, fontSize: 7)),
            if (isQuotation) pw.Text('4. This is a computer generated quote and requires conversion to invoice.', style: pw.TextStyle(font: normal, fontSize: 7)),
          ],
        ),
        pw.Column(
          children: [
            pw.Container(width: 120, height: 1, color: PdfColors.black),
            pw.SizedBox(height: 4),
            pw.Text('Authorized Signatory', style: pw.TextStyle(font: normal, fontSize: 8)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildFooter(pw.Font normal) {
    return pw.Column(
      children: [
        pw.Divider(color: PdfColors.grey300),
        pw.Center(
          child: pw.Text(
            'This is a computer generated document. No signature is required unless mentioned.',
            style: pw.TextStyle(font: normal, fontSize: 7, color: PdfColors.grey500),
          ),
        ),
      ],
    );
  }

  pw.Widget _cell(String text, {bool bold = false, pw.TextAlign align = pw.TextAlign.left, required int flex}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(6),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9), textAlign: align),
    );
  }

  pw.Widget _totalLine(String label, double value, pw.Font font) {
    return pw.Row(
      mainAxisSize: pw.MainAxisSize.min,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 10)),
        pw.SizedBox(width: 60),
        pw.Text('₹${value.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 10)),
      ],
    );
  }

  Future<Uint8List> generateThermalReceipt(SalesInvoice invoice) async {
    final pdf = pw.Document();
    final font = await PdfGoogleFonts.poppinsRegular();
    final boldFont = await PdfGoogleFonts.poppinsBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const pw.EdgeInsets.all(10),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Center(
              child: pw.Column(
                children: [
                  pw.Text(_businessName, style: pw.TextStyle(font: boldFont, fontSize: 12), textAlign: pw.TextAlign.center),
                  pw.Text(_businessAddress, style: pw.TextStyle(font: font, fontSize: 8), textAlign: pw.TextAlign.center),
                  pw.Text('GSTIN: $_businessGstin', style: pw.TextStyle(font: font, fontSize: 8)),
                  pw.Text('--------------------------------------', style: pw.TextStyle(font: font)),
                ],
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text('INV #: ${invoice.id}', style: pw.TextStyle(font: boldFont, fontSize: 9)),
            pw.Text('DATE : ${invoice.date.toString().split(' ')[0]}', style: pw.TextStyle(font: font, fontSize: 9)),
            pw.Text('CUST : ${invoice.customerName}', style: pw.TextStyle(font: font, fontSize: 9)),
            pw.SizedBox(height: 8),
            pw.Text('--------------------------------------', style: pw.TextStyle(font: font)),
            ...invoice.items.map((item) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(item.name.toUpperCase(), style: pw.TextStyle(font: font, fontSize: 8)),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('${item.qty} x ${item.price.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 8)),
                    pw.Text('₹${item.subtotal.toStringAsFixed(2)}', style: pw.TextStyle(font: boldFont, fontSize: 8)),
                  ],
                ),
                pw.SizedBox(height: 2),
              ],
            )),
            pw.Text('--------------------------------------', style: pw.TextStyle(font: font)),
            _receiptRow('SUBTOTAL', invoice.subtotal, font),
            _receiptRow('GST (18%)', invoice.totalGst, font),
            if (invoice.discount > 0) _receiptRow('DISCOUNT', -invoice.discount, font),
            pw.SizedBox(height: 4),
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text('TOTAL', style: pw.TextStyle(font: boldFont, fontSize: 12)),
                pw.Text('₹${invoice.grandTotal.toStringAsFixed(2)}', style: pw.TextStyle(font: boldFont, fontSize: 12)),
              ],
            ),
            pw.SizedBox(height: 16),
            pw.Center(
              child: pw.Text('*** THANK YOU! VISIT AGAIN ***', style: pw.TextStyle(font: font, fontSize: 7)),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _receiptRow(String label, double value, pw.Font font) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label, style: pw.TextStyle(font: font, fontSize: 8)),
        pw.Text('₹${value.toStringAsFixed(2)}', style: pw.TextStyle(font: font, fontSize: 8)),
      ],
    );
  }
}
