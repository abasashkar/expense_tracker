import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/widgets/sync_action_button.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/widgets/transaction_tile.dart';

class PendingSyncPage extends StatelessWidget {
  const PendingSyncPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, syncState) {
        return BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, catState) {
            return BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, txState) {
                final unsyncedCategories = catState.unsyncedCategories;
                final unsyncedTransactions = txState.unsyncedTransactions;
                final isLoading = (catState.status == CategoryStatus.loading &&
                        catState.unsyncedCategories.isEmpty) ||
                    (txState.status == TransactionStatus.loading &&
                        txState.unsyncedTransactions.isEmpty);

                final hasDeletionOnly = syncState.hasPendingWork &&
                    unsyncedCategories.isEmpty &&
                    unsyncedTransactions.isEmpty;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              'Pending Sync',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                          const SyncActionButton(),
                        ],
                      ),
                    ),
                    if (isLoading)
                      Expanded(child: _buildShimmer())
                    else
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                          children: [
                            if (hasDeletionOnly) ...[
                              const Text(
                                'Pending deletions will be purged on the server when you sync.',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (unsyncedCategories.isNotEmpty) ...[
                              _sectionHeader(
                                'Unsynced Categories (${unsyncedCategories.length})',
                              ),
                              const SizedBox(height: 8),
                              ...unsyncedCategories.map(
                                (cat) => Padding(
                                  padding: const EdgeInsets.only(bottom: 8),
                                  child: _pendingRow(cat.name),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                            if (unsyncedTransactions.isNotEmpty) ...[
                              _sectionHeader(
                                'Unsynced Transactions (${unsyncedTransactions.length})',
                              ),
                              const SizedBox(height: 8),
                              ...unsyncedTransactions.map(
                                (tx) => TransactionTile(
                                  transaction: tx,
                                  onDelete: () => context
                                      .read<TransactionBloc>()
                                      .add(TransactionDeleteRequested(tx.id)),
                                ),
                              ),
                            ],
                            if (!syncState.hasPendingWork &&
                                unsyncedCategories.isEmpty &&
                                unsyncedTransactions.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 48),
                                child: Center(
                                  child: Text(
                                    'All data is synced',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
      ),
    );
  }

  Widget _pendingRow(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.category_outlined,
            color: AppTheme.primary,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
          const Icon(
            Icons.cloud_upload_outlined,
            color: AppTheme.textSecondary,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppTheme.surface,
      highlightColor: AppTheme.surfaceLight,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: 6,
        itemBuilder: (_, __) => Container(
          height: 72,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }
}
