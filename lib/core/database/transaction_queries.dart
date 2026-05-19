import 'database_tables.dart';

/// SQL used by the transaction repository layer (Phase 2 JOIN challenge).
class TransactionQueries {
  TransactionQueries._();

  /// Alias for category name resolved via INNER JOIN (not stored on transactions).
  static const String categoryNameAlias = 'category_name';

  /// Active transactions joined with their category name for list/card UI.
  static const String selectWithCategoryJoin = '''
    SELECT t.*, c.${DatabaseTables.colName} AS $categoryNameAlias
    FROM ${DatabaseTables.transactions} t
    INNER JOIN ${DatabaseTables.categories} c
      ON t.${DatabaseTables.colCategoryId} = c.${DatabaseTables.colId}
    WHERE t.${DatabaseTables.colIsDeleted} = 0
      AND c.${DatabaseTables.colIsDeleted} = 0
  ''';

  /// Unsynced transactions joined with category name (for cloud backup).
  static const String selectUnsyncedWithCategoryJoin = '''
    SELECT t.*, c.${DatabaseTables.colName} AS $categoryNameAlias
    FROM ${DatabaseTables.transactions} t
    INNER JOIN ${DatabaseTables.categories} c
      ON t.${DatabaseTables.colCategoryId} = c.${DatabaseTables.colId}
    WHERE t.${DatabaseTables.colIsSynced} = 0
      AND t.${DatabaseTables.colIsDeleted} = 0
  ''';
}
