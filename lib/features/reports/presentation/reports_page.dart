import 'package:flutter/material.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Özet')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          ListTile(
            title: Text('Son 30 gün toplam harcama'),
            subtitle: Text('TODO: Supabase\'den çekilecek'),
            trailing: Text('₺ 0'),
          ),
          Divider(),
          ListTile(
            title: Text('Kategori dağılımı'),
            subtitle: Text('TODO: Donut chart / liste'),
          ),
        ],
      ),
    );
  }
}
