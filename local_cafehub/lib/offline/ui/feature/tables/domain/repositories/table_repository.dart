import 'package:hive/hive.dart';
import '../../data/models/table.dart';

class TableRepository {
  static const String _boxName = 'tables';
  static const int _currentSchemaVersion = 1;
  static const String _versionKey = 'table_schema_version';

  Future<Box<TableModel>> _getBox() async {
    // Check if we need to migrate
    try {
      final versionBox = await Hive.openBox('table_version');
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
      return await Hive.openBox<TableModel>(_boxName);
    }
    return Hive.box<TableModel>(_boxName);
  }

  // Get all tables
  Future<List<TableModel>> getTables() async {
    final box = await _getBox();
    final tables = box.values.toList();
    // Sort by table number
    tables.sort((a, b) => a.tableNumber.compareTo(b.tableNumber));
    return tables;
  }

  // Add a single table
  Future<void> addTable(TableModel table) async {
    final box = await _getBox();
    await box.put(table.id, table);
  }

  // Update table
  Future<void> updateTable(TableModel table) async {
    final box = await _getBox();
    await box.put(table.id, table);
  }

  // Delete table
  Future<void> deleteTable(String id) async {
    final box = await _getBox();
    await box.delete(id);
  }

  // Set number of tables (creates/removes tables as needed)
  Future<void> setNumberOfTables(int count) async {
    final box = await _getBox();
    final currentTables = box.values.toList();

    if (count > currentTables.length) {
      // Add more tables
      for (int i = currentTables.length + 1; i <= count; i++) {
        final newTable = TableModel(id: 'table_$i', tableNumber: i);
        await box.put(newTable.id, newTable);
      }
    } else if (count < currentTables.length) {
      // Remove excess tables (from the end)
      currentTables.sort((a, b) => b.tableNumber.compareTo(a.tableNumber));
      for (int i = 0; i < currentTables.length - count; i++) {
        await box.delete(currentTables[i].id);
      }
    }
  }

  // Get number of tables
  Future<int> getTableCount() async {
    final box = await _getBox();
    return box.length;
  }

  // Clear all tables
  Future<void> clearAll() async {
    final box = await _getBox();
    await box.clear();
  }
}
