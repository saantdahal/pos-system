import 'package:hive/hive.dart';

import '../../data/models/category.dart';

class CategoryRepository {
  static const String _boxName = 'categories';
  static const int _currentSchemaVersion = 1;
  static const String _versionKey = 'category_schema_version';

  Future<Box<Category>> _getBox() async {
    // Check if we need to migrate
    try {
      final versionBox = await Hive.openBox('category_version');
      final storedVersion = versionBox.get(_versionKey, defaultValue: 0);

      if (storedVersion < _currentSchemaVersion) {
        await Hive.deleteBoxFromDisk(_boxName);
        await versionBox.put(_versionKey, _currentSchemaVersion);
      }
      await versionBox.close();
    } catch (e) {
      await Hive.deleteBoxFromDisk(_boxName);
    }

    if (!Hive.isBoxOpen(_boxName)) {
      return await Hive.openBox<Category>(_boxName);
    }
    return Hive.box<Category>(_boxName);
  }

  // get all categories:
  Future<List<Category>> getCategories() async {
    final box = await _getBox();
    return box.values.toList();
  }

  // add category:
  Future<void> addCategory(Category category) async {
    final box = await _getBox();
    await box.put(category.id, category);
  }

  // update category:
  Future<void> updateCategory(Category category) async {
    final box = await _getBox();
    await box.put(category.id, category);
  }

  //  delete category:
  Future<void> deleteCategory(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  // clear all categories:
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }

  // import categories (bulk insert):
  Future<void> importCategories(List<Category> categories) async {
    final box = await _getBox();
    for (final category in categories) {
      await box.put(category.id, category);
    }
  }
}
