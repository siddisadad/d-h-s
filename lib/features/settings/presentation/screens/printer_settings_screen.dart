import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import '../../../../core/design_system/theme/app_theme.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/services/printer_service.dart';
import '../../../../core/providers/app_bar_provider.dart';

class PrinterSettingsScreen extends ConsumerWidget {
  const PrinterSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final defaultPrinterAsync = ref.watch(printerServiceProvider);
    final tokens = context.tokens;

    // Update Global AppBar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(appBarNotifierProvider.notifier).update(
        title: 'PRINTER SETTINGS',
      );
    });

    return SingleChildScrollView(
      padding: EdgeInsets.all(tokens.space24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildActivePrinterCard(context, ref, defaultPrinterAsync.value),
          const SizedBox(height: 32),
          Text(
            'AVAILABLE NETWORK PRINTERS',
            style: context.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              letterSpacing: 1.2,
              color: context.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 16),
          _buildPrinterList(context, ref),
        ],
      ),
    );
  }

  Widget _buildActivePrinterCard(BuildContext context, WidgetRef ref, String? activeName) {
    return CustomCard(
      color: activeName != null ? context.colorScheme.primaryContainer.withValues(alpha: 0.3) : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.print_rounded,
                color: activeName != null ? context.colorScheme.primary : context.theme.disabledColor,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      activeName ?? 'No Default Printer',
                      style: context.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      activeName != null ? 'Ready for One-Tap direct printing' : 'Connect a yard printer for faster receipts',
                      style: context.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (activeName != null)
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: Colors.red),
                  onPressed: () => ref.read(printerServiceProvider.notifier).clearPrinter(),
                ),
            ],
          ),
          if (activeName != null) ...[
            const Divider(height: 32),
            CustomButton(
              text: 'SEND TEST PRINT',
              variant: CustomButtonVariant.outline,
              fullWidth: true,
              onPressed: () => _sendTestPrint(ref),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPrinterList(BuildContext context, WidgetRef ref) {
    return FutureBuilder<List<Printer>>(
      future: ref.read(printerServiceProvider.notifier).discoverPrinters(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Padding(
            padding: EdgeInsets.all(32.0),
            child: CircularProgressIndicator(),
          ));
        }

        final printers = snapshot.data ?? [];
        if (printers.isEmpty) {
          return CustomCard(
            child: Center(
              child: Column(
                children: [
                  Icon(Icons.print_disabled_rounded, size: 48, color: context.theme.disabledColor),
                  const SizedBox(height: 16),
                  const Text('No network printers found'),
                  Text('Ensure your printer is on the same WiFi network.', style: context.textTheme.bodySmall),
                  const SizedBox(height: 16),
                  CustomButton(
                    text: 'RESCAN',
                    onPressed: () => (context as Element).markNeedsBuild(),
                  ),
                ],
              ),
            ),
          );
        }

        return CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: printers.map((p) => ListTile(
              leading: const Icon(Icons.cast_connected_rounded),
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w600)),
              subtitle: Text(p.url),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => ref.read(printerServiceProvider.notifier).setPrinter(p.name),
            )).toList(),
          ),
        );
      },
    );
  }

  void _sendTestPrint(WidgetRef ref) async {
    // Generate a simple test PDF
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
      pageFormat: PdfPageFormat.roll80,
      build: (context) => pw.Center(
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text('DESHMUKH ERP', style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold)),
            pw.Text('TEST PRINT SUCCESSFUL', style: pw.TextStyle(fontSize: 10)),
            pw.SizedBox(height: 10),
            pw.Text(DateTime.now().toString(), style: pw.TextStyle(fontSize: 8)),
          ],
        ),
      ),
    ));

    final bytes = await pdf.save();
    await ref.read(printerServiceProvider.notifier).directPrint(bytes, jobName: 'Test_Print');
  }
}
