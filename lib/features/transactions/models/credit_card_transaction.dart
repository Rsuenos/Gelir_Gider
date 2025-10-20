class CreditCardTransaction {
  const CreditCardTransaction({
    required this.id,
    required this.ownerId,
    required this.cardId,
    required this.flow,
    required this.amount,
    required this.dueDate,
    required this.isPosted,
    required this.createdAt,
    this.expenseId,
    this.description,
    this.installmentTotal,
    this.installmentNo,
    this.postedAt,
  });

  factory CreditCardTransaction.fromJson(Map<String, dynamic> json) {
    return CreditCardTransaction(
      id: json['id'] as String,
      ownerId: json['owner_id'] as String,
      cardId: json['card_id'] as String,
      expenseId: json['expense_id'] as String?,
      flow: json['flow'] as String,
      amount: (json['amount'] as num).toDouble(),
      description: json['description'] as String?,
      installmentTotal: json['installment_total'] as int?,
      installmentNo: json['installment_no'] as int?,
      isPosted: json['is_posted'] as bool,
      dueDate: DateTime.parse(json['due_date'] as String),
      postedAt: json['posted_at'] != null
          ? DateTime.parse(json['posted_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  final String id;
  final String ownerId;
  final String cardId;
  final String? expenseId;
  final String flow; // 'spend' | 'payment'
  final double amount;
  final String? description;
  final int? installmentTotal; // 2..12
  final int? installmentNo; // 1..N
  final bool isPosted;
  final DateTime dueDate;
  final DateTime? postedAt;
  final DateTime createdAt;

  CreditCardTransaction copyWith({
    String? id,
    String? ownerId,
    String? cardId,
    String? expenseId,
    String? flow,
    double? amount,
    String? description,
    int? installmentTotal,
    int? installmentNo,
    bool? isPosted,
    DateTime? dueDate,
    DateTime? postedAt,
    DateTime? createdAt,
  }) {
    return CreditCardTransaction(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      cardId: cardId ?? this.cardId,
      expenseId: expenseId ?? this.expenseId,
      flow: flow ?? this.flow,
      amount: amount ?? this.amount,
      description: description ?? this.description,
      installmentTotal: installmentTotal ?? this.installmentTotal,
      installmentNo: installmentNo ?? this.installmentNo,
      isPosted: isPosted ?? this.isPosted,
      dueDate: dueDate ?? this.dueDate,
      postedAt: postedAt ?? this.postedAt,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'owner_id': ownerId,
      'card_id': cardId,
      'expense_id': expenseId,
      'flow': flow,
      'amount': amount,
      'description': description,
      'installment_total': installmentTotal,
      'installment_no': installmentNo,
      'is_posted': isPosted,
      'due_date': dueDate.toIso8601String().split('T')[0], // date only
      'posted_at': postedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'CreditCardTransaction(id: $id, flow: $flow, amount: $amount, dueDate: $dueDate)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CreditCardTransaction && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
