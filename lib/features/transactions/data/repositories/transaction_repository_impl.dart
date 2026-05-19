import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/core/utils/uuid_generator.dart';
import 'package:expense_tracker/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_model.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';

/// Persists transactions locally. Reads use [TransactionQueries.selectWithCategoryJoin]
/// (SQL INNER JOIN) so each row includes the related category name for UI cards.
class TransactionRepositoryImpl implements TransactionRepository {
  TransactionRepositoryImpl(this._local);

  final TransactionLocalDataSource _local;

  @override
  Future<({List<Transaction>? data, Failure? failure})> getRecentTransactions({
    int limit = 10,
  }) async {
    try {
      return (data: await _local.getTransactions(limit: limit), failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({List<Transaction>? data, Failure? failure})> getAllTransactions() async {
    try {
      return (data: await _local.getTransactions(), failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({double? income, double? expense, Failure? failure})> getTotals() async {
    try {
      final income = await _local.getTotalByType('credit');
      final expense = await _local.getTotalByType('debit');
      return (income: income, expense: expense, failure: null);
    } catch (_) {
      return (income: null, expense: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({double? data, Failure? failure})> getMonthlyDebitTotal() async {
    try {
      return (data: await _local.getMonthlyDebitTotal(), failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({Transaction? data, Failure? failure})> addTransaction({
    required double amount,
    required String note,
    required TransactionType type,
    required String categoryId,
  }) async {
    try {
      final tx = TransactionModel(
        id: UuidGenerator.newId(),
        amount: amount,
        note: note.trim(),
        type: type,
        categoryId: categoryId,
        categoryName: '',
        timestamp: DateTime.now(),
        isSynced: false,
        isDeleted: false,
      );
      final saved = await _local.insert(tx);
      return (data: saved, failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({bool? data, Failure? failure})> deleteTransaction(String id) async {
    try {
      await _local.softDelete(id);
      return (data: true, failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({List<Transaction>? data, Failure? failure})>
      getUnsyncedTransactions() async {
    try {
      return (data: await _local.getUnsynced(), failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({List<String>? data, Failure? failure})>
      getDeletedTransactionIds() async {
    try {
      return (data: await _local.getDeletedIds(), failure: null);
    } catch (_) {
      return (data: null, failure: const CacheFailure());
    }
  }

  @override
  Future<({bool? data, Failure? failure})> markTransactionsSynced(
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
  Future<({bool? data, Failure? failure})> permanentlyDeleteTransactions(
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
