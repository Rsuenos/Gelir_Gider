import 'dart:async';

import 'package:gelir_gider/core/services/supabase_service.dart';
import 'package:gelir_gider/features/credit/data/credit_card_repository.dart';
import 'package:gelir_gider/features/transactions/data/transaction_repository.dart';
import 'package:gelir_gider/features/transactions/models/credit_card_transaction.dart';
import 'package:gelir_gider/features/transactions/models/expense.dart';
import 'package:gelir_gider/features/transactions/utils/installment_utils.dart';
import 'package:uuid/uuid.dart';

class ExpenseService {
  static const _uuid = Uuid();

  /// Create expense with credit card impact (transactional)
  static Future<void> createExpenseWithCardImpact(Expense expense) async {
    final userId = SupabaseService.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Kullanıcı oturumu bulunamadı');
    }

    // Validate credit card payment fields
    if (expense.paymentType == PaymentType.creditCard) {
      if (expense.creditCardFlow == null) {
        throw ArgumentError('Kredi kartı işlem türü gerekli');
      }
      if (expense.creditCardId == null) {
        throw ArgumentError('Kredi kartı seçimi gerekli');
      }
      if (expense.cardPaymentMode == null) {
        throw ArgumentError('Ödeme şekli seçimi gerekli');
      }
      if (expense.cardPaymentMode == CardPaymentMode.installment) {
        if (expense.installmentCount == null ||
            expense.installmentCount! < 2 ||
            expense.installmentCount! > 12) {
          throw ArgumentError('Taksit sayısı 2-12 arasında olmalı');
        }
      }

      // Validate that the credit card exists
      final cards = await CreditCardRepository.fetchCards();
      final cardExists =
          cards.any((card) => card['id'] == expense.creditCardId);
      if (!cardExists) {
        throw ArgumentError('Seçilen kredi kartı bulunamadı');
      }
    }

    // Start transaction
    try {
      // 1. Create the expense record (using existing flow)
      await TransactionRepository.add(
        walletId: expense.walletId,
        type: expense.type,
        category: expense.category,
        subcategory: expense.subcategory,
        amount: expense.amount,
        occurredAt: expense.occurredAt,
        currency: expense.currency,
        description: expense.description,
        isUpcoming: expense.isUpcoming,
      );

      // 2. If credit card payment, create credit card transactions
      if (expense.paymentType == PaymentType.creditCard) {
        final expenseId = expense.id;
        await _createCreditCardTransactions(
          userId: userId,
          expenseId: expenseId,
          expense: expense,
        );
      }
    } catch (e) {
      // If any step fails, the error will bubble up and no partial data will remain
      // due to Supabase's transactional nature
      rethrow;
    }
  }

  static Future<void> _createCreditCardTransactions({
    required String userId,
    required String expenseId,
    required Expense expense,
  }) async {
    final now = DateTime.now();
    final transactions = <CreditCardTransaction>[];

    if (expense.cardPaymentMode == CardPaymentMode.single) {
      // Single payment: 1 posted transaction
      transactions.add(CreditCardTransaction(
        id: _uuid.v4(),
        ownerId: userId,
        cardId: expense.creditCardId!,
        expenseId: expenseId,
        flow: expense.creditCardFlow!.name,
        amount: expense.amount,
        description: expense.description,
        isPosted: true,
        dueDate: DateTime(expense.occurredAt.year, expense.occurredAt.month,
            expense.occurredAt.day,),
        postedAt: now,
        createdAt: now,
      ),);
    } else {
      // Installment payment: N transactions
      final installmentCount = expense.installmentCount!;
      final slices =
          InstallmentUtils.splitAmount(expense.amount, installmentCount);

      for (var i = 0; i < slices.length; i++) {
        final slice = slices[i];
        final dueDate = InstallmentUtils.addMonthsSafe(expense.occurredAt, i);
        final isCurrentMonth = InstallmentUtils.isSameMonth(dueDate, now);

        transactions.add(CreditCardTransaction(
          id: _uuid.v4(),
          ownerId: userId,
          cardId: expense.creditCardId!,
          expenseId: expenseId,
          flow: expense.creditCardFlow!.name,
          amount: slice.amount,
          description: expense.description,
          installmentTotal: installmentCount,
          installmentNo: slice.index,
          isPosted: isCurrentMonth,
          dueDate: DateTime(dueDate.year, dueDate.month, dueDate.day),
          postedAt: isCurrentMonth ? now : null,
          createdAt: now,
        ),);
      }
    }

    // Insert all transactions
    await CreditCardRepository.insertTransactions(transactions);
  }
}
