import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/services/budget_limit_service.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  TransactionBloc({
    required TransactionRepository repository,
    required BudgetLimitService budgetLimitService,
  })  : _repository = repository,
        _budgetLimitService = budgetLimitService,
        super(const TransactionState()) {
    on<TransactionLoadDashboardRequested>(_onLoadDashboard);
    on<TransactionLoadAllRequested>(_onLoadAll);
    on<TransactionLoadUnsyncedRequested>(_onLoadUnsynced);
    on<TransactionRefreshAfterSyncRequested>(_onRefreshAfterSync);
    on<TransactionAddRequested>(_onAdd);
    on<TransactionDeleteRequested>(_onDelete);
  }

  final TransactionRepository _repository;
  final BudgetLimitService _budgetLimitService;

  Future<void> _onLoadDashboard(
    TransactionLoadDashboardRequested event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    final recent = await _repository.getRecentTransactions(limit: 10);
    final totals = await _repository.getTotals();
    final monthly = await _repository.getMonthlyDebitTotal();

    if (recent.failure != null || totals.failure != null) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: recent.failure?.message ?? totals.failure?.message,
      ));
      return;
    }

    emit(state.copyWith(
      status: TransactionStatus.success,
      recentTransactions: recent.data ?? [],
      totalIncome: totals.income ?? 0,
      totalExpense: totals.expense ?? 0,
      monthlyDebit: monthly.data ?? 0,
      clearError: true,
    ));
  }

  Future<void> _onLoadAll(
    TransactionLoadAllRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (state.allTransactions.isEmpty) {
      emit(state.copyWith(status: TransactionStatus.loading));
    }
    final result = await _repository.getAllTransactions();
    if (result.failure != null) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: result.failure!.message,
      ));
      return;
    }
    emit(state.copyWith(
      status: TransactionStatus.success,
      allTransactions: result.data ?? [],
      clearError: true,
    ));
  }

  Future<void> _onLoadUnsynced(
    TransactionLoadUnsyncedRequested event,
    Emitter<TransactionState> emit,
  ) async {
    if (state.unsyncedTransactions.isEmpty) {
      emit(state.copyWith(status: TransactionStatus.loading));
    }
    final result = await _repository.getUnsyncedTransactions();
    if (result.failure != null) {
      emit(state.copyWith(
        status: TransactionStatus.failure,
        errorMessage: result.failure!.message,
      ));
      return;
    }
    emit(state.copyWith(
      status: TransactionStatus.success,
      unsyncedTransactions: result.data ?? [],
      clearError: true,
    ));
  }

  Future<void> _onRefreshAfterSync(
    TransactionRefreshAfterSyncRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final recent = await _repository.getRecentTransactions(limit: 10);
    final totals = await _repository.getTotals();
    final monthly = await _repository.getMonthlyDebitTotal();
    final all = state.allTransactions.isNotEmpty ? await _repository.getAllTransactions() : null;
    final unsynced = await _repository.getUnsyncedTransactions();

    if (recent.failure != null || totals.failure != null) return;

    emit(state.copyWith(
      status: TransactionStatus.success,
      recentTransactions: recent.data ?? [],
      allTransactions: all?.data ?? state.allTransactions,
      unsyncedTransactions: unsynced.data ?? [],
      totalIncome: totals.income ?? 0,
      totalExpense: totals.expense ?? 0,
      monthlyDebit: monthly.data ?? 0,
      clearError: true,
    ));
  }

  Future<void> _onAdd(
    TransactionAddRequested event,
    Emitter<TransactionState> emit,
  ) async {
    final result = await _repository.addTransaction(
      amount: event.amount,
      note: event.note,
      type: event.type,
      categoryId: event.categoryId,
    );
    if (result.failure != null) {
      emit(state.copyWith(errorMessage: result.failure!.message));
      return;
    }

    final tx = result.data!;

    final recent = [tx, ...state.recentTransactions];
    final trimmedRecent = recent.take(10).toList();
    final all = [tx, ...state.allTransactions];
    final unsynced = [tx, ...state.unsyncedTransactions];

    var income = state.totalIncome;
    var expense = state.totalExpense;
    var monthlyDebit = state.monthlyDebit;

    if (tx.isCredit) {
      income += tx.amount;
    } else {
      expense += tx.amount;
      if (_isCurrentMonth(tx.timestamp)) {
        monthlyDebit += tx.amount;
      }
    }

    emit(state.copyWith(
      status: TransactionStatus.success,
      recentTransactions: trimmedRecent,
      allTransactions: all,
      unsyncedTransactions: unsynced,
      totalIncome: income,
      totalExpense: expense,
      monthlyDebit: monthlyDebit,
      clearError: true,
    ));

    if (event.type == TransactionType.debit) {
      await _budgetLimitService.onDebitTransactionAdded(event.amount);
    }

    final unsyncedResult = await _repository.getUnsyncedTransactions();
    if (unsyncedResult.data != null) {
      emit(state.copyWith(unsyncedTransactions: unsyncedResult.data!));
    }
  }

  Future<void> _onDelete(
    TransactionDeleteRequested event,
    Emitter<TransactionState> emit,
  ) async {
    Transaction? removed;
    for (final list in [state.recentTransactions, state.allTransactions]) {
      for (final t in list) {
        if (t.id == event.id) {
          removed = t;
          break;
        }
      }
      if (removed != null) break;
    }

    final updatedRecent = state.recentTransactions.where((t) => t.id != event.id).toList();
    final updatedAll = state.allTransactions.where((t) => t.id != event.id).toList();
    final updatedUnsynced = state.unsyncedTransactions.where((t) => t.id != event.id).toList();

    var income = state.totalIncome;
    var expense = state.totalExpense;
    var monthlyDebit = state.monthlyDebit;

    if (removed != null) {
      if (removed.isCredit) {
        income -= removed.amount;
      } else {
        expense -= removed.amount;
        if (_isCurrentMonth(removed.timestamp)) {
          monthlyDebit -= removed.amount;
        }
      }
    }

    emit(state.copyWith(
      recentTransactions: updatedRecent,
      allTransactions: updatedAll,
      unsyncedTransactions: updatedUnsynced,
      totalIncome: income < 0 ? 0 : income,
      totalExpense: expense < 0 ? 0 : expense,
      monthlyDebit: monthlyDebit < 0 ? 0 : monthlyDebit,
    ));

    final deleteResult = await _repository.deleteTransaction(event.id);
    if (deleteResult.failure != null) {
      add(const TransactionRefreshAfterSyncRequested());
      emit(state.copyWith(errorMessage: deleteResult.failure!.message));
      return;
    }

    add(const TransactionRefreshAfterSyncRequested());
  }

  bool _isCurrentMonth(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month;
  }
}
