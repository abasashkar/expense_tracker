import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/services/settings_service.dart';
import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/widgets/app_bottom_nav.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/dashboard_page.dart';
import 'package:expense_tracker/features/dashboard/presentation/pages/profile_page.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:expense_tracker/features/sync/presentation/pages/pending_sync_page.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/add_transaction_sheet.dart';
import 'package:expense_tracker/features/transactions/presentation/pages/transactions_page.dart';

class HomeShellPage extends StatefulWidget {
  const HomeShellPage({
    super.key,
    required this.nickname,
    required this.settingsService,
  });

  final String nickname;
  final SettingsService settingsService;

  @override
  State<HomeShellPage> createState() => _HomeShellPageState();
}

class _HomeShellPageState extends State<HomeShellPage> {
  AppNavTab _activeTab = AppNavTab.dashboard;
  bool _showAllTransactions = false;

  @override
  void initState() {
    super.initState();
    context.read<TransactionBloc>().add(const TransactionLoadDashboardRequested());
    context.read<CategoryBloc>().add(const CategoryLoadRequested());
    context.read<SyncBloc>().add(const SyncPendingStatusRequested());
  }

  void _refreshSyncPendingStatus() {
    context.read<SyncBloc>().add(const SyncPendingStatusRequested());
  }

  void _openAddTransaction() {
    context.read<CategoryBloc>().add(const CategoryLoadRequested());
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppTheme.background,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const AddTransactionSheet(),
    );
  }

  void _onTabSelected(AppNavTab tab) {
    setState(() {
      _showAllTransactions = false;
      _activeTab = tab;
    });

    final txBloc = context.read<TransactionBloc>();
    switch (tab) {
      case AppNavTab.dashboard:
        txBloc.add(const TransactionLoadDashboardRequested());
      case AppNavTab.sync:
        txBloc.add(const TransactionLoadUnsyncedRequested());
        context.read<CategoryBloc>()
          ..add(const CategoryLoadUnsyncedRequested())
          ..add(const CategoryLoadRequested());
      case AppNavTab.profile:
        context.read<CategoryBloc>().add(const CategoryLoadRequested());
    }
    _refreshSyncPendingStatus();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<TransactionBloc, TransactionState>(
          listenWhen: (previous, current) =>
              previous.unsyncedTransactions != current.unsyncedTransactions ||
              previous.recentTransactions.length !=
                  current.recentTransactions.length ||
              previous.allTransactions.length != current.allTransactions.length,
          listener: (_, __) => _refreshSyncPendingStatus(),
        ),
        BlocListener<CategoryBloc, CategoryState>(
          listenWhen: (previous, current) =>
              previous.unsyncedCategories != current.unsyncedCategories ||
              previous.categories.length != current.categories.length,
          listener: (_, __) => _refreshSyncPendingStatus(),
        ),
      ],
      child: Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: _showAllTransactions
            ? TransactionsPage(
                onBack: () {
                  setState(() => _showAllTransactions = false);
                  context
                      .read<TransactionBloc>()
                      .add(const TransactionLoadDashboardRequested());
                },
              )
            : switch (_activeTab) {
                AppNavTab.dashboard => DashboardPage(
                    nickname: widget.nickname,
                    settingsService: widget.settingsService,
                    onViewAllTransactions: () {
                      setState(() => _showAllTransactions = true);
                      context
                          .read<TransactionBloc>()
                          .add(const TransactionLoadAllRequested());
                    },
                  ),
                AppNavTab.sync => const PendingSyncPage(),
                AppNavTab.profile => ProfilePage(
                    nickname: widget.nickname,
                    settingsService: widget.settingsService,
                  ),
              },
      ),
      floatingActionButton: _activeTab == AppNavTab.dashboard ||
              _showAllTransactions
          ? FloatingActionButton(
              onPressed: _openAddTransaction,
              backgroundColor: AppTheme.success,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 28),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BlocBuilder<SyncBloc, SyncState>(
        builder: (context, syncState) {
          return AppBottomNav(
            activeTab: _showAllTransactions ? AppNavTab.dashboard : _activeTab,
            isSyncing: syncState.isSyncing,
            onTabSelected: _onTabSelected,
          );
        },
      ),
      ),
    );
  }
}
