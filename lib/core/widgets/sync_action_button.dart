import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_bloc.dart';

/// Circular sync trigger used on the pending-sync screen header.
class SyncActionButton extends StatelessWidget {
  const SyncActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SyncBloc, SyncState>(
      builder: (context, syncState) {
        final enabled = syncState.canSync;

        return Material(
          color: enabled
              ? AppTheme.primary
              : AppTheme.primary.withValues(alpha: 0.35),
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: syncState.isSyncing
                ? null
                : () => context.read<SyncBloc>().add(const SyncRequested()),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: syncState.isSyncing
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Icon(
                      Icons.sync,
                      color: Colors.white.withValues(alpha: enabled ? 1 : 0.7),
                      size: 22,
                    ),
            ),
          ),
        );
      },
    );
  }
}
