import 'dart:convert';
import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../ui/feature/categories/data/models/category.dart';
import '../../ui/feature/menus/data/menu_item.dart';

class DataExportImportService {
  /// Export categories and menu items to Excel
  Future<String> exportToExcel({
    required List<Category> categories,
    required List<MenuItem> menuItems,
  }) async {
    try {
      // Create Excel workbook
      final excel = Excel.createExcel();

      // Remove default sheet
      excel.delete('Sheet1');

      // Create Categories sheet
      final categoriesSheet = excel['Categories'];
      categoriesSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Name (English)'),
        TextCellValue('Name (Nepali)'),
      ]);

      for (final category in categories) {
        categoriesSheet.appendRow([
          TextCellValue(category.id),
          TextCellValue(category.nameEn),
          TextCellValue(category.nameNe),
        ]);
      }

      // Create Menu Items sheet
      final menuItemsSheet = excel['Menu Items'];
      menuItemsSheet.appendRow([
        TextCellValue('ID'),
        TextCellValue('Name (English)'),
        TextCellValue('Name (Nepali)'),
        TextCellValue('Price'),
        TextCellValue('Category ID'),
      ]);

      for (final item in menuItems) {
        menuItemsSheet.appendRow([
          TextCellValue(item.id),
          TextCellValue(item.nameEn),
          TextCellValue(item.nameNe),
          DoubleCellValue(item.price),
          TextCellValue(item.category),
        ]);
      }

      // Add helpful notes at the bottom
      menuItemsSheet.appendRow([]);
      menuItemsSheet.appendRow([]);
      menuItemsSheet.appendRow([TextCellValue('📝 DATA ENTRY HELP:')]);
      menuItemsSheet.appendRow([
        TextCellValue(
          '• Category ID should be the same for all items in the same category (refer to Categories sheet)',
        ),
      ]);
      menuItemsSheet.appendRow([
        TextCellValue(
          '⚠️ WARNING: Double-check all data when editing manually to avoid errors',
        ),
      ]);

      // Save to file
      final directory = await _getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'cafehub_backup_$timestamp.xlsx';
      final filePath = '${directory.path}/$fileName';

