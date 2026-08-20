import 'dart:convert';

import 'package:web/web.dart' as web;

Future<void> saveBytes(
  List<int> bytes,
  String fileName, {
  bool temporary = false,
}) async {
  final base64 = base64Encode(bytes);
  final anchor = web.HTMLAnchorElement()
    ..href = 'data:application/octet-stream;base64,$base64'
    ..download = fileName;
  anchor.click();
}
