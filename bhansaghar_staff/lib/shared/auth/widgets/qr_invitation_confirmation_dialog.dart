import 'package:bhansaghar_staff/shared/auth/bloc/auth_bloc.dart';
import 'package:bhansaghar_staff/shared/auth/widgets/google_account_selection_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Dialog shown after QR scan
/// Displays the invitation email and asks user to confirm they'll sign in with that email
class QRInvitationConfirmationDialog extends StatelessWidget {
  final String inviteId;
  final String invitationEmail;
  final bool isLoading;

  const QRInvitationConfirmationDialog({
    super.key,
    required this.inviteId,
    required this.invitationEmail,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(24.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Icon
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_circle, color: Colors.green, size: 40.sp),
          ),
          SizedBox(height: 20.h),

          // Title
          Text(
            'QR Code Found',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 12.h),

          // Description
          Text(
            'This QR invitation is for:',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),

          // Email display (highlight)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              invitationEmail,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: Colors.blue[300],
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),

          // Important note
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.1),
              border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, color: Colors.orange, size: 18.sp),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    'You must sign in with this email to claim the invitation',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.orange[300],
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 24.h),

          // Buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton(
                  onPressed: isLoading ? null : () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[600]!, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[300],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),

              // Continue button
              Expanded(
                child: ElevatedButton(
                  onPressed: isLoading
                      ? null
                      : () async {
                          // Trigger Google login with QR
                          debugPrint(
                            '🚀 User confirmed. Proceeding with account selection for: $invitationEmail',
                          );

                          // Store context and bloc reference BEFORE popping dialog
                          final bloc = context.read<AuthBloc>();
                          final authRepo = bloc.authRepository;

                          // Pop dialog first to avoid context issues
                          Navigator.pop(context);

                          // Use Future.delayed to ensure dialog is fully closed
                          Future.delayed(const Duration(milliseconds: 300), () async {
                            try {
                              // Get available Google accounts
                              final availableAccounts = await authRepo
                                  .getAvailableGoogleAccounts();

                              debugPrint(
                                '📱 Available accounts: ${availableAccounts.map((a) => a.email).toList()}',
                              );

                              GoogleSignInAccount? selectedAccount;

                              if (availableAccounts.isEmpty) {
                                // No accounts available, proceed with normal sign-in
                                debugPrint(
                                  'ℹ️ No available accounts, showing Google Sign-In',
                                );
                                selectedAccount = await GoogleSignIn().signIn();
                              } else {
                                // Always show selection dialog - user should choose
                                // even if there's only one account
                                debugPrint(
                                  '👥 Showing account selection dialog (${availableAccounts.length} account(s) available)',
                                );
                                if (!context.mounted) return;
                                selectedAccount =
                                    await showDialog<GoogleSignInAccount>(
                                      context: context,
                                      barrierDismissible: false,
                                      builder: (context) =>
                                          GoogleAccountSelectionDialog(
                                            invitationEmail: invitationEmail,
                                            availableAccounts:
                                                availableAccounts,
                                          ),
                                    );
                              }

                              if (selectedAccount != null) {
                                debugPrint(
                                  '✅ Account selected: ${selectedAccount.email}, dispatching AuthGoogleLoginFromQRWithAccount event',
                                );
                                debugPrint(
                                  '📋 Event details - inviteId: $inviteId, account email: ${selectedAccount.email}',
                                );
                                // Dispatch the QR claim event with the invite ID
                                bloc.add(
                                  AuthGoogleLoginFromQRWithAccount(
                                    inviteId,
                                    selectedAccount,
                                  ),
                                );
                                debugPrint('✅ Event dispatched successfully');
                              } else {
                                debugPrint('❌ No account selected by user');
                              }
                            } catch (e) {
                              debugPrint(
                                '❌ Error during account selection: $e',
                              );
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Error: $e'),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          });
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.blue.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : Text(
                          'Continue',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
