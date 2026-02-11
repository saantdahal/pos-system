import 'package:flutter/material.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class PinSetupSuccessStep extends StatelessWidget {
  final VoidCallback onContinue;

  const PinSetupSuccessStep({super.key, required this.onContinue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
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
                  color: index == 3
                      ? AppColors.brandAccent
                      : AppColors.getSubtitleColor(
                          context,
                        ).withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          // Success Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.green.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.check_circle_outline,
              size: 60,
              color: AppColors.green,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            AppLocalizations.of(context)!.pinCreatedSuccessfully,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 32,
              fontWeight: FontWeight.bold,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 16),
          // Subtitle
          Text(
            AppLocalizations.of(context)!.pinCreatedMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const Spacer(),
          // Continue Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.continueButton,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
