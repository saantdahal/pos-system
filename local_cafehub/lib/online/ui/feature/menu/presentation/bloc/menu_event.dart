import 'package:bhansa_ghar/online/ui/feature/menu/domain/models/menu_item_model.dart';
import 'package:equatable/equatable.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize menu - fetch categories and items
class MenuInitialized extends MenuEvent {
  const MenuInitialized();
}

/// Search menu items by query
class MenuSearched extends MenuEvent {
  final String query;
  const MenuSearched(this.query);

  @override
  List<Object?> get props => [query];
}

/// Filter menu items by category
class MenuCategoryFiltered extends MenuEvent {
  final int categoryId;
  const MenuCategoryFiltered(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

/// Refresh menu items
class MenuRefreshed extends MenuEvent {
  const MenuRefreshed();
}

/// Fetch categories
class CategoriesFetched extends MenuEvent {
  const CategoriesFetched();
}

/// Create a new menu item
class MenuItemCreated extends MenuEvent {
  final MenuItemModel item;
  final String? imagePath;

  const MenuItemCreated({required this.item, this.imagePath});

  @override
  List<Object?> get props => [item, imagePath];
}

/// Update an existing menu item
class MenuItemUpdated extends MenuEvent {
  final int itemId;
  final MenuItemModel item;
  final String? imagePath;

  const MenuItemUpdated({
    required this.itemId,
    required this.item,
    this.imagePath,
  });

  @override
  List<Object?> get props => [itemId, item, imagePath];
}

/// Delete a menu item
class MenuItemDeleted extends MenuEvent {
  final int itemId;
  const MenuItemDeleted(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Update stock quantity
class MenuItemStockUpdated extends MenuEvent {
  final int itemId;
  final int stockQuantity;

  const MenuItemStockUpdated({
    required this.itemId,
    required this.stockQuantity,
  });

  @override
  List<Object?> get props => [itemId, stockQuantity];
}

/// Clear filters and search
class MenuFilterCleared extends MenuEvent {
  const MenuFilterCleared();
}
