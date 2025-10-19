import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider/core/widgets/app_drawer.dart';
import 'package:gelir_gider/features/credit/data/credit_card_repository.dart';

class AddCreditCardPage extends StatefulWidget {
  const AddCreditCardPage({super.key});

  @override
  State<AddCreditCardPage> createState() => _AddCreditCardPageState();
}

class _AddCreditCardPageState extends State<AddCreditCardPage> {
  final _formKey = GlobalKey<FormState>();
  final _cardName = TextEditingController();
  final _bankName = TextEditingController();
  final _last4 = TextEditingController();
  final _limit = TextEditingController();
  final _balance = TextEditingController();
  int? _statementDay;
  int? _dueDay;
  bool _busy = false;

  List<DropdownMenuItem<int>> get _dayItems => List.generate(
        28,
        (index) => DropdownMenuItem(
          value: index + 1,
          child: Text('${index + 1}'),
        ),
      );

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final limitText = _limit.text.trim();
    final balanceText = _balance.text.trim();
    final limitValue = limitText.isEmpty
        ? null
        : double.tryParse(limitText.replaceAll(',', '.'));
    final balanceValue = balanceText.isEmpty
        ? null
        : double.tryParse(balanceText.replaceAll(',', '.'));

    if (limitText.isNotEmpty && limitValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('credit.amountInvalid'))),
      );
      return;
    }

    if (balanceText.isNotEmpty && balanceValue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('credit.amountInvalid'))),
      );
      return;
    }

    if (limitValue != null && limitValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('credit.amountInvalid'))),
      );
      return;
    }

    if (balanceValue != null && balanceValue < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('credit.amountInvalid'))),
      );
      return;
    }

    setState(() => _busy = true);
    try {
      await CreditCardRepository.addCard(
        cardName: _cardName.text.trim(),
        bankName: _bankName.text.trim().isEmpty ? null : _bankName.text.trim(),
        last4: _last4.text.trim().isEmpty ? null : _last4.text.trim(),
        statementDay: _statementDay,
        dueDay: _dueDay,
        totalLimit: limitValue,
        currentBalance: balanceValue,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(tr('credit.cardCreated'))),
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
    _cardName.dispose();
    _bankName.dispose();
    _last4.dispose();
    _limit.dispose();
    _balance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const t = tr;

    return Scaffold(
      appBar: AppBar(title: Text(t('credit.addCreditCard'))),
      drawer: const AppDrawer(),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _cardName,
              decoration: InputDecoration(labelText: t('credit.cardName')),
              validator: (value) => value == null || value.trim().isEmpty
                  ? t('credit.required')
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _bankName,
              decoration: InputDecoration(labelText: t('credit.bankName')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _last4,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: InputDecoration(labelText: t('credit.last4')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _limit,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: t('credit.totalLimit')),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _balance,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration:
                  InputDecoration(labelText: t('credit.currentBalance')),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _statementDay,
              items: _dayItems,
              decoration: InputDecoration(labelText: t('credit.statementDay')),
              onChanged: (value) => setState(() => _statementDay = value),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<int>(
              initialValue: _dueDay,
              items: _dayItems,
              decoration: InputDecoration(labelText: t('credit.dueDay')),
              onChanged: (value) => setState(() => _dueDay = value),
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
