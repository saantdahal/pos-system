import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/data/menu_item.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/bloc/category_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/bloc/category_state.dart';
import 'package:uuid/uuid.dart';
import 'package:bhansa_ghar/offline/core/utils/image_compressor.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class AddEditMenuDialog extends StatefulWidget {
  final MenuItem? item;
  final Function(MenuItem) onSave;

  const AddEditMenuDialog({super.key, this.item, required this.onSave});

  @override
  State<AddEditMenuDialog> createState() => _AddEditMenuDialogState();
}

class _AddEditMenuDialogState extends State<AddEditMenuDialog> {
  late TextEditingController _nameEnController;
  late TextEditingController _nameNeController;
  late TextEditingController _priceController;
  late TextEditingController _imageUrlController;
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _nameEnController = TextEditingController(text: widget.item?.nameEn ?? '');
    _nameNeController = TextEditingController(text: widget.item?.nameNe ?? '');
    _priceController = TextEditingController(
      text: widget.item?.price.toString() ?? '',
    );
    _imageUrlController = TextEditingController(
      text: widget.item?.imageUrl ?? '',
    );
    _selectedCategory = widget.item?.category;
  }

  @override
  void dispose() {
    _nameEnController.dispose();
    _nameNeController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  // ...

  Future<void> _pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
    );

    if (result != null) {
      final file = File(result.files.single.path!);

      // Check file size (1MB = 1024 * 1024 bytes)
      final fileSize = await file.length();
      const maxSize = 1024 * 1024; // 1MB in bytes

      if (fileSize > maxSize) {
        if (mounted) {
          snackBar(
            message: AppLocalizations.of(context)!.imageSizeTooLarge,
            messageType: MessageType.error,
          );
        }
        return;
      }

      final compressedFile = await ImageCompressor.compressImage(file);

      if (compressedFile != null) {
        setState(() {
          _imageUrlController.text = compressedFile.path;
        });
      }
    }
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
                decoration: BoxDecoration(
                  color: AppColors.getDialogBackground(context),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: AppColors.getSubtitleColor(
                        context,
                      ).withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.item == null
                          ? AppLocalizations.of(context)!.addNewMenuItem
                          : AppLocalizations.of(context)!.editMenuItem,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Form Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // English Name Field
                    Text(
                      AppLocalizations.of(context)!.titleEnglish,
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
                        )!.titleEnglishHint,
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
                      AppLocalizations.of(context)!.titleNepali,
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
                        hintText: AppLocalizations.of(context)!.titleNepaliHint,
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
                    // Image Upload
                    Text(
                      AppLocalizations.of(context)!.image,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 140,
                        decoration: BoxDecoration(
                          color: AppColors.getTextField(context),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.getSubtitleColor(
                              context,
                            ).withValues(alpha: 0.3),
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _imageUrlController.text.isNotEmpty
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_imageUrlController.text),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to asset if it's a seed data path (starts with assets/)
                                    if (_imageUrlController.text.startsWith(
                                      'assets/',
                                    )) {
                                      return Image.asset(
                                        _imageUrlController.text,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) =>
                                                _buildUploadPlaceholder(),
                                      );
                                    }
                                    return _buildUploadPlaceholder();
                                  },
                                ),
                              )
                            : _buildUploadPlaceholder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Price Field
                    Text(
                      AppLocalizations.of(context)!.price,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _priceController,
                      style: TextStyle(color: AppColors.getTextColor(context)),
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: AppLocalizations.of(context)!.priceHint,
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
                    // Category Dropdown
                    Text(
                      AppLocalizations.of(context)!.category,
                      style: TextStyle(
                        color: AppColors.getTextColor(context),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.getTextField(context),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: BlocBuilder<CategoryBloc, CategoryState>(
                        builder: (context, state) {
                          final languageCode = Localizations.localeOf(
                            context,
                          ).languageCode;
                          final categories = state.categories
                              .map(
                                (e) => MapEntry(
                                  e.id,
                                  e.getLocalizedName(languageCode),
                                ),
                              )
                              .toList();

                          // Ensure selected category is valid
                          if (_selectedCategory != null &&
                              !categories.any(
                                (e) => e.key == _selectedCategory,
                              )) {
                            _selectedCategory = null;
                          }

                          return DropdownButtonFormField<String>(
                            initialValue: _selectedCategory,
                            hint: Text(
                              AppLocalizations.of(context)!.selectCategory,
                              style: TextStyle(
                                color: AppColors.getSubtitleColor(context),
                              ),
                            ),
                            dropdownColor: AppColors.getTextField(context),
                            style: TextStyle(
                              color: AppColors.getTextColor(context),
                            ),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            icon: Icon(
                              Icons.keyboard_arrow_down,
                              color: AppColors.getTextColor(context),
                            ),
                            items: categories.map((entry) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Text(entry.value),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() {
                                _selectedCategory = value;
                              });
                            },
                          );
                        },
                      ),
                    ),
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
                          style: const TextStyle(
                            color: Colors.red,
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
                          AppLocalizations.of(context)!.addItem,
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

  Widget _buildUploadPlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_outlined, size: 48, color: AppColors.blue),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.clickToUpload,
            style: TextStyle(
              color: AppColors.getTextColor(context),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppLocalizations.of(context)!.imageFormatSize,
            style: TextStyle(
              color: AppColors.getSubtitleColor(context),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _handleSave() {
    // Validate names
    if (_nameEnController.text.trim().isEmpty ||
        _nameNeController.text.trim().isEmpty) {
      snackBar(
        message: AppLocalizations.of(context)!.pleaseEnterMenuItemNames,
        messageType: MessageType.error,
      );

      return;
    }

    // Validate price
    if (_priceController.text.trim().isEmpty) {
      snackBar(
        message: AppLocalizations.of(context)!.pleaseEnterPrice,
        messageType: MessageType.error,
      );
      return;
    }

    final price = double.tryParse(_priceController.text.trim());
    if (price == null || price <= 0) {
      snackBar(
        messageType: MessageType.error,
        message: AppLocalizations.of(context)!.pleaseEnterValidPrice,
      );
      return;
    }

    // Validate category
    if (_selectedCategory == null || _selectedCategory!.trim().isEmpty) {
      snackBar(
        message: AppLocalizations.of(context)!.pleaseSelectCategory,
        messageType: MessageType.error,
      );
      return;
    }

    final newItem = MenuItem(
      id: widget.item?.id ?? const Uuid().v4(),
      nameEn: _nameEnController.text.trim(),
      nameNe: _nameNeController.text.trim(),
      price: price,
      category: _selectedCategory!,
      imageUrl: _imageUrlController.text,
      availableQuantity: null, // Unlimited stock
    );

    widget.onSave(newItem);
    Navigator.pop(context);
  }
}
