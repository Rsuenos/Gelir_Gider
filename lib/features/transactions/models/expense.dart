enum PaymentType { cash, transfer, creditCard }

enum CreditCardFlow { spend, payment }

enum CardPaymentMode { single, installment }

class Expense {
  const Expense({
    required this.id,
    required this.walletId,
    required this.type,
    required this.category,
    required this.amount,
    required this.occurredAt,
    this.subcategory,
    this.currency = 'USD',
    this.description,
    this.isUpcoming = false,
    this.paymentType = PaymentType.cash,
    this.creditCardFlow,
    this.creditCardId,
    this.cardPaymentMode,
    this.installmentCount,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String walletId;
  final String type; // 'income' | 'expense' | 'transfer'
  final String category;
  final String? subcategory;
  final double amount;
  final String currency;
  final DateTime occurredAt;
  final String? description;
  final bool isUpcoming;

  // Yeni payment integration alanları
  final PaymentType paymentType; // cash | transfer | creditCard
  final CreditCardFlow? creditCardFlow; // only when creditCard
  final String? creditCardId; // only when creditCard
  final CardPaymentMode? cardPaymentMode; // only when creditCard
  final int? installmentCount; // 2..12, only when creditCard & installment

  final DateTime? createdAt;
  final DateTime? updatedAt;

  Expense copyWith({
    String? id,
    String? walletId,
    String? type,
    String? category,
    String? subcategory,
    double? amount,
    String? currency,
    DateTime? occurredAt,
    String? description,
    bool? isUpcoming,
    PaymentType? paymentType,
    CreditCardFlow? creditCardFlow,
    String? creditCardId,
    CardPaymentMode? cardPaymentMode,
    int? installmentCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      walletId: walletId ?? this.walletId,
      type: type ?? this.type,
      category: category ?? this.category,
      subcategory: subcategory ?? this.subcategory,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      occurredAt: occurredAt ?? this.occurredAt,
      description: description ?? this.description,
      isUpcoming: isUpcoming ?? this.isUpcoming,
      paymentType: paymentType ?? this.paymentType,
      creditCardFlow: creditCardFlow ?? this.creditCardFlow,
      creditCardId: creditCardId ?? this.creditCardId,
      cardPaymentMode: cardPaymentMode ?? this.cardPaymentMode,
      installmentCount: installmentCount ?? this.installmentCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'wallet_id': walletId,
      'type': type,
      'category': category,
      'subcategory': subcategory,
      'amount': amount,
      'currency': currency,
      'occurred_at': occurredAt.toIso8601String(),
      'description': description,
      'is_upcoming': isUpcoming,
      'payment_type': paymentType.name,
      'credit_card_flow': creditCardFlow?.name,
      'credit_card_id': creditCardId,
      'card_payment_mode': cardPaymentMode?.name,
      'installment_count': installmentCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      walletId: json['wallet_id'] as String,
      type: json['type'] as String,
      category: json['category'] as String,
      subcategory: json['subcategory'] as String?,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      occurredAt: DateTime.parse(json['occurred_at'] as String),
      description: json['description'] as String?,
      isUpcoming: json['is_upcoming'] as bool? ?? false,
      paymentType: _parsePaymentType(json['payment_type'] as String?),
      creditCardFlow: _parseCreditCardFlow(json['credit_card_flow'] as String?),
      creditCardId: json['credit_card_id'] as String?,
      cardPaymentMode:
          _parseCardPaymentMode(json['card_payment_mode'] as String?),
      installmentCount: json['installment_count'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  static PaymentType _parsePaymentType(String? value) {
    if (value == null) return PaymentType.cash; // default for old data
    return PaymentType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => PaymentType.cash,
    );
  }

  static CreditCardFlow? _parseCreditCardFlow(String? value) {
    if (value == null) return null;
    return CreditCardFlow.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CreditCardFlow.spend,
    );
  }

  static CardPaymentMode? _parseCardPaymentMode(String? value) {
    if (value == null) return null;
    return CardPaymentMode.values.firstWhere(
      (e) => e.name == value,
      orElse: () => CardPaymentMode.single,
    );
  }

  @override
  String toString() {
    return 'Expense(id: $id, category: $category, amount: $amount, paymentType: $paymentType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Expense && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
