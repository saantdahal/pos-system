import 'dart:io';
import 'package:bhansa_ghar/online/ui/feature/profile/bloc/profile_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:bhansa_ghar/online/core/models/profile/user_profile.dart';
import 'package:bhansa_ghar/online/core/models/profile/profile_update_request.dart';
import 'package:bhansa_ghar/online/core/models/profile/email_update_request.dart';
import 'package:bhansa_ghar/online/core/services/image_picker_service.dart';

class ProfileForm extends StatefulWidget {
  final UserProfile profile;

  const ProfileForm({super.key, required this.profile});

  @override
  State<ProfileForm> createState() => _ProfileFormState();
}

class _ProfileFormState extends State<ProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _usernameController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _emailController;
  late TextEditingController _newEmailController;
  late TextEditingController _otpController;

  bool _isEmailUpdateMode = false;
  bool _isOtpVerificationMode = false;

  // Image state
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _usernameController = TextEditingController(text: widget.profile.username);
    _phoneController = TextEditingController(text: widget.profile.phone);
    _addressController = TextEditingController(text: widget.profile.address);
    _emailController = TextEditingController(text: widget.profile.email);
    _newEmailController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emailController.dispose();
    _newEmailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedPath = await ImagePickerService.pickImage(context);
    if (pickedPath != null) {
      setState(() {
        _profileImagePath = pickedPath;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture Section
          Center(
            child: GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  _profileImagePath != null
                      ? Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: FileImage(File(_profileImagePath!)),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : widget.profile.avatar != null &&
                            widget.profile.avatar!.isNotEmpty
                      ? Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            image: DecorationImage(
                              image: NetworkImage(widget.profile.avatar!),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      : Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary,
                                theme.colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _getInitials(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 36.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 20.r,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 32.h),

          // Basic Information Section
          Text(
            'Basic Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Username Field
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              hintText: 'Enter your username',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: Icon(Icons.person, size: 20.r),
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Username is required';
              }
              if (value.length < 3) {
                return 'Username must be at least 3 characters';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Phone Field
          TextFormField(
            controller: _phoneController,
            decoration: InputDecoration(
              labelText: 'Phone Number *',
              hintText: 'Enter your phone number',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: Icon(Icons.phone, size: 20.r),
            ),
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your phone number';
              }
              // Basic phone number validation
              final phoneRegex = RegExp(r'^\+?[0-9]{10,15}$');
              if (!phoneRegex.hasMatch(value.replaceAll(RegExp(r'\s+'), ''))) {
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          SizedBox(height: 16.h),

          // Address Field (Simple Text)
          TextFormField(
            controller: _addressController,
            decoration: InputDecoration(
              labelText: 'Address',
              hintText: 'Enter your address (optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              prefixIcon: Icon(Icons.location_on, size: 20.r),
            ),
            keyboardType: TextInputType.streetAddress,
          ),
          SizedBox(height: 32.h),

          // Email Section
          Text(
            'Email Information',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),

          // Current Email Display
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.email, color: theme.colorScheme.primary, size: 20.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Email',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(
                            alpha: 0.6,
                          ),
                        ),
                      ),
                      Text(
                        widget.profile.email,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
                if (widget.profile.isEmailVerified == true)
                  Icon(Icons.verified, color: Colors.green, size: 20.r),
              ],
            ),
          ),
          SizedBox(height: 16.h),

          // Email Update Section
          if (_isOtpVerificationMode) ...[
            TextFormField(
              controller: _otpController,
              decoration: InputDecoration(
                labelText: 'Verification Code',
                hintText: 'Enter 6-digit code',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: Icon(Icons.lock, size: 20.r),
              ),
              keyboardType: TextInputType.number,
              maxLength: 6,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Verification code is required';
                }
                if (value.length != 6) {
                  return 'Code must be 6 digits';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _verifyEmailUpdate,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text('Verify Email'),
                  ),
                ),
                SizedBox(width: 12.w),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isOtpVerificationMode = false;
                      _isEmailUpdateMode = false;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ] else if (_isEmailUpdateMode) ...[
            TextFormField(
              controller: _newEmailController,
              decoration: InputDecoration(
                labelText: 'New Email Address',
                hintText: 'Enter new email address',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                prefixIcon: Icon(Icons.email_outlined, size: 20.r),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Email is required';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value)) {
                  return 'Enter a valid email address';
                }
                if (value == widget.profile.email) {
                  return 'New email must be different from current email';
                }
                return null;
              },
            ),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _requestEmailUpdate,
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: const Text('Send Verification Code'),
                  ),
                ),
                SizedBox(width: 12.w),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEmailUpdateMode = false;
                    });
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ] else ...[
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _isEmailUpdateMode = true;
                });
              },
              icon: Icon(Icons.edit, size: 20.r),
              label: const Text('Change Email'),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 24.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ],

          SizedBox(height: 32.h),

          // Save Button
          if (!_isEmailUpdateMode && !_isOtpVerificationMode) ...[
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Text(
                  'Save Changes',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getInitials() {
    if (widget.profile.username.isNotEmpty) {
      final parts = widget.profile.username.split(' ');
      if (parts.length >= 2) {
        return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      }
      return widget.profile.username[0].toUpperCase();
    }
    return 'U';
  }

  void _saveProfile() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = ProfileUpdateRequest(
        username: _usernameController.text.trim(),
        phone: _phoneController.text.trim(),
        address: _addressController.text.trim().isEmpty
            ? null
            : _addressController.text.trim(),
      );

      context.read<ProfileBloc>().add(
        UpdateProfileEvent(request: request, imagePath: _profileImagePath),
      );
    }
  }

  void _requestEmailUpdate() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = EmailUpdateRequest(
        newEmail: _newEmailController.text.trim(),
      );
      context.read<ProfileBloc>().add(
        RequestEmailUpdateEvent(request: request),
      );

      setState(() {
        _isOtpVerificationMode = true;
        _isEmailUpdateMode = false;
      });
    }
  }

  void _verifyEmailUpdate() {
    if (_formKey.currentState?.validate() ?? false) {
      final request = EmailVerifyRequest(otp: _otpController.text.trim());
      context.read<ProfileBloc>().add(VerifyEmailUpdateEvent(request: request));
    }
  }
}
