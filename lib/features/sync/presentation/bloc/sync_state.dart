part of 'sync_bloc.dart';

enum SyncStatus { idle, syncing, success, failure, noWork }

class SyncState extends Equatable {
  const SyncState({
    this.status = SyncStatus.idle,
    this.errorMessage,
    this.hasPendingWork = false,
  });

  static const String nothingToSyncMessage = 'Nothing to sync';

  final SyncStatus status;
  final String? errorMessage;
  final bool hasPendingWork;

  bool get isSyncing => status == SyncStatus.syncing;
  bool get canSync => hasPendingWork && !isSyncing;

  SyncState copyWith({
    SyncStatus? status,
    String? errorMessage,
    bool? hasPendingWork,
    bool clearError = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      hasPendingWork: hasPendingWork ?? this.hasPendingWork,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, hasPendingWork];
}
