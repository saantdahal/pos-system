import 'package:equatable/equatable.dart';
import '../../data/menu_item.dart';

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class LoadMenu extends MenuEvent {}

class AddMenuItem extends MenuEvent {
  final MenuItem item;

  const AddMenuItem(this.item);

  @override
  List<Object> get props => [item];
}

class UpdateMenuItem extends MenuEvent {
  final MenuItem item;

  const UpdateMenuItem(this.item);

  @override
  List<Object> get props => [item];
}

class DeleteMenuItem extends MenuEvent {
  final String id;

  const DeleteMenuItem(this.id);

  @override
  List<Object> get props => [id];
}
