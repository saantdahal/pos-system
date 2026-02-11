import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';

class GuidanceScreen extends StatelessWidget {
  const GuidanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.guidanceTitle,
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/settings'),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Theme.of(context).iconTheme.color,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 24),
            _buildSection(
              context,
              title: AppLocalizations.of(context)!.initialSetup,
              icon: Icons.settings_suggest,
              steps: [
                AppLocalizations.of(context)!.initialSetupStep1,
                AppLocalizations.of(context)!.initialSetupStep2,
              ],
            ),
            _buildSection(
              context,
              title: AppLocalizations.of(context)!.prepareCafe,
              icon: Icons.storefront,
              steps: [
                AppLocalizations.of(context)!.prepareCafeStep1,
                AppLocalizations.of(context)!.prepareCafeStep2,
              ],
            ),
            _buildSection(
              context,
              title: AppLocalizations.of(context)!.startServing,
              icon: Icons.wifi_tethering,
              steps: [
                AppLocalizations.of(context)!.startServingStep1,
                AppLocalizations.of(context)!.startServingStep2,
                AppLocalizations.of(context)!.startServingStep3,
                AppLocalizations.of(context)!.startServingStep4,
              ],
            ),
            _buildSection(
              context,
              title: AppLocalizations.of(context)!.customerExperience,
              icon: Icons.phone_iphone,
              steps: [
                AppLocalizations.of(context)!.customerExperienceStep1,
                AppLocalizations.of(context)!.customerExperienceStep2,
                AppLocalizations.of(context)!.customerExperienceStep3,
                AppLocalizations.of(context)!.customerExperienceStep4,
              ],
            ),
            _buildSection(
              context,
              title: AppLocalizations.of(context)!.orderManagement,
              icon: Icons.manage_accounts,
              steps: [
                AppLocalizations.of(context)!.orderManagementStep1,
                AppLocalizations.of(context)!.orderManagementStep2,
              ],
            ),
            const SizedBox(height: 24),
            _buildSupportSection(context),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.blue, AppColors.blue.withValues(alpha: 0.7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.tips_and_updates, color: Colors.white, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.welcomeTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.welcomeSubtitle,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<String> steps,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: AppColors.blue, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: steps
                  .map(
                    (step) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Icon(
                              Icons.circle,
                              size: 6,
                              color: AppColors.getSubtitleColor(context),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              step,
                              style: TextStyle(
                                color: AppColors.getSubtitleColor(context),
                                fontSize: 14,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupportSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.orange.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.support_agent, color: AppColors.orange),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.needHelp,
                style: TextStyle(
                  color: AppColors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            AppLocalizations.of(context)!.contactSupport,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            'NNine Solution',
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontWeight: FontWeight.bold,
            ),
          ),
          SelectableText(
            'nninesolutions@gmail.com',
            style: TextStyle(
              color: AppColors.blue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
