part of 'category_bloc.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object?> get props => [];
}

class CategoryLoadRequested extends CategoryEvent {
  const CategoryLoadRequested();
}

class CategoryAddRequested extends CategoryEvent {
  const CategoryAddRequested(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

class CategoryDeleteRequested extends CategoryEvent {
  const CategoryDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}

class CategoryRefreshAfterSyncRequested extends CategoryEvent {
  const CategoryRefreshAfterSyncRequested();
}
