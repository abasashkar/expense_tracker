import 'package:expense_tracker/core/database/database_tables.dart';
import 'package:expense_tracker/features/categories/domain/entities/category.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    super.isSynced,
    super.isDeleted,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map[DatabaseTables.colId] as String,
      name: map[DatabaseTables.colName] as String,
      isSynced: (map[DatabaseTables.colIsSynced] as int? ?? 0) == 1,
      isDeleted: (map[DatabaseTables.colIsDeleted] as int? ?? 0) == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      DatabaseTables.colId: id,
      DatabaseTables.colName: name,
      DatabaseTables.colIsSynced: isSynced ? 1 : 0,
      DatabaseTables.colIsDeleted: isDeleted ? 1 : 0,
    };
  }
}
