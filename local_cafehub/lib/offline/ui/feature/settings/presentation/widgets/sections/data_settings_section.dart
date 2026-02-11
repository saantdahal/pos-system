import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/services/data_export_import_service.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/bloc/data_import_export_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/bloc/data_import_export_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/setting_item.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/import_confirmation_dialog.dart';

class DataSettingsSection extends StatelessWidget {
  const DataSettingsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SettingItem(
          icon: Icons.file_upload_outlined,
          title: AppLocalizations.of(context)!.importData,
          subtitle: AppLocalizations.of(context)!.importDataSubtitle,
          onTap: () => _handleImport(context),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        SettingItem(
          icon: Icons.file_download_outlined,
          title: AppLocalizations.of(context)!.exportData,
          subtitle: AppLocalizations.of(context)!.exportDataSubtitle,
          onTap: () => _handleExport(context),
          trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _handleExport(BuildContext context) async {
    context.read<DataImportExportBloc>().add(ExportDataEvent());
  }

  Future<void> _handleImport(BuildContext context) async {
    try {
      final service = DataExportImportService();
      final filePath = await service.pickExcelFile();

      if (filePath == null) return;

      // Parse file to get preview data (supports both Excel and JSON)
      ImportResult importResult;
      if (filePath.endsWith('.xlsx')) {
        importResult = await service.importFromExcel(filePath);
      } else if (filePath.endsWith('.json')) {
        importResult = await service.importFromJson(filePath);
      } else {
        throw Exception('Unsupported file format');
      }

      if (!context.mounted) return;

      // Show confirmation dialog
      showDialog(
        context: context,
        builder: (dialogContext) => ImportConfirmationDialog(
          categoriesCount: importResult.categories.length,
          menuItemsCount: importResult.menuItems.length,
          onConfirm: () {
            context.read<DataImportExportBloc>().add(ImportDataEvent(filePath));
          },
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      snackBar(
        message: '${AppLocalizations.of(context)!.failedToReadFile} $e',
        messageType: MessageType.error,
      );
    }
  }
}
