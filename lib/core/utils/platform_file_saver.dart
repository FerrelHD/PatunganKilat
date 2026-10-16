import 'dart:typed_data';

import 'platform_file_saver_stub.dart'
    if (dart.library.js_interop) 'platform_file_saver_web.dart'
    if (dart.library.io) 'platform_file_saver_io.dart';

Future<bool> saveOrShareReceiptImage({
  required Uint8List bytes,
  required String fileName,
  required String text,
}) =>
    saveOrShareImage(bytes: bytes, fileName: fileName, text: text);

