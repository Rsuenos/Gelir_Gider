import 'dart:async';
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider/core/services/local_db.dart';
import 'package:gelir_gider/core/widgets/app_drawer.dart';
import 'package:gelir_gider/features/debt/data/debt_repository.dart';

/// Reports with charts, KPI dashboard, and simple insights.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tx = [];
  double _creditOutstanding = 0;
  double _debtOutstanding = 0;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    // In a real app, query by date range and categories.
    final last100 = await LocalDb.getLastNTransactions(100);
    final totals = await DebtRepository.totalRemainingByKind();
    setState(() {
      _tx = last100;
      _creditOutstanding = totals['credit'] ?? 0;
      _debtOutstanding = totals['debt'] ?? 0;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const t = tr;

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(t('reports.title'))),
        drawer: const AppDrawer(),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final income = _tx.where((e) => e['type'] == 'income').toList();
    final expense = _tx.where((e) => e['type'] == 'expense').toList();

    final totalIncome = income.fold<double>(
      0,
      (s, e) => s + (e['amount'] as num).toDouble(),
    );
    final totalExpense = expense.fold<double>(
      0,
      (s, e) => s + (e['amount'] as num).toDouble(),
    );
    final saving = totalIncome - totalExpense;
    final savingRate = totalIncome == 0 ? 0 : max(0, saving) / totalIncome;

    final byExpenseCategory = groupBy(expense, (e) => e['category'] as String);
    final pieData = byExpenseCategory.entries.map((entry) {
      final total = entry.value.fold<double>(
        0,
        (s, v) => s + (v['amount'] as num).toDouble(),
      );
      return MapEntry(entry.key, total);
    }).toList();

    final topExpenseCategory =
        pieData.sorted((a, b) => b.value.compareTo(a.value)).firstOrNull?.key ??
            '-';

    // Simple trend: last N days sum
    final byDay = groupBy(_tx, (e) {
      final dt = DateTime.fromMillisecondsSinceEpoch(e['occurred_at'] as int);
      return DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch;
    });
    final trend = byDay.entries.map((e) {
      final sum = e.value.fold<double>(0, (s, v) {
        final sign = v['type'] == 'income' ? 1 : -1;
        return s + sign * (v['amount'] as num).toDouble();
      });
      return MapEntry(e.key, sum);
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Basic insights
    final insights = <String>[];
    if (_creditOutstanding > 0) {
      insights.add(
        t(
          'reports.creditOutstandingInfo',
          args: [_creditOutstanding.toStringAsFixed(2)],
        ),
      );
    }
    if (_debtOutstanding > 0) {
      insights.add(
        t(
          'reports.debtOutstandingInfo',
          args: [_debtOutstanding.toStringAsFixed(2)],
        ),
      );
    }
    if (totalIncome > 0 && totalExpense / totalIncome > 0.4) {
      insights.add(t('reports.debtIncomeWarn'));
    }
    if (savingRate < 0.1) {
      insights.add(t('reports.savingLow'));
    }
    if (pieData.isNotEmpty) {
      insights.add(t('reports.topSpendingCat', args: [topExpenseCategory]));
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('reports.title'))),
      drawer: const AppDrawer(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI Cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _KpiCard(label: t('reports.totalIncome'), value: totalIncome),
              _KpiCard(label: t('reports.totalExpense'), value: totalExpense),
              _KpiCard(label: t('reports.saving'), value: saving),
              _KpiCard(
                label: t('reports.savingRate'),
                valueText: '${(savingRate * 100).toStringAsFixed(1)}%',
              ),
              _KpiCard(
                label: t('reports.totalCreditOutstanding'),
                value: _creditOutstanding,
              ),
              _KpiCard(
                label: t('reports.totalDebtOutstanding'),
                value: _debtOutstanding,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Pie Chart (Expense distribution)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('reports.expenseDistribution'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 40,
                        sections: [
                          for (final e in pieData)
                            PieChartSectionData(
                              value: e.value,
                              title: e.key,
                              radius: 80,
                              titleStyle: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Line Chart (Net trend)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t('reports.netTrend'),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: LineChart(
                      LineChartData(
                        lineBarsData: [
                          LineChartBarData(
                            isCurved: true,
                            color: Colors.blue,
                            barWidth: 3,
                            spots: [
                              for (var i = 0; i < trend.length; i++)
                                FlSpot(i.toDouble(), trend[i].value),
                            ],
                          ),
                        ],
                        titlesData: const FlTitlesData(show: false),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Insights
          if (insights.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('reports.smartInsights'),
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 10),
                    for (final i in insights)
                      ListTile(
                        leading: const Icon(
                          Icons.lightbulb_outline,
                          color: Colors.amber,
                        ),
                        title: Text(i),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, this.value, this.valueText});
  final String label;
  final double? value;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final text = valueText ?? (value ?? 0).toStringAsFixed(2);
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.bodySmall),
              const SizedBox(height: 8),
              Text(
                text,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
