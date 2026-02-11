import 'package:bhansaghar_staff/core/utils/qr_detector.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// Shows a QR scanner dialog and returns the scanned QR code value
/// Returns null if the user cancels the scan
Future<String?> showQRScanner(BuildContext context) async {
  return showDialog<String?>(
    context: context,
    builder: (context) => const _QRScannerDialog(),
  );
}

class _QRScannerDialog extends StatefulWidget {
  const _QRScannerDialog();

  @override
  State<_QRScannerDialog> createState() => _QRScannerDialogState();
}

class _QRScannerDialogState extends State<_QRScannerDialog> {
  late MobileScannerController controller;
  bool _isPickingImage = false;

  @override
  void initState() {
    super.initState();
    controller = MobileScannerController();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    setState(() => _isPickingImage = true);

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);

      if (image != null && mounted) {
        debugPrint('📷 Image selected from gallery: ${image.path}');
        final qrValue = await QRDetector.detectQRFromImage(image.path);

        if (mounted) {
          setState(() => _isPickingImage = false);

          if (qrValue != null && qrValue.isNotEmpty) {
            debugPrint('✅ QR code detected from gallery: $qrValue');
            Navigator.of(context).pop(qrValue);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No QR code found in the selected image'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        if (mounted) {
          setState(() => _isPickingImage = false);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isPickingImage = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Scan QR Code',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          // Scanner
          SizedBox(
            height: 300,
            width: double.infinity,
            child: MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final scannedValue =
                      barcodes.first.rawValue ?? barcodes.first.displayValue;
                  debugPrint('QR Code scanned: $scannedValue');
                  Navigator.of(context).pop(scannedValue);
                }
              },
            ),
          ),
          // Scan Button below camera
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.qr_code_scanner),
                onPressed: () => controller.start(),
                label: const Text('Start Scanning'),
              ),
            ),
          ),
          // Footer with instructions
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(
                  'Point your camera at a QR code',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: Icon(Icons.photo_library),
                    onPressed: _isPickingImage ? null : _pickImageFromGallery,
                    label: _isPickingImage
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Pick from Gallery'),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
