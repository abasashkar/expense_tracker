part of 'category_bloc.dart';

enum CategoryStatus { initial, loading, success, failure }

class CategoryState extends Equatable {
  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  final CategoryStatus status;
  final List<Category> categories;
  final String? errorMessage;

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}
