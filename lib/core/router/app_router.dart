import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/features/auth/session_controller.dart';
import 'package:gelir_gider/features/auth/view/sign_in_screen.dart';
import 'package:gelir_gider/features/home/home_screen.dart';
import 'package:gelir_gider/features/reports/reports_screen.dart';
import 'package:gelir_gider/features/settings/settings_screen.dart';
import 'package:gelir_gider/features/transactions/view/add_expense_screen.dart';
import 'package:gelir_gider/features/transactions/view/add_income_screen.dart';
import 'package:go_router/go_router.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final session = ref.watch(sessionProvider);

  return GoRouter(
    initialLocation: '/',
    refreshListenable: session,
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) {
          if (session.isAuthenticated) {
            return const HomeScreen();
          }
          return const SignInScreen();
        },
      ),
      GoRoute(
        path: '/settings',
        builder: (_, __) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/add-income',
        builder: (_, __) => const AddIncomeScreen(),
      ),
      GoRoute(
        path: '/add-expense',
        builder: (_, __) => const AddExpenseScreen(),
      ),
      GoRoute(
        path: '/reports',
        builder: (_, __) => const ReportsScreen(),
      ),
    ],
  );
});
