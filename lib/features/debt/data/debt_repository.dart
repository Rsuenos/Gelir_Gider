import 'dart:async';
import 'dart:math';

import 'package:gelir_gider/core/services/supabase_service.dart';
import 'package:gelir_gider/features/transactions/data/transaction_repository.dart';

/// Repository for managing debts and credit-based liabilities.
class DebtRepository {
  static const _table = 'debts';

  static Future<void> addDebt({
    required String title,
    required double totalAmount,
    required double remainingAmount,
    double? monthlyPayment,
    DateTime? nextDueDate,
    String kind = 'debt',
    String? creditCardId,
  }) async {
    final payload = <String, dynamic>{
      'title': title,
      'total_amount': totalAmount,
      'remaining_amount': max(remainingAmount, 0),
      'kind': kind,
      if (monthlyPayment != null) 'monthly_payment': monthlyPayment,
      if (nextDueDate != null)
        'next_due_date':
            DateTime(nextDueDate.year, nextDueDate.month, nextDueDate.day)
                .toIso8601String(),
      if (creditCardId != null && creditCardId.isNotEmpty)
        'credit_card_id': creditCardId,
    };

    await SupabaseService.client.from(_table).insert(payload);
  }

  static Future<void> applyPayment({
    required String debtId,
    required double amount,
    required String walletId,
    DateTime? paidAt,
  }) async {
    try {
      final data = await SupabaseService.client
          .from(_table)
          .select('id, title, remaining_amount')
          .eq('id', debtId)
          .maybeSingle();

      if (data == null) return;

      final remaining = (data['remaining_amount'] as num).toDouble() - amount;
      await SupabaseService.client.from(_table).update({
        'remaining_amount': max(0, remaining),
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      }).eq('id', debtId);

      await TransactionRepository.add(
        walletId: walletId,
        type: 'expense',
        category: 'Loan',
        subcategory: 'DebtPayment',
        amount: amount,
        occurredAt: paidAt ?? DateTime.now(),
        description: 'Payment for debt ${data['title']}',
      );
    } on Object {
      // Ignore transient failures; upstream callers can surface errors if
      // desired.
    }
  }

  static Future<Map<String, double>> totalRemainingByKind() async {
    try {
      final data = await SupabaseService.client
          .from(_table)
          .select('kind, remaining_amount') as List<dynamic>;

      final totals = <String, double>{'credit': 0, 'debt': 0};
      for (final raw in data) {
        final map = raw as Map<String, dynamic>;
        final kind = (map['kind'] as String?) ?? 'debt';
        final amount = (map['remaining_amount'] as num?)?.toDouble() ?? 0;
        totals.update(kind, (value) => value + amount, ifAbsent: () => amount);
      }
      return totals;
    } on Object {
      return const {'credit': 0, 'debt': 0};
    }
  }

  static Future<List<Map<String, dynamic>>> fetchDebts({String? kind}) async {
    try {
      var query = SupabaseService.client.from(_table).select();
      if (kind != null) {
        query = query.eq('kind', kind);
      }
      final data =
          await query.order('updated_at', ascending: false) as List<dynamic>;
      return data.cast<Map<String, dynamic>>();
    } on Object {
      return [];
    }
  }
}
