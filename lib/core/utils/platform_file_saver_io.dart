import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<bool> saveOrShareImage({
  required Uint8List bytes,
  required String fileName,
  required String text,
}) async {
  try {
    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/$fileName').create();
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: text);
    return true;
  } catch (e) {
    return false;
  }
}

