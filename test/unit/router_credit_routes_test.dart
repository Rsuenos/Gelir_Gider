import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gelir_gider/core/router/app_router.dart';
import 'package:gelir_gider/features/auth/session_controller.dart';
import 'package:go_router/go_router.dart';

void main() {
  test('router exposes credit and debt routes', () {
    final notifier = SessionNotifier.test(isAuthenticated: true);
    final container = ProviderContainer(
      overrides: [
        sessionProvider.overrideWith((ref) => notifier),
      ],
    );

    addTearDown(container.dispose);

    final router = container.read(appRouterProvider);
    final paths = <String>{};
    for (final route in router.configuration.routes) {
      if (route is GoRoute) {
        paths.add(route.path);
      }
    }

    expect(paths, contains('/add-credit-card'));
    expect(paths, contains('/add-credit'));
    expect(paths, contains('/add-debt'));
  });
}
