import 'package:expense_tracker/core/constants/api_constants.dart';
import 'package:expense_tracker/core/error/exceptions.dart';
import 'package:expense_tracker/core/network/api_client.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';
import 'package:expense_tracker/features/transactions/domain/entities/transaction.dart';

abstract class SyncRemoteDataSource {
  Future<List<String>> deleteCategories(List<String> ids);
  Future<List<String>> deleteTransactions(List<String> ids);
  Future<List<String>> uploadCategories(List<Category> categories);
  Future<List<String>> uploadTransactions(List<Transaction> transactions);
}

class SyncRemoteDataSourceImpl implements SyncRemoteDataSource {
  SyncRemoteDataSourceImpl(this._apiClient);

  final ApiClient _apiClient;

  List<String> _parseIdList(Map<String, dynamic> json, String key) {
    return (json[key] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
  }

  bool _isSuccess(Map<String, dynamic> json) =>
      json['status']?.toString().toLowerCase() == 'success';

  @override
  Future<List<String>> deleteCategories(List<String> ids) async {
    if (ids.isEmpty) return [];

    final json = await _apiClient.delete(
      ApiConstants.categoriesDelete,
      body: {'ids': ids},
      requiresAuth: true,
    );
    if (!_isSuccess(json)) {
      throw ServerException('Failed to delete categories');
    }
    final confirmed = _parseIdList(json, 'deleted_ids');
    return confirmed.isNotEmpty ? confirmed : ids;
  }

  @override
  Future<List<String>> deleteTransactions(List<String> ids) async {
    if (ids.isEmpty) return [];

    final json = await _apiClient.delete(
      ApiConstants.transactionsDelete,
      body: {'ids': ids},
      requiresAuth: true,
    );
    if (!_isSuccess(json)) {
      throw ServerException('Failed to delete transactions');
    }
    final confirmed = _parseIdList(json, 'deleted_ids');
    return confirmed.isNotEmpty ? confirmed : ids;
  }

  @override
  Future<List<String>> uploadCategories(List<Category> categories) async {
    if (categories.isEmpty) return [];
    final synced = <String>[];
    for (final c in categories) {
      final json = await _apiClient.postForm(
        ApiConstants.categoriesAdd,
        fields: {
          'category_id': c.id,
          'name': c.name,
        },
        requiresAuth: true,
      );
      if (!_isSuccess(json)) {
        throw ServerException('Failed to sync categories');
      }
      final ids = _parseIdList(json, 'synced_ids');
      synced.addAll(ids.isNotEmpty ? ids : [c.id]);
    }
    return synced;
  }

  @override
  Future<List<String>> uploadTransactions(
    List<Transaction> transactions,
  ) async {
    if (transactions.isEmpty) return [];

    final json = await _apiClient.post(
      ApiConstants.transactionsAdd,
      body: {
        'transactions': transactions
            .map(
              (t) => {
                'id': t.id,
                'amount': t.amount,
                'note': t.note,
                'type': t.isCredit ? 'credit' : 'debit',
                'category_id': t.categoryId,
                'timestamp': _formatTimestamp(t.timestamp),
              },
            )
            .toList(),
      },
      requiresAuth: true,
    );

    if (!_isSuccess(json)) {
      throw ServerException(
        json['message']?.toString() ?? 'Failed to sync transactions',
      );
    }

    final syncedIds = _parseIdList(json, 'synced_ids');
    if (syncedIds.isEmpty) {
      throw ServerException('Failed to sync transactions');
    }
    return syncedIds;
  }

  String _formatTimestamp(DateTime dt) {
    return '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}:${dt.second.toString().padLeft(2, '0')}';
  }
}
