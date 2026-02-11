import 'package:bhansa_ghar/online/ui/feature/menu/domain/models/menu_item_model.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/domain/repositories/menu_repository.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bhansa_ghar/online/core/services/user_friendly_response_service.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository menuRepository;

  MenuBloc({required this.menuRepository}) : super(const MenuInitial()) {
    on<MenuInitialized>(_onMenuInitialized);
    on<CategoriesFetched>(_onCategoriesFetched);
    on<MenuSearched>(_onMenuSearched);
    on<MenuCategoryFiltered>(_onMenuCategoryFiltered);
    on<MenuRefreshed>(_onMenuRefreshed);
    on<MenuItemCreated>(_onMenuItemCreated);
    on<MenuItemUpdated>(_onMenuItemUpdated);
    on<MenuItemDeleted>(_onMenuItemDeleted);
    on<MenuFilterCleared>(_onMenuFilterCleared);
    on<MenuItemStockUpdated>(_onMenuItemStockUpdated);
  }

  Future<void> _onMenuInitialized(
    MenuInitialized event,
    Emitter<MenuState> emit,
  ) async {
    emit(const MenuLoading());
    try {
      debugPrint('🔄 MenuBloc: Initializing menu...');
      final items = await menuRepository.getMenuItems();
      debugPrint('✅ MenuBloc: Fetched ${items.length} menu items');

      final categories = await menuRepository.getCategories();
      debugPrint('✅ MenuBloc: Fetched ${categories.length} categories');

      emit(
        MenuLoaded(items: items, filteredItems: items, categories: categories),
      );
      debugPrint('✅ MenuBloc: Menu initialized successfully');
    } catch (e) {
      debugPrint('❌ MenuBloc: Error initializing menu: $e');
      final errorMessage = UserFriendlyResponseService.getErrorMessage(e);
      emit(MenuError(errorMessage));
    }
  }

  Future<void> _onCategoriesFetched(
    CategoriesFetched event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      try {
        final categories = await menuRepository.getCategories();
        emit(currentState.copyWith(categories: categories));
      } catch (e) {
        debugPrint('Error fetching categories: $e');
        emit(MenuError('Failed to load categories: ${e.toString()}'));
      }
    }
  }

  Future<void> _onMenuSearched(
    MenuSearched event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      final query = event.query.toLowerCase();

      List<MenuItemModel> filtered = currentState.items;

      // Filter by search query
      if (query.isNotEmpty) {
        filtered = filtered
            .where(
              (item) =>
                  item.name.toLowerCase().contains(query) ||
                  item.description.toLowerCase().contains(query),
            )
            .toList();
      }

      // Apply category filter
      if (currentState.selectedCategoryId != null) {
        filtered = filtered
            .where((item) => item.category == currentState.selectedCategoryId)
            .toList();
      }

      emit(
        currentState.copyWith(
          filteredItems: filtered,
          searchQuery: event.query,
        ),
      );
    }
  }

  Future<void> _onMenuCategoryFiltered(
    MenuCategoryFiltered event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      List<MenuItemModel> filtered = currentState.items;

      // Apply category filter
      filtered = filtered
          .where((item) => item.category == event.categoryId)
          .toList();

      // Apply search filter
      if (currentState.searchQuery.isNotEmpty) {
        final query = currentState.searchQuery.toLowerCase();
        filtered = filtered
            .where(
              (item) =>
                  item.name.toLowerCase().contains(query) ||
                  item.description.toLowerCase().contains(query),
            )
            .toList();
      }

      emit(
        currentState.copyWith(
          filteredItems: filtered,
          selectedCategoryId: event.categoryId,
        ),
      );
    }
  }

  Future<void> _onMenuFilterCleared(
    MenuFilterCleared event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(
        currentState.copyWith(
          filteredItems: currentState.items,
          selectedCategoryId: null,
          searchQuery: '',
        ),
      );
    }
  }

  Future<void> _onMenuRefreshed(
    MenuRefreshed event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      emit(const MenuLoading());
      try {
        final items = await menuRepository.getMenuItems();
        final categories = await menuRepository.getCategories();
        final currentState = state as MenuLoaded;

        emit(
          MenuLoaded(
            items: items,
            filteredItems: items,
            categories: categories,
            selectedCategoryId: currentState.selectedCategoryId,
            searchQuery: currentState.searchQuery,
          ),
        );
      } catch (e) {
        debugPrint('Error refreshing menu: $e');
        emit(MenuError('Failed to refresh menu: ${e.toString()}'));
      }
    }
  }

  Future<void> _onMenuItemCreated(
    MenuItemCreated event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(const MenuItemCreating());

      try {
        debugPrint('🔄 MenuBloc: Creating menu item: ${event.item.name}');
        final createdItem = await menuRepository.createMenuItem(
          event.item,
          event.imagePath,
        );
        debugPrint(
          '✅ MenuBloc: Menu item created: ID=${createdItem.id}, Name=${createdItem.name}',
        );
        final updatedItems = [...currentState.items, createdItem];

        // Apply current filters
        List<MenuItemModel> filtered = updatedItems;

        if (currentState.selectedCategoryId != null) {
          filtered = filtered
              .where((item) => item.category == currentState.selectedCategoryId)
              .toList();
        }

        if (currentState.searchQuery.isNotEmpty) {
          final query = currentState.searchQuery.toLowerCase();
          filtered = filtered
              .where(
                (item) =>
                    item.name.toLowerCase().contains(query) ||
                    item.description.toLowerCase().contains(query),
              )
              .toList();
        }

        emit(
          MenuLoaded(
            items: updatedItems,
            filteredItems: filtered,
            categories: currentState.categories,
            selectedCategoryId: currentState.selectedCategoryId,
            searchQuery: currentState.searchQuery,
          ),
        );
        emit(MenuItemCreatedSuccess(createdItem));
      } catch (e) {
        debugPrint('Error creating menu item: $e');
        emit(MenuError('Failed to create menu item: ${e.toString()}'));
      }
    }
  }

  Future<void> _onMenuItemUpdated(
    MenuItemUpdated event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(const MenuItemUpdating());

      try {
        debugPrint('🔄 MenuBloc: Updating menu item: ID=${event.itemId}');
        final updatedItem = await menuRepository.updateMenuItem(
          event.itemId,
          event.item,
          event.imagePath,
        );
        debugPrint('✅ MenuBloc: Menu item updated: ID=${updatedItem.id}');

        final updatedItems = currentState.items.map((item) {
          return item.id == event.itemId ? updatedItem : item;
        }).toList();

        // Apply current filters
        List<MenuItemModel> filtered = updatedItems;

        if (currentState.selectedCategoryId != null) {
          filtered = filtered
              .where((item) => item.category == currentState.selectedCategoryId)
              .toList();
        }

        if (currentState.searchQuery.isNotEmpty) {
          final query = currentState.searchQuery.toLowerCase();
          filtered = filtered
              .where(
                (item) =>
                    item.name.toLowerCase().contains(query) ||
                    item.description.toLowerCase().contains(query),
              )
              .toList();
        }

        emit(
          MenuLoaded(
            items: updatedItems,
            filteredItems: filtered,
            categories: currentState.categories,
            selectedCategoryId: currentState.selectedCategoryId,
            searchQuery: currentState.searchQuery,
          ),
        );
        emit(MenuItemUpdatedSuccess(updatedItem));
      } catch (e) {
        debugPrint('Error updating menu item: $e');
        emit(MenuError('Failed to update menu item: ${e.toString()}'));
      }
    }
  }

  Future<void> _onMenuItemDeleted(
    MenuItemDeleted event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;
      emit(MenuItemDeleting(event.itemId));

      try {
        debugPrint('🔄 MenuBloc: Deleting menu item: ID=${event.itemId}');
        await menuRepository.deleteMenuItem(event.itemId);
        debugPrint('✅ MenuBloc: Menu item deleted: ID=${event.itemId}');

        final updatedItems = currentState.items
            .where((item) => item.id != event.itemId)
            .toList();

        // Apply current filters
        List<MenuItemModel> filtered = updatedItems;

        if (currentState.selectedCategoryId != null) {
          filtered = filtered
              .where((item) => item.category == currentState.selectedCategoryId)
              .toList();
        }

        if (currentState.searchQuery.isNotEmpty) {
          final query = currentState.searchQuery.toLowerCase();
          filtered = filtered
              .where(
                (item) =>
                    item.name.toLowerCase().contains(query) ||
                    item.description.toLowerCase().contains(query),
              )
              .toList();
        }

        emit(
          MenuLoaded(
            items: updatedItems,
            filteredItems: filtered,
            categories: currentState.categories,
            selectedCategoryId: currentState.selectedCategoryId,
            searchQuery: currentState.searchQuery,
          ),
        );
        emit(MenuItemDeletedSuccess(event.itemId));
      } catch (e) {
        debugPrint('Error deleting menu item: $e');
        emit(MenuError('Failed to delete menu item: ${e.toString()}'));
      }
    }
  }

  Future<void> _onMenuItemStockUpdated(
    MenuItemStockUpdated event,
    Emitter<MenuState> emit,
  ) async {
    if (state is MenuLoaded) {
      final currentState = state as MenuLoaded;

      try {
        final updatedItem = await menuRepository.updateMenuItemStock(
          event.itemId,
          event.stockQuantity,
        );

        final updatedItems = currentState.items.map((item) {
          return item.id == event.itemId ? updatedItem : item;
        }).toList();

        // Apply current filters
        List<MenuItemModel> filtered = updatedItems;

        if (currentState.selectedCategoryId != null) {
          filtered = filtered
              .where((item) => item.category == currentState.selectedCategoryId)
              .toList();
        }

        if (currentState.searchQuery.isNotEmpty) {
          final query = currentState.searchQuery.toLowerCase();
          filtered = filtered
              .where(
                (item) =>
                    item.name.toLowerCase().contains(query) ||
                    item.description.toLowerCase().contains(query),
              )
              .toList();
        }

        emit(
          MenuLoaded(
            items: updatedItems,
            filteredItems: filtered,
            categories: currentState.categories,
            selectedCategoryId: currentState.selectedCategoryId,
            searchQuery: currentState.searchQuery,
          ),
        );
      } catch (e) {
        debugPrint('Error updating menu item stock: $e');
        emit(MenuError('Failed to update stock: ${e.toString()}'));
      }
    }
  }
}
