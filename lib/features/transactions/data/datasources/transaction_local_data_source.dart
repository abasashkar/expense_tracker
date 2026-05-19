import 'package:expense_tracker/core/database/database_helper.dart';
import 'package:expense_tracker/core/database/database_tables.dart';
import 'package:expense_tracker/core/database/transaction_queries.dart';
import 'package:expense_tracker/features/transactions/data/models/transaction_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class TransactionLocalDataSource {
  Future<List<TransactionModel>> getTransactions({int? limit});
  Future<TransactionModel> insert(TransactionModel transaction);
  Future<void> softDelete(String id);
  Future<double> getTotalByType(String type);
  Future<double> getMonthlyDebitTotal();
  Future<List<TransactionModel>> getUnsynced();
  Future<List<String>> getDeletedIds();
  Future<void> markSynced(List<String> ids);
  Future<void> permanentlyDelete(List<String> ids);
}

class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  TransactionLocalDataSourceImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;

  Future<Database> get _db => _dbHelper.database;

  @override
  Future<List<TransactionModel>> getTransactions({int? limit}) async {
    var query =
        '${TransactionQueries.selectWithCategoryJoin} ORDER BY t.${DatabaseTables.colTimestamp} DESC';
    if (limit != null) query += ' LIMIT $limit';
    final rows = await (await _db).rawQuery(query);
    return rows.map(TransactionModel.fromJoinedMap).toList();
  }

  @override
  Future<TransactionModel> insert(TransactionModel transaction) async {
    await (await _db).insert(
      DatabaseTables.transactions,
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    final rows = await (await _db).rawQuery(
      '${TransactionQueries.selectWithCategoryJoin} AND t.${DatabaseTables.colId} = ?',
      [transaction.id],
    );
    return TransactionModel.fromJoinedMap(rows.first);
  }

  @override
  Future<void> softDelete(String id) async {
    await (await _db).update(
      DatabaseTables.transactions,
      {DatabaseTables.colIsDeleted: 1, DatabaseTables.colIsSynced: 0},
      where: '${DatabaseTables.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<double> getTotalByType(String type) async {
    final result = await (await _db).rawQuery('''
      SELECT COALESCE(SUM(${DatabaseTables.colAmount}), 0) as total
      FROM ${DatabaseTables.transactions}
      WHERE ${DatabaseTables.colIsDeleted} = 0 AND ${DatabaseTables.colType} = ?
    ''', [type]);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  @override
  Future<double> getMonthlyDebitTotal() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1).toIso8601String();
    final end = DateTime(now.year, now.month + 1, 1).toIso8601String();
    final result = await (await _db).rawQuery('''
      SELECT COALESCE(SUM(${DatabaseTables.colAmount}), 0) as total
      FROM ${DatabaseTables.transactions}
      WHERE ${DatabaseTables.colIsDeleted} = 0
        AND ${DatabaseTables.colType} = 'debit'
        AND ${DatabaseTables.colTimestamp} >= ?
        AND ${DatabaseTables.colTimestamp} < ?
    ''', [start, end]);
    return (result.first['total'] as num?)?.toDouble() ?? 0;
  }

  @override
  Future<List<TransactionModel>> getUnsynced() async {
    final rows = await (await _db).rawQuery(
      TransactionQueries.selectUnsyncedWithCategoryJoin,
    );
    return rows.map(TransactionModel.fromJoinedMap).toList();
  }

  @override
  Future<List<String>> getDeletedIds() async {
    final rows = await (await _db).query(
      DatabaseTables.transactions,
      columns: [DatabaseTables.colId],
      where: '${DatabaseTables.colIsDeleted} = ?',
      whereArgs: [1],
    );
    return rows.map((r) => r[DatabaseTables.colId] as String).toList();
  }

  @override
  Future<void> markSynced(List<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db;
    final batch = db.batch();
    for (final id in ids) {
      batch.update(
        DatabaseTables.transactions,
        {DatabaseTables.colIsSynced: 1},
        where: '${DatabaseTables.colId} = ?',
        whereArgs: [id],
      );
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<void> permanentlyDelete(List<String> ids) async {
    if (ids.isEmpty) return;
    await (await _db).delete(
      DatabaseTables.transactions,
      where:
          '${DatabaseTables.colId} IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
  }

}
