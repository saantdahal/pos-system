import 'package:bhansa_ghar/online/ui/feature/menu/domain/models/category_model.dart';
import 'package:bhansa_ghar/online/ui/feature/menu/domain/models/menu_item_model.dart';
import 'package:equatable/equatable.dart';

abstract class MenuState extends Equatable {
  const MenuState();

  @override
  List<Object?> get props => [];
}

class MenuInitial extends MenuState {
  const MenuInitial();
}

class MenuLoading extends MenuState {
  const MenuLoading();
}

class MenuLoaded extends MenuState {
  final List<MenuItemModel> items;
  final List<MenuItemModel> filteredItems;
  final List<CategoryModel> categories;
  final int? selectedCategoryId;
  final String searchQuery;

  const MenuLoaded({
    required this.items,
    required this.filteredItems,
    required this.categories,
    this.selectedCategoryId,
    this.searchQuery = '',
  });

  MenuLoaded copyWith({
    List<MenuItemModel>? items,
    List<MenuItemModel>? filteredItems,
    List<CategoryModel>? categories,
    int? selectedCategoryId,
    String? searchQuery,
  }) {
    return MenuLoaded(
      items: items ?? this.items,
      filteredItems: filteredItems ?? this.filteredItems,
      categories: categories ?? this.categories,
      selectedCategoryId: selectedCategoryId ?? this.selectedCategoryId,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [
    items,
    filteredItems,
    categories,
    selectedCategoryId,
    searchQuery,
  ];
}

class MenuError extends MenuState {
  final String message;
  const MenuError(this.message);

  @override
  List<Object?> get props => [message];
}

class MenuItemCreating extends MenuState {
  const MenuItemCreating();
}

class MenuItemCreatedSuccess extends MenuState {
  final MenuItemModel item;
  const MenuItemCreatedSuccess(this.item);

  @override
  List<Object?> get props => [item];
}

class MenuItemUpdating extends MenuState {
  const MenuItemUpdating();
}

class MenuItemUpdatedSuccess extends MenuState {
  final MenuItemModel item;
  const MenuItemUpdatedSuccess(this.item);

  @override
  List<Object?> get props => [item];
}

class MenuItemDeleting extends MenuState {
  final int itemId;
  const MenuItemDeleting(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class MenuItemDeletedSuccess extends MenuState {
  final int itemId;
  const MenuItemDeletedSuccess(this.itemId);

  @override
  List<Object?> get props => [itemId];
}
