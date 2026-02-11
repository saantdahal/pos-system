import 'package:flutter/material.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class PinSetupWelcomeStep extends StatelessWidget {
  final VoidCallback onGetStarted;

  const PinSetupWelcomeStep({super.key, required this.onGetStarted});

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
                  color: index == 0
                      ? AppColors.brandAccent
                      : AppColors.getSubtitleColor(
                          context,
                        ).withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          const SizedBox(height: 60),
          // Lock Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandAccent.withValues(alpha: 0.2),
            ),
            child: const Icon(
              Icons.lock_outline,
              size: 60,
              color: AppColors.brandAccent,
            ),
          ),
          const SizedBox(height: 40),
          // Title
          Text(
            AppLocalizations.of(context)!.letsSecureYourAccount,
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
            AppLocalizations.of(context)!.pinSetupWelcomeMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 16,
              height: 1.5,
            ),
          ),
          const Spacer(),
          // Get Started Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onGetStarted,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                AppLocalizations.of(context)!.getStarted,
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
