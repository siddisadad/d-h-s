import 'dart:io';

import 'package:path_provider/path_provider.dart';

Future<void> saveBytes(
  List<int> bytes,
  String fileName, {
  bool temporary = false,
}) async {
  final directory = temporary
      ? await getTemporaryDirectory()
      : await getApplicationDocumentsDirectory();
  await File('${directory.path}/$fileName').writeAsBytes(bytes);
}
