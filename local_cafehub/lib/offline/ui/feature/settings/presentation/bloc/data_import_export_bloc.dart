import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/services/data_export_import_service.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../menus/domain/menu_repository.dart';
import 'data_import_export_event.dart';
import 'data_import_export_state.dart';

class DataImportExportBloc
    extends Bloc<DataImportExportEvent, DataImportExportState> {
  final DataExportImportService _service;
  final CategoryRepository _categoryRepository;
  final MenuRepository _menuRepository;

  DataImportExportBloc({
    required DataExportImportService service,
    required CategoryRepository categoryRepository,
    required MenuRepository menuRepository,
  }) : _service = service,
       _categoryRepository = categoryRepository,
       _menuRepository = menuRepository,
       super(DataImportExportInitial()) {
    on<ExportDataEvent>(_onExportData);
    on<ImportDataEvent>(_onImportData);
    on<ResetStateEvent>(_onResetState);
  }

  Future<void> _onExportData(
    ExportDataEvent event,
    Emitter<DataImportExportState> emit,
  ) async {
    emit(DataExportLoading());
    try {
      // Get all categories and menu items
      final categories = await _categoryRepository.getCategories();
      final menuItems = await _menuRepository.getMenu();

      // Export to Excel
      final filePath = await _service.exportToExcel(
        categories: categories,
        menuItems: menuItems,
      );

      emit(
        DataExportSuccess(
          filePath: filePath,
          categoriesCount: categories.length,
          menuItemsCount: menuItems.length,
        ),
      );
    } catch (e) {
      emit(DataImportExportError('Export failed: ${e.toString()}'));
    }
  }

  Future<void> _onImportData(
    ImportDataEvent event,
    Emitter<DataImportExportState> emit,
  ) async {
    emit(DataImportLoading());
    try {
      // Determine file type and import accordingly
      ImportResult importResult;
      if (event.filePath.endsWith('.xlsx')) {
        importResult = await _service.importFromExcel(event.filePath);
      } else if (event.filePath.endsWith('.json')) {
        importResult = await _service.importFromJson(event.filePath);
      } else {
        throw Exception('Unsupported file format. Please use .xlsx or .json');
      }

      // Clear existing data
      await _categoryRepository.clearAll();
      await _menuRepository.clearAll();

      // Import new data
      await _categoryRepository.importCategories(importResult.categories);
      await _menuRepository.importMenuItems(importResult.menuItems);

      emit(
        DataImportSuccess(
          categoriesCount: importResult.categories.length,
          menuItemsCount: importResult.menuItems.length,
        ),
      );
    } catch (e) {
      emit(DataImportExportError('Import failed: ${e.toString()}'));
    }
  }

  void _onResetState(
    ResetStateEvent event,
    Emitter<DataImportExportState> emit,
  ) {
    emit(DataImportExportInitial());
  }
}
