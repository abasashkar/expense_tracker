import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/services/settings_service.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/dashboard_shimmer.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/monthly_limit_card.dart';
import 'package:expense_tracker/features/dashboard/presentation/widgets/summary_card.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_tile.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.nickname,
    required this.onViewAllTransactions,
    required this.settingsService,
  });

  final String nickname;
  final VoidCallback onViewAllTransactions;
  final SettingsService settingsService;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionBloc, TransactionState>(
      builder: (context, state) {
        if (state.status == TransactionStatus.loading && state.recentTransactions.isEmpty) {
          return const SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 18, 20, 120),
            child: DashboardShimmer(),
          );
        }

        final limit = settingsService.monthlyLimit;

        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '👋 Welcome, $nickname!',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: SummaryCard(
                      label: 'Total Income',
                      amount: state.totalIncome,
                      gradientColors: const [
                        AppTheme.incomeGradientStart,
                        AppTheme.incomeGradientEnd,
                      ],
                      arrowIcon: Icons.south_west,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SummaryCard(
                      label: 'Total Expense',
                      amount: state.totalExpense,
                      gradientColors: const [
                        AppTheme.expenseGradientStart,
                        AppTheme.expenseGradientEnd,
                      ],
                      arrowIcon: Icons.north_east,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              MonthlyLimitCard(
                spent: state.monthlyDebit,
                limit: limit,
              ),
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Transactions',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  GestureDetector(
                    onTap: state.recentTransactions.isEmpty ? null : onViewAllTransactions,
                    child: Text(
                      'View all',
                      style: TextStyle(
                        color: state.recentTransactions.isEmpty
                            ? AppTheme.textSecondary.withValues(alpha: 0.4)
                            : AppTheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (state.recentTransactions.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32),
                  child: Center(
                    child: Text(
                      'No transactions yet.\nTap + to add one.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppTheme.textSecondary),
                    ),
                  ),
                )
              else
                ...state.recentTransactions.map(
                  (tx) => TransactionTile(
                    transaction: tx,
                    onDelete: () => context.read<TransactionBloc>().add(TransactionDeleteRequested(tx.id)),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
