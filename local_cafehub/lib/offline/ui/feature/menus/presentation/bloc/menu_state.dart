import 'package:equatable/equatable.dart';
import '../../data/menu_item.dart';

enum MenuStatus { initial, loading, loaded, error }

class MenuState extends Equatable {
  final MenuStatus status;
  final List<MenuItem> items;
  final String? errorMessage;

  const MenuState({
    this.status = MenuStatus.initial,
    this.items = const [],
    this.errorMessage,
  });

  MenuState copyWith({
    MenuStatus? status,
    List<MenuItem>? items,
    String? errorMessage,
  }) {
    return MenuState(
      status: status ?? this.status,
      items: items ?? this.items,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, items, errorMessage];
}
