import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:expense_tracker/core/theme/app_theme.dart';
import 'package:expense_tracker/core/widgets/sync_feedback_listener.dart';
import 'package:expense_tracker/features/auth/presentation/pages/auth_gate_page.dart';
import 'package:expense_tracker/injection.dart';

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  static final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: AppInjection.authBloc),
        BlocProvider.value(value: AppInjection.categoryBloc),
        BlocProvider.value(value: AppInjection.transactionBloc),
        BlocProvider.value(value: AppInjection.syncBloc),
      ],
      child: MaterialApp(
        title: 'Expense Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        scaffoldMessengerKey: scaffoldMessengerKey,
        home: const AuthGatePage(),
        builder: (context, child) {
          return SyncFeedbackListener(
            messengerKey: scaffoldMessengerKey,
            child: child ?? const SizedBox.shrink(),
          );
        },
      ),
    );
  }
}
