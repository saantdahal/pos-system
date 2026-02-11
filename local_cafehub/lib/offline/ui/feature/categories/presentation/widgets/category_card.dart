import 'package:flutter/material.dart';
import '../../data/models/category.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';

class CategoryCard extends StatelessWidget {
  final Category category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const CategoryCard({
    super.key,
    required this.category,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.getCardBackground(context),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.getSubtitleColor(context).withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.orange.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.fastfood, color: AppColors.orange, size: 20),
          ),

          const SizedBox(width: 16),
          // Category Name
          Expanded(
            child: Text(
              category.getLocalizedName(
                Localizations.localeOf(context).languageCode,
              ),
              style: TextStyle(
                color: AppColors.getTextColor(context),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Edit Button
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).iconTheme.color,
              size: 20,
            ),
            onPressed: onEdit,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 16),
          // Delete Button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
            onPressed: onDelete,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}
