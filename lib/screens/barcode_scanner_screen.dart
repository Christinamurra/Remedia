import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../providers/scan_provider.dart';
import '../theme/remedia_theme.dart';
import 'product_result_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    facing: CameraFacing.back,
    torchEnabled: false,
  );

  bool _isProcessing = false;
  bool _hasScanned = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing || _hasScanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() {
      _isProcessing = true;
      _hasScanned = true;
    });

    // Pause the scanner
    _controller.stop();

    final scanProvider = context.read<ScanProvider>();
    final product = await scanProvider.scanBarcode(barcode.rawValue!);

    if (!mounted) return;

    if (product != null) {
      // Navigate to product result screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProductResultScreen(product: product),
        ),
      );
    } else {
      // Show error and allow retry
      _showErrorDialog(scanProvider.errorMessage ?? 'Product not found');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: RemediaColors.creamBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: RemediaColors.terraCotta),
            const SizedBox(width: 12),
            Text(
              'Scan Failed',
              style: TextStyle(
                color: RemediaColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: TextStyle(color: RemediaColors.textMuted),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: RemediaColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _isProcessing = false;
                _hasScanned = false;
              });
              _controller.start();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: RemediaColors.mutedGreen,
            ),
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),

          // Overlay with scanning frame
          _buildScanOverlay(),

          // Top bar with close button
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCircleButton(
                    icon: Icons.close,
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildCircleButton(
                    icon: _controller.torchEnabled
                        ? Icons.flash_on
                        : Icons.flash_off,
                    onTap: () => _controller.toggleTorch(),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instructions
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.8),
                  ],
                ),
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_isProcessing) ...[
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          RemediaColors.mutedGreen,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Looking up product...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ] else ...[
                      const Text(
                        'Scan Barcode',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Point your camera at a product barcode',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildScanOverlay() {
    return CustomPaint(
      painter: ScanOverlayPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    // Calculate scan window dimensions
    final scanWidth = size.width * 0.75;
    final scanHeight = scanWidth * 0.6;
    final left = (size.width - scanWidth) / 2;
    final top = (size.height - scanHeight) / 2 - 50;

    // Draw dark overlay with transparent center
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(left, top, scanWidth, scanHeight),
        const Radius.circular(16),
      ))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(path, paint);

    // Draw corner brackets
    final cornerPaint = Paint()
      ..color = RemediaColors.mutedGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    const cornerLength = 30.0;
    const radius = 16.0;

    // Top-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + cornerLength)
        ..lineTo(left, top + radius)
        ..arcToPoint(
          Offset(left + radius, top),
          radius: const Radius.circular(radius),
        )
        ..lineTo(left + cornerLength, top),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanWidth - cornerLength, top)
        ..lineTo(left + scanWidth - radius, top)
        ..arcToPoint(
          Offset(left + scanWidth, top + radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(left + scanWidth, top + cornerLength),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawPath(
      Path()
        ..moveTo(left, top + scanHeight - cornerLength)
        ..lineTo(left, top + scanHeight - radius)
        ..arcToPoint(
          Offset(left + radius, top + scanHeight),
          radius: const Radius.circular(radius),
        )
        ..lineTo(left + cornerLength, top + scanHeight),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawPath(
      Path()
        ..moveTo(left + scanWidth - cornerLength, top + scanHeight)
        ..lineTo(left + scanWidth - radius, top + scanHeight)
        ..arcToPoint(
          Offset(left + scanWidth, top + scanHeight - radius),
          radius: const Radius.circular(radius),
        )
        ..lineTo(left + scanWidth, top + scanHeight - cornerLength),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
