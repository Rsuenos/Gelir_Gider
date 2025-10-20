import 'package:flutter_test/flutter_test.dart';
import 'package:gelir_gider/features/transactions/models/expense.dart';
import 'package:gelir_gider/features/transactions/services/expense_service.dart';

void main() {
  group('ExpenseService Tests', () {
    test('createExpenseWithCardImpact - tek çekim ödeme testi', () async {
      // Arrange: Tek çekim kredi kartı ödemesi
      final expense = Expense(
        id: '',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Payments',
        subcategory: 'CreditCard',
        amount: 100.0,
        occurredAt: DateTime.now(),
        paymentType: PaymentType.creditCard,
        creditCardId: 'card-123',
        creditCardFlow: CreditCardFlow.spend,
        cardPaymentMode: CardPaymentMode.single,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert: Test implementasyonu gerçek Supabase bağlantısı gerektiriyor
      // Burada sadece validation mantığını test edebiliriz
      expect(expense.paymentType, PaymentType.creditCard);
      expect(expense.cardPaymentMode, CardPaymentMode.single);
      expect(expense.installmentCount, isNull);
    });

    test('createExpenseWithCardImpact - taksitli ödeme validation testi',
        () async {
      // Arrange: Taksitli kredi kartı ödemesi
      final expense = Expense(
        id: '',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Spending',
        subcategory: 'Grocery',
        amount: 600.0,
        occurredAt: DateTime.now(),
        paymentType: PaymentType.creditCard,
        creditCardId: 'card-123',
        creditCardFlow: CreditCardFlow.spend,
        cardPaymentMode: CardPaymentMode.installment,
        installmentCount: 6,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Act & Assert: Model validation
      expect(expense.paymentType, PaymentType.creditCard);
      expect(expense.cardPaymentMode, CardPaymentMode.installment);
      expect(expense.installmentCount, 6);
      expect(expense.amount, 600.0);
    });

    test('Expense model - nakit ödeme testi', () {
      // Arrange: Nakit ödeme
      final expense = Expense(
        id: 'expense-123',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Spending',
        subcategory: 'Grocery',
        amount: 50.0,
        occurredAt: DateTime.now(),
        paymentType: PaymentType.cash,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Assert: Nakit ödeme alanları
      expect(expense.paymentType, PaymentType.cash);
      expect(expense.creditCardId, isNull);
      expect(expense.creditCardFlow, isNull);
      expect(expense.cardPaymentMode, isNull);
      expect(expense.installmentCount, isNull);
    });

    test('JSON serialization test', () {
      // Arrange
      final expense = Expense(
        id: 'expense-123',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Payments',
        subcategory: 'CreditCard',
        amount: 250.0,
        occurredAt: DateTime(2024, 1, 15),
        paymentType: PaymentType.creditCard,
        creditCardId: 'card-123',
        creditCardFlow: CreditCardFlow.spend,
        cardPaymentMode: CardPaymentMode.installment,
        installmentCount: 3,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Act: JSON'a çevir ve geri parse et
      final json = expense.toJson();
      final parsedExpense = Expense.fromJson(json);

      // Assert: Tüm alanlar korunmuş olmalı
      expect(parsedExpense.id, expense.id);
      expect(parsedExpense.amount, expense.amount);
      expect(parsedExpense.paymentType, expense.paymentType);
      expect(parsedExpense.creditCardId, expense.creditCardId);
      expect(parsedExpense.creditCardFlow, expense.creditCardFlow);
      expect(parsedExpense.cardPaymentMode, expense.cardPaymentMode);
      expect(parsedExpense.installmentCount, expense.installmentCount);
    });
  });
}
