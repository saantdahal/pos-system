import 'package:flutter/material.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/ui/feature/auth/presentation/widgets/number_pad.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class PinSetupConfirmStep extends StatelessWidget {
  final String confirmPin;
  final Function(String) onNumberPressed;
  final VoidCallback onDeletePressed;

  const PinSetupConfirmStep({
    super.key,
    required this.confirmPin,
    required this.onNumberPressed,
    required this.onDeletePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 20),
          // Progress Indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              4,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index == 2
                      ? AppColors.brandAccent
                      : AppColors.getSubtitleColor(
                          context,
                        ).withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          // Title
          Text(
            AppLocalizations.of(context)!.confirmYourPin,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.reenterPinToConfirm,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 60),
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
                  color: index < confirmPin.length
                      ? AppColors.brandAccent
                      : AppColors.getSubtitleColor(
                          context,
                        ).withValues(alpha: 0.3),
                  border: Border.all(
                    color: index < confirmPin.length
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
          const Spacer(),
          // Number Pad
          NumberPad(
            onNumberPressed: onNumberPressed,
            onDeletePressed: onDeletePressed,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
