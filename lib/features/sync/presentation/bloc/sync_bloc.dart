import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/features/sync/domain/repositories/sync_repository.dart';

part 'sync_event.dart';
part 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  SyncBloc({required SyncRepository repository})
      : _repository = repository,
        super(const SyncState()) {
    on<SyncPendingStatusRequested>(_onPendingStatusRequested);
    on<SyncRequested>(_onSync);
  }

  final SyncRepository _repository;

  Future<void> _onPendingStatusRequested(
    SyncPendingStatusRequested event,
    Emitter<SyncState> emit,
  ) async {
    await _refreshPendingWork(emit);
  }

  Future<void> _refreshPendingWork(Emitter<SyncState> emit) async {
    final result = await _repository.hasPendingWork();
    emit(state.copyWith(
      hasPendingWork: result.data ?? false,
      clearError: true,
    ));
  }

  Future<void> _onSync(SyncRequested event, Emitter<SyncState> emit) async {
    if (state.isSyncing) return;

    await _refreshPendingWork(emit);
    if (!state.hasPendingWork) {
      emit(state.copyWith(status: SyncStatus.noWork));
      await Future<void>.delayed(const Duration(milliseconds: 50));
      emit(state.copyWith(status: SyncStatus.idle));
      return;
    }

    emit(state.copyWith(status: SyncStatus.syncing, clearError: true));

    try {
      final result = await _repository.syncAll();
      if (result.failure != null) {
        emit(state.copyWith(
          status: SyncStatus.failure,
          errorMessage: result.failure!.message,
        ));
        return;
      }
      emit(state.copyWith(status: SyncStatus.success, clearError: true));
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await _refreshPendingWork(emit);
      emit(state.copyWith(status: SyncStatus.idle, clearError: true));
    } catch (e) {
      emit(state.copyWith(
        status: SyncStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }
}
