import 'package:flutter/material.dart';
import '../../../../../core/theme.dart';
import '../../../../../core/l10n/app_localizations.dart';

class ExportOptionsDialog extends StatelessWidget {
  final String filePath;
  final int categoriesCount;
  final int menuItemsCount;
  final VoidCallback onSave;
  final VoidCallback onShare;

  const ExportOptionsDialog({
    super.key,
    required this.filePath,
    required this.categoriesCount,
    required this.menuItemsCount,
    required this.onSave,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getDialogBackground(context),
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Success Icon
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 48,
              ),
            ),
            const SizedBox(height: 20),

            // Title
            Text(
              AppLocalizations.of(context)!.exportSuccessTitle,
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Export Summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.getCardBackground(context),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildSummaryRow(
                    context,
                    Icons.category_outlined,
                    AppLocalizations.of(context)!.categories,
                    categoriesCount.toString(),
                  ),
                  const SizedBox(height: 12),
                  Divider(
                    color: AppColors.getSubtitleColor(
                      context,
                    ).withValues(alpha: 0.2),
                    height: 1,
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    context,
                    Icons.restaurant_menu,
                    AppLocalizations.of(context)!.menuItems,
                    menuItemsCount.toString(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // File Path Info
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.blue.withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.folder_outlined,
                    color: AppColors.blue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      filePath,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onSave();
                    },
                    icon: const Icon(Icons.save_alt, size: 20),
                    label: Text(AppLocalizations.of(context)!.saved),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.green,
                      side: const BorderSide(color: Colors.green),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      onShare();
                    },
                    icon: const Icon(Icons.share, size: 20),
                    label: Text(AppLocalizations.of(context)!.share),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    IconData icon,
    String label,
    String count,
  ) {
    return Row(
      children: [
        Icon(icon, color: AppColors.blue, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 15,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.blue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count,
            style: const TextStyle(
              color: AppColors.blue,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
