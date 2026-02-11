import 'dart:io';
import 'package:flutter/material.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/data/menu_item.dart';

class MenuCard extends StatelessWidget {
  final MenuItem item;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const MenuCard({
    super.key,
    required this.item,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppColors.getSubtitleColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.getSubtitleColor(context),
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: _buildImage(),
                  )
                : Icon(Icons.restaurant, color: AppColors.blue, size: 28),
          ),
          const SizedBox(width: 16),
          // Title and Price
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.getLocalizedName(
                    Localizations.localeOf(context).languageCode,
                  ),
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Rs ${item.price.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.getSubtitleColor(context),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          // Edit and Delete Icons
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.blue,
              size: 20,
            ),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 12),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.red,
              size: 20,
            ),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    // Check if it's an asset path or file path
    if (item.imageUrl.startsWith('assets/')) {
      return Image.asset(
        item.imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.restaurant, color: AppColors.blue, size: 28);
        },
      );
    } else {
      // It's a file path
      return Image.file(
        File(item.imageUrl),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Icon(Icons.restaurant, color: AppColors.blue, size: 28);
        },
      );
    }
  }
}
