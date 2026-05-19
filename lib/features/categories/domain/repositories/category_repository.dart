import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<({List<Category>? data, Failure? failure})> getCategories();

  Future<({Category? data, Failure? failure})> addCategory(String name);

  Future<({bool? data, Failure? failure})> deleteCategory(String id);

  Future<({List<Category>? data, Failure? failure})> getUnsyncedCategories();

  Future<({List<String>? data, Failure? failure})> getDeletedCategoryIds();

  Future<({bool? data, Failure? failure})> markCategoriesSynced(List<String> ids);

  Future<({bool? data, Failure? failure})> permanentlyDeleteCategories(
    List<String> ids,
  );
}
