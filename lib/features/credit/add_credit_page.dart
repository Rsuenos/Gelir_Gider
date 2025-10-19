import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider/core/widgets/app_drawer.dart';
import 'package:gelir_gider/features/credit/data/credit_card_repository.dart';
import 'package:gelir_gider/features/debt/data/debt_repository.dart';
import 'package:gelir_gider/features/transactions/data/transaction_repository.dart';
import 'package:gelir_gider/features/wallets/wallet_selector.dart';

class AddCreditPage extends StatefulWidget {
  const AddCreditPage({super.key});

  @override
  State<AddCreditPage> createState() => _AddCreditPageState();
}

class _AddCreditPageState extends State<AddCreditPage> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _amount = TextEditingController();
  final _monthlyPayment = TextEditingController();
  final _description = TextEditingController();
  DateTime? _nextDueDate;
  String? _walletId;
  String? _selectedCardId;
  bool _busy = false;
  bool _loadingCards = true;
  List<Map<String, dynamic>> _cards = const [];

  @override
  void initState() {
    super.initState();
    unawaited(_loadCards());
  }

  Future<void> _loadCards() async {
    final cards = await CreditCardRepository.fetchCards();
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _loadingCards = false;
    });
  }

  Future<void> _selectNextDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
      initialDate: _nextDueDate ?? now,
    );
    if (picked != null) {
      setState(() => _nextDueDate = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_walletId == null || _walletId!.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('credit.walletRequired'))),
      );
      return;
    }

    final amountValue =
        double.tryParse(_amount.text.trim().replaceAll(',', '.'));
    final monthlyValue =
        double.tryParse(_monthlyPayment.text.trim().replaceAll(',', '.'));

    if (amountValue == null || amountValue <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('credit.amountInvalid'))),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await DebtRepository.addDebt(
        title: _title.text.trim(),
        totalAmount: amountValue,
        remainingAmount: amountValue,
        monthlyPayment: monthlyValue,
        nextDueDate: _nextDueDate,
        kind: 'credit',
        creditCardId: _selectedCardId?.isEmpty ?? true ? null : _selectedCardId,
      );

      await TransactionRepository.add(
        walletId: _walletId!,
        type: 'income',
        category: 'Loan',
        subcategory: 'Credit',
        amount: amountValue,
        occurredAt: DateTime.now(),
        description: _description.text.trim().isEmpty
            ? 'Credit: ${_title.text.trim()}'
            : _description.text.trim(),
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('credit.creditCreated'))),
      );
      Navigator.of(context).pop();
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _amount.dispose();
    _monthlyPayment.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const t = tr;
    final dueText = _nextDueDate == null
        ? t('credit.nextDueDateHint')
        : DateFormat.yMMMd().format(_nextDueDate!);

    return Scaffold(
      appBar: AppBar(title: Text(t('credit.addCredit'))),
      drawer: const AppDrawer(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            WalletSelector(onChanged: (value) => _walletId = value),
            const SizedBox(height: 12),
            TextFormField(
              controller: _title,
              decoration: InputDecoration(labelText: t('credit.loanTitle')),
              validator: (value) => value == null || value.trim().isEmpty
                  ? t('credit.required')
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _amount,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: t('credit.amount')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _monthlyPayment,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: t('credit.monthlyPayment')),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(t('credit.nextDueDate')),
              subtitle: Text(dueText),
              trailing: const Icon(Icons.calendar_today),
              onTap: _selectNextDueDate,
            ),
            const SizedBox(height: 12),
            if (_loadingCards)
              const Center(child: CircularProgressIndicator())
            else
              DropdownButtonFormField<String>(
                initialValue: _selectedCardId ?? '',
                decoration:
                    InputDecoration(labelText: t('credit.selectCardOptional')),
                items: [
                  DropdownMenuItem(
                    value: '',
                    child: Text(t('credit.noCardOption')),
                  ),
                  ..._cards.map(
                    (card) => DropdownMenuItem(
                      value: card['id'] as String,
                      child: Text(card['card_name'] as String? ?? '-'),
                    ),
                  ),
                ],
                onChanged: (value) => setState(() => _selectedCardId = value),
              ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _description,
              decoration: InputDecoration(labelText: t('credit.description')),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _busy ? null : _submit,
              icon: _busy
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(t('common.save')),
            ),
          ],
        ),
      ),
    );
  }
}
