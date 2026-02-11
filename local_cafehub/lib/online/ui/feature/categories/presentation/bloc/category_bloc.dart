import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/core/repositories/category_repository.dart';
import 'package:bhansa_ghar/online/core/services/user_friendly_response_service.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository,
      super(const CategoryInitial()) {
    on<CategoryLoadRequested>(_onCategoryLoadRequested);
    on<CategoryCreateRequested>(_onCategoryCreateRequested);
    on<CategoryUpdateRequested>(_onCategoryUpdateRequested);
    on<CategoryDeleteRequested>(_onCategoryDeleteRequested);
    on<CategoryDetailRequested>(_onCategoryDetailRequested);
  }

  Future<void> _onCategoryLoadRequested(
    CategoryLoadRequested event,
    Emitter<CategoryState> emit,
  ) async {
    debugPrint('CategoryBloc: _onCategoryLoadRequested called');
    emit(const CategoryLoading());
    try {
      final categories = await _categoryRepository.listCategories();
      debugPrint('CategoryBloc: Loaded ${categories.length} categories');
      emit(CategoryLoaded(categories));
    } catch (e) {
      debugPrint('CategoryBloc: Error loading categories: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(CategoryError(errorMessage));
    }
  }

  Future<void> _onCategoryCreateRequested(
    CategoryCreateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    debugPrint('CategoryBloc: _onCategoryCreateRequested called');
    emit(const CategoryLoading());
    try {
      final category = await _categoryRepository.createCategory(event.request);
      debugPrint('CategoryBloc: Category created: ${category.name}');
      emit(CategoryCreated(category));
      // Reload categories after creation
      await _reloadCategories(emit);
    } catch (e) {
      debugPrint('CategoryBloc: Error creating category: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(CategoryError(errorMessage));
    }
  }

  Future<void> _onCategoryUpdateRequested(
    CategoryUpdateRequested event,
    Emitter<CategoryState> emit,
  ) async {
    debugPrint('CategoryBloc: _onCategoryUpdateRequested called');
    emit(const CategoryLoading());
    try {
      final category = await _categoryRepository.updateCategory(
        event.id,
        event.request,
      );
      debugPrint('CategoryBloc: Category updated: ${category.name}');
      emit(CategoryUpdated(category));
      // Reload categories after update
      await _reloadCategories(emit);
    } catch (e) {
      debugPrint('CategoryBloc: Error updating category: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(CategoryError(errorMessage));
    }
  }

  Future<void> _onCategoryDeleteRequested(
    CategoryDeleteRequested event,
    Emitter<CategoryState> emit,
  ) async {
    debugPrint('CategoryBloc: _onCategoryDeleteRequested called');
    emit(const CategoryLoading());
    try {
      await _categoryRepository.deleteCategory(event.id);
      debugPrint('CategoryBloc: Category deleted: ${event.id}');
      emit(CategoryDeleted(event.id));
      // Reload categories after deletion
      await _reloadCategories(emit);
    } catch (e) {
      debugPrint('CategoryBloc: Error deleting category: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(CategoryError(errorMessage));
    }
  }

  Future<void> _onCategoryDetailRequested(
    CategoryDetailRequested event,
    Emitter<CategoryState> emit,
  ) async {
    debugPrint('CategoryBloc: _onCategoryDetailRequested called');
    emit(const CategoryLoading());
    try {
      final category = await _categoryRepository.getCategoryDetail(event.id);
      debugPrint('CategoryBloc: Category detail loaded: ${category.name}');
      emit(CategoryDetailLoaded(category));
    } catch (e) {
      debugPrint('CategoryBloc: Error loading category detail: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(CategoryError(errorMessage));
    }
  }

  Future<void> _reloadCategories(Emitter<CategoryState> emit) async {
    try {
      final categories = await _categoryRepository.listCategories();
      emit(CategoryLoaded(categories));
    } catch (e) {
      debugPrint('CategoryBloc: Error reloading categories: $e');
    }
  }
}
