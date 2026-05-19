import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'database_tables.dart';

class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'expense_tracker.db';
  static const int _dbVersion = 1;

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Phase 2 — Categories: id (UUID), name, is_synced, is_deleted
    await db.execute('''
      CREATE TABLE ${DatabaseTables.categories} (
        ${DatabaseTables.colId} TEXT PRIMARY KEY,
        ${DatabaseTables.colName} TEXT NOT NULL,
        ${DatabaseTables.colIsSynced} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseTables.colIsDeleted} INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Phase 2 — Transactions: id, amount, note, type, category_id (FK),
    // is_synced, is_deleted (+ timestamp for ordering/display)
    await db.execute('''
      CREATE TABLE ${DatabaseTables.transactions} (
        ${DatabaseTables.colId} TEXT PRIMARY KEY,
        ${DatabaseTables.colAmount} REAL NOT NULL,
        ${DatabaseTables.colNote} TEXT NOT NULL,
        ${DatabaseTables.colType} TEXT NOT NULL CHECK (${DatabaseTables.colType} IN ('credit', 'debit')),
        ${DatabaseTables.colCategoryId} TEXT NOT NULL,
        ${DatabaseTables.colTimestamp} TEXT NOT NULL,
        ${DatabaseTables.colIsSynced} INTEGER NOT NULL DEFAULT 0,
        ${DatabaseTables.colIsDeleted} INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (${DatabaseTables.colCategoryId})
          REFERENCES ${DatabaseTables.categories} (${DatabaseTables.colId})
      )
    ''');
  }

  Future<void> close() async {
    final db = _database;
    if (db != null && db.isOpen) {
      await db.close();
      _database = null;
    }
  }
}
