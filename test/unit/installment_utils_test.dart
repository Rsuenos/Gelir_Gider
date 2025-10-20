import 'package:flutter_test/flutter_test.dart';
import 'package:gelir_gider/features/transactions/utils/installment_utils.dart';

void main() {
  group('InstallmentUtils Tests', () {
    test('splitAmount - 600 TL, 6 taksit', () {
      // Act
      final installments = InstallmentUtils.splitAmount(600.0, 6);

      // Assert
      expect(installments.length, 6);
      for (final installment in installments) {
        expect(installment.amount, 100.0);
      }
    });

    test('splitAmount - 1000 TL, 12 taksit', () {
      // Act
      final installments = InstallmentUtils.splitAmount(1000.0, 12);

      // Assert
      expect(installments.length, 12);
      // İlk 11 taksit 83.33, son taksit 83.37 olmalı (kuruş farkı)
      for (var i = 0; i < 11; i++) {
        expect(installments[i].amount, 83.33);
      }
      expect(installments[11].amount, 83.37);
    });

    test('splitAmount - 100 TL, 3 taksit (kuruş farkı testi)', () {
      // Act
      final installments = InstallmentUtils.splitAmount(100.0, 3);

      // Assert
      expect(installments.length, 3);
      expect(installments[0].amount, 33.33);
      expect(installments[1].amount, 33.33);
      expect(installments[2].amount, 33.34); // Son taksitte kuruş farkı

      // Toplam kontrolü
      final total =
          installments.fold<double>(0, (sum, slice) => sum + slice.amount);
      expect(total, 100.0);
    });

    test('splitAmount - tek taksit', () {
      // Act
      final installments = InstallmentUtils.splitAmount(500.0, 1);

      // Assert
      expect(installments.length, 1);
      expect(installments[0].amount, 500.0);
      expect(installments[0].index, 1);
    });

    test('addMonthsSafe - ay ilerletme testi', () {
      // Arrange
      final startDate = DateTime(2024, 1, 15);

      // Act
      final nextMonth = InstallmentUtils.addMonthsSafe(startDate, 1);
      final twoMonthsLater = InstallmentUtils.addMonthsSafe(startDate, 2);

      // Assert
      expect(nextMonth, DateTime(2024, 2, 15));
      expect(twoMonthsLater, DateTime(2024, 3, 15));
    });

    test('addMonthsSafe - yıl geçiş testi', () {
      // Arrange
      final startDate = DateTime(2024, 11, 15);

      // Act
      final twoMonthsLater = InstallmentUtils.addMonthsSafe(startDate, 2);

      // Assert
      expect(twoMonthsLater, DateTime(2025, 1, 15));
    });

    test('addMonthsSafe - 31 Ocak → 29 Şubat (artık yıl)', () {
      // Arrange
      final startDate = DateTime(2024, 1, 31); // 2024 artık yıl

      // Act
      final february = InstallmentUtils.addMonthsSafe(startDate, 1);

      // Assert
      expect(february, DateTime(2024, 2, 29)); // 29 Şubat'a düşer
    });

    test('InstallmentSlice model test', () {
      // Arrange
      const slice = InstallmentSlice(
        index: 2,
        amount: 150.5,
      );

      // Assert
      expect(slice.index, 2);
      expect(slice.amount, 150.5);
    });

    test('edge case - 0 taksit', () {
      // Act & Assert
      expect(() => InstallmentUtils.splitAmount(100.0, 0), throwsArgumentError);
    });

    test('edge case - negatif taksit sayısı', () {
      // Act & Assert
      expect(
          () => InstallmentUtils.splitAmount(100.0, -1), throwsArgumentError,);
    });

    test('edge case - 0 tutar', () {
      // Act
      final installments = InstallmentUtils.splitAmount(0.0, 3);

      // Assert
      expect(installments.length, 3);
      for (final installment in installments) {
        expect(installment.amount, 0.0);
      }
    });
  });
}
