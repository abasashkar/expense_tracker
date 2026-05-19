import 'package:expense_tracker/core/database/database_helper.dart';
import 'package:expense_tracker/core/database/database_tables.dart';
import 'package:expense_tracker/features/categories/data/models/category_model.dart';
import 'package:sqflite/sqflite.dart';

abstract class CategoryLocalDataSource {
  Future<List<CategoryModel>> getActiveCategories();
  Future<CategoryModel> insert(CategoryModel category);
  Future<void> softDelete(String id);
  Future<void> softDeleteTransactionsForCategory(String categoryId);
  Future<List<CategoryModel>> getUnsynced();
  Future<List<String>> getDeletedIds();
  Future<void> markSynced(List<String> ids);
  Future<void> permanentlyDelete(List<String> ids);
}

class CategoryLocalDataSourceImpl implements CategoryLocalDataSource {
  CategoryLocalDataSourceImpl(this._dbHelper);

  final DatabaseHelper _dbHelper;

  Future<Database> get _db => _dbHelper.database;

  @override
  Future<List<CategoryModel>> getActiveCategories() async {
    final rows = await (await _db).query(
      DatabaseTables.categories,
      where: '${DatabaseTables.colIsDeleted} = ?',
      whereArgs: [0],
      orderBy: '${DatabaseTables.colName} ASC',
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<CategoryModel> insert(CategoryModel category) async {
    await (await _db).insert(
      DatabaseTables.categories,
      category.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    return category;
  }

  @override
  Future<void> softDelete(String id) async {
    await softDeleteTransactionsForCategory(id);
    await (await _db).update(
      DatabaseTables.categories,
      {DatabaseTables.colIsDeleted: 1, DatabaseTables.colIsSynced: 0},
      where: '${DatabaseTables.colId} = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> softDeleteTransactionsForCategory(String categoryId) async {
    await (await _db).update(
      DatabaseTables.transactions,
      {DatabaseTables.colIsDeleted: 1, DatabaseTables.colIsSynced: 0},
      where:
          '${DatabaseTables.colCategoryId} = ? AND ${DatabaseTables.colIsDeleted} = ?',
      whereArgs: [categoryId, 0],
    );
  }

  @override
  Future<List<CategoryModel>> getUnsynced() async {
    final rows = await (await _db).query(
      DatabaseTables.categories,
      where:
          '${DatabaseTables.colIsSynced} = ? AND ${DatabaseTables.colIsDeleted} = ?',
      whereArgs: [0, 0],
    );
    return rows.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<List<String>> getDeletedIds() async {
    final rows = await (await _db).query(
      DatabaseTables.categories,
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
        DatabaseTables.categories,
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
    final db = await _db;
    await db.delete(
      DatabaseTables.categories,
      where:
          '${DatabaseTables.colId} IN (${List.filled(ids.length, '?').join(',')})',
      whereArgs: ids,
    );
  }
}
