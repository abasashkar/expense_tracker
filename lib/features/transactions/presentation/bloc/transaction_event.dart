part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class TransactionLoadDashboardRequested extends TransactionEvent {
  const TransactionLoadDashboardRequested();
}

class TransactionLoadAllRequested extends TransactionEvent {
  const TransactionLoadAllRequested();
}

class TransactionLoadUnsyncedRequested extends TransactionEvent {
  const TransactionLoadUnsyncedRequested();
}

/// Refreshes lists and totals after sync without showing the loading shimmer.
class TransactionRefreshAfterSyncRequested extends TransactionEvent {
  const TransactionRefreshAfterSyncRequested();
}

class TransactionAddRequested extends TransactionEvent {
  const TransactionAddRequested({
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
  });

  final double amount;
  final String note;
  final TransactionType type;
  final String categoryId;

  @override
  List<Object?> get props => [amount, note, type, categoryId];
}

class TransactionDeleteRequested extends TransactionEvent {
  const TransactionDeleteRequested(this.id);

  final String id;

  @override
  List<Object?> get props => [id];
}
