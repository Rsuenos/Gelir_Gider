import 'package:flutter_test/flutter_test.dart';
import 'package:gelir_gider/features/cards/domain/models.dart';

void main() {
  test('CreditCard model constructs', () {
    final c = CreditCard(
      id: '1',
      name: 'Ana Kart',
      last4: '1234',
      limitAmount: 80000,
      cutoffDay: 10,
      dueDay: 15,
      aprPercent: 0,
    );
    expect(c.last4, '1234');
  });
}