      final fileBytes = excel.save();
      if (fileBytes != null) {
        final file = File(filePath);
        await file.writeAsBytes(fileBytes);
        return filePath;
      } else {
        throw Exception('Failed to generate Excel file');
      }
    } catch (e) {
      throw Exception('Failed to export to Excel: $e');
    }
  }

  /// Import categories and menu items from Excel
  Future<ImportResult> importFromExcel(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final bytes = await file.readAsBytes();
      final excel = Excel.decodeBytes(bytes);

      // Validate sheets exist
      if (!excel.tables.containsKey('Categories')) {
        throw Exception('Missing "Categories" sheet');
      }
      if (!excel.tables.containsKey('Menu Items')) {
        throw Exception('Missing "Menu Items" sheet');
      }

      // Parse Categories
      final categoriesSheet = excel.tables['Categories']!;
      final categories = <Category>[];

      // Skip header row (index 0)
      for (var i = 1; i < categoriesSheet.rows.length; i++) {
        final row = categoriesSheet.rows[i];
        if (row.isEmpty || row[0] == null) continue;

        final id = _getCellValue(row, 0);
        final nameEn = _getCellValue(row, 1);
        final nameNe = _getCellValue(row, 2);

        if (id.isEmpty) {
          throw Exception('Category ID cannot be empty at row ${i + 1}');
        }
        if (nameEn.isEmpty || nameNe.isEmpty) {
          throw Exception('Category names cannot be empty at row ${i + 1}');
        }

        categories.add(Category(id: id, nameEn: nameEn, nameNe: nameNe));
      }

      // Parse Menu Items
      final menuItemsSheet = excel.tables['Menu Items']!;
      final menuItems = <MenuItem>[];

      // Skip header row (index 0)
      for (var i = 1; i < menuItemsSheet.rows.length; i++) {
        final row = menuItemsSheet.rows[i];
        if (row.isEmpty || row[0] == null) continue;

        final id = _getCellValue(row, 0);

        // Skip rows that are notes/help text (start with special characters)
        if (id.startsWith('📝') || id.startsWith('•') || id.startsWith('⚠️')) {
          continue;
        }

        final nameEn = _getCellValue(row, 1);
        final nameNe = _getCellValue(row, 2);
        final priceStr = _getCellValue(row, 3);
        final categoryId = _getCellValue(row, 4);

        if (id.isEmpty) {
          throw Exception('Menu item ID cannot be empty at row ${i + 1}');
        }
        if (nameEn.isEmpty || nameNe.isEmpty) {
          throw Exception('Menu item names cannot be empty at row ${i + 1}');
        }

        final price = double.tryParse(priceStr);
        if (price == null || price <= 0) {
          throw Exception('Invalid price for menu item at row ${i + 1}');
        }

        if (categoryId.isEmpty) {
          throw Exception('Menu item category cannot be empty at row ${i + 1}');
        }

        menuItems.add(
          MenuItem(
            id: id,
            nameEn: nameEn,
            nameNe: nameNe,
            price: price,
            category: categoryId,
            imageUrl: '', // Image URL not required in Excel format
            isAvailable: true, // Available by default
            availableQuantity: null, // Stock not managed via Excel
            lowStockThreshold: null, // Threshold not managed via Excel
          ),
        );
      }

      // Validate category references
      final categoryIds = categories.map((c) => c.id).toSet();
      for (final item in menuItems) {
        if (!categoryIds.contains(item.category)) {
          throw Exception(
            'Menu item "${item.nameEn}" references non-existent category ID "${item.category}"',
          );
        }
      }

      return ImportResult(
        categories: categories,
        menuItems: menuItems,
        version: '2.0', // Excel format version
        exportDate: DateTime.now().toIso8601String(),
      );
    } on FormatException catch (e) {
      throw Exception('Invalid Excel format: $e');
    } catch (e) {
      throw Exception('Failed to import from Excel: $e');
    }
  }

  /// Helper method to get cell value as string
  String _getCellValue(List<Data?> row, int index) {
    if (index >= row.length || row[index] == null) {
      return '';
    }
    final cell = row[index];
    return cell?.value?.toString() ?? '';
  }

  /// Get export directory based on platform
  Future<Directory> _getExportDirectory() async {
    if (Platform.isAndroid) {
      final directory = Directory('/storage/emulated/0/Download');
      if (await directory.exists()) {
        return directory;
      }
    }
    return await getApplicationDocumentsDirectory();
  }

  /// Export to JSON (kept for backward compatibility)
  Future<Map<String, dynamic>> exportToJson({
    required List<Category> categories,
    required List<MenuItem> menuItems,
  }) async {
    return {
      'version': '1.0',
      'exportDate': DateTime.now().toIso8601String(),
      'categories': categories.map((c) => c.toJson()).toList(),
      'menuItems': menuItems.map((m) => m.toJson()).toList(),
    };
  }

  /// Save JSON data to file (kept for backward compatibility)
  Future<String> saveJsonToDevice(Map<String, dynamic> jsonData) async {
    try {
      final directory = await _getExportDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = 'cafehub_backup_$timestamp.json';
      final filePath = '${directory.path}/$fileName';

      final file = File(filePath);
      final jsonString = const JsonEncoder.withIndent('  ').convert(jsonData);
      await file.writeAsString(jsonString);

      return filePath;
    } catch (e) {
      throw Exception('Failed to save JSON file: $e');
    }
  }

  /// Share an already saved file
  Future<void> shareFile(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], subject: 'Bhansa Ghar Data Backup'),
      );
    } catch (e) {
      throw Exception('Failed to share file: $e');
    }
  }

  /// Pick an Excel file from device
  Future<String?> pickExcelFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xlsx'],
      );

      if (result != null && result.files.single.path != null) {
        return result.files.single.path!;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to pick file: $e');
    }
  }

  /// Import from JSON (kept for backward compatibility)
  Future<ImportResult> importFromJson(String filePath) async {
    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('File does not exist');
      }

      final jsonString = await file.readAsString();
      final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;

      // Validate structure
      _validateJsonStructure(jsonData);

      // Parse categories
      final categoriesJson = jsonData['categories'] as List<dynamic>;
      final categories = categoriesJson
          .map((json) => Category.fromJson(json as Map<String, dynamic>))
          .toList();

      // Parse menu items
      final menuItemsJson = jsonData['menuItems'] as List<dynamic>;
      final menuItems = menuItemsJson
          .map((json) => MenuItem.fromJson(json as Map<String, dynamic>))
          .toList();

      return ImportResult(
        categories: categories,
        menuItems: menuItems,
        version: jsonData['version'] as String,
        exportDate: jsonData['exportDate'] as String,
      );
    } on FormatException catch (e) {
      throw Exception('Invalid JSON format: $e');
    } catch (e) {
      throw Exception('Failed to import data: $e');
    }
  }

  /// Validate JSON structure
  void _validateJsonStructure(Map<String, dynamic> jsonData) {
    if (!jsonData.containsKey('version')) {
      throw Exception('Missing version field');
    }
    if (!jsonData.containsKey('exportDate')) {
      throw Exception('Missing exportDate field');
    }
    if (!jsonData.containsKey('categories')) {
      throw Exception('Missing categories field');
    }
    if (!jsonData.containsKey('menuItems')) {
      throw Exception('Missing menuItems field');
    }

    if (jsonData['categories'] is! List) {
      throw Exception('Categories must be an array');
    }
    if (jsonData['menuItems'] is! List) {
      throw Exception('MenuItems must be an array');
    }
  }
}

/// Result of import operation
class ImportResult {
  final List<Category> categories;
  final List<MenuItem> menuItems;
  final String version;
  final String exportDate;

  ImportResult({
    required this.categories,
    required this.menuItems,
    required this.version,
    required this.exportDate,
  });
}
