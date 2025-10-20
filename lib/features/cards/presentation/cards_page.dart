import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CardsPage extends StatelessWidget {
  const CardsPage({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: provider/repo'dan gerçek veriyi bağla
    final cards = const [
      {
        'id': '1',
        'name': 'Ana Kart',
        'last4': '1234',
        'limit': 80000,
        'available': 24500,
        'dueDay': 15
      },
      {
        'id': '2',
        'name': 'İş Kartı',
        'last4': '9876',
        'limit': 120000,
        'available': 96000,
        'dueDay': 7
      },
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Kartlarım')),
      body: ListView.separated(
        itemCount: cards.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (c, i) {
          final k = cards[i];
          return ListTile(
            title: Text('${k['name']} • **** ${k['last4']}'),
            subtitle: Text('Kalan limit: ${k['available']} / ${k['limit']}'),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('Son gün'),
                Text('Gün ${k['dueDay']}'),
              ],
            ),
            onTap: () => context.go('/cards/${k['id']}'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {/* yeni kart */},
        icon: const Icon(Icons.add),
        label: const Text('Kart ekle'),
      ),
    );
  }
}
