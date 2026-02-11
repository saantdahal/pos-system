import 'package:equatable/equatable.dart';
import 'package:bhansa_ghar/online/core/models/category/category_request.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryLoadRequested extends CategoryEvent {
  const CategoryLoadRequested();
}

class CategoryCreateRequested extends CategoryEvent {
  final CategoryRequest request;

  const CategoryCreateRequested(this.request);

  @override
  List<Object> get props => [request];
}

class CategoryUpdateRequested extends CategoryEvent {
  final int id;
  final CategoryRequest request;

  const CategoryUpdateRequested(this.id, this.request);

  @override
  List<Object> get props => [id, request];
}

class CategoryDeleteRequested extends CategoryEvent {
  final int id;

  const CategoryDeleteRequested(this.id);

  @override
  List<Object> get props => [id];
}

class CategoryDetailRequested extends CategoryEvent {
  final int id;

  const CategoryDetailRequested(this.id);

  @override
  List<Object> get props => [id];
}
