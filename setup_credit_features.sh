#!/bin/bash
echo "Yeni ekranlar oluşturuluyor..."
mkdir -p lib/features/credit lib/features/debt

cat > lib/features/credit/add_credit_card_page.dart <<'EOF'
import 'package:flutter/material.dart';
class AddCreditCardPage extends StatelessWidget {
  const AddCreditCardPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kredi Kartı Ekle')),
    body: const Center(child: Text('Kredi kartı formu burada')),
  );
}
EOF

cat > lib/features/credit/add_credit_page.dart <<'EOF'
import 'package:flutter/material.dart';
class AddCreditPage extends StatelessWidget {
  const AddCreditPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Kredi Ekle')),
    body: const Center(child: Text('Kredi formu burada')),
  );
}
EOF

cat > lib/features/debt/add_debt_page.dart <<'EOF'
import 'package:flutter/material.dart';
class AddDebtPage extends StatelessWidget {
  const AddDebtPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Borç Ekle')),
    body: const Center(child: Text('Borç formu burada')),
  );
}
EOF

echo "Şimdi router dosyana şu 3 GoRoute'u elle ekle:"
echo "
GoRoute(path: '/add-credit-card', name: 'addCreditCard', builder: (ctx, st) => const AddCreditCardPage()),
GoRoute(path: '/add-credit', name: 'addCredit', builder: (ctx, st) => const AddCreditPage()),
GoRoute(path: '/add-debt', name: 'addDebt', builder: (ctx, st) => const AddDebtPage()),
"

echo "Drawer ve çeviri adımlarını elle yapmayı unutma!"
