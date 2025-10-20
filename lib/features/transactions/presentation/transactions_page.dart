import 'package:flutter/material.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('İşlemler')),
      body: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.shopping_cart),
            ),
            title: Text('İşlem ${index + 1}'),
            subtitle: const Text('Market alışverişi'),
            trailing: const Text('₺ 125.50'),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Add transaction
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
