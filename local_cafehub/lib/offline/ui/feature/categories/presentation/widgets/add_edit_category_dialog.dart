import 'package:flutter/material.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import '../../data/models/category.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:uuid/uuid.dart';

class AddEditCategoryDialog extends StatefulWidget {
  final Category? category;
  final Function(Category) onSave;

  const AddEditCategoryDialog({super.key, this.category, required this.onSave});

  @override
  State<AddEditCategoryDialog> createState() => _AddEditCategoryDialogState();
}

class _AddEditCategoryDialogState extends State<AddEditCategoryDialog> {
  late TextEditingController _nameEnController;
  late TextEditingController _nameNeController;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(
      text: widget.category?.nameEn ?? '',
    );
    _nameNeController = TextEditingController(
      text: widget.category?.nameNe ?? '',
    );
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameNeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.getDialogBackground(context),
          borderRadius: BorderRadius.circular(16),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Text(
                  widget.category == null
                      ? AppLocalizations.of(context)!.addNewCategory
                      : AppLocalizations.of(context)!.editCategory,
                  style: TextStyle(
                    color: AppColors.getTextColor(context),
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Content
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.enterCategoryDescription,
                      style: TextStyle(
                        color: AppColors.getSubtitleColor(context),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // English Name Field
                    Text(
                      AppLocalizations.of(context)!.categoryNameEnglish,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameEnController,
                      style: TextStyle(color: AppColors.getTextColor(context)),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.categoryNameEnglishHint,
                        hintStyle: TextStyle(
                          color: AppColors.getSubtitleColor(context),
                        ),
                        filled: true,
                        fillColor: AppColors.getTextField(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Nepali Name Field
                    Text(
                      AppLocalizations.of(context)!.categoryNameNepali,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameNeController,
                      style: TextStyle(color: AppColors.getTextColor(context)),
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(
                          context,
                        )!.categoryNameNepaliHint,
                        hintStyle: TextStyle(
                          color: AppColors.getSubtitleColor(context),
                        ),
                        filled: true,
                        fillColor: AppColors.getTextField(context),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              // Action Buttons
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: AppColors.getSubtitleColor(
                        context,
                      ).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context),
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.cancel,
                          style: TextStyle(
                            color: AppColors.getSubtitleColor(context),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _handleSave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)!.save,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleSave() {
    if (_nameEnController.text.isEmpty || _nameNeController.text.isEmpty) {
      snackBar(
        messageType: MessageType.error,
        message: AppLocalizations.of(context)!.pleaseEnterBothLanguages,
      );
      return;
    }

    final newCategory = Category(
      id: widget.category?.id ?? const Uuid().v4(),
      nameEn: _nameEnController.text,
      nameNe: _nameNeController.text,
    );

    widget.onSave(newCategory);
    Navigator.pop(context);
  }
}
