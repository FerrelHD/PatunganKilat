import 'dart:js_interop';
import 'dart:typed_data';
import 'package:share_plus/share_plus.dart';
import 'package:web/web.dart' as web;

Future<bool> saveOrShareImage({
  required Uint8List bytes,
  required String fileName,
  required String text,
}) async {
  // First attempt: Try Share.shareXFiles (triggers native iOS/Android share sheet on mobile web!)
  try {
    final xFile = XFile.fromData(bytes, mimeType: 'image/png', name: fileName);
    final result = await Share.shareXFiles([xFile], text: text);
    if (result.status == ShareResultStatus.success || result.status == ShareResultStatus.dismissed) {
      return true;
    }
  } catch (_) {
    // If Web Share API is unavailable or user agent doesn't support file sharing,
    // fallback to instant HTML download.
  }

  try {
    final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: 'image/png'));
    final url = web.URL.createObjectURL(blob);
    final anchor = web.HTMLAnchorElement()
      ..href = url
      ..download = fileName;
    web.document.body?.append(anchor);
    anchor.click();
    anchor.remove();
    web.URL.revokeObjectURL(url);
    return true;
  } catch (e) {
    return false;
  }
}

