import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';

import 'package:expense_tracker/core/services/settings_service.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/utils/currency_formatter.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.nickname,
    required this.settingsService,
  });

  final String nickname;
  final SettingsService settingsService;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _categoryController;
  late TextEditingController _limitController;
  late double _currentLimit;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController();
    _currentLimit = widget.settingsService.monthlyLimit;
    _limitController = TextEditingController(
      text: _currentLimit.toInt().toString(),
    );
    context.read<CategoryBloc>().add(const CategoryLoadRequested());
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _setLimit() async {
    final value = double.tryParse(_limitController.text.trim());
    if (value == null || value <= 0) return;
    await widget.settingsService.setMonthlyLimit(value);
    setState(() => _currentLimit = value);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Monthly limit updated')),
      );
    }
  }

  void _onCategoryDeleted() {
    final txBloc = context.read<TransactionBloc>();
    txBloc.add(const TransactionLoadDashboardRequested());
    if (txBloc.state.allTransactions.isNotEmpty) {
      txBloc.add(const TransactionLoadAllRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile & Settings',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'NICKNAME',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          _darkField(
            child: Text(
              widget.nickname,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'ALERT LIMIT (₹)',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: _darkField(
                  child: TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: const InputDecoration(
                      hintText: 'Amount ( ₹ )',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _setLimit,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(80, 52),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  child: const Text('Set'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Current Limit: ${CurrencyFormatter.format(_currentLimit)}',
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'CATEGORIES',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, catState) {
              if (catState.status == CategoryStatus.loading &&
                  catState.categories.isEmpty) {
                return Shimmer.fromColors(
                  baseColor: AppTheme.surface,
                  highlightColor: AppTheme.surfaceLight,
                  child: Column(
                    children: List.generate(
                      3,
                      (_) => Container(
                        height: 52,
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ),
                );
              }

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _darkField(
                          child: TextField(
                            controller: _categoryController,
                            style: const TextStyle(color: AppTheme.textPrimary),
                            decoration: const InputDecoration(
                              hintText: 'New category Name',
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: () {
                            context.read<CategoryBloc>().add(
                                  CategoryAddRequested(
                                    _categoryController.text,
                                  ),
                                );
                            _categoryController.clear();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(52, 52),
                          ),
                          child: const Icon(
                            Icons.add,
                            size: 24,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...catState.categories.map(
                    (cat) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _darkField(
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                cat.name,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 15,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.read<CategoryBloc>().add(
                                      CategoryDeleteRequested(cat.id),
                                    );
                                _onCategoryDeleted();
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color:
                                        AppTheme.danger.withValues(alpha: 0.5),
                                  ),
                                  borderRadius: BorderRadius.circular(8),
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
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 28),
          const Text(
            'CLOUD SYNC',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 10),
          BlocBuilder<SyncBloc, SyncState>(
            builder: (context, syncState) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Material(
                    color: syncState.canSync
                        ? AppTheme.primary
                        : AppTheme.primary.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: syncState.isSyncing
                          ? null
                          : () => context
                              .read<SyncBloc>()
                              .add(const SyncRequested()),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    syncState.isSyncing
                                        ? 'Syncing...'
                                        : 'Sync To Cloud',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Sync and update data to the backend',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            syncState.isSyncing
                                ? const SizedBox(
                                    width: 28,
                                    height: 28,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.cloud_upload_outlined,
                                    color: Colors.white.withValues(
                                      alpha: syncState.canSync ? 1 : 0.7,
                                    ),
                                    size: 32,
                                  ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (syncState.status == SyncStatus.failure &&
                      syncState.errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      syncState.errorMessage!,
                      style: const TextStyle(
                        color: AppTheme.danger,
                        fontSize: 13,
                      ),
                    ),
                  ] else if (syncState.status == SyncStatus.success) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Sync completed successfully',
                      style: TextStyle(
                        color: AppTheme.success,
                        fontSize: 13,
                      ),
                    ),
                  ] else if (syncState.isSyncing) ...[
                    const SizedBox(height: 8),
                    const Text(
                      'Syncing your data to the cloud...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _darkField({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: child,
    );
  }
}
