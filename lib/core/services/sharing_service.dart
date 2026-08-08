import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../utils/logger.dart';

part 'sharing_service.g.dart';

@riverpod
class SharingService extends _$SharingService {
  @override
  void build() {}

  Future<void> sendWhatsAppMessage({required String phone, required String message}) async {
    // Sanitize phone number (remove +, spaces, dashes)
    final sanitizedPhone = phone.replaceAll(RegExp(r'[^0-9]'), '');
    // Ensure Indian country code if missing (standard for this business)
    final finalPhone = sanitizedPhone.length == 10 ? '91$sanitizedPhone' : sanitizedPhone;

    final url = 'https://wa.me/$finalPhone?text=${Uri.encodeComponent(message)}';

    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      Log.e('Could not launch WhatsApp for $finalPhone', name: 'Sharing');
    }
  }

  Future<void> shareText(String text) async {
    // For now, using WhatsApp as primary text sharing channel for the business
    final url = 'whatsapp://send?text=${Uri.encodeComponent(text)}';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      Log.w('Could not launch WhatsApp for text sharing', name: 'Sharing');
    }
  }

  Future<void> shareFile(Uint8List bytes, String fileName, {String? phoneNumber}) async {
    if (kIsWeb) {
      Log.w('File sharing not supported on Web via this service. Use direct download.', name: 'Sharing');
      return;
    }

    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(bytes);

      if (phoneNumber != null) {
        // WhatsApp with attachment is tricky without share_plus.
        // For now, we launch WhatsApp message and the user can attach the recently saved file.
        // Or if share_plus is added, we use that.
        final text = 'Please find the attached statement.';
        final url = 'whatsapp://send?phone=${phoneNumber.replaceAll(' ', '')}&text=${Uri.encodeComponent(text)}';

        if (await canLaunchUrl(Uri.parse(url))) {
          await launchUrl(Uri.parse(url));
          Log.i('Launched WhatsApp. User must manually attach the PDF from temporary storage.', name: 'Sharing');
        }
      }

      // Note: In a real app with share_plus, we would do:
      // await Share.shareXFiles([XFile(file.path)], text: 'Statement');
    } catch (e) {
      Log.e('Error sharing file', error: e, name: 'Sharing');
    }
  }
}
