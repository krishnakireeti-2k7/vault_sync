import 'dart:convert';
import 'dart:io';

class SyncthingService {
  final String apiKey;
  final String baseUrl;
  final String binaryPath;
  final String homeDir;

  Process? _process;

  SyncthingService({
    required this.apiKey,
    required this.binaryPath,
    required this.homeDir,
    this.baseUrl = 'http://127.0.0.1:8384/',
  });

  /// Start Syncthing process
  Future<void> start() async {
    Directory(homeDir).createSync(recursive: true);

    _process = await Process.start(binaryPath, [
      '--home',
      homeDir,
      '--no-browser',
      '--gui-address',
      '127.0.0.1:8384',
    ], runInShell: true);

    _process!.stdout.transform(utf8.decoder).listen((data) => print(data));
    _process!.stderr.transform(utf8.decoder).listen((data) => print(data));

    await _waitForApiReady();
  }

  Future<void> _waitForApiReady({
    int retries = 20,
    Duration delay = const Duration(seconds: 1),
  }) async {
    for (var i = 0; i < retries; i++) {
      try {
        final uri = Uri.parse('$baseUrl/rest/system/ping');
        final req = await HttpClient().getUrl(uri);
        req.headers.set('X-API-Key', apiKey);
        final res = await req.close();
        if (res.statusCode == 200) return;
      } catch (_) {}
      await Future.delayed(delay);
    }
    throw Exception(
      'Syncthing REST API not responding after ${retries * delay.inSeconds}s',
    );
  }

  /// Ping REST API
  Future<void> ping() async {
    final uri = Uri.parse('$baseUrl/rest/system/ping');
    final req = await HttpClient().getUrl(uri);
    req.headers.set('X-API-Key', apiKey);
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('✅ Syncthing ping response: $body');
  }

  /// Print device info
  Future<void> printDeviceInfo() async {
    final uri = Uri.parse('$baseUrl/rest/system/status');
    final req = await HttpClient().getUrl(uri);
    req.headers.set('X-API-Key', apiKey);
    final res = await req.close();
    final body = await res.transform(utf8.decoder).join();
    print('🖥️ Device info: $body');
  }

  /// ✅ Add a folder to Syncthing
  Future<void> addVaultFolder(String folderId, String path) async {
    final uri = Uri.parse('$baseUrl/rest/config/folders/$folderId');
    final folderConfig = {
      "id": folderId,
      "path": path,
      "label": folderId,
      "type": "sendreceive",
      "rescanIntervalS": 10,
      "ignorePatterns": [
        {"pattern": "**/.DS_Store"},
      ],
    };

    final request = await HttpClient().putUrl(uri);
    request.headers.set('X-API-Key', apiKey);
    request.headers.set('Content-Type', 'application/json');
    request.add(utf8.encode(jsonEncode(folderConfig)));

    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    print('📁 Added vault folder: $body');
  }

  void stop() {
    _process?.kill();
  }
}
