import 'package:bhansaghar_staff/core/repositories/auth_repository.dart';
import 'package:bhansaghar_staff/core/routes/qr_scanner.dart';
import 'package:bhansaghar_staff/core/utils/qr_parser.dart';
import 'package:bhansaghar_staff/shared/auth/widgets/qr_invitation_confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class QRScanButton extends StatefulWidget {
  final bool isLoading;
  final Function(String)? onQRScanned;

  const QRScanButton({super.key, this.isLoading = false, this.onQRScanned});

  @override
  State<QRScanButton> createState() => _QRScanButtonState();
}

class _QRScanButtonState extends State<QRScanButton> {
  bool _isLoadingInvitation = false;

  Future<void> _handleQRScanned(String qrValue) async {
    // Extract the actual invite ID from the QR code value
    final inviteId = QRParser.extractInviteId(qrValue);

    debugPrint('📱 QR scanned successfully, qrValue: $qrValue');
    debugPrint('📱 Extracted inviteId: $inviteId');

    if (widget.onQRScanned != null) {
      debugPrint('🔄 Calling custom onQRScanned callback');
      widget.onQRScanned!(inviteId);
      return;
    }

    // Default behavior: show confirmation dialog with invitation details
    setState(() => _isLoadingInvitation = true);

    try {
      final authRepository = context.read<AuthRepository>();
      final invitationEmail = await authRepository.getInvitationEmail(
        inviteId: inviteId,
      );

      if (!context.mounted) return;
      setState(() => _isLoadingInvitation = false);

      if (invitationEmail != null && invitationEmail.isNotEmpty) {
        debugPrint(
          '📧 Showing confirmation for invitation email: $invitationEmail',
        );
        if (!mounted) return;
        // Show confirmation dialog with the invitation email
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => QRInvitationConfirmationDialog(
            inviteId: inviteId,
            invitationEmail: invitationEmail,
            isLoading: widget.isLoading,
          ),
        );
      } else {
        if (!mounted) return;
        // Could not get email - show error and let user proceed anyway
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not verify invitation details. Please try again.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      setState(() => _isLoadingInvitation = false);

      debugPrint('❌ Error fetching invitation: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: OutlinedButton(
        onPressed: (widget.isLoading || _isLoadingInvitation)
            ? null
            : () async {
                final inviteId = await showQRScanner(context);
                if (inviteId != null) {
                  await _handleQRScanned(inviteId);
                } else {
                  debugPrint('❌ QR scan returned null');
                }
              },
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 1.5,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: _isLoadingInvitation
            ? SizedBox(
                height: 24.h,
                width: 24.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_scanner,
                    size: 20.sp,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'Scan QR Invite',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
