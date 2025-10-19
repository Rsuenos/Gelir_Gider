import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/features/credit/data/credit_card_repository.dart';

typedef CreditCardRecord = Map<String, dynamic>;
typedef CreditCardDetailData = Map<String, dynamic>?;
typedef CreditCardRelatedList = List<CreditCardRecord>;

// Riverpod family tipi oldukça uzun olduğundan
// okunabilirliği korumak için türü derleyicinin çıkarmasına izin veriyoruz.
// ignore: specify_nonobvious_property_types
final creditCardDetailProvider =
    FutureProvider.autoDispose.family<CreditCardDetailData, String>(
  (ref, cardId) async {
    return CreditCardRepository.fetchCardDetail(cardId);
  },
);

class CreditCardDetailPage extends ConsumerWidget {
  const CreditCardDetailPage({required this.cardId, super.key});

  final String cardId;

  String _formatAmount(dynamic value) {
    if (value == null) return '-';
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    final parsed = double.tryParse(value.toString());
    return parsed != null ? parsed.toStringAsFixed(2) : value.toString();
  }

  String _formatDate(BuildContext context, dynamic value) {
    if (value == null) return '-';
    if (value is DateTime) {
      return DateFormat.yMMMMd(context.locale.toString()).format(value);
    }
    final parsed = DateTime.tryParse(value.toString());
    if (parsed == null) return value.toString();
    return DateFormat.yMMMMd(context.locale.toString()).format(parsed);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardAsync = ref.watch(creditCardDetailProvider(cardId));

    Future<void> refresh() async {
      final future = ref.refresh(creditCardDetailProvider(cardId).future);
      await future;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('credit.detailTitle')),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: cardAsync.when(
          data: (CreditCardDetailData data) {
            if (data == null) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Text(tr('credit.cardNotFound')),
                ],
              );
            }

            final card = data['card'] as CreditCardRecord;
            final installments =
                (data['installments'] as CreditCardRelatedList?) ??
                    const <CreditCardRecord>[];
            final transactions =
                (data['transactions'] as CreditCardRelatedList?) ??
                    const <CreditCardRecord>[];

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                _InfoRow(
                  label: tr('credit.cardName'),
                  value: card['card_name']?.toString() ?? '-',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: tr('credit.bankName'),
                  value: card['bank_name']?.toString() ?? '-',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: tr('credit.totalLimit'),
                  value: _formatAmount(card['total_limit']),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: tr('credit.currentBalance'),
                  value: _formatAmount(card['current_balance']),
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: tr('credit.statementDay'),
                  value: card['statement_day']?.toString() ?? '-',
                ),
                const SizedBox(height: 8),
                _InfoRow(
                  label: tr('credit.dueDay'),
                  value: card['due_day']?.toString() ?? '-',
                ),
                const SizedBox(height: 24),
                Text(
                  tr('credit.installmentsTitle'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (installments.isEmpty)
                  Text(tr('credit.noInstallments'))
                else
                  ...installments.map((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.event_available_outlined),
                        title: Text(item['title']?.toString() ?? '-'),
                        subtitle: Text(_formatDate(context, item['due_date'])),
                        trailing: Text(_formatAmount(item['amount'])),
                      ),
                    );
                  }),
                const SizedBox(height: 24),
                Text(
                  tr('credit.transactionsTitle'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                if (transactions.isEmpty)
                  Text(tr('credit.noTransactions'))
                else
                  ...transactions.map((item) {
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        leading: const Icon(Icons.sync_alt_outlined),
                        title: Text(item['category']?.toString() ?? '-'),
                        subtitle:
                            Text(_formatDate(context, item['occurred_at'])),
                        trailing: Text(_formatAmount(item['amount'])),
                      ),
                    );
                  }),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (Object error, StackTrace stackTrace) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  error.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: Theme.of(context).colorScheme.error),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: refresh,
                  child: Text(tr('common.retry')),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}
