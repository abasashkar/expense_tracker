import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

abstract class TransactionRepository {
  Future<({List<Transaction>? data, Failure? failure})> getRecentTransactions({
    int limit = 10,
  });

  Future<({List<Transaction>? data, Failure? failure})> getAllTransactions();

  Future<({double? income, double? expense, Failure? failure})> getTotals();

  Future<({double? data, Failure? failure})> getMonthlyDebitTotal();

  Future<({Transaction? data, Failure? failure})> addTransaction({
    required double amount,
    required String note,
    required TransactionType type,
    required String categoryId,
  });

  Future<({bool? data, Failure? failure})> deleteTransaction(String id);

  Future<({List<Transaction>? data, Failure? failure})> getUnsyncedTransactions();

  Future<({List<String>? data, Failure? failure})> getDeletedTransactionIds();

  Future<({bool? data, Failure? failure})> markTransactionsSynced(
    List<String> ids,
  );

  Future<({bool? data, Failure? failure})> permanentlyDeleteTransactions(
    List<String> ids,
  );
}
