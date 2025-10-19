import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/features/auth/session_controller.dart';
import 'package:gelir_gider/features/auth/view/sign_in_screen.dart';
import 'package:gelir_gider/features/credit/add_credit_card_page.dart';
import 'package:gelir_gider/features/credit/add_credit_page.dart';
import 'package:gelir_gider/features/credit/credit_card_detail_page.dart';
import 'package:gelir_gider/features/credit/credit_card_list_page.dart';
import 'package:gelir_gider/features/debt/add_debt_page.dart';
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
        path: '/credit-cards',
        name: 'creditCards',
        builder: (_, __) => const CreditCardListPage(),
      ),
      GoRoute(
        path: '/credit-cards/:id',
        name: 'creditCardDetail',
        builder: (_, state) {
          final id = state.pathParameters['id'];
          if (id == null) {
            return const CreditCardListPage();
          }
          return CreditCardDetailPage(cardId: id);
        },
      ),
      GoRoute(
        path: '/add-credit-card',
        name: 'addCreditCard',
        builder: (_, __) => const AddCreditCardPage(),
      ),
      GoRoute(
        path: '/add-credit',
        name: 'addCredit',
        builder: (_, __) => const AddCreditPage(),
      ),
      GoRoute(
        path: '/add-debt',
        name: 'addDebt',
        builder: (_, __) => const AddDebtPage(),
      ),
      GoRoute(
        path: '/reports',
        builder: (_, __) => const ReportsScreen(),
      ),
    ],
  );
});
