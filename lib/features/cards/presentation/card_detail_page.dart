import 'package:flutter/material.dart';

class CardDetailPage extends StatefulWidget {
  const CardDetailPage({super.key, required this.cardId});
  final String cardId;

  @override
  State<CardDetailPage> createState() => _CardDetailPageState();
}

class _CardDetailPageState extends State<CardDetailPage>
    with TickerProviderStateMixin {
  late final TabController _tab = TabController(length: 4, vsync: this);

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kart Detayı #${widget.cardId}'),
        bottom: TabBar(
          controller: _tab,
          tabs: const [
            Tab(text: 'Özet'),
            Tab(text: 'Hareketler'),
            Tab(text: 'Gelecek'),
            Tab(text: 'Ekstreler'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tab,
        children: const [
          _CardSummaryTab(),
          _CardTransactionsTab(),
          _CardUpcomingTab(),
          _CardStatementsTab(),
        ],
      ),
    );
  }
}

class _CardSummaryTab extends StatelessWidget {
  const _CardSummaryTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            title: const Text('Kalan Limit'),
            subtitle: const Text('45.200 / 80.000'),
            trailing: FilledButton(
              onPressed: () {},
              child: const Text('Ödeme yap'),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Card(
          child: ListTile(
            title: Text('Kesim / Son Ödeme'),
            subtitle: Text('Her ay 10 / 15'),
          ),
        ),
      ],
    );
  }
}

class _CardTransactionsTab extends StatelessWidget {
  const _CardTransactionsTab();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _TxnFilters(),
        const Divider(height: 1),
        Expanded(
          child: ListView.builder(
            itemCount: 12,
            itemBuilder: (c, i) => ListTile(
              title: Text('İşlem $i • Market'),
              subtitle: const Text('12 taksit (3/12) • 250,00'),
              trailing: const Text('250,00'),
              onTap: () {},
            ),
          ),
        ),
      ],
    );
  }
}

class _TxnFilters extends StatelessWidget {
  const _TxnFilters();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(label: Text('Bu dönem'), selected: true, onSelected: null),
          FilterChip(
              label: Text('Taksitli'), selected: false, onSelected: null),
          FilterChip(label: Text('İade'), onSelected: null),
          FilterChip(label: Text('Ödeme'), onSelected: null),
          FilterChip(label: Text('Kategori: Market'), onSelected: null),
        ],
      ),
    );
  }
}

class _CardUpcomingTab extends StatelessWidget {
  const _CardUpcomingTab();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(12),
      itemCount: 6,
      itemBuilder: (c, i) => ListTile(
        title: Text('Taksit ${i + 4}/12 • 250,00'),
        subtitle: const Text('Vade: 15 Kasım 2025'),
        trailing: TextButton(
          onPressed: () {},
          child: const Text('Erken kapat'),
        ),
      ),
      separatorBuilder: (_, __) => const Divider(height: 1),
    );
  }
}

class _CardStatementsTab extends StatelessWidget {
  const _CardStatementsTab();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 8,
      itemBuilder: (c, i) => ListTile(
        title: const Text('Ekim 2025 • Toplam 7.950'),
        subtitle: const Text('Asgari 2.385 • Son gün 15 Kas'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: () {}, child: const Text('PDF')),
            FilledButton.tonal(
              onPressed: () {},
              child: const Text('Asgari öde'),
            ),
          ],
        ),
      ),
    );
  }
}
