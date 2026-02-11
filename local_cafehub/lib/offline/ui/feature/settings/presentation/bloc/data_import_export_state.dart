abstract class DataImportExportState {}

class DataImportExportInitial extends DataImportExportState {}

class DataExportLoading extends DataImportExportState {}

class DataExportSuccess extends DataImportExportState {
  final String filePath;
  final int categoriesCount;
  final int menuItemsCount;

  DataExportSuccess({
    required this.filePath,
    required this.categoriesCount,
    required this.menuItemsCount,
  });
}

class DataImportLoading extends DataImportExportState {}

class DataImportSuccess extends DataImportExportState {
  final int categoriesCount;
  final int menuItemsCount;

  DataImportSuccess({
    required this.categoriesCount,
    required this.menuItemsCount,
  });
}

class DataImportExportError extends DataImportExportState {
  final String message;

  DataImportExportError(this.message);
}
