import 'package:equatable/equatable.dart';
import 'package:bhansa_ghar/online/core/models/category/category.dart';

abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

class CategoryLoaded extends CategoryState {
  final List<Category> categories;

  const CategoryLoaded(this.categories);

  @override
  List<Object> get props => [categories];
}

class CategoryDetailLoaded extends CategoryState {
  final Category category;

  const CategoryDetailLoaded(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryCreated extends CategoryState {
  final Category category;

  const CategoryCreated(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryUpdated extends CategoryState {
  final Category category;

  const CategoryUpdated(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryDeleted extends CategoryState {
  final int id;

  const CategoryDeleted(this.id);

  @override
  List<Object> get props => [id];
}

class CategoryError extends CategoryState {
  final String message;

  const CategoryError(this.message);

  @override
  List<Object> get props => [message];
}
