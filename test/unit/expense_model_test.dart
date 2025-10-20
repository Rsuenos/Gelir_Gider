import 'package:flutter_test/flutter_test.dart';
import 'package:gelir_gider/features/transactions/models/expense.dart';

void main() {
  group('Expense Model Tests', () {
    test('Expense creation - nakit ödeme', () {
      // Arrange & Act
      final expense = Expense(
        id: 'expense-123',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Spending',
        subcategory: 'Grocery',
        amount: 150.0,
        occurredAt: DateTime(2024, 1, 15),
        paymentType: PaymentType.cash,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(expense.id, 'expense-123');
      expect(expense.paymentType, PaymentType.cash);
      expect(expense.creditCardId, isNull);
      expect(expense.creditCardFlow, isNull);
      expect(expense.cardPaymentMode, isNull);
      expect(expense.installmentCount, isNull);
    });

    test('Expense creation - kredi kartı tek çekim', () {
      // Arrange & Act
      final expense = Expense(
        id: 'expense-456',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Payments',
        subcategory: 'CreditCard',
        amount: 300.0,
        occurredAt: DateTime(2024, 1, 15),
        paymentType: PaymentType.creditCard,
        creditCardId: 'card-123',
        creditCardFlow: CreditCardFlow.spend,
        cardPaymentMode: CardPaymentMode.single,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(expense.paymentType, PaymentType.creditCard);
      expect(expense.creditCardId, 'card-123');
      expect(expense.creditCardFlow, CreditCardFlow.spend);
      expect(expense.cardPaymentMode, CardPaymentMode.single);
      expect(expense.installmentCount, isNull);
    });

    test('Expense creation - kredi kartı taksitli', () {
      // Arrange & Act
      final expense = Expense(
        id: 'expense-789',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Spending',
        subcategory: 'Electronics',
        amount: 1200.0,
        occurredAt: DateTime(2024, 1, 15),
        paymentType: PaymentType.creditCard,
        creditCardId: 'card-456',
        creditCardFlow: CreditCardFlow.spend,
        cardPaymentMode: CardPaymentMode.installment,
        installmentCount: 12,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Assert
      expect(expense.paymentType, PaymentType.creditCard);
      expect(expense.creditCardId, 'card-456');
      expect(expense.creditCardFlow, CreditCardFlow.spend);
      expect(expense.cardPaymentMode, CardPaymentMode.installment);
      expect(expense.installmentCount, 12);
    });

    test('JSON serialization - kredi kartı ödemesi', () {
      // Arrange
      final originalExpense = Expense(
        id: 'expense-json',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Spending',
        subcategory: 'Grocery',
        amount: 250.0,
        occurredAt: DateTime(2024, 1, 15),
        description: 'Market alışverişi',
        paymentType: PaymentType.creditCard,
        creditCardId: 'card-123',
        creditCardFlow: CreditCardFlow.spend,
        cardPaymentMode: CardPaymentMode.installment,
        installmentCount: 3,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Act
      final json = originalExpense.toJson();
      final parsedExpense = Expense.fromJson(json);

      // Assert
      expect(parsedExpense.id, originalExpense.id);
      expect(parsedExpense.walletId, originalExpense.walletId);
      expect(parsedExpense.amount, originalExpense.amount);
      expect(parsedExpense.description, originalExpense.description);
      expect(parsedExpense.paymentType, originalExpense.paymentType);
      expect(parsedExpense.creditCardId, originalExpense.creditCardId);
      expect(parsedExpense.creditCardFlow, originalExpense.creditCardFlow);
      expect(parsedExpense.cardPaymentMode, originalExpense.cardPaymentMode);
      expect(parsedExpense.installmentCount, originalExpense.installmentCount);
    });

    test('JSON serialization - nakit ödeme', () {
      // Arrange
      final originalExpense = Expense(
        id: 'expense-cash',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Spending',
        subcategory: 'Food',
        amount: 75.0,
        occurredAt: DateTime(2024, 1, 15),
        paymentType: PaymentType.cash,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Act
      final json = originalExpense.toJson();
      final parsedExpense = Expense.fromJson(json);

      // Assert
      expect(parsedExpense.paymentType, PaymentType.cash);
      expect(parsedExpense.creditCardId, isNull);
      expect(parsedExpense.creditCardFlow, isNull);
      expect(parsedExpense.cardPaymentMode, isNull);
      expect(parsedExpense.installmentCount, isNull);
    });

    test('copyWith method - updating credit card fields', () {
      // Arrange
      final originalExpense = Expense(
        id: 'expense-copy',
        walletId: 'wallet-123',
        type: 'expense',
        category: 'Spending',
        subcategory: 'Grocery',
        amount: 100.0,
        occurredAt: DateTime(2024, 1, 15),
        paymentType: PaymentType.cash,
        createdAt: DateTime(2024, 1, 15),
        updatedAt: DateTime(2024, 1, 15),
      );

      // Act
      final updatedExpense = originalExpense.copyWith(
        paymentType: PaymentType.creditCard,
        creditCardId: 'card-new',
        creditCardFlow: CreditCardFlow.spend,
        cardPaymentMode: CardPaymentMode.single,
      );

      // Assert
      expect(updatedExpense.id, originalExpense.id); // Unchanged
      expect(updatedExpense.amount, originalExpense.amount); // Unchanged
      expect(updatedExpense.paymentType, PaymentType.creditCard); // Changed
      expect(updatedExpense.creditCardId, 'card-new'); // Changed
      expect(updatedExpense.creditCardFlow, CreditCardFlow.spend); // Changed
      expect(updatedExpense.cardPaymentMode, CardPaymentMode.single); // Changed
    });

    test('Enum values validation', () {
      // Assert - PaymentType values
      expect(PaymentType.values.length, 3);
      expect(
          PaymentType.values,
          containsAll([
            PaymentType.cash,
            PaymentType.transfer,
            PaymentType.creditCard,
          ]));

      // Assert - CreditCardFlow values
      expect(CreditCardFlow.values.length, 2);
      expect(
          CreditCardFlow.values,
          containsAll([
            CreditCardFlow.spend,
            CreditCardFlow.payment,
          ]));

      // Assert - CardPaymentMode values
      expect(CardPaymentMode.values.length, 2);
      expect(
          CardPaymentMode.values,
          containsAll([
            CardPaymentMode.single,
            CardPaymentMode.installment,
          ]));
    });
  });
}
