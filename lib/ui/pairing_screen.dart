import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({super.key});

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> {
  bool showMyQr = false;

  // Placeholder data (later this will be real device JSON)
  final String myQrData = '{"device":"Device A","vault":"VaultTest"}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        title: const Text('VaultSync Pairing'),
        backgroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0E0E0E), Color(0xFF1A1A1A)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Pair Your Device',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              showMyQr
                  ? 'Show this QR to your other device'
                  : 'Scan your friend’s QR code to pair',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 40),

            // 🔹 Toggle between My QR and Scanner
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              transitionBuilder:
                  (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
              child: showMyQr ? _buildMyQrView() : _buildScannerView(),
            ),

            const SizedBox(height: 50),

            // 🔹 Toggle button
            TextButton(
              onPressed: () {
                setState(() => showMyQr = !showMyQr);
              },
              child: Text(
                showMyQr ? 'Scan QR Instead' : 'Show My QR',
                style: const TextStyle(fontSize: 15, color: Colors.blueAccent),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMyQrView() {
    return Column(
      children: [
        QrImageView(data: myQrData, size: 220, backgroundColor: Colors.white),
        const SizedBox(height: 20),
        const Text(
          'Device ID: DEVICE-A-PLACEHOLDER',
          style: TextStyle(fontSize: 13, color: Colors.white70),
        ),
      ],
    );
  }

  Widget _buildScannerView() {
    return SizedBox(
      width: 250,
      height: 250,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            MobileScanner(
              controller: MobileScannerController(
                detectionSpeed: DetectionSpeed.normal,
                facing: CameraFacing.back,
              ),
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final qrValue = barcodes.first.rawValue ?? '';
                  debugPrint('✅ Scanned QR: $qrValue');
                  // TODO: parse pairing data & configure Syncthing
                }
              },
            ),
            Container(
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
