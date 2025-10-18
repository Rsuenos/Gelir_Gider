import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider/features/transactions/data/transaction_repository.dart';
import 'package:gelir_gider/features/transactions/view/voice_input_button.dart';
import 'package:gelir_gider/features/wallets/wallet_selector.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'Salary';
  String? _walletId;
  DateTime _date = DateTime.now();
  bool _busy = false;

  Future<void> _save() async {
    if (_walletId == null) return;
    setState(() => _busy = true);
    await TransactionRepository.add(
      walletId: _walletId!,
      type: 'income',
      category: _category,
      amount: double.tryParse(_amount.text.trim()) ?? 0,
      occurredAt: _date,
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _applyVoiceResult(String text) {
    // Simple NLP stub: Extract first number as amount, rest as description.
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

    return Scaffold(
      appBar: AppBar(title: Text(t('income.addIncome'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WalletSelector(onChanged: (id) => setState(() => _walletId = id)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _category,
            items: [
              'Salary',
              'Investment',
              'Freelance',
              'Passive',
              'Other',
            ]
                .map(
                  (e) => DropdownMenuItem(
                    value: e,
                    child: Text(t('income.$e')),
                  ),
                )
                .toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: InputDecoration(labelText: t('income.category')),
          ),
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
