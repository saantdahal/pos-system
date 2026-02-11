import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';

class QRDetector {
  static final BarcodeScanner _barcodeScanner = BarcodeScanner();

  /// Detect QR codes from an image file using Google ML Kit
  /// Returns the first QR code value found, or null if none found
  static Future<String?> detectQRFromImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('❌ Image file does not exist: $imagePath');
        return null;
      }

      debugPrint('📷 Step 1 - Loading image from: $imagePath');

      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      debugPrint(
        '📷 Step 2 - Analysis complete, found ${barcodes.length} codes',
      );

      if (barcodes.isEmpty) {
        debugPrint('❌ No QR codes detected in image');
        return null;
      }

      final qrValue = barcodes.first.displayValue ?? barcodes.first.rawValue;
      debugPrint('✅ QR code detected: $qrValue');
      return qrValue;
    } catch (e) {
      debugPrint('❌ Error detecting QR from image: $e');
      return null;
    }
  }

  /// Detect all QR codes from an image file
  static Future<List<String>> detectAllQRFromImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (!await file.exists()) {
        debugPrint('❌ Image file does not exist: $imagePath');
        return [];
      }

      debugPrint('📷 Step 1 - Loading image from: $imagePath');

      final inputImage = InputImage.fromFilePath(imagePath);
      final barcodes = await _barcodeScanner.processImage(inputImage);

      debugPrint(
        '📷 Step 2 - Analysis complete, found ${barcodes.length} codes',
      );

      if (barcodes.isEmpty) {
        debugPrint('❌ No QR codes detected in image');
        return [];
      }

      final qrValues = barcodes
          .map((barcode) => barcode.displayValue ?? barcode.rawValue ?? '')
          .where((value) => value.isNotEmpty)
          .toList();

      debugPrint('✅ Found ${qrValues.length} QR code(s) in image: $qrValues');
      return qrValues;
    } catch (e) {
      debugPrint('❌ Error detecting QR codes from image: $e');
      return [];
    }
  }

  /// Dispose resources
  static Future<void> dispose() async {
    await _barcodeScanner.close();
  }
}
