import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/features/auth/session_controller.dart';
import 'package:go_router/go_router.dart';

class AppDrawer extends ConsumerWidget {
  const AppDrawer({super.key});

  // Rota karşılaştırmalarında küçük normalize yardımı
  String _norm(String s) => s.startsWith('/') ? s : '/$s';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Anlık konumu her build’te çek
    final current = GoRouterState.of(context).uri.toString();
    final session = ref.read(sessionProvider);
    const t = tr;

    void navigate(String route) {
      // Drawer’ı kapat
      Navigator.of(context).pop();

      // Konumu *fonksiyon içinde* tekrar al (güncel değer)
      final now = GoRouterState.of(context).uri.toString();

      if (_norm(now) != _norm(route)) {
        context.go(route);
      }
    }

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  'Gelir Gider',
                  style: Theme.of(context)
                      .textTheme
                      .headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
            ),
            _DrawerTile(
              icon: Icons.dashboard_outlined,
              label: t('navigation.home'),
              selected: _norm(current) == '/',
              onTap: () => navigate('/'),
            ),
            _DrawerTile(
              icon: Icons.trending_up,
              label: t('navigation.addIncome'),
              selected: _norm(current).startsWith('/add-income'),
              onTap: () => navigate('/add-income'),
            ),
            _DrawerTile(
              icon: Icons.trending_down,
              label: t('navigation.addExpense'),
              selected: _norm(current).startsWith('/add-expense'),
              onTap: () => navigate('/add-expense'),
            ),
            _DrawerTile(
              icon: Icons.pie_chart_outline,
              label: t('navigation.reports'),
              selected: _norm(current).startsWith('/reports'),
              onTap: () => navigate('/reports'),
            ),
            _DrawerTile(
              icon: Icons.settings_outlined,
              label: t('navigation.settings'),
              selected: _norm(current).startsWith('/settings'),
              onTap: () => navigate('/settings'),
            ),
            const Divider(),
            _DrawerTile(
              icon: Icons.logout,
              label: t('navigation.signOut'),
              selected: false,
              onTap: () async {
                Navigator.of(context).pop();
                await session.signOut();
                if (context.mounted) {
                  context.go('/');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerTile extends StatelessWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      selected: selected,
      onTap: onTap,
    );
  }
}
