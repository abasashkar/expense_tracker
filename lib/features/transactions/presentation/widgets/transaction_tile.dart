import 'package:flutter/material.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/core/utils/date_formatter.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onDelete,
  });

  final Transaction transaction;
  final VoidCallback onDelete;

  static IconData iconForCategory(String name) {
    final lower = name.toLowerCase();
    if (lower.contains('food') || lower.contains('grocery')) {
      return Icons.shopping_cart_outlined;
    }
    if (lower.contains('bill') || lower.contains('electric')) {
      return Icons.water_drop_outlined;
    }
    if (lower.contains('transport')) return Icons.directions_car_outlined;
    if (lower.contains('shop')) return Icons.shopping_bag_outlined;
    return Icons.receipt_long_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.isCredit;
    final amountColor = isCredit ? AppTheme.success : AppTheme.danger;
    final prefix = isCredit ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF141414),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.cardBorder),
            ),
            child: Icon(
              iconForCategory(transaction.categoryName),
              color: AppTheme.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.note,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  transaction.categoryName,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                DateFormatter.displayDate(transaction.timestamp),
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$prefix${CurrencyFormatter.format(transaction.amount)}',
                style: TextStyle(
                  color: amountColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.danger.withValues(alpha: 0.45),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.delete_outline,
                color: AppTheme.danger,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
