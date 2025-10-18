import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite cache for offline-first functionality.
/// This DB stores a denormalized subset of data for offline use.
/// In production, consider SQLCipher or at least app-level encryption for
/// sensitive fields.
class LocalDb {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'gelir_gider_cache.db');

    // Note: For at-rest encryption, consider sqlcipher plugin
    // (platform-specific).
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Minimal tables for offline cache; remote is authoritative
        // (Supabase).
        await db.execute('''
          CREATE TABLE IF NOT EXISTS wallets (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            currency TEXT NOT NULL DEFAULT 'USD',
            updated_at INTEGER NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS transactions (
            id TEXT PRIMARY KEY,
            wallet_id TEXT NOT NULL,
            type TEXT NOT NULL,
            category TEXT NOT NULL,
            subcategory TEXT,
            amount REAL NOT NULL,
            currency TEXT NOT NULL DEFAULT 'USD',
            occurred_at INTEGER NOT NULL,
            description TEXT,
            is_upcoming INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL
          );
        ''');

        await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_tx_occurred '
          'ON transactions(occurred_at DESC);',
        );
      },
    );
    return db;
  }

  // Basic cache helpers (example)
  static Future<void> upsertTransactions(
    List<Map<String, dynamic>> rows,
  ) async {
    final db = await instance;
    final batch = db.batch();
    for (final r in rows) {
      batch.insert(
        'transactions',
        r,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getLastNTransactions(int n) async {
    final db = await instance;
    return db.query(
      'transactions',
      orderBy: 'occurred_at DESC',
      limit: n,
    );
  }

  static Future<List<Map<String, dynamic>>> getUpcomingN(int n) async {
    final db = await instance;
    return db.query(
      'transactions',
      where: 'is_upcoming = ?',
      whereArgs: [1],
      orderBy: 'occurred_at ASC',
      limit: n,
    );
  }
}
