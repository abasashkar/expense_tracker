part of 'sync_bloc.dart';

abstract class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

class SyncRequested extends SyncEvent {
  const SyncRequested();
}

class SyncPendingStatusRequested extends SyncEvent {
  const SyncPendingStatusRequested();
}
