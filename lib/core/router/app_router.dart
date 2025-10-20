import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/features/auth/session_controller.dart';
import 'package:gelir_gider/features/auth/view/sign_in_screen.dart';
import 'package:gelir_gider/features/cards/presentation/card_detail_page.dart';
import 'package:gelir_gider/features/cards/presentation/cards_page.dart';
import 'package:gelir_gider/features/home/presentation/home_shell.dart';
import 'package:gelir_gider/features/reports/presentation/reports_page.dart';
import 'package:gelir_gider/features/transactions/presentation/transactions_page.dart';
import 'package:go_router/go_router.dart';

CustomTransitionPage<T> _fade<T>({required Widget child}) {
  return CustomTransitionPage<T>(
    child: child,
    transitionsBuilder: (context, anim, secAnim, child) =>
        FadeTransition(opacity: anim, child: child),
  );
}

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: '/home',
    refreshListenable: session,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          if (session.isAuthenticated) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const SignInScreen();
        },
      ),
      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/home',
            name: 'home',
            pageBuilder: (_, __) => _fade(child: const ReportsPage()),
          ),
          GoRoute(
            path: '/transactions',
            name: 'transactions',
            pageBuilder: (_, __) => _fade(child: const TransactionsPage()),
          ),
          GoRoute(
            path: '/cards',
            name: 'cards',
            pageBuilder: (_, __) => _fade(child: const CardsPage()),
          ),
          GoRoute(
            path: '/cards/:id',
            name: 'card_detail',
            pageBuilder: (ctx, st) => _fade(
              child: CardDetailPage(cardId: st.pathParameters['id']!),
            ),
          ),
        ],
      ),
    ],
  );
});
