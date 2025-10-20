import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.child});
  final Widget child;

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _indexFromLocation(String loc) {
    if (loc.startsWith('/transactions')) return 1;
    if (loc.startsWith('/cards')) return 2;
    return 0;
  }

  void _go(int i) {
    switch (i) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/transactions');
        break;
      case 2:
        context.go('/cards');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = GoRouterState.of(context).uri.toString();
    final currentIndex = _indexFromLocation(loc);

    final destinations = const [
      NavigationDestination(
          icon: Icon(Icons.analytics_outlined), label: 'Özet'),
      NavigationDestination(
          icon: Icon(Icons.receipt_long_outlined), label: 'İşlemler'),
      NavigationDestination(
          icon: Icon(Icons.credit_card_outlined), label: 'Kartlar'),
    ];

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 900;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: currentIndex,
                  onDestinationSelected: _go,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations
                      .map((d) => NavigationRailDestination(
                            icon: d.icon,
                            label: Text(d.label),
                          ))
                      .toList(),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: widget.child),
              ],
            ),
          );
        }
        return Scaffold(
          body: widget.child,
          bottomNavigationBar: NavigationBar(
            selectedIndex: currentIndex,
            destinations: destinations,
            onDestinationSelected: _go,
          ),
        );
      },
    );
  }
}
