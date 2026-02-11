import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_bloc.dart';
import 'package:bhansa_ghar/offline/server/bloc/server_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/qr/presentation/bloc/qr_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/qr/presentation/bloc/qr_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/qr/presentation/bloc/qr_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/qr/presentation/widgets/qr_card.dart';
import 'package:bhansa_ghar/offline/ui/feature/qr/presentation/widgets/wifi_qr_dialog.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

class QrScreen extends StatefulWidget {
  const QrScreen({super.key});

  @override
  State<QrScreen> createState() => _QrScreenState();
}

class _QrScreenState extends State<QrScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/'),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
        title: Text(
          AppLocalizations.of(context)!.generateQrCodes,
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<QrBloc, QrState>(
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 20),
                // WiFi QR Section
                QrCard(
                  title: AppLocalizations.of(context)!.cafeGuestWifi,
                  subtitle: AppLocalizations.of(
                    context,
                  )!.connectCustomersToInternet,
                  qrData: state.qrType == QrType.wifi ? state.qrData : null,
                  backgroundColor: const Color(0xFF4A5568),
                  onGenerate: () => _showWifiDialog(context),
                  onSave: state.qrType == QrType.wifi && state.qrData != null
                      ? () => _saveQrCode(context, state.qrData!, 'WiFi_QR')
                      : null,
                  onShare: state.qrType == QrType.wifi && state.qrData != null
                      ? () => _shareQrCode(context, state.qrData!, 'WiFi_QR')
                      : null,
                ),
                // Generate WiFi QR Button
                if (state.qrType != QrType.wifi || state.qrData == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showWifiDialog(context),
                        icon: const Icon(Icons.wifi, size: 20),
                        label: Text(
                          AppLocalizations.of(context)!.generateWifiQr,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
                // Digital Menu QR Section
                QrCard(
                  title: AppLocalizations.of(context)!.digitalMenu,
                  subtitle: AppLocalizations.of(context)!.linkCustomersToMenu,
                  qrData: state.qrType == QrType.menu ? state.qrData : null,
                  backgroundColor: const Color(0xFF5A7A7C),
                  onSave: state.qrType == QrType.menu && state.qrData != null
                      ? () => _saveQrCode(context, state.qrData!, 'Menu_QR')
                      : null,
                  onShare: state.qrType == QrType.menu && state.qrData != null
                      ? () => _shareQrCode(context, state.qrData!, 'Menu_QR')
                      : null,
                ),
                // Generate Menu QR Button
                if (state.qrType != QrType.menu || state.qrData == null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _generateMenuQr(context),
                        icon: const Icon(Icons.restaurant_menu, size: 20),
                        label: Text(
                          AppLocalizations.of(context)!.generateMenuQr,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5A7A7C),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // iOS Safari Workaround Instructions
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.orange.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              color: Colors.orange,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              AppLocalizations.of(context)!.foriPhoneiPadUsers,
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.sslErrorInstructions,
                          style: TextStyle(
                            color: AppColors.getTextColor(context),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 8),
                        BlocBuilder<QrBloc, QrState>(
                          builder: (context, qrState) {
                            // Show the URL if a Menu QR code has been generated
                            if (qrState.qrType == QrType.menu &&
                                qrState.qrData != null &&
                                qrState.qrData!.isNotEmpty) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppColors.getCardBackground(context),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppColors.getSubtitleColor(
                                      context,
                                    ).withValues(alpha: 0.3),
                                  ),
                                ),
                                child: SelectableText(
                                  qrState.qrData!,
                                  style: TextStyle(
                                    color: Colors.blue,
                                    fontSize: 14,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              );
                            }
                            return Text(
                              AppLocalizations.of(context)!.generateMenuQrFirst,
                              style: TextStyle(
                                color: AppColors.getSubtitleColor(context),
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showWifiDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return WifiQrDialog(
          onGenerate: (ssid, password) {
            context.read<QrBloc>().add(
              GenerateWifiQr(ssid: ssid, password: password),
            );
          },
        );
      },
    );
  }

  void _generateMenuQr(BuildContext context) {
    final serverState = context.read<ServerBloc>().state;

    // Check if server is running and has IP/port
    if (serverState.status == ServerStatus.running &&
        serverState.ip != null &&
        serverState.port != null) {
      final menuUrl = 'http://${serverState.ip}:${serverState.port}';
      context.read<QrBloc>().add(GenerateMenuQr(menuUrl));
    } else {
      // Show error message if server is not running
      snackBar(
        message: AppLocalizations.of(context)!.pleaseStartServerFirst,
        messageType: MessageType.error,
      );
    }
  }

  Future<void> _saveQrCode(
    BuildContext context,
    String qrData,
    String fileName,
  ) async {
    try {
      // Generate QR code image
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          gapless: true,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(0xFF000000),
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(0xFF000000),
          ),
        );

        // Convert to image
        final picData = await painter.toImageData(
          400,
          format: ui.ImageByteFormat.png,
        );

        if (picData == null) {
          throw Exception('Failed to generate QR code image');
        }

        // Get directory to save
        final directory = await getApplicationDocumentsDirectory();
        final filePath = '${directory.path}/$fileName.png';
        final file = File(filePath);

        // Write to file
        await file.writeAsBytes(picData.buffer.asUint8List());

        if (context.mounted) {
          snackBar(
            message: '${AppLocalizations.of(context)!.qrCodeSavedTo} $filePath',
            messageType: MessageType.success,
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        snackBar(
          message: '${AppLocalizations.of(context)!.errorSavingQrCode} $e',
          messageType: MessageType.error,
        );
      }
    }
  }

  Future<void> _shareQrCode(
    BuildContext context,
    String qrData,
    String fileName,
  ) async {
    try {
      // Generate QR code image
      final qrValidationResult = QrValidator.validate(
        data: qrData,
        version: QrVersions.auto,
        errorCorrectionLevel: QrErrorCorrectLevel.L,
      );

      if (qrValidationResult.status == QrValidationStatus.valid) {
        final qrCode = qrValidationResult.qrCode!;
        final painter = QrPainter.withQr(
          qr: qrCode,
          gapless: true,
          eyeStyle: const QrEyeStyle(
            eyeShape: QrEyeShape.square,
            color: Color(0xFF000000),
          ),
          dataModuleStyle: const QrDataModuleStyle(
            dataModuleShape: QrDataModuleShape.square,
            color: Color(0xFF000000),
          ),
        );

        // Convert to image
        final picData = await painter.toImageData(
          400,
          format: ui.ImageByteFormat.png,
        );

        if (picData == null) {
          throw Exception('Failed to generate QR code image');
        }

        // Get temporary directory
        final directory = await getTemporaryDirectory();
        final filePath = '${directory.path}/$fileName.png';
        final file = File(filePath);

        // Write to file
        await file.writeAsBytes(picData.buffer.asUint8List());

        // Share the file
        await SharePlus.instance.share(
          ShareParams(files: [XFile(filePath)], subject: 'Scan this QR code'),
        );
      }
    } catch (e) {
      if (context.mounted) {
        snackBar(
          message: '${AppLocalizations.of(context)!.errorSharingQrCode} $e',
          messageType: MessageType.error,
        );
      }
    }
  }
}
