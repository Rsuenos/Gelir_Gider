import 'dart:async';

import 'package:gelir_gider/core/services/supabase_service.dart';

/// Repository responsible for CRUD operations on credit cards.
class CreditCardRepository {
  static const _table = 'credit_cards';
  static const _installmentsTable = 'credit_card_installments';

  static Future<void> addCard({
    required String cardName,
    String? bankName,
    String? last4,
    int? statementDay,
    int? dueDay,
    double? totalLimit,
    double? currentBalance,
  }) async {
    final userId = SupabaseService.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Kullanıcı oturumu bulunamadı');
    }

    final payload = <String, dynamic>{
      'card_name': cardName,
      'owner_id': userId,
      if (bankName != null && bankName.trim().isNotEmpty) 'bank_name': bankName,
      if (last4 != null && last4.trim().isNotEmpty) 'last4': last4.trim(),
      if (statementDay != null) 'statement_day': statementDay,
      if (dueDay != null) 'due_day': dueDay,
      if (totalLimit != null) 'total_limit': totalLimit,
      'current_balance': currentBalance ?? 0,
    };

    await SupabaseService.client.from(_table).insert(payload);
  }

  static Future<List<Map<String, dynamic>>> fetchCards() async {
    try {
      final result = await SupabaseService.client
          .from(_table)
          .select()
          .order('card_name') as List<dynamic>;
      return result.cast<Map<String, dynamic>>();
    } on Object {
      return [];
    }
  }

  static Future<Map<String, dynamic>?> fetchCardDetail(String cardId) async {
    try {
      final card = await SupabaseService.client
          .from(_table)
          .select()
          .eq('id', cardId)
          .maybeSingle();

      if (card == null) return null;

      final rawInstallments = await SupabaseService.client
          .from(_installmentsTable)
          .select()
          .eq('card_id', cardId)
          .order('due_date')
          .limit(5) as List<dynamic>;

      final rawTransactions = await SupabaseService.client
          .from('transactions')
          .select()
          .eq('credit_card_id', cardId)
          .order('occurred_at', ascending: false)
          .limit(5) as List<dynamic>;

      return {
        'card': card,
        'installments': rawInstallments.cast<Map<String, dynamic>>(),
        'transactions': rawTransactions.cast<Map<String, dynamic>>(),
      };
    } on Object {
      return null;
    }
  }
}
