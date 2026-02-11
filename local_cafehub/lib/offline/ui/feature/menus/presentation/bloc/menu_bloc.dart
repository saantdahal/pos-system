import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/menu_repository.dart';
import 'menu_event.dart';
import 'menu_state.dart';

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  final MenuRepository _menuRepository;

  MenuBloc({required MenuRepository menuRepository})
    : _menuRepository = menuRepository,
      super(const MenuState()) {
    on<LoadMenu>(_onLoadMenu);
    on<AddMenuItem>(_onAddMenuItem);
    on<UpdateMenuItem>(_onUpdateMenuItem);
    on<DeleteMenuItem>(_onDeleteMenuItem);
  }

  Future<void> _onLoadMenu(LoadMenu event, Emitter<MenuState> emit) async {
    emit(state.copyWith(status: MenuStatus.loading));
    try {
      final items = await _menuRepository.getMenu();
      emit(state.copyWith(status: MenuStatus.loaded, items: items));
    } catch (e) {
      emit(
        state.copyWith(status: MenuStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onAddMenuItem(
    AddMenuItem event,
    Emitter<MenuState> emit,
  ) async {
    try {
      await _menuRepository.addMenuItem(event.item);
      add(LoadMenu());
    } catch (e) {
      emit(
        state.copyWith(status: MenuStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onUpdateMenuItem(
    UpdateMenuItem event,
    Emitter<MenuState> emit,
  ) async {
    try {
      await _menuRepository.updateMenuItem(event.item);
      add(LoadMenu());
    } catch (e) {
      emit(
        state.copyWith(status: MenuStatus.error, errorMessage: e.toString()),
      );
    }
  }

  Future<void> _onDeleteMenuItem(
    DeleteMenuItem event,
    Emitter<MenuState> emit,
  ) async {
    try {
      await _menuRepository.deleteMenuItem(event.id);
      add(LoadMenu());
    } catch (e) {
      emit(
        state.copyWith(status: MenuStatus.error, errorMessage: e.toString()),
      );
    }
  }
}
