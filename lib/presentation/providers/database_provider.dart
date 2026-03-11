import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_pos/data/database/app_database.dart';

/// Singleton provider for the Drift database instance.
///
/// This is the single source of truth for the database connection.
/// All repository providers depend on this.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(() => db.close());
  return db;
});
