import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/features/credit/data/credit_card_repository.dart';
import 'package:go_router/go_router.dart';

typedef CreditCardRecord = Map<String, dynamic>;
typedef CreditCardList = List<CreditCardRecord>;

// Provider türü otomatik tasarlanan karmaşık bir generik;
// okunabilirlik için türü Dart'ın çıkarmasına izin veriyoruz.
// ignore: specify_nonobvious_property_types
final creditCardListProvider = FutureProvider.autoDispose<CreditCardList>(
  (ref) async {
    return CreditCardRepository.fetchCards();
  },
);

class CreditCardListPage extends ConsumerWidget {
  const CreditCardListPage({super.key});

  String _formatAmount(dynamic value) {
    if (value == null) return '-';
    if (value is num) {
      return value.toStringAsFixed(2);
    }
    final parsed = double.tryParse(value.toString());
    return parsed != null ? parsed.toStringAsFixed(2) : value.toString();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cardsAsync = ref.watch(creditCardListProvider);

    Future<void> refresh() async {
      final future = ref.refresh(creditCardListProvider.future);
      await future;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(tr('credit.cardsTitle')),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/add-credit-card'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: refresh,
        child: cardsAsync.when(
          data: (CreditCardList cards) {
            if (cards.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: Text(
                      tr('credit.cardsEmpty'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: cards.length,
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemBuilder: (BuildContext context, int index) {
                final card = cards[index];
                final name = card['card_name']?.toString() ?? '';
                final bank = card['bank_name']?.toString();
                final limit = _formatAmount(card['total_limit']);
                final balance = _formatAmount(card['current_balance']);
                return ListTile(
                  leading: const Icon(Icons.credit_card),
                  title: Text(name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (bank != null && bank.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Text(bank),
                        ),
                      Text('${tr('credit.totalLimit')}: $limit'),
                      Text('${tr('credit.currentBalance')}: $balance'),
                    ],
                  ),
                  isThreeLine: true,
                  onTap: () {
                    final id = card['id']?.toString();
                    if (id != null && id.isNotEmpty) {
                      context.go('/credit-cards/$id');
                    }
                  },
                );
              },
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
