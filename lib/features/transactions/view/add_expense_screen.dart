import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider/core/widgets/app_drawer.dart';
import 'package:gelir_gider/features/transactions/data/transaction_repository.dart';
import 'package:gelir_gider/features/transactions/view/voice_input_button.dart';
import 'package:gelir_gider/features/wallets/wallet_selector.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'Payments'; // top: Payments|Spending...
  String _subCategory = 'Bill'; // e.g., Bill, CreditCard, Loan, Subscriptions
  String? _walletId;
  DateTime _date = DateTime.now();
  bool _busy = false;

  Future<void> _save() async {
    if (_walletId == null) return;
    setState(() => _busy = true);
    await TransactionRepository.add(
      walletId: _walletId!,
      type: 'expense',
      category: _category,
      subcategory: _subCategory,
      amount: double.tryParse(_amount.text.trim()) ?? 0,
      occurredAt: _date,
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
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
