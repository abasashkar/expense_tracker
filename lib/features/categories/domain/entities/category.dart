import 'package:equatable/equatable.dart';

class Category extends Equatable {
  const Category({
    required this.id,
    required this.name,
    this.isSynced = false,
    this.isDeleted = false,
  });

  final String id;
  final String name;
  final bool isSynced;
  final bool isDeleted;

  @override
  List<Object?> get props => [id, name, isSynced, isDeleted];
}
