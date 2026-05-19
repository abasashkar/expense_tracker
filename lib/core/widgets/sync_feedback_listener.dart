import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';

class SyncFeedbackListener extends StatelessWidget {
  const SyncFeedbackListener({
    super.key,
    required this.child,
    this.messengerKey,
  });

  final Widget child;
  final GlobalKey<ScaffoldMessengerState>? messengerKey;

  ScaffoldMessengerState? get _messenger => messengerKey?.currentState;

  void _showSnackBar(SnackBar snackBar) {
    final messenger = _messenger;
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(snackBar);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SyncBloc, SyncState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case SyncStatus.syncing:
            _showSnackBar(
              const SnackBar(
                content: Text('Syncing to cloud...'),
                duration: Duration(seconds: 30),
              ),
            );
          case SyncStatus.success:
            context.read<TransactionBloc>()
              ..add(const TransactionRefreshAfterSyncRequested())
              ..add(const TransactionLoadUnsyncedRequested());
            context.read<CategoryBloc>()
              ..add(const CategoryRefreshAfterSyncRequested())
              ..add(const CategoryLoadUnsyncedRequested());
            context.read<SyncBloc>().add(const SyncPendingStatusRequested());
            _showSnackBar(
              const SnackBar(
                content: Text('Sync completed successfully'),
                backgroundColor: AppTheme.success,
                duration: Duration(seconds: 3),
              ),
            );
          case SyncStatus.failure:
            _showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'Sync failed'),
                backgroundColor: AppTheme.danger,
                duration: const Duration(seconds: 4),
              ),
            );
          case SyncStatus.noWork:
            _showSnackBar(
              const SnackBar(
                content: Text(SyncState.nothingToSyncMessage),
                duration: Duration(seconds: 3),
              ),
            );
          case SyncStatus.idle:
            break;
        }
      },
      child: child,
    );
  }
}
