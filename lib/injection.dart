import 'package:flutter/foundation.dart';

import 'package:expense_tracker/core/database/database_helper.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/core/notifications/notifications_service.dart';
import 'package:expense_tracker/core/services/budget_limit_service.dart';
import 'package:expense_tracker/core/services/settings_service.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:expense_tracker/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:expense_tracker/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:expense_tracker/features/auth/domain/repositories/auth_repository.dart';
import 'package:expense_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:expense_tracker/features/categories/data/datasources/category_local_data_source.dart';
import 'package:expense_tracker/features/categories/data/repositories/category_repository_impl.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/categories/presentation/bloc/category_bloc.dart';
import 'package:expense_tracker/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:expense_tracker/features/sync/data/repositories/sync_repository_impl.dart';
import 'package:expense_tracker/features/sync/domain/repositories/sync_repository.dart';
import 'package:expense_tracker/features/sync/presentation/bloc/sync_bloc.dart';
import 'package:expense_tracker/features/transactions/data/datasources/transaction_local_data_source.dart';
import 'package:expense_tracker/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker/features/transactions/presentation/bloc/transaction_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInjection {
  AppInjection._();

  static late final ApiClient apiClient;
  static late final SettingsService settingsService;
  static late final NotificationsService notificationsService;
  static late final BudgetLimitService budgetLimitService;
  static late final AuthRepository authRepository;
  static late final CategoryRepository categoryRepository;
  static late final TransactionRepository transactionRepository;
  static late final SyncRepository syncRepository;
  static late final AuthBloc authBloc;
  static late final CategoryBloc categoryBloc;
  static late final TransactionBloc transactionBloc;
  static late final SyncBloc syncBloc;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();

    apiClient = ApiClient();
    settingsService = SettingsService(prefs);
    notificationsService = NotificationsService();
    await DatabaseHelper.instance.database;

    final authLocalDataSource = AuthLocalDataSourceImpl(prefs);
    final authRemoteDataSource = AuthRemoteDataSourceImpl(apiClient);

    authRepository = AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
      localDataSource: authLocalDataSource,
      apiClient: apiClient,
    );

    final categoryLocal = CategoryLocalDataSourceImpl(DatabaseHelper.instance);
    final transactionLocal =
        TransactionLocalDataSourceImpl(DatabaseHelper.instance);

    categoryRepository = CategoryRepositoryImpl(categoryLocal);
    transactionRepository = TransactionRepositoryImpl(transactionLocal);

    budgetLimitService = BudgetLimitService(
      settingsService: settingsService,
      notificationsService: notificationsService,
      transactionRepository: transactionRepository,
    );

    final syncRemote = SyncRemoteDataSourceImpl(apiClient);
    syncRepository = SyncRepositoryImpl(
      remote: syncRemote,
      categoryRepository: categoryRepository,
      transactionRepository: transactionRepository,
    );

    authBloc = AuthBloc(authRepository: authRepository)
      ..add(const AuthCheckRequested());

    categoryBloc = CategoryBloc(repository: categoryRepository);
    transactionBloc = TransactionBloc(
      repository: transactionRepository,
      budgetLimitService: budgetLimitService,
    );
    syncBloc = SyncBloc(repository: syncRepository)
      ..add(const SyncPendingStatusRequested());
  }

  /// Initializes notifications and requests permission after the Activity exists.
  static Future<void> setupNotifications() async {
    try {
      await notificationsService.initialize();
      await notificationsService.requestPermissions();
    } catch (error, stack) {
      debugPrint('Notification setup failed: $error\n$stack');
    }
  }
}
