import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/data/models/category.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/bloc/category_bloc.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/bloc/category_event.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/bloc/category_state.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/widgets/category_card.dart';
import 'package:bhansa_ghar/offline/ui/feature/categories/presentation/widgets/add_edit_category_dialog.dart';
import 'package:bhansa_ghar/offline/core/theme.dart';
import 'package:bhansa_ghar/offline/core/l10n/app_localizations.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          AppLocalizations.of(context)!.manageCategories,
          style: TextStyle(
            color: AppColors.getTextColor(context),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state.status == CategoryStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: Colors.orange),
            );
          }
          if (state.status == CategoryStatus.error) {
            return Center(
              child: Text(
                '${AppLocalizations.of(context)!.serverError} ${state.errorMessage}',
                style: TextStyle(color: AppColors.getTextColor(context)),
              ),
            );
          }
          if (state.categories.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.category_outlined,
                    size: 80,
                    color: AppColors.getSubtitleColor(context),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppLocalizations.of(context)!.noCategoriesYet,
                    style: TextStyle(
                      color: AppColors.getSubtitleColor(context),
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.tapPlusToAddCategory,
                    style: TextStyle(
                      color: AppColors.getSubtitleColor(context),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              return CategoryCard(
                category: category,
                onEdit: () => _showAddEditDialog(context, category: category),
                onDelete: () => _showDeleteConfirmation(context, category),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddEditDialog(context),
        backgroundColor: Colors.orange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, {Category? category}) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AddEditCategoryDialog(
          category: category,
          onSave: (newCategory) {
            if (category == null) {
              context.read<CategoryBloc>().add(AddCategory(newCategory));
            } else {
              context.read<CategoryBloc>().add(UpdateCategory(newCategory));
            }
          },
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.getDialogBackground(context),
          title: Text(
            AppLocalizations.of(context)!.deleteCategory,
            style: TextStyle(color: AppColors.getTextColor(context)),
          ),
          content: Text(
            '${AppLocalizations.of(context)!.confirmDeleteCategory} "${category.getLocalizedName(Localizations.localeOf(context).languageCode)}"?',
            style: TextStyle(color: AppColors.getTextColor(context)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'Cancel',
                style: TextStyle(color: AppColors.getSubtitleColor(context)),
              ),
            ),
            TextButton(
              onPressed: () {
                context.read<CategoryBloc>().add(DeleteCategory(category.id));
                Navigator.pop(dialogContext);
              },
              child: Text(
                AppLocalizations.of(context)!.delete,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
