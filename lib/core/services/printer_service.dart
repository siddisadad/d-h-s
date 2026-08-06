import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

part 'printer_service.g.dart';

@Riverpod(keepAlive: true)
class PrinterService extends _$PrinterService {
  static const _prefKey = 'default_printer_name';
  String? _selectedPrinterName;

  @override
  FutureOr<String?> build() async {
    final prefs = await SharedPreferences.getInstance();
    _selectedPrinterName = prefs.getString(_prefKey);
    return _selectedPrinterName;
  }

  Future<void> setPrinter(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, name);
    _selectedPrinterName = name;
    state = AsyncData(name);
    Log.i('Default printer set to: $name', name: 'Printer');
  }

  Future<void> clearPrinter() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
    _selectedPrinterName = null;
    state = const AsyncData(null);
  }

  Future<bool> directPrint(Uint8List bytes, {String? jobName}) async {
    try {
      if (_selectedPrinterName == null) {
        Log.w('No default printer selected. Falling back to system dialog.', name: 'Printer');
        return await Printing.layoutPdf(onLayout: (_) => bytes, name: jobName ?? 'ERP_Print_Job');
      }

      final printers = await Printing.listPrinters();
      final target = printers.firstWhere(
        (p) => p.name == _selectedPrinterName,
        orElse: () => throw Exception('Saved printer not found on network'),
      );

      Log.i('Direct printing to: ${target.name}', name: 'Printer');
      return await Printing.directPrintPdf(
        printer: target,
        onLayout: (_) => bytes,
      );
    } catch (e) {
      Log.e('Direct print failed', error: e, name: 'Printer');
      // Fallback
      return await Printing.layoutPdf(onLayout: (_) => bytes, name: jobName ?? 'ERP_Print_Job');
    }
  }

  Future<List<Printer>> discoverPrinters() async {
    return await Printing.listPrinters();
  }
}
