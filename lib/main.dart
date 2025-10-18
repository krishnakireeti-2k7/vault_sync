import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'services/syncthing_service.dart';
import 'ui/pairing_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const apiKey = 'TdiN4q3yZUix7KMHYYfRGAMnttfarWDF';

  // 🔹 Get app document directory (safe on Android/iOS)
  final appDocDir = await getApplicationDocumentsDirectory();
  final homeDir = Directory('${appDocDir.path}/.syncthing');
  homeDir.createSync(recursive: true);

  final vaultDir = Directory('${appDocDir.path}/VaultTest');
  vaultDir.createSync(recursive: true);

  // 🔹 Android Syncthing binary path (update this if needed)
  final binaryPath = '${Directory.current.path}/runtimes/android/syncthing';

  final syncthing = SyncthingService(
    apiKey: apiKey,
    binaryPath: binaryPath,
    homeDir: homeDir.path,
    baseUrl: 'http://127.0.0.1:8384',
  );

  try {
    await syncthing.start();
    await syncthing.ping();
    await syncthing.printDeviceInfo();
    await syncthing.addVaultFolder('vault-main', vaultDir.path);

    print('✅ Vault folder ready for syncing: ${vaultDir.path}');
  } catch (e) {
    print('❌ Error starting Syncthing: $e');
  }

  runApp(VaultSyncApp(vaultPath: vaultDir.path));
}

class VaultSyncApp extends StatelessWidget {
  final String vaultPath;
  const VaultSyncApp({super.key, required this.vaultPath});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VaultSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0A0A),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          centerTitle: true,
        ),
      ),
      home: PairingScreenWrapper(vaultPath: vaultPath),
    );
  }
}

/// Wrapper so we can pass vaultPath to the PairingScreen
class PairingScreenWrapper extends StatelessWidget {
  final String vaultPath;
  const PairingScreenWrapper({super.key, required this.vaultPath});

  @override
  Widget build(BuildContext context) {
    return PairingScreen();
  }
}
