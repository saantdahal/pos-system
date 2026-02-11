abstract class DataImportExportEvent {}

class ExportDataEvent extends DataImportExportEvent {}

class ImportDataEvent extends DataImportExportEvent {
  final String filePath;

  ImportDataEvent(this.filePath);
}

class ResetStateEvent extends DataImportExportEvent {}
