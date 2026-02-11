import 'package:flutter/material.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';

class PinEntryWidget extends StatelessWidget {
  final String pin;
  final ValueChanged<String> onNumberPressed;
  final VoidCallback onDeletePressed;
  final String title;
  final String subtitle;
  final String? errorMessage;
  final bool showBiometric;
  final VoidCallback? onBiometricPressed;

  const PinEntryWidget({
    super.key,
    required this.pin,
    required this.onNumberPressed,
    required this.onDeletePressed,
    this.title = 'Enter PIN',
    this.subtitle = 'Please enter your 4-digit PIN',
    this.errorMessage,
    this.showBiometric = false,
    this.onBiometricPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 40),
        // Logo or Icon
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.brandAccent.withValues(alpha: 0.2),
          ),
          child: const Icon(
            Icons.lock_outline,
            size: 40,
            color: AppColors.brandAccent,
          ),
        ),
        const SizedBox(height: 24),
        // Welcome Text
        Text(
          title,
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.getSubtitleColor(context),
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 40),
        // PIN Dots
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            4,
            (index) => Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: index < pin.length
                    ? AppColors.brandAccent
                    : AppColors.getSubtitleColor(
                        context,
                      ).withValues(alpha: 0.3),
                border: Border.all(
                  color: index < pin.length
                      ? AppColors.brandAccent
                      : AppColors.getSubtitleColor(
                          context,
                        ).withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Error Message
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          height: errorMessage != null ? 24 : 0,
          child: errorMessage != null
              ? Text(
                  errorMessage!,
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                )
              : const SizedBox.shrink(),
        ),
        const SizedBox(height: 40),
        // Number Pad
        _buildNumberPad(context),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildNumberPad(BuildContext context) {
    return Column(
      children: [
        // Row 1-3
        for (int row = 0; row < 3; row++)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (int col = 1; col <= 3; col++)
                  _buildNumberButton(context, (row * 3 + col).toString()),
              ],
            ),
          ),
        // Row 0 and Delete
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (showBiometric && onBiometricPressed != null)
              GestureDetector(
                onTap: onBiometricPressed,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.transparent,
                  ),
                  child: Icon(
                    Icons.fingerprint,
                    size: 32,
                    color: AppColors.brandAccent,
                  ),
                ),
              )
            else
              const SizedBox(width: 70, height: 70), // Empty space
            _buildNumberButton(context, '0'),
            _buildDeleteButton(context),
          ],
        ),
      ],
    );
  }

  Widget _buildNumberButton(BuildContext context, String number) {
    return GestureDetector(
      onTap: () => onNumberPressed(number),
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.getCardBackground(context),
          border: Border.all(
            color: AppColors.getSubtitleColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            number,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteButton(BuildContext context) {
    return GestureDetector(
      onTap: onDeletePressed,
      child: Container(
        width: 70,
        height: 70,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.getCardBackground(context),
          border: Border.all(
            color: AppColors.getSubtitleColor(context).withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Center(
          child: Icon(Icons.backspace_outlined, color: AppColors.red, size: 24),
        ),
      ),
    );
  }
}
