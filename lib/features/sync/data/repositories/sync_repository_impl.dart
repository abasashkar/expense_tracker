import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/error/failures.dart';
import 'package:expense_tracker/features/categories/domain/repositories/category_repository.dart';
import 'package:expense_tracker/features/sync/data/datasources/sync_remote_data_source.dart';
import 'package:expense_tracker/features/sync/domain/repositories/sync_repository.dart';
import 'package:expense_tracker/features/transactions/domain/repositories/transaction_repository.dart';

class SyncRepositoryImpl implements SyncRepository {
  SyncRepositoryImpl({
    required SyncRemoteDataSource remote,
    required CategoryRepository categoryRepository,
    required TransactionRepository transactionRepository,
  })  : _remote = remote,
        _categoryRepository = categoryRepository,
        _transactionRepository = transactionRepository;

  final SyncRemoteDataSource _remote;
  final CategoryRepository _categoryRepository;
  final TransactionRepository _transactionRepository;

  @override
  Future<({bool? data, Failure? failure})> hasPendingWork() async {
    try {
      final unsyncedTx = (await _transactionRepository.getUnsyncedTransactions()).data ?? [];
      final unsyncedCat = (await _categoryRepository.getUnsyncedCategories()).data ?? [];
      final deletedTx = (await _transactionRepository.getDeletedTransactionIds()).data ?? [];
      final deletedCat = (await _categoryRepository.getDeletedCategoryIds()).data ?? [];

      final pending = unsyncedTx.isNotEmpty || unsyncedCat.isNotEmpty || deletedTx.isNotEmpty || deletedCat.isNotEmpty;

      return (data: pending, failure: null);
    } catch (_) {
      return (
        data: null,
        failure: const ServerFailure('Could not check sync status'),
      );
    }
  }

  @override
  Future<({bool? data, Failure? failure})> syncAll() async {
    try {
      await _stepAPurgeDeletions();
      await _stepBUploadNewData();
      return (data: true, failure: null);
    } on ServerException catch (e) {
      return (data: null, failure: ServerFailure(e.message));
    } on NetworkException catch (e) {
      return (data: null, failure: NetworkFailure(e.message));
    } catch (_) {
      return (data: null, failure: const ServerFailure('Sync failed'));
    }
  }

  Future<void> _stepAPurgeDeletions() async {
    await _purgeDeletedTransactions();
    await _purgeDeletedCategories();
  }

  Future<void> _purgeDeletedTransactions() async {
    final deletedTxIds = (await _transactionRepository.getDeletedTransactionIds()).data ?? [];
    if (deletedTxIds.isEmpty) return;

    try {
      final confirmed = await _remote.deleteTransactions(deletedTxIds);
      if (confirmed.isNotEmpty) {
        await _transactionRepository.permanentlyDeleteTransactions(confirmed);
      }
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        await _transactionRepository.permanentlyDeleteTransactions(deletedTxIds);
      }
    }
  }

  Future<void> _purgeDeletedCategories() async {
    final deletedCatIds = (await _categoryRepository.getDeletedCategoryIds()).data ?? [];
    if (deletedCatIds.isEmpty) return;

    try {
      final confirmed = await _remote.deleteCategories(deletedCatIds);
      if (confirmed.isNotEmpty) {
        await _categoryRepository.permanentlyDeleteCategories(confirmed);
      }
    } on ServerException catch (e) {
      if (e.statusCode == 404) {
        await _categoryRepository.permanentlyDeleteCategories(deletedCatIds);
      }
    }
  }

  Future<void> _stepBUploadNewData() async {
    final unsyncedCategories = (await _categoryRepository.getUnsyncedCategories()).data ?? [];
    if (unsyncedCategories.isNotEmpty) {
      final syncedIds = await _remote.uploadCategories(unsyncedCategories);
      if (syncedIds.isNotEmpty) {
        await _categoryRepository.markCategoriesSynced(syncedIds);
      }
      final remaining = (await _categoryRepository.getUnsyncedCategories()).data ?? [];
      if (remaining.isNotEmpty) {
        throw ServerException('Failed to sync categories');
      }
    }

    final unsyncedTransactions = (await _transactionRepository.getUnsyncedTransactions()).data ?? [];
    if (unsyncedTransactions.isEmpty) return;

    final localIds = unsyncedTransactions.map((t) => t.id).toList();
    final responseIds = await _remote.uploadTransactions(unsyncedTransactions);
    if (responseIds.isEmpty) {
      throw ServerException('Failed to sync transactions');
    }

    await _transactionRepository.markTransactionsSynced(localIds);
  }
}
