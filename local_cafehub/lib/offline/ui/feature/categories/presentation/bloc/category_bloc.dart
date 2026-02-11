import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/category_repository.dart';
import 'category_event.dart';
import 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository _categoryRepository;

  CategoryBloc({required CategoryRepository categoryRepository})
    : _categoryRepository = categoryRepository,
      super(const CategoryState()) {
    on<LoadCategories>(_onLoadCategories);
    on<AddCategory>(_onAddCategory);
    on<UpdateCategory>(_onUpdateCategory);
    on<DeleteCategory>(_onDeleteCategory);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categories = await _categoryRepository.getCategories();
      emit(
        state.copyWith(status: CategoryStatus.loaded, categories: categories),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.addCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.updateCategory(event.category);
      add(LoadCategories());
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoryState> emit,
  ) async {
    try {
      await _categoryRepository.deleteCategory(event.id);
      add(LoadCategories());
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
