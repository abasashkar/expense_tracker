import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/uuid_generator.dart';
import 'package:expense_tracker/features/categories/data/datasources/category_local_data_source.dart';
import 'package:expense_tracker/features/categories/data/models/category_model.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  CategoryRepositoryImpl(this._local);

  final CategoryLocalDataSource _local;

  @override
  Future<({List<Category>? data, Failure? failure})> getCategories() async {
    try {
      final list = await _local.getActiveCategories();
      return (data: list, failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({Category? data, Failure? failure})> addCategory(String name) async {
    try {
      final category = CategoryModel(
        id: UuidGenerator.newId(),
        name: name.trim(),
        isSynced: false,
        isDeleted: false,
      );
      final saved = await _local.insert(category);
      return (data: saved, failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({bool? data, Failure? failure})> deleteCategory(String id) async {
    try {
      await _local.softDelete(id);
      return (data: true, failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({List<Category>? data, Failure? failure})> getUnsyncedCategories() async {
    try {
      return (data: await _local.getUnsynced(), failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({List<String>? data, Failure? failure})> getDeletedCategoryIds() async {
    try {
      return (data: await _local.getDeletedIds(), failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({bool? data, Failure? failure})> markCategoriesSynced(
    List<String> ids,
  ) async {
    try {
      await _local.markSynced(ids);
      return (data: true, failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({bool? data, Failure? failure})> permanentlyDeleteCategories(
    List<String> ids,
  ) async {
    try {
      await _local.permanentlyDelete(ids);
      return (data: true, failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }
}
