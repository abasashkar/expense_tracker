part of 'transaction_bloc.dart';

enum TransactionStatus { initial, loading, success, failure }

class TransactionState extends Equatable {
  const TransactionState({
    this.status = TransactionStatus.initial,
    this.recentTransactions = const [],
    this.allTransactions = const [],
    this.unsyncedTransactions = const [],
    this.totalIncome = 0,
    this.totalExpense = 0,
    this.monthlyDebit = 0,
    this.errorMessage,
  });

  final TransactionStatus status;
  final List<Transaction> recentTransactions;
  final List<Transaction> allTransactions;
  final List<Transaction> unsyncedTransactions;
  final double totalIncome;
  final double totalExpense;
  final double monthlyDebit;
  final String? errorMessage;

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? recentTransactions,
    List<Transaction>? allTransactions,
    List<Transaction>? unsyncedTransactions,
    double? totalIncome,
    double? totalExpense,
    double? monthlyDebit,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TransactionState(
      status: status ?? this.status,
      recentTransactions: recentTransactions ?? this.recentTransactions,
      allTransactions: allTransactions ?? this.allTransactions,
      unsyncedTransactions:
          unsyncedTransactions ?? this.unsyncedTransactions,
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      monthlyDebit: monthlyDebit ?? this.monthlyDebit,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
        status,
        recentTransactions,
        allTransactions,
        unsyncedTransactions,
        totalIncome,
        totalExpense,
        monthlyDebit,
        errorMessage,
      ];
}
