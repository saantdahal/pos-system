import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/online/core/services/image_picker_service.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/domain/models/category_model.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/domain/models/menu_item_model.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/presentation/bloc/menu_bloc.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/presentation/bloc/menu_event.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/presentation/bloc/menu_state.dart';

const Color primaryColor = Color(0xFFFF6B35);
const Color hintColor = Color(0xFFB8A0A0);

enum StockType { unlimited, limited }

class MenuFormPage extends StatefulWidget {
  final MenuItemModel? menuItem;
  final List<CategoryModel> categories;

  const MenuFormPage({super.key, this.menuItem, required this.categories});

  @override
  State<MenuFormPage> createState() => _MenuFormPageState();
}

class _MenuFormPageState extends State<MenuFormPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountController;
  late final TextEditingController _stockController;

  CategoryModel? _selectedCategory;
  String? _imagePath;
  bool _isLoading = false;
  bool _enableDiscount = false;
  late StockType _stockType;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _nameController = TextEditingController(text: widget.menuItem?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.menuItem?.description ?? '',
    );
    _priceController = TextEditingController(
      text: widget.menuItem?.basePrice.toString() ?? '',
    );
    _discountController = TextEditingController(
      text: widget.menuItem?.discountPercentage.toString() ?? '0',
    );

    // Determine if unlimited or limited stock
    _stockType = widget.menuItem?.stockQuantity == null
        ? StockType.unlimited
        : StockType.limited;

    _stockController = TextEditingController(
      text: widget.menuItem?.stockQuantity != null
          ? widget.menuItem!.stockQuantity.toString()
          : '',
    );

    _enableDiscount = (widget.menuItem?.discountPercentage ?? 0) > 0;

    if (widget.menuItem != null) {
      _selectedCategory = widget.categories.firstWhere(
        (cat) => cat.id == widget.menuItem!.category,
        orElse: () => widget.categories.first,
      );
    } else if (widget.categories.isNotEmpty) {
      _selectedCategory = widget.categories.first;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedPath = await ImagePickerService.pickImage(context);
    if (pickedPath != null) {
      setState(() {
        _imagePath = pickedPath;
      });
    }
  }

  bool _validateForm() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter menu item name')),
      );
      return false;
    }

    if (_descriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please enter description')));
      return false;
    }

    final price = double.tryParse(_priceController.text);
    if (_priceController.text.isEmpty || price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid price')),
      );
      return false;
    }

    if (_stockType == StockType.limited) {
      final stock = int.tryParse(_stockController.text);
      if (_stockController.text.isEmpty || stock == null || stock < 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter valid stock quantity')),
        );
        return false;
      }
    }

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return false;
    }

    return true;
  }

  void _submitForm() {
    if (!_validateForm()) return;

    setState(() => _isLoading = true);

    debugPrint('📝 [_submitForm] Starting form submission');
    debugPrint('📝 Image path in form: $_imagePath');
    debugPrint('📝 Image path is null: ${_imagePath == null}');
    debugPrint('📝 Image path is empty: ${_imagePath?.isEmpty}');

    // Parse values safely
    final double basePrice = double.parse(_priceController.text.trim());
    final int? stockQuantity = _stockType == StockType.unlimited
        ? null
        : int.parse(_stockController.text.trim());
    final double discountPercentage = _enableDiscount
        ? (double.tryParse(_discountController.text.trim()) ?? 0.0)
        : 0.0;

    final menuItem = MenuItemModel(
      id: widget.menuItem?.id,
      category: _selectedCategory!.id,
      name: _nameController.text.trim(),
      description: _descriptionController.text.trim(),
      basePrice: basePrice,
      discountPercentage: discountPercentage,
      stockQuantity: stockQuantity,
      position: 0, // Backend will auto-assign
      imageUrl: widget.menuItem?.imageUrl,
    );

    debugPrint('📝 MenuItem created: ${menuItem.name}');
    debugPrint('📝 Stock type: $_stockType, Stock quantity: $stockQuantity');

    if (widget.menuItem == null) {
      debugPrint('📝 Creating new menu item with image path: $_imagePath');
      context.read<MenuBloc>().add(
        MenuItemCreated(item: menuItem, imagePath: _imagePath),
      );
    } else {
      debugPrint(
        '📝 Updating menu item ID=${widget.menuItem!.id} with image path: $_imagePath',
      );
      context.read<MenuBloc>().add(
        MenuItemUpdated(
          itemId: widget.menuItem!.id!,
          item: menuItem,
          imagePath: _imagePath,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surfaceColor = isDark ? const Color(0xFF2A2A2A) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF1A1A1A)
          : const Color(0xFFF8F8F8),
      appBar: AppBar(
        backgroundColor: surfaceColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => context.pop(),
        ),
        title: Text(
          widget.menuItem == null ? 'Add Menu Item' : 'Edit Menu Item',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: textColor,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocListener<MenuBloc, MenuState>(
        listener: (context, state) {
          if (state is MenuItemCreatedSuccess) {
            context.pop();
          } else if (state is MenuItemUpdatedSuccess) {
            context.pop();
          } else if (state is MenuError) {
            setState(() => _isLoading = false);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Dropdown
                Text(
                  'Category *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: DropdownButton<CategoryModel>(
                    value: _selectedCategory,
                    isExpanded: true,
                    underline: const SizedBox(),
                    dropdownColor: surfaceColor,
                    items: widget.categories
                        .map(
                          (category) => DropdownMenuItem(
                            value: category,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                category.name,
                                style: TextStyle(color: textColor),
                              ),
                            ),
                          ),
                        )
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedCategory = value);
                    },
                  ),
                ),
                const SizedBox(height: 20),

                // Item Name
                Text(
                  'Item Name *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _nameController,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'e.g., Chicken Momo',
                    hintStyle: const TextStyle(color: hintColor),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Description
                Text(
                  'Description *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  maxLines: 3,
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Describe your menu item...',
                    hintStyle: const TextStyle(color: hintColor),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Price Section
                Text(
                  'Base Price *',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: TextStyle(color: textColor),
                  decoration: InputDecoration(
                    hintText: '0.00',
                    hintStyle: const TextStyle(color: hintColor),
                    filled: true,
                    fillColor: surfaceColor,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Stock Management Section
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Stock Management',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<StockType>(
                          selected: <StockType>{_stockType},
                          onSelectionChanged: (Set<StockType> newSelection) {
                            setState(() {
                              _stockType = newSelection.first;
                              if (_stockType == StockType.unlimited) {
                                _stockController.clear();
                              }
                            });
                          },
                          segments: const <ButtonSegment<StockType>>[
                            ButtonSegment<StockType>(
                              value: StockType.unlimited,
                              label: Text('Unlimited'),
                            ),
                            ButtonSegment<StockType>(
                              value: StockType.limited,
                              label: Text('Limited'),
                            ),
                          ],
                        ),
                        if (_stockType == StockType.limited) ...[
                          const SizedBox(height: 12),
                          TextField(
                            controller: _stockController,
                            keyboardType: TextInputType.number,
                            style: TextStyle(color: textColor),
                            decoration: InputDecoration(
                              hintText: 'Enter stock quantity',
                              hintStyle: const TextStyle(color: hintColor),
                              filled: true,
                              fillColor: surfaceColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Discount Toggle and Field
                Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Add Discount %',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: textColor,
                          ),
                        ),
                        Switch(
                          value: _enableDiscount,
                          onChanged: (value) {
                            setState(() {
                              _enableDiscount = value;
                              if (!value) {
                                _discountController.text = '0';
                              }
                            });
                          },
                          activeThumbColor: primaryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                if (_enableDiscount) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _discountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: TextStyle(color: textColor),
                    decoration: InputDecoration(
                      hintText: 'Discount percentage (0-100)',
                      hintStyle: const TextStyle(color: hintColor),
                      filled: true,
                      fillColor: surfaceColor,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      suffixText: '%',
                      suffixStyle: TextStyle(color: textColor),
                    ),
                  ),
                ],
                const SizedBox(height: 20),

                // Image Picker
                Text(
                  'Menu Item Image',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _isLoading ? null : _pickImage,
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 20,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (_imagePath == null)
                            Column(
                              children: [
                                Icon(
                                  Icons.cloud_upload_outlined,
                                  size: 48,
                                  color: primaryColor.withValues(alpha: 0.6),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Tap to upload image',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'PNG, JPG up to 10MB',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: hintColor,
                                  ),
                                ),
                              ],
                            )
                          else
                            Column(
                              children: [
                                const Icon(
                                  Icons.check_circle,
                                  size: 48,
                                  color: Colors.green,
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Image selected',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: textColor,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _imagePath!.split('/').last,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: hintColor,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                TextButton.icon(
                                  onPressed: _isLoading ? null : _pickImage,
                                  icon: const Icon(Icons.edit),
                                  label: const Text('Change'),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      disabledBackgroundColor: primaryColor.withValues(
                        alpha: 0.5,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : Text(
                            widget.menuItem == null
                                ? 'Add Item'
                                : 'Update Item',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
