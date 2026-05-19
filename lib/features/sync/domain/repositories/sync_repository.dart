import 'package:expense_tracker/core/error/failures.dart';

abstract class SyncRepository {
  Future<({bool? data, Failure? failure})> syncAll();

  /// True when there is upload, delete-purge, or category work for [syncAll].
  Future<({bool? data, Failure? failure})> hasPendingWork();
}
