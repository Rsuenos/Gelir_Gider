import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/core/widgets/app_drawer.dart';
import 'package:gelir_gider/features/credit/data/credit_card_repository.dart';
import 'package:gelir_gider/features/transactions/data/transaction_repository.dart';
import 'package:gelir_gider/features/transactions/models/expense.dart';
import 'package:gelir_gider/features/transactions/services/expense_service.dart';
import 'package:gelir_gider/features/transactions/view/voice_input_button.dart';
import 'package:gelir_gider/features/wallets/wallet_selector.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'Payments'; // top: Payments|Spending...
  String _subCategory = 'Bill'; // e.g., Bill, CreditCard, Loan, Subscriptions
  String? _walletId;
  DateTime _date = DateTime.now();
  bool _busy = false;

  // Yeni alanlar: Ödeme tipi ve kredi kartı entegrasyonu
  PaymentType _paymentType = PaymentType.cash;
  String? _selectedCreditCardId;
  CreditCardFlow? _creditCardFlow;
  CardPaymentMode? _paymentMode;
  int? _installmentCount;
  List<Map<String, dynamic>> _availableCards = [];

  @override
  void initState() {
    super.initState();
    _loadCreditCards();
  }

  Future<void> _loadCreditCards() async {
    try {
      final cards = await CreditCardRepository.fetchCards();
      if (mounted) {
        setState(() {
          _availableCards = cards;
        });
      }
    } catch (e) {
      // Hata durumunda log
      debugPrint('Kredi kartları yüklenirken hata: $e');
    }
  }

  Future<void> _save() async {
    if (_walletId == null) return;

    final amount = double.tryParse(_amount.text.trim()) ?? 0;
    if (amount <= 0) return;

    setState(() => _busy = true);

    try {
      if (_paymentType == PaymentType.creditCard &&
          _selectedCreditCardId != null) {
        // Kredi kartı ile ödeme - yeni ExpenseService kullan
        final expense = Expense(
          id: '', // Repository tarafından set edilecek
          walletId: _walletId!,
          type: 'expense',
          category: _category,
          subcategory: _subCategory,
          amount: amount,
          occurredAt: _date,
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
          paymentType: _paymentType,
          creditCardId: _selectedCreditCardId,
          creditCardFlow: _creditCardFlow,
          cardPaymentMode: _paymentMode,
          installmentCount: _installmentCount,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await ExpenseService.createExpenseWithCardImpact(expense);
      } else {
        // Nakit ödeme - mevcut yöntem
        await TransactionRepository.add(
          walletId: _walletId!,
          type: 'expense',
          category: _category,
          subcategory: _subCategory,
          amount: amount,
          occurredAt: _date,
          description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
        );
      }

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hata: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _applyVoiceResult(String text) {
    final match = RegExp('([0-9]+([.,][0-9]+)?)').firstMatch(text);
    if (match != null) {
      _amount.text = match.group(0)!.replaceAll(',', '.');
      _desc.text = text.replaceFirst(match.group(0)!, '').trim();
    } else {
      _desc.text = text;
    }
  }

  String _getPaymentTypeText(PaymentType type) {
    switch (type) {
      case PaymentType.cash:
        return 'Nakit';
      case PaymentType.creditCard:
        return 'Kredi Kartı';
      case PaymentType.transfer:
        return 'Banka Havalesi';
    }
  }

  String _getCreditCardFlowText(CreditCardFlow flow) {
    switch (flow) {
      case CreditCardFlow.spend:
        return 'Harcama';
      case CreditCardFlow.payment:
        return 'Ödeme';
    }
  }

  String _getCardPaymentModeText(CardPaymentMode mode) {
    switch (mode) {
      case CardPaymentMode.single:
        return 'Tek Çekim';
      case CardPaymentMode.installment:
        return 'Taksitli';
    }
  }

  @override
  Widget build(BuildContext context) {
    const t = tr;

    final mainCats = {
      'Payments': ['Bill', 'CreditCard', 'Loan', 'Subscriptions'],
      'Spending': [
        'Grocery',
        'Pharmacy',
        'Vehicle',
        'Education',
        'Health',
        'Entertainment',
        'Vacation',
      ],
    };

    final submap = {
      'Grocery': ['Food', 'Cosmetics', 'Cleaning'],
      'Vehicle': ['Tax', 'Repair', 'Service', 'Fuel'],
    };

    final currentSubs = mainCats[_category]!;
    final subSubs = submap[_subCategory] ?? <String>[];

    return Scaffold(
      appBar: AppBar(title: Text(t('expense.addExpense'))),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WalletSelector(onChanged: (id) => setState(() => _walletId = id)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: mainCats.keys
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(t('expense.$e')),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _category = v;
                  _subCategory = mainCats[v]!.first;
                });
              }
            },
            decoration: InputDecoration(labelText: t('expense.mainClass')),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _subCategory,
            items: currentSubs
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(t('expense.$e')),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _subCategory = v ?? _subCategory),
            decoration: InputDecoration(labelText: t('expense.subClass')),
          ),
          const SizedBox(height: 12),
          // Ödeme Tipi Seçimi
          DropdownButtonFormField<PaymentType>(
            initialValue: _paymentType,
            items: PaymentType.values
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(_getPaymentTypeText(type)),
                  ),
                )
                .toList(),
            onChanged: (type) {
              setState(() {
                _paymentType = type ?? PaymentType.cash;
                if (_paymentType != PaymentType.creditCard) {
                  _selectedCreditCardId = null;
                  _creditCardFlow = null;
                  _paymentMode = null;
                  _installmentCount = null;
                }
              });
            },
            decoration: const InputDecoration(labelText: 'Ödeme Tipi'),
          ),

          // Kredi Kartı Seçimi (sadece kredi kartı ödemesinde görünür)
          if (_paymentType == PaymentType.creditCard) ...[
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _selectedCreditCardId,
              items: _availableCards
                  .map(
                    (card) => DropdownMenuItem<String>(
                      value: card['id'].toString(),
                      child: Text(card['card_name']?.toString() ?? 'Kart'),
                    ),
                  )
                  .toList(),
              onChanged: (cardId) {
                setState(() {
                  _selectedCreditCardId = cardId;
                });
              },
              decoration: const InputDecoration(labelText: 'Kredi Kartı'),
              hint: const Text('Kredi kartı seçin'),
            ),

            // Kredi Kartı Flow Seçimi
            if (_selectedCreditCardId != null) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<CreditCardFlow>(
                initialValue: _creditCardFlow,
                items: CreditCardFlow.values
                    .map(
                      (flow) => DropdownMenuItem(
                        value: flow,
                        child: Text(_getCreditCardFlowText(flow)),
                      ),
                    )
                    .toList(),
                onChanged: (flow) {
                  setState(() {
                    _creditCardFlow = flow;
                    _paymentMode = null;
                    _installmentCount = null;
                  });
                },
                decoration: const InputDecoration(labelText: 'Ödeme Akışı'),
              ),

              // Ödeme Modu Seçimi
              if (_creditCardFlow != null) ...[
                const SizedBox(height: 12),
                DropdownButtonFormField<CardPaymentMode>(
                  initialValue: _paymentMode,
                  items: CardPaymentMode.values
                      .map(
                        (mode) => DropdownMenuItem(
                          value: mode,
                          child: Text(_getCardPaymentModeText(mode)),
                        ),
                      )
                      .toList(),
                  onChanged: (mode) {
                    setState(() {
                      _paymentMode = mode;
                      if (mode != CardPaymentMode.installment) {
                        _installmentCount = null;
                      }
                    });
                  },
                  decoration: const InputDecoration(labelText: 'Ödeme Modu'),
                ),

                // Taksit Sayısı (sadece taksit modunda)
                if (_paymentMode == CardPaymentMode.installment) ...[
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: _installmentCount,
                    items: [2, 3, 4, 5, 6, 9, 12, 18, 24, 36]
                        .map(
                          (count) => DropdownMenuItem(
                            value: count,
                            child: Text('$count Taksit'),
                          ),
                        )
                        .toList(),
                    onChanged: (count) {
                      setState(() {
                        _installmentCount = count;
                      });
                    },
                    decoration:
                        const InputDecoration(labelText: 'Taksit Sayısı'),
                  ),
                ],
              ],
            ],
          ],
          if (subSubs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: subSubs
                  .map(
                    (e) => ActionChip(
                      label: Text(t('expense.$e')),
                      onPressed: () => _desc.text = e,
                    ),
                  )
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t('common.amount')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            decoration: InputDecoration(labelText: t('common.description')),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(DateFormat.yMMMd().format(_date))),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: _date,
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Text(t('common.pickDate')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          VoiceInputButton(
            onResult: _applyVoiceResult,
            label: t('common.voiceInput'),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy
                ? const CircularProgressIndicator()
                : Text(t('common.save')),
          ),
        ],
      ),
    );
  }
}
