import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'library_service.dart';

class WifiTransferService extends ChangeNotifier {
  WifiTransferService(this.libraryService);

  final LibraryService libraryService;
  HttpServer? _server;
  String? _address;
  bool _busy = false;
  int _uploadedCount = 0;
  String? _lastMessage;

  bool get isRunning => _server != null;
  bool get busy => _busy;
  int get uploadedCount => _uploadedCount;
  String? get lastMessage => _lastMessage;
  String? get url => _server == null || _address == null
      ? null
      : 'http://$_address:${_server!.port}';

  Future<void> start() async {
    if (_server != null) return;
    _busy = true;
    _lastMessage = null;
    notifyListeners();
    try {
      _address = await _findLocalIpv4();
      if (_address == null) {
        throw const SocketException('Không tìm thấy địa chỉ Wi‑Fi nội bộ.');
      }
      _server = await HttpServer.bind(InternetAddress.anyIPv4, 0, shared: true);
      _server!.listen(
        _handleRequest,
        onError: (Object error) {
          _lastMessage = 'Máy chủ Wi‑Fi gặp lỗi: $error';
          notifyListeners();
        },
        onDone: () {
          _server = null;
          notifyListeners();
        },
      );
      _lastMessage = 'Máy chủ đã sẵn sàng.';
    } catch (error) {
      _server = null;
      _address = null;
      _lastMessage = error.toString();
      rethrow;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    final server = _server;
    _server = null;
    _address = null;
    if (server != null) await server.close(force: true);
    _lastMessage = 'Đã tắt truyền nhạc qua Wi‑Fi.';
    notifyListeners();
  }

  Future<String?> _findLocalIpv4() async {
    final interfaces = await NetworkInterface.list(
      type: InternetAddressType.IPv4,
      includeLoopback: false,
      includeLinkLocal: false,
    );
    final addresses = <String>[];
    for (final interface in interfaces) {
      for (final address in interface.addresses) {
        final value = address.address;
        if (!value.startsWith('169.254.')) addresses.add(value);
      }
    }
    for (final value in addresses) {
      if (value.startsWith('192.168.') ||
          value.startsWith('10.') ||
          RegExp(r'^172\.(1[6-9]|2\d|3[01])\.').hasMatch(value)) {
        return value;
      }
    }
    return addresses.isEmpty ? null : addresses.first;
  }

  Future<void> _handleRequest(HttpRequest request) async {
    request.response.headers.set('Cache-Control', 'no-store');
    try {
      if (request.method == 'GET' && request.uri.path == '/') {
        await _sendHome(request.response);
        return;
      }
      if (request.method == 'GET' && request.uri.path == '/status') {
        request.response.headers.contentType = ContentType.json;
        request.response.write(jsonEncode({
          'running': true,
          'uploaded': _uploadedCount,
          'songs': libraryService.songs.length,
        }));
        await request.response.close();
        return;
      }
      if (request.method == 'POST' && request.uri.path == '/upload') {
        await _handleUpload(request);
        return;
      }
      request.response.statusCode = HttpStatus.notFound;
      request.response.write('Not found');
      await request.response.close();
    } catch (error) {
      request.response.statusCode = HttpStatus.internalServerError;
      request.response.headers.contentType = ContentType.html;
      request.response.write(_page(
        title: 'Có lỗi xảy ra',
        body: '<div class="card"><h2>Không thể tải file</h2>'
            '<p>${const HtmlEscape().convert(error.toString())}</p>'
            '<a class="button" href="/">Quay lại</a></div>',
      ));
      await request.response.close();
    }
  }

  Future<void> _handleUpload(HttpRequest request) async {
    final contentType = request.headers.contentType;
    final boundary = contentType?.parameters['boundary'];
    if (contentType == null ||
        contentType.mimeType != 'multipart/form-data' ||
        boundary == null) {
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write('Yêu cầu tải lên không hợp lệ.');
      await request.response.close();
      return;
    }

    final tempDirectory = await getTemporaryDirectory();
    final pending = <({File file, String name})>[];
    final parts = request.transform(MimeMultipartTransformer(boundary));

    await for (final part in parts) {
      final disposition = part.headers['content-disposition'] ?? '';
      final match = RegExp(r'filename="([^"]*)"').firstMatch(disposition);
      final rawName = match?.group(1);
      if (rawName == null || rawName.trim().isEmpty) {
        await part.drain();
        continue;
      }
      final name = p.basename(rawName);
      final safeName = name.replaceAll(RegExp(r'[\\/:*?"<>|]'), '_');
      final tempFile = File(
        p.join(
          tempDirectory.path,
          '${DateTime.now().microsecondsSinceEpoch}_$safeName',
        ),
      );
      final sink = tempFile.openWrite();
      await part.pipe(sink);
      pending.add((file: tempFile, name: name));
    }

    final result = await libraryService.importExternalFiles(pending);
    for (final item in pending) {
      if (await item.file.exists()) await item.file.delete();
    }
    _uploadedCount += result.imported;
    _lastMessage = result.message;
    notifyListeners();

    request.response.headers.contentType = ContentType.html;
    request.response.write(_page(
      title: 'Tải nhạc hoàn tất',
      body: '<div class="card success"><div class="big">✓</div>'
          '<h2>Đã xử lý file</h2>'
          '<p>${const HtmlEscape().convert(result.message)}</p>'
          '<a class="button" href="/">Tải thêm nhạc</a></div>',
    ));
    await request.response.close();
  }

  Future<void> _sendHome(HttpResponse response) async {
    response.headers.contentType = ContentType.html;
    response.write(_page(
      title: 'Offline Music • Wi‑Fi Upload',
      body: '''
<div class="brand">OFFLINE MUSIC</div>
<div class="card">
  <div class="eyebrow">TRUYỀN NHẠC QUA WI‑FI</div>
  <h1>Gửi nhạc vào iPhone</h1>
  <p>Điện thoại và máy tính phải dùng cùng một mạng Wi‑Fi. Chọn nhiều file rồi nhấn tải lên.</p>
  <form action="/upload" method="post" enctype="multipart/form-data">
    <label class="picker">
      <input type="file" name="files" accept="audio/*,.mp3,.m4a,.aac,.wav,.flac,.ogg,.opus,.aiff" multiple required>
      <span>Chọn file nhạc</span>
    </label>
    <button type="submit">Tải vào thư viện</button>
  </form>
  <div class="note">Đã nhận trong phiên này: $_uploadedCount bài</div>
</div>
''',
    ));
    await response.close();
  }

  String _page({required String title, required String body}) => '''
<!doctype html>
<html lang="vi">
<head>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width,initial-scale=1">
<title>$title</title>
<style>
:root{color-scheme:dark;--bg:#070d10;--panel:#11191e;--line:#263037;--text:#f3f6f7;--muted:#9aa5ad;--accent:#5be0cf}
*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",sans-serif;min-height:100vh;display:grid;place-items:center;padding:24px}
main{width:min(620px,100%)}.brand{font-weight:900;letter-spacing:.18em;color:var(--accent);margin:0 0 16px}.card{background:var(--panel);border:1px solid var(--line);padding:28px}.eyebrow{font-size:12px;letter-spacing:.14em;color:var(--accent);font-weight:800}h1{font-size:clamp(30px,7vw,52px);line-height:1;margin:16px 0}h2{font-size:28px;margin:12px 0}p{color:var(--muted);font-size:17px;line-height:1.55}.picker{display:block;border:1px dashed #526069;padding:24px;text-align:center;margin:24px 0 12px;cursor:pointer}.picker input{display:none}.picker span{font-weight:800}button,.button{display:block;width:100%;border:0;background:var(--accent);color:#07110f;padding:16px;text-align:center;font-size:16px;font-weight:900;text-decoration:none;cursor:pointer}.note{margin-top:16px;color:var(--muted);font-size:14px}.success{text-align:center}.big{font-size:64px;color:var(--accent)}
</style>
</head>
<body><main>$body</main></body>
</html>
''';

  @override
  void dispose() {
    _server?.close(force: true);
    super.dispose();
  }
}
