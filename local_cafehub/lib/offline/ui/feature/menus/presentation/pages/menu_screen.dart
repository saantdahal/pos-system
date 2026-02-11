import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/core/services/data_export_import_service.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/utils/snackbar.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/domain/repositories/category_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/domain/menu_repository.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/data/menu_item.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/presentation/bloc/menu_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/presentation/bloc/menu_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/presentation/bloc/menu_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/presentation/widgets/category_widget.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/presentation/widgets/menu_card.dart';
import 'package:bhansa_ghar/offline/ui/feature/menus/presentation/widgets/add_edit_menu_dialog.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/bloc/category_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/bloc/category_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/bloc/category_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/bloc/data_import_export_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/bloc/data_import_export_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/bloc/data_import_export_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/settings/presentation/widgets/import_confirmation_dialog.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    context.read<MenuBloc>().add(LoadMenu());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DataImportExportBloc(
        service: DataExportImportService(),
        categoryRepository: RepositoryProvider.of<CategoryRepository>(context),
        menuRepository: RepositoryProvider.of<MenuRepository>(context),
      ),
      child: Builder(
        builder: (context) =>
            BlocListener<DataImportExportBloc, DataImportExportState>(
              listener: (context, state) {
                if (state is DataImportSuccess) {
                  snackBar(
                    messageType: MessageType.success,
                    message: AppLocalizations.of(context)!
                        .importedCategoriesAndItems(
                          state.categoriesCount,
                          state.menuItemsCount,
                        ),
                  );

                  // Reload data
                  context.read<CategoryBloc>().add(LoadCategories());
                  context.read<MenuBloc>().add(LoadMenu());
                  context.read<DataImportExportBloc>().add(ResetStateEvent());
                } else if (state is DataImportExportError) {
                  snackBar(
                    messageType: MessageType.error,
                    message: state.message,
                  );
                  context.read<DataImportExportBloc>().add(ResetStateEvent());
                }
              },
              child: Scaffold(
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                appBar: AppBar(
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  leading: IconButton(
                    onPressed: () {
                      context.go('/');
                    },
                    icon: Icon(
                      Icons.arrow_back_ios_new,
                      color: Theme.of(context).iconTheme.color,
                    ),
                  ),
                  title: Text(
                    AppLocalizations.of(context)!.menuManagement,
                    style: TextStyle(
                      color: AppColors.getTextColor(context),
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: Icon(
                        Icons.file_upload_outlined,
                        color: Theme.of(context).iconTheme.color,
                      ),
                      onPressed: () => _showImportDialog(context),
                    ),
                  ],
                ),
                body: BlocBuilder<CategoryBloc, CategoryState>(
                  builder: (context, categoryState) {
                    final languageCode = Localizations.localeOf(
                      context,
                    ).languageCode;
                    final categories = [
                      MapEntry('All', AppLocalizations.of(context)!.all),
                      ...categoryState.categories.map(
                        (e) => MapEntry(e.id, e.getLocalizedName(languageCode)),
                      ),
                    ];

                    return Column(
                      children: [
                        // Category Selector
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: categories.asMap().entries.map((entry) {
                                final index = entry.key;
                                final category = entry.value;
                                return Row(
                                  children: [
                                    if (index > 0) const SizedBox(width: 12),
                                    CategoryTab(
                                      label: category.value,
                                      isSelected:
                                          _selectedCategory == category.key,
                                      onTap: () => setState(
                                        () => _selectedCategory = category.key,
                                      ),
                                    ),
                                  ],
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                        // Menu List
                        Expanded(
                          child: BlocBuilder<MenuBloc, MenuState>(
                            builder: (context, menuState) {
                              if (menuState.status == MenuStatus.loading) {
                                return Center(
                                  child: CircularProgressIndicator(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                  ),
                                );
                              }
                              if (menuState.status == MenuStatus.error) {
                                return Center(
                                  child: Text(
                                    '${AppLocalizations.of(context)!.serverError} ${menuState.errorMessage}',
                                    style: TextStyle(
                                      color: AppColors.getTextColor(context),
                                    ),
                                  ),
                                );
                              }

                              final filteredItems = _selectedCategory == 'All'
                                  ? menuState.items
                                  : menuState.items
                                        .where(
                                          (item) =>
                                              item.category ==
                                              _selectedCategory,
                                        )
                                        .toList();

                              if (filteredItems.isEmpty) {
                                return Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.restaurant_menu,
                                        size: 80,
                                        color: AppColors.getSubtitleColor(
                                          context,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.noItemsInCategory,
                                        style: TextStyle(
                                          color: AppColors.getSubtitleColor(
                                            context,
                                          ),
                                          fontSize: 16,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        AppLocalizations.of(
                                          context,
                                        )!.tapPlusToAddItem,
                                        style: TextStyle(
                                          color: AppColors.getSubtitleColor(
                                            context,
                                          ),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }

                              return ListView.builder(
                                padding: const EdgeInsets.all(16.0),
                                itemCount: filteredItems.length,
                                itemBuilder: (context, index) {
                                  final item = filteredItems[index];
                                  return MenuCard(
                                    item: item,
                                    onEdit: () =>
                                        _showAddEditDialog(context, item: item),
                                    onDelete: () => context
                                        .read<MenuBloc>()
                                        .add(DeleteMenuItem(item.id)),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () => _showAddEditDialog(context),
                  backgroundColor: AppColors.orange,
                  child: const Icon(Icons.add, color: AppColors.white),
                ),
              ),
            ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {MenuItem? item}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AddEditMenuDialog(
          item: item,
          onSave: (newItem) {
            if (item == null) {
              context.read<MenuBloc>().add(AddMenuItem(newItem));
            } else {
              context.read<MenuBloc>().add(UpdateMenuItem(newItem));
            }
          },
        );
      },
    );
  }

  Future<void> _showImportDialog(BuildContext context) async {
    try {
      // Capture localized strings BEFORE any async operations
      final unsupportedFormatError = AppLocalizations.of(
        context,
      )!.unsupportedFileFormat;

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
        throw Exception(unsupportedFormatError);
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
      final errorMessage = AppLocalizations.of(context)!.failedToReadFile;
      if (!context.mounted) return;
      snackBar(message: '$errorMessage $e', messageType: MessageType.error);
    }
  }
}
