import 'package:expense_tracker/core/database/database_tables.dart';
import 'package:expense_tracker/core/database/transaction_queries.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.amount,
    required super.note,
    required super.type,
    required super.categoryId,
    required super.categoryName,
    required super.timestamp,
    super.isSynced,
    super.isDeleted,
  });

  factory TransactionModel.fromJoinedMap(Map<String, dynamic> map) {
    final typeStr = map[DatabaseTables.colType] as String;
    return TransactionModel(
      id: map[DatabaseTables.colId] as String,
      amount: (map[DatabaseTables.colAmount] as num).toDouble(),
      note: map[DatabaseTables.colNote] as String,
      type: typeStr == 'credit'
          ? TransactionType.credit
          : TransactionType.debit,
      categoryId: map[DatabaseTables.colCategoryId] as String,
      categoryName: map[TransactionQueries.categoryNameAlias] as String? ??
          'Unknown',
      timestamp: DateTime.parse(map[DatabaseTables.colTimestamp] as String),
      isSynced: (map[DatabaseTables.colIsSynced] as int? ?? 0) == 1,
      isDeleted: (map[DatabaseTables.colIsDeleted] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colId: id,
      DatabaseTables.colAmount: amount,
      DatabaseTables.colNote: note,
      DatabaseTables.colType:
          type == TransactionType.credit ? 'credit' : 'debit',
      DatabaseTables.colCategoryId: categoryId,
      DatabaseTables.colTimestamp: timestamp.toIso8601String(),
      DatabaseTables.colIsSynced: isSynced ? 1 : 0,
      DatabaseTables.colIsDeleted: isDeleted ? 1 : 0,
    };
  }
}
