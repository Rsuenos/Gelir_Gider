import 'dart:async';

import 'package:gelir_gider/core/services/local_db.dart';
import 'package:gelir_gider/core/services/supabase_service.dart';
import 'package:uuid/uuid.dart';

/// Repository encapsulates all logic to add/edit/delete transactions,
/// synchronize with Supabase, and manage offline cache coherence.
class TransactionRepository {
  static const _table = 'transactions';
  static const _uuid = Uuid();

  /// Add income/expense to Supabase and cache.
  static Future<void> add({
    required String walletId,
    required String type, // 'income' | 'expense' | 'transfer'
    required String category,
    required double amount,
    required DateTime occurredAt,
    String? subcategory,
    String currency = 'USD',
    String? description,
    bool isUpcoming = false,
  }) async {
    final id = _uuid.v4();
    final row = {
      'id': id,
      'wallet_id': walletId,
      'type': type,
      'category': category,
      'subcategory': subcategory,
      'amount': amount,
      'currency': currency,
      'occurred_at': occurredAt.toUtc().toIso8601String(),
      'description': description,
      'is_upcoming': isUpcoming,
    };

    // Try remote first; if fails, cache-only (queued sync).
    try {
      await SupabaseService.client.from(_table).insert(row);
    } on Exception catch (_) {
         }

    // Cache
    await LocalDb.upsertTransactions([
      {
        'id': id,
        'wallet_id': walletId,
        'type': type,
        'category': category,
        'subcategory': subcategory,
        'amount': amount,
        'currency': currency,
        'occurred_at': occurredAt.millisecondsSinceEpoch,
        'description': description,
        'is_upcoming': isUpcoming ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }
    ]);
  }

  /// Pulls latest changes from Supabase into local cache.
  static Future<void> syncFromSupabase() async {
    try {
      final data = await SupabaseService.client
          .from(_table)
          .select()
          .order('occurred_at', ascending: false)
          .limit(100);

      final normalized =
          (data as List<dynamic>).map<Map<String, dynamic>>((dynamic raw) {
        final record = raw as Map<String, dynamic>;
        return {
          'id': record['id'],
          'wallet_id': record['wallet_id'],
          'type': record['type'],
          'category': record['category'],
          'subcategory': record['subcategory'],
          'amount': record['amount'],
          'currency': record['currency'] ?? 'USD',
          'occurred_at': DateTime.parse(
            record['occurred_at'] as String,
          ).millisecondsSinceEpoch,
          'description': record['description'],
          'is_upcoming': record['is_upcoming']?.toString() == 'true' ? 1 : 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        };
      }).toList();

      await LocalDb.upsertTransactions(normalized);
    } on Exception catch (_) {
      // network error: ignore
    }
  }
}
