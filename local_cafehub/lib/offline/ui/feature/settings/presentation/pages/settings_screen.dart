import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/services/data_export_import_service.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/domain/repositories/category_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/domain/menu_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/export_options_dialog.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/bloc/data_import_export_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/bloc/data_import_export_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/bloc/data_import_export_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/presentation/bloc/table_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/tables/presentation/bloc/table_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/setting_item.dart';
import 'package:share_plus/share_plus.dart';
import 'package:bhansa_ghar/core/bloc/mode/mode_bloc.dart';

// Sections
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/sections/voice_settings_section.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/sections/language_settings_section.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/sections/server_settings_section.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/sections/table_settings_section.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/sections/appearance_settings_section.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/sections/security_settings_section.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/sections/data_settings_section.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load tables when screen initializes
    context.read<TableBloc>().add(LoadTables());
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => DataImportExportBloc(
            service: DataExportImportService(),
            categoryRepository: RepositoryProvider.of<CategoryRepository>(
              context,
            ),
            menuRepository: RepositoryProvider.of<MenuRepository>(context),
          ),
        ),
      ],
      child: Builder(
        builder: (context) => BlocListener<DataImportExportBloc, DataImportExportState>(
          listener: (context, state) {
            if (state is DataExportSuccess) {
              showDialog(
                context: context,
                builder: (dialogContext) => ExportOptionsDialog(
                  filePath: state.filePath,
                  categoriesCount: state.categoriesCount,
                  menuItemsCount: state.menuItemsCount,
                  onSave: () {
                    snackBar(
                      message: AppLocalizations.of(
                        context,
                      )!.fileSavedSuccessfully,
                      messageType: MessageType.success,
                    );
                  },
                  onShare: () => _handleShare(context, state.filePath),
                ),
              );
              context.read<DataImportExportBloc>().add(ResetStateEvent());
            } else if (state is DataImportSuccess) {
              snackBar(
                message:
                    '${AppLocalizations.of(context)!.importedSuccess} ${state.categoriesCount} ${AppLocalizations.of(context)!.categoriesAnd} ${state.menuItemsCount} ${AppLocalizations.of(context)!.menuItems}',
                messageType: MessageType.success,
              );
              context.read<DataImportExportBloc>().add(ResetStateEvent());
            } else if (state is DataImportExportError) {
              snackBar(message: state.message, messageType: MessageType.error);
              context.read<DataImportExportBloc>().add(ResetStateEvent());
            }
          },
          child: Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            appBar: AppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () => context.go('/'),
                icon: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Theme.of(context).iconTheme.color,
                ),
              ),
              title: Text(
                AppLocalizations.of(context)!.settingsTitle,
                style: TextStyle(
                  color: AppColors.getTextColor(context),
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader(
                    AppLocalizations.of(context)!.voiceAnnouncements,
                  ),
                  const SizedBox(height: 12),
                  const VoiceSettingsSection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader(AppLocalizations.of(context)!.language),
                  const SizedBox(height: 12),
                  const LanguageSettingsSection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader(AppLocalizations.of(context)!.server),
                  const SizedBox(height: 12),
                  const ServerSettingsSection(),
                  const SizedBox(height: 12),

                  _buildSectionHeader(AppLocalizations.of(context)!.guidance),
                  const SizedBox(height: 12),
                  SettingItem(
                    icon: Icons.info,
                    title: AppLocalizations.of(context)!.guidanceTitle,
                    subtitle: AppLocalizations.of(
                      context,
                    )!.guidanceTitle, // Using title as subtitle based on previous code
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => context.go('/guidance'),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader('App Mode'),
                  const SizedBox(height: 12),
                  SettingItem(
                    icon: Icons.cloud_outlined,
                    title: 'Switch to Online Mode',
                    subtitle: 'Access cloud features and real-time updates',
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => _showOnlineModeDialog(context),
                  ),
                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    AppLocalizations.of(context)!.tableManagement,
                  ),
                  const SizedBox(height: 12),
                  const TableSettingsSection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader(AppLocalizations.of(context)!.appearance),
                  const SizedBox(height: 12),
                  const AppearanceSettingsSection(),
                  const SizedBox(height: 32),

                  const SecuritySettingsSection(),
                  const SizedBox(height: 32),

                  _buildSectionHeader(
                    AppLocalizations.of(context)!.importExport,
                  ),
                  const SizedBox(height: 12),
                  const DataSettingsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        color: AppColors.getSubtitleColor(context),
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Future<void> _handleShare(BuildContext context, String filePath) async {
    try {
      await SharePlus.instance.share(
        ShareParams(files: [XFile(filePath)], text: 'Bhansa Ghar Menu Data'),
      );
    } catch (e) {
      debugPrint('Error sharing file: $e');
    }
  }

  void _showOnlineModeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Switch to Online Mode'),
        content: const Text(
          'Are you sure you want to switch to online mode? You will need to restart the app and sign in.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              // Switch mode using ModeBloc
              context.read<ModeBloc>().add(const ModeChanged(AppMode.online));
              // Show confirmation
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text(
                    'Switched to online mode. Please restart the app.',
                  ),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                ),
              );
            },
            child: const Text('Switch'),
          ),
        ],
      ),
    );
  }
}
