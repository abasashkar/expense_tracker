import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  CategoryBloc({required CategoryRepository repository})
      : _repository = repository,
        super(const CategoryState()) {
    on<CategoryLoadRequested>(_onLoad);
    on<CategoryLoadUnsyncedRequested>(_onLoadUnsynced);
    on<CategoryAddRequested>(_onAdd);
    on<CategoryDeleteRequested>(_onDelete);
    on<CategoryRefreshAfterSyncRequested>(_onRefreshAfterSync);
  }

  final CategoryRepository _repository;

  Future<void> _onLoad(
    CategoryLoadRequested event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    final result = await _repository.getCategories();
    if (result.failure != null) {
      emit(state.copyWith(
        status: CategoryStatus.failure,
        errorMessage: result.failure!.message,
      ));
      return;
    }
    emit(state.copyWith(
      status: CategoryStatus.success,
      categories: result.data ?? [],
      clearError: true,
    ));
  }

  Future<void> _onLoadUnsynced(
    CategoryLoadUnsyncedRequested event,
    Emitter<CategoryState> emit,
  ) async {
    if (state.unsyncedCategories.isEmpty) {
      emit(state.copyWith(status: CategoryStatus.loading));
    }
    final result = await _repository.getUnsyncedCategories();
    if (result.failure != null) {
      emit(state.copyWith(
        status: CategoryStatus.failure,
        errorMessage: result.failure!.message,
      ));
      return;
    }
    emit(state.copyWith(
      status: CategoryStatus.success,
      unsyncedCategories: result.data ?? [],
      clearError: true,
    ));
  }

  Future<void> _onAdd(
    CategoryAddRequested event,
    Emitter<CategoryState> emit,
  ) async {
    if (event.name.trim().isEmpty) return;
    final result = await _repository.addCategory(event.name);
    if (result.failure != null) {
      emit(state.copyWith(errorMessage: result.failure!.message));
      return;
    }

    final category = result.data!;
    emit(state.copyWith(
      status: CategoryStatus.success,
      categories: [...state.categories, category],
      unsyncedCategories: [...state.unsyncedCategories, category],
      clearError: true,
    ));
  }

  Future<void> _onDelete(
    CategoryDeleteRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final previousCategories = state.categories;
    final previousUnsynced = state.unsyncedCategories;

    final filtered =
        state.categories.where((c) => c.id != event.id).toList();
    final filteredUnsynced =
        state.unsyncedCategories.where((c) => c.id != event.id).toList();

    emit(state.copyWith(
      categories: filtered,
      unsyncedCategories: filteredUnsynced,
    ));

    final result = await _repository.deleteCategory(event.id);
    if (result.failure != null) {
      emit(state.copyWith(
        categories: previousCategories,
        unsyncedCategories: previousUnsynced,
        errorMessage: result.failure!.message,
      ));
    }
  }

  Future<void> _onRefreshAfterSync(
    CategoryRefreshAfterSyncRequested event,
    Emitter<CategoryState> emit,
  ) async {
    final active = await _repository.getCategories();
    final unsynced = await _repository.getUnsyncedCategories();
    if (active.failure != null) return;
    emit(state.copyWith(
      status: CategoryStatus.success,
      categories: active.data ?? [],
      unsyncedCategories: unsynced.data ?? [],
      clearError: true,
    ));
  }
}
