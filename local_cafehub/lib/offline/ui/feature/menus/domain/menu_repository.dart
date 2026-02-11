import 'package:hive/hive.dart';
import '../data/menu_item.dart';

class MenuRepository {
  static const String _boxName = 'menu_items';

  // Migration flag - increment this when schema changes
  static const int _currentSchemaVersion = 2;
  static const String _versionKey = 'schema_version';

  Future<Box<MenuItem>> _getBox() async {
    // Check if we need to migrate by checking a separate box for version
    try {
      final versionBox = await Hive.openBox('menu_version');
      final storedVersion = versionBox.get(_versionKey, defaultValue: 1);

      if (storedVersion < _currentSchemaVersion) {
        // Schema has changed, delete the old box
        await Hive.deleteBoxFromDisk(_boxName);
        // Update version
        await versionBox.put(_versionKey, _currentSchemaVersion);
      }
      await versionBox.close();
    } catch (e) {
      // If version box fails, just try to delete the menu box to be safe
      await Hive.deleteBoxFromDisk(_boxName);
    }

    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<MenuItem>(_boxName);
    }
    return Hive.box<MenuItem>(_boxName);
  }

  // get menu:
  Future<List<MenuItem>> getMenu() async {
    final box = await _getBox();
    return box.values.toList();
  }

  // add menu item:
  Future<void> addMenuItem(MenuItem item) async {
    final box = await _getBox();
    await box.put(item.id, item);
  }

  // update menu item:
  Future<void> updateMenuItem(MenuItem item) async {
    final box = await _getBox();
    await box.put(item.id, item);
  }

  // delete menu item:
  Future<void> deleteMenuItem(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  // clear all menu items:
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }

  // import menu items (bulk insert):
  Future<void> importMenuItems(List<MenuItem> items) async {
    final box = await _getBox();
    for (final item in items) {
      await box.put(item.id, item);
    }
  }

  // update stock
  Future<void> updateStock(String itemId, int quantityChange) async {
    final box = await _getBox();
    final item = box.get(itemId);
    if (item != null && item.availableQuantity != null) {
      final newQuantity = item.availableQuantity! + quantityChange;
      // Ensure we don't go below zero, though logic should prevent this
      final updatedItem = MenuItem(
        id: item.id,
        nameEn: item.nameEn,
        nameNe: item.nameNe,
        price: item.price,
        category: item.category,
        isAvailable: item.isAvailable,
        imageUrl: item.imageUrl,
        availableQuantity: newQuantity < 0 ? 0 : newQuantity,
        lowStockThreshold: item.lowStockThreshold,
      );
      await box.put(itemId, updatedItem);
    }
  }
}
