import 'package:gelir_gider/features/cards/domain/models.dart';

abstract class CreditCardRepository {
  Future<List<CreditCard>> listCards();
  Future<List<CardTransaction>> listTransactions(String cardId);
  Future<List<CardStatement>> listStatements(String cardId);
  Future<List<UpcomingInstallment>> listUpcoming(String cardId);

  Future<void> createSpend({
    required String cardId,
    required double amount,
    String? merchant,
    String? category,
    int? installmentTotal,
  });

  Future<void> createPayment({
    required String cardId,
    String? statementId,
    required double amount,
    String method = 'eft',
  });

  Future<void> closeStatement({
    required String cardId,
    required DateTime periodEnd,
  });
}
