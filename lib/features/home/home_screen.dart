import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider/core/services/local_db.dart';
import 'package:gelir_gider/features/transactions/data/transaction_repository.dart';
import 'package:go_router/go_router.dart';

/// Home: shows last 3 transactions, next 2 upcoming, and actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _lastTx = [];
  List<Map<String, dynamic>> _upcoming = [];
  bool _loading = true;

  Future<void> _load() async {
    final last3 = await LocalDb.getLastNTransactions(3);
    final next2 = await LocalDb.getUpcomingN(2);
    setState(() {
      _lastTx = last3;
      _upcoming = next2;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initial pull (in real app, also trigger sync from Supabase).
    unawaited(_load());
  }

  @override
  Widget build(BuildContext context) {
    const t = tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('home.title')),
        actions: [
          IconButton(
            onPressed: () => context.push('/reports'),
            icon: const Icon(Icons.pie_chart_rounded),
            tooltip: t('home.reports'),
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: t('home.settings'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await TransactionRepository.syncFromSupabase(); // example sync
                await _load();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Section(
                    title: t('home.recentTransactions'),
                    child: _TxList(items: _lastTx),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: t('home.upcoming'),
                    child: _TxList(items: _upcoming),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.push('/add-income'),
                          icon: const Icon(Icons.add_card),
                          label: Text(t('home.addIncome')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/add-expense'),
                          icon: const Icon(Icons.remove_circle),
                          label: Text(t('home.addExpense')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _TxList extends StatelessWidget {
  const _TxList({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        tr('home.noData'),
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Column(
      children: items.map((e) {
        final amount = (e['amount'] as num).toDouble();
        final isIncome = e['type'] == 'income';
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isIncome ? Colors.green : Colors.red,
            child: Icon(
              isIncome ? Icons.trending_up : Icons.trending_down,
              color: Colors.white,
            ),
          ),
          title: Text('${e['category']} ${e['subcategory'] ?? ''}'),
          subtitle: Text(
            DateFormat.yMMMd().format(
              DateTime.fromMillisecondsSinceEpoch(e['occurred_at'] as int),
            ),
          ),
          trailing: Text(
            '${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)} '
            '${e['currency']}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }
}
