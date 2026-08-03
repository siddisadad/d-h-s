import 'dart:io';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
// For web download support
import 'dart:convert';
import 'package:web/web.dart' as web;

part 'excel_service.g.dart';

@riverpod
class ExcelService extends _$ExcelService {
  @override
  void build() {}

  Future<void> exportInventory(List<dynamic> products) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Inventory Stock'];

    // Header
    sheetObject.appendRow([
      TextCellValue('SKU'),
      TextCellValue('Product Name'),
      TextCellValue('Category'),
      TextCellValue('Price'),
      TextCellValue('Stock'),
      TextCellValue('Unit'),
    ]);

    // Data
    for (var p in products) {
      sheetObject.appendRow([
        TextCellValue(p.sku),
        TextCellValue(p.name),
        TextCellValue(p.category),
        TextCellValue(p.price),
        TextCellValue(p.stock),
        TextCellValue(p.unit),
      ]);
    }

    final fileBytes = excel.encode();
    if (fileBytes == null) return;

    if (kIsWeb) {
      _downloadWeb(fileBytes, 'Inventory_Stock.xlsx');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/Inventory_Stock.xlsx');
      await file.writeAsBytes(fileBytes);
    }
  }

  Future<void> exportSalesReport(List<dynamic> invoices) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Sales Report'];

    // Header
    sheetObject.appendRow([
      TextCellValue('Invoice ID'),
      TextCellValue('Date'),
      TextCellValue('Customer'),
      TextCellValue('Discount'),
      TextCellValue('Grand Total'),
    ]);

    // Data
    for (var inv in invoices) {
      sheetObject.appendRow([
        TextCellValue(inv.id),
        TextCellValue(inv.date.toIso8601String()),
        TextCellValue(inv.customerName),
        TextCellValue(inv.discount.toString()),
        TextCellValue(inv.grandTotal.toString()),
      ]);
    }

    final fileBytes = excel.encode();
    if (fileBytes == null) return;

    if (kIsWeb) {
      _downloadWeb(fileBytes, 'Sales_Report.xlsx');
    } else {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/Sales_Report.xlsx');
      await file.writeAsBytes(fileBytes);
    }
  }

  void _downloadWeb(List<int> bytes, String fileName) {
    final base64 = base64Encode(bytes);
    final anchor = web.HTMLAnchorElement()
      ..href = 'data:application/octet-stream;base64,$base64'
      ..download = fileName;
    anchor.click();
  }
}
