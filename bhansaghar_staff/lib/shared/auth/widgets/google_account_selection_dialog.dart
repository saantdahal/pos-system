import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_sign_in/google_sign_in.dart';

/// Dialog to select Google account from available accounts on device
class GoogleAccountSelectionDialog extends StatefulWidget {
  final String invitationEmail;
  final List<GoogleSignInAccount> availableAccounts;

  const GoogleAccountSelectionDialog({
    super.key,
    required this.invitationEmail,
    required this.availableAccounts,
  });

  @override
  State<GoogleAccountSelectionDialog> createState() =>
      _GoogleAccountSelectionDialogState();
}

class _GoogleAccountSelectionDialogState
    extends State<GoogleAccountSelectionDialog> {
  late GoogleSignInAccount? selectedAccount;

  @override
  void initState() {
    super.initState();
    // Pre-select account that matches invitation email, if available
    selectedAccount =
        widget.availableAccounts.firstWhere(
              (account) =>
                  account.email.toLowerCase() ==
                  widget.invitationEmail.toLowerCase(),
              orElse: () => null as dynamic,
            )
            as GoogleSignInAccount?;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A2A),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      contentPadding: EdgeInsets.all(24.w),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.account_circle, color: Colors.blue, size: 40.sp),
          ),
          SizedBox(height: 20.h),

          // Title
          Text(
            'Select Google Account',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),

          // Description
          Text(
            'This invitation is for:',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[400]),
          ),
          SizedBox(height: 8.h),

          // Invitation email highlight
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.1),
              border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Text(
              widget.invitationEmail,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: Colors.green[300],
              ),
            ),
          ),
          SizedBox(height: 20.h),

          // Accounts list
          Text(
            'Available accounts:',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),

          // List of accounts
          ListView.builder(
            shrinkWrap: true,
            itemCount: widget.availableAccounts.length,
            itemBuilder: (context, index) {
              final account = widget.availableAccounts[index];
              final isSelected = selectedAccount?.email == account.email;
              final isMatchingEmail =
                  account.email.toLowerCase() ==
                  widget.invitationEmail.toLowerCase();

              return GestureDetector(
                onTap: () {
                  setState(() => selectedAccount = account);
                },
                child: Container(
                  margin: EdgeInsets.only(bottom: 8.h),
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 12.h,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.blue.withValues(alpha: 0.2)
                        : Colors.grey.withValues(alpha: 0.1),
                    border: Border.all(
                      color: isSelected
                          ? Colors.blue
                          : Colors.grey.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    children: [
                      // Radio button
                      Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey,
                            width: 2,
                          ),
                        ),
                        child: isSelected
                            ? Center(
                                child: Container(
                                  width: 10.w,
                                  height: 10.w,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.blue,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 12.w),

                      // Email and status
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              account.email,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            if (isMatchingEmail)
                              Padding(
                                padding: EdgeInsets.only(top: 4.h),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      size: 14.sp,
                                      color: Colors.green,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'Matches invitation',
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        color: Colors.green[300],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 24.h),

          // Buttons
          Row(
            children: [
              // Cancel button
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
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
                  onPressed: selectedAccount != null
                      ? () {
                          final isCorrectEmail =
                              selectedAccount!.email.toLowerCase() ==
                              widget.invitationEmail.toLowerCase();

                          if (!isCorrectEmail) {
                            // Show warning if wrong email selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Selected email (${selectedAccount!.email}) does not match the invitation email (${widget.invitationEmail})',
                                ),
                                backgroundColor: Colors.orange,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context, selectedAccount);
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.blue.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
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
