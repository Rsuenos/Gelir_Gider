class CreditCard {
  final String id;
  final String name;
  final String last4;
  final double limitAmount;
  final int cutoffDay;
  final int dueDay;
  final double aprPercent;

  CreditCard({
    required this.id,
    required this.name,
    required this.last4,
    required this.limitAmount,
    required this.cutoffDay,
    required this.dueDay,
    required this.aprPercent,
  });
}

class CardStatement {
  final String id;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime dueDate;
  final double total;
  final double minDue;
  final bool isClosed;

  CardStatement({
    required this.id,
    required this.periodStart,
    required this.periodEnd,
    required this.dueDate,
    required this.total,
    required this.minDue,
    required this.isClosed,
  });
}

class CardTransaction {
  final String id;
  final String flow; // spend|payment|refund|fee
  final double amount;
  final DateTime postedAt;
  final String? merchant;
  final String? category;
  final int? installmentTotal;
  final int? installmentNo;

  CardTransaction({
    required this.id,
    required this.flow,
    required this.amount,
    required this.postedAt,
    this.merchant,
    this.category,
    this.installmentTotal,
    this.installmentNo,
  });
}

class UpcomingInstallment {
  final String txnId;
  final int? installmentTotal;
  final int? installmentNo;
  final DateTime nextDueDate;

  UpcomingInstallment({
    required this.txnId,
    this.installmentTotal,
    this.installmentNo,
    required this.nextDueDate,
  });
}
