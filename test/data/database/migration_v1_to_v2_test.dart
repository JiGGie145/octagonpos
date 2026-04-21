import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_pos/data/database/app_database.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart' as sqlite;

void main() {
  group('Migration v1 -> v2', () {
    late Directory tempDir;
    late File dbFile;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('flutter_pos_migration_');
      dbFile = File('${tempDir.path}/pos_v1.sqlite');
      _createV1Database(dbFile);
    });

    tearDown(() async {
      if (await dbFile.exists()) {
        await dbFile.delete();
      }
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('upgrades schema and preserves v1 rows', () async {
      final db = AppDatabase(NativeDatabase(dbFile));
      addTearDown(db.close);

      final products = await db.getAllProducts();
      expect(products, hasLength(1));

      final product = products.single;
      expect(product.localId, 'prod-v1');
      expect(product.name, 'Legacy Coffee');
      expect(product.price, 3000);

      // New product columns should be available with expected defaults/nulls.
      expect(product.trackStock, isFalse);
      expect(product.usesIngredients, isFalse);
      expect(product.stockQty, isNull);
      expect(product.lowStockThreshold, isNull);
      expect(product.costPrice, isNull);
      expect(product.isSellable, isTrue);

      // Existing order item should remain and new snapshot columns should exist.
      final itemRows = await db.customSelect(
        "SELECT local_id, cost_snapshot_total, revenue_snapshot_total "
        "FROM order_items WHERE local_id = 'item-v1'",
      ).get();

      expect(itemRows, hasLength(1));
      expect(itemRows.single.read<String>('local_id'), 'item-v1');
      expect(itemRows.single.read<int?>('cost_snapshot_total'), isNull);
      expect(itemRows.single.read<int?>('revenue_snapshot_total'), isNull);

      // New v2 tables should exist.
      final tables = await db.customSelect(
        "SELECT name FROM sqlite_master "
        "WHERE type = 'table' "
        "AND name IN ('recipe_items','restock_entries','stock_adjustments')",
      ).get();

      final tableNames = tables.map((r) => r.read<String>('name')).toSet();
      expect(tableNames, containsAll(<String>{
        'recipe_items',
        'restock_entries',
        'stock_adjustments',
      }));
    });
  });
}

void _createV1Database(File file) {
  final rawDb = sqlite.sqlite3.open(file.path);

  // Schema version 1 baseline (before inventory migration).
  rawDb.execute('''
    CREATE TABLE products (
      local_id TEXT NOT NULL PRIMARY KEY,
      name TEXT NOT NULL,
      price INTEGER NOT NULL,
      category TEXT NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      image_url TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'pending'
    );
  ''');

  rawDb.execute('''
    CREATE TABLE orders (
      local_id TEXT NOT NULL UNIQUE,
      order_number INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,
      status TEXT NOT NULL DEFAULT 'pending',
      note TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      deleted_at INTEGER,
      sync_status TEXT NOT NULL DEFAULT 'pending'
    );
  ''');

  rawDb.execute('''
    CREATE TABLE order_items (
      local_id TEXT NOT NULL PRIMARY KEY,
      order_id TEXT NOT NULL,
      product_id TEXT NOT NULL,
      product_name TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');

  rawDb.execute('''
    CREATE TABLE payments (
      local_id TEXT NOT NULL PRIMARY KEY,
      order_id TEXT NOT NULL,
      method TEXT NOT NULL,
      amount INTEGER NOT NULL,
      created_at INTEGER NOT NULL
    );
  ''');

  rawDb.execute('''
    CREATE TABLE settings (
      id INTEGER NOT NULL PRIMARY KEY DEFAULT 1,
      business_name TEXT NOT NULL,
      currency TEXT NOT NULL,
      currency_symbol TEXT NOT NULL,
      tax_percentage INTEGER NOT NULL,
      receipt_footer TEXT NOT NULL DEFAULT ''
    );
  ''');

  const ts = 1735689600; // 2025-01-01T00:00:00Z

  rawDb.execute(
    'INSERT INTO products ('
    'local_id, name, price, category, is_active, image_url, '
    'created_at, updated_at, deleted_at, sync_status'
    ') VALUES ('
    "'prod-v1', 'Legacy Coffee', 3000, 'Beverages', 1, NULL, "
    '$ts, $ts, NULL, '
    "'pending'"
    ')',
  );

  rawDb.execute(
    'INSERT INTO orders ('
    'local_id, status, note, created_at, updated_at, deleted_at, sync_status'
    ') VALUES ('
    "'order-v1', 'pending', 'legacy note', $ts, $ts, NULL, 'pending'"
    ')',
  );

  rawDb.execute(
    'INSERT INTO order_items ('
    'local_id, order_id, product_id, product_name, quantity, unit_price, created_at, updated_at'
    ') VALUES ('
    "'item-v1', 'order-v1', 'prod-v1', 'Legacy Coffee', 2, 3000, $ts, $ts"
    ')',
  );

  rawDb.execute('PRAGMA user_version = 1;');
  rawDb.dispose();
}
