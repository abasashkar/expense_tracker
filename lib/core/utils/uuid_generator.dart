import 'package:uuid/uuid.dart';

/// Generates local UUID v4 identifiers for categories and transactions (Phase 2).
class UuidGenerator {
  UuidGenerator._();

  static const _uuid = Uuid();

  static String newId() => _uuid.v4();
}
