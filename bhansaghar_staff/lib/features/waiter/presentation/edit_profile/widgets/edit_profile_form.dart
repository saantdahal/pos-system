import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../bloc/edit_profile_bloc.dart';

class WaiterEditProfileForm extends StatefulWidget {
  const WaiterEditProfileForm({super.key});

  @override
  State<WaiterEditProfileForm> createState() => _WaiterEditProfileFormState();
}

class _WaiterEditProfileFormState extends State<WaiterEditProfileForm> {
  late TextEditingController _firstNameController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _newEmailController;
  late TextEditingController _otpController;

  File? _selectedImage;
  bool _showOtpVerification = false;
  String? _pendingEmail;

  @override
  void initState() {
    super.initState();
    final state = context.read<WaiterEditProfileBloc>().state;
    if (state is WaiterEditProfileLoaded) {
      final profile = state.profile;
      _firstNameController = TextEditingController(
        text: profile.firstName ?? '',
      );
      _emailController = TextEditingController(text: profile.email);
      _locationController = TextEditingController(text: profile.location);
      _phoneController = TextEditingController(text: profile.phone ?? '');
      _addressController = TextEditingController(text: profile.address ?? '');
    } else {
      _firstNameController = TextEditingController();
      _emailController = TextEditingController();
      _locationController = TextEditingController();
      _phoneController = TextEditingController();
      _addressController = TextEditingController();
    }
    _newEmailController = TextEditingController();
    _otpController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _newEmailController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  void _requestEmailUpdate() {
    final newEmail = _newEmailController.text.trim();
    if (newEmail.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter a new email')));
      return;
    }
    if (!newEmail.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    context.read<WaiterEditProfileBloc>().add(
      RequestEmailUpdateEvent(newEmail: newEmail),
    );
    _pendingEmail = newEmail;
  }

  void _verifyEmailUpdate() {
    final otp = _otpController.text.trim();
    if (otp.isEmpty || otp.length != 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 6-digit OTP')),
      );
      return;
    }

    context.read<WaiterEditProfileBloc>().add(VerifyEmailUpdateEvent(otp: otp));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WaiterEditProfileBloc, WaiterEditProfileState>(
      listener: (context, state) {
        if (state is WaiterEmailUpdateRequested) {
          setState(() {
            _showOtpVerification = true;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        } else if (state is WaiterEmailUpdateVerified) {
          setState(() {
            _showOtpVerification = false;
            _otpController.clear();
            _newEmailController.clear();
            _emailController.text = state.profile.email;
          });
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      child: BlocBuilder<WaiterEditProfileBloc, WaiterEditProfileState>(
        builder: (context, state) {
          final isUpdating = state is WaiterEditProfileUpdating;
          final isVerifying = state is WaiterEmailUpdateVerifying;

          return SingleChildScrollView(
            padding: EdgeInsets.all(20.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar Section
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 120.w,
                        height: 120.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF22C55E),
                            width: 3,
                          ),
                          color: Colors.grey[200],
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(120.w),
                                child: Image.file(
                                  _selectedImage!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : (state is WaiterEditProfileLoaded &&
                                      state.profile.profileImageUrl != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                        120.w,
                                      ),
                                      child: Image.network(
                                        state.profile.profileImageUrl!,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, _, _) => Icon(
                                          Icons.person,
                                          size: 60.w,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                  : Icon(
                                      Icons.person,
                                      size: 60.w,
                                      color: Colors.grey,
                                    )),
                      ),
                      SizedBox(height: 12.h),
                      ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Change Avatar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF22C55E),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30.h),

                // First Name Field
                Text(
                  'First Name',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _firstNameController,
                  enabled: !isUpdating,
                  decoration: InputDecoration(
                    hintText: 'Enter first name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Phone Field
                Text(
                  'Phone',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _phoneController,
                  enabled: !isUpdating,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    hintText: 'Enter phone number',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),

                // Address Field
                Text(
                  'Address',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _addressController,
                  enabled: !isUpdating,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Enter address',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                  ),
                ),
                SizedBox(height: 30.h),

                // Update Button
                SizedBox(
                  width: double.infinity,
                  height: 48.h,
                  child: ElevatedButton(
                    onPressed: isUpdating
                        ? null
                        : () {
                            context.read<WaiterEditProfileBloc>().add(
                              UpdateWaiterProfileEvent(
                                firstName: _firstNameController.text.trim(),
                                phone: _phoneController.text.trim(),
                                address: _addressController.text.trim(),
                                avatarPath: _selectedImage?.path,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: isUpdating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Update Profile'),
                  ),
                ),
                SizedBox(height: 30.h),

                // Email Change Section
                Divider(height: 30.h),
                SizedBox(height: 20.h),
                Text(
                  'Change Email',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),

                // Current Email (Read-only)
                Text(
                  'Current Email',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: _emailController,
                  enabled: false,
                  decoration: InputDecoration(
                    hintText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    filled: true,
                    fillColor: Colors.grey[200],
                  ),
                ),
                SizedBox(height: 20.h),

                // Email Change Form
                if (!_showOtpVerification)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Email',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _newEmailController,
                        keyboardType: TextInputType.emailAddress,
                        enabled: !isUpdating && !isVerifying,
                        decoration: InputDecoration(
                          hintText: 'Enter new email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: (isUpdating || isVerifying)
                              ? null
                              : _requestEmailUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: const Text('Send Verification Code'),
                        ),
                      ),
                    ],
                  ),

                // OTP Verification Form
                if (_showOtpVerification)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16.r),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(color: Colors.blue[200]!),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Verification Code Sent',
                              style: Theme.of(context).textTheme.bodyMedium
                                  ?.copyWith(fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'A verification code has been sent to $_pendingEmail. Please enter it below.',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Enter OTP',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _otpController,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        enabled: !isVerifying,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 24.sp, letterSpacing: 2),
                        decoration: InputDecoration(
                          hintText: '000000',
                          hintStyle: TextStyle(fontSize: 24.sp),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 12.h,
                          ),
                          counterText: '',
                        ),
                      ),
                      SizedBox(height: 16.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: ElevatedButton(
                          onPressed: isVerifying ? null : _verifyEmailUpdate,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF22C55E),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: isVerifying
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text('Verify Email'),
                        ),
                      ),
                      SizedBox(height: 12.h),
                      SizedBox(
                        width: double.infinity,
                        height: 48.h,
                        child: OutlinedButton(
                          onPressed: isVerifying
                              ? null
                              : () {
                                  setState(() {
                                    _showOtpVerification = false;
                                    _otpController.clear();
                                    _newEmailController.clear();
                                  });
                                },
                          child: const Text('Cancel'),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
