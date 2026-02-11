import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:bhansaghar_staff/features/kitchen/inventory/repositories/inventory_repository.dart';

// Events
abstract class InventoryEvent extends Equatable {
  const InventoryEvent();
  @override
  List<Object?> get props => [];
}

class LoadInventory extends InventoryEvent {}

class UpdateStock extends InventoryEvent {
  final int itemId;
  final int? quantity;

  const UpdateStock(this.itemId, this.quantity);

  @override
  List<Object?> get props => [itemId, quantity];
}

// State
class InventoryState extends Equatable {
  final bool isLoading;
  final List<dynamic> categories; // Raw JSON for now
  final List<dynamic> items; // Raw JSON for now
  final String? error;

  const InventoryState({
    this.isLoading = false,
    this.categories = const [],
    this.items = const [],
    this.error,
  });

  InventoryState copyWith({
    bool? isLoading,
    List<dynamic>? categories,
    List<dynamic>? items,
    String? error,
  }) {
    return InventoryState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [isLoading, categories, items, error];
}

// BLoC
class InventoryBloc extends Bloc<InventoryEvent, InventoryState> {
  final InventoryRepository _repository;

  InventoryBloc(this._repository) : super(const InventoryState()) {
    on<LoadInventory>(_onLoadInventory);
    on<UpdateStock>(_onUpdateStock);
  }

  Future<void> _onLoadInventory(
    LoadInventory event,
    Emitter<InventoryState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final data = await _repository.getMenu();
      // data[0] is categories, data[1] is items
      emit(
        state.copyWith(
          isLoading: false,
          categories: data[0] as List,
          items: data[1] as List,
        ),
      );
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onUpdateStock(
    UpdateStock event,
    Emitter<InventoryState> emit,
  ) async {
    try {
      // Optimistic update could go here, but for simplicity we reload or just update local state
      // Let's implement optimistic update for smoother UI
      final updatedItems = state.items.map((item) {
        if (item['id'].toString() == event.itemId.toString()) {
          final newItem = Map<String, dynamic>.from(item);
          newItem['stock_quantity'] = event.quantity;
          return newItem;
        }
        return item;
      }).toList();

      emit(state.copyWith(items: updatedItems));

      await _repository.updateStock(event.itemId, event.quantity);
      // Success, maybe show toast? handled by UI listener usually.
    } catch (e) {
      // Revert on failure
      add(LoadInventory()); // Reload to be safe
      emit(state.copyWith(error: "Failed to update stock: $e"));
    }
  }
}
