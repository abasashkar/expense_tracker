import 'package:equatable/equatable.dart';

enum TransactionType { credit, debit }

class Transaction extends Equatable {
  const Transaction({
    required this.id,
    required this.amount,
    required this.note,
    required this.type,
    required this.categoryId,
    required this.categoryName,
    required this.timestamp,
    this.isSynced = false,
    this.isDeleted = false,
  });

  final String id;
  final double amount;
  final String note;
  final TransactionType type;
  final String categoryId;
  final String categoryName;
  final DateTime timestamp;
  final bool isSynced;
  final bool isDeleted;

  bool get isCredit => type == TransactionType.credit;

  @override
  List<Object?> get props => [
        id,
        amount,
        note,
        type,
        categoryId,
        categoryName,
        timestamp,
        isSynced,
        isDeleted,
      ];
}
