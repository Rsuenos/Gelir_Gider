#!/usr/bin/env bash
set -euo pipefail

mkdir -p lib/core/services lib/core/router lib/core lib/features/auth/view lib/features/auth lib/features/home lib/features/reports lib/features/settings lib/features/transactions/data lib/features/transactions/view lib/features/wallets assets/translations assets/sql .github/workflows test/unit test/widget python_service

cat > .gitignore << 'EOF'
# Flutter/Dart/Pub related
.dart_tool/
.packages
.pub-cache/
build/

# IDEs
.vscode/
.idea/

# Flutter specific
.flutter-plugins
.flutter-plugins-dependencies
.metadata

# Platform builds
android/
ios/
macos/
web/
linux/
windows/

# Others
**/*.iml
*.log
EOF

cat > README.md << 'EOF'
# Gelir Gider — Flutter + Supabase Kişisel Finans Takibi

Global kullanıcılar için modern finans takip uygulaması:
- Flutter (UI), Supabase (DB + Auth), SQLite (offline cache)
- Riverpod (State), GoRouter (Routing)
- Çoklu tema (Minimalist, Neomorphism, Flat, Material, One UI)
- Çoklu dil (TR/EN)
- Raporlar, KPI, akıllı öneriler, sesli giriş, aile paylaşımı
- PDF/Excel raporlama
- CI/CD (GitHub Actions)

## Hızlı Başlangıç

1) Ortam değişkenleri (dart-define):
- SUPABASE_URL
- SUPABASE_ANON_KEY
- SUPABASE_REDIRECT_URL

Örnek:
flutter run --dart-define=SUPABASE_URL=https://xxx.supabase.co --dart-define=SUPABASE_ANON_KEY=anon-key --dart-define=SUPABASE_REDIRECT_URL=com.example.app://login-callback


2) Paketleri kur:
flutter pub get

3) Lokalizasyon:
- assets/translations/en.json
- assets/translations/tr.json

4) SQLite offline cache otomatik oluşur.

5) Supabase:
- assets/sql/schema.sql ve assets/sql/rls_policies.sql dosyalarını Supabase DB’nize uygulayın (SQL Editor).

6) iOS/Android:
- OAuth redirect URI ayarlayın.
- Home widget ve izinler için Manifest/Info.plist düzenleyin.

## Özellikler
- Kredi Kartı, Borç, Kasa
- Gelir/Gider ekleme (alt/ana sınıflar)
- Ana ekranda: Son 3 işlem, yaklaşan 2 işlem
- Zaman aralığına göre raporlar; grafikleri fl_chart ile
- KPI panosu ve akıllı öneriler
- Çoklu cüzdan ve aile paylaşımı (RLS)
- PDF/Excel dışa aktarma
- Sesli giriş (speech_to_text)
- CI/CD: GitHub Actions (build+test)

## Güvenlik
- RLS ile kullanıcı bazlı veri izolasyonu
- Lokal DB için şifreleme alternatifi (SQLCipher) önerilir
- GDPR: veri saklama/silme uçları (Edge Functions / Python servis)

## Katkı ve Lisans
- MIT lisansı önerilir (isteğe bağlı).
EOF

cat > pubspec.yaml << 'EOF'
name: gelir_gider
description: Global-ready personal finance tracker (Flutter + Supabase).
publish_to: "none"
version: 0.1.0+1

environment:
  sdk: ">=3.4.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.8

  # Core
  flutter_riverpod: ^2.5.1
  go_router: ^14.2.0

  # Supabase
  supabase_flutter: ^2.8.0

  # Local DB
  sqflite: ^2.3.3
  path_provider: ^2.1.4
  path: ^1.9.0

  # UI/UX
  google_fonts: ^6.2.1
  fl_chart: ^0.69.0
  home_widget: ^0.5.1

  # Localization
  easy_localization: ^3.0.5

  # Voice input
  speech_to_text: ^6.6.2

  # Reports export
  pdf: ^3.11.0
  printing: ^5.13.4
  excel: ^2.1.2
  share_plus: ^10.0.2

  # Utils
  intl: ^0.19.0
  collection: ^1.18.0
  uuid: ^4.4.2
  http: ^1.2.2

dev_dependencies:
  flutter_test:
    sdk: flutter
  very_good_analysis: ^6.0.0
  build_runner: ^2.4.12
  json_serializable: ^6.8.0

flutter:
  uses-material-design: true
  assets:
    - assets/translations/
    - assets/sql/
EOF

cat > analysis_options.yaml << 'EOF'
include: package:very_good_analysis/analysis_options.yaml

linter:
  rules:
    public_member_api_docs: false
EOF

cat > lib/main.dart << 'EOF'
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/constants.dart';
import 'core/services/supabase_service.dart';

/// Entry-point: Minimal, readable, and sets up only the essentials.
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize localization
  await EasyLocalization.ensureInitialized();

  // Initialize Supabase (Auth + DB)
  await SupabaseService.init(
    supabaseUrl: kSupabaseUrl,
    anonKey: kSupabaseAnonKey,
  );

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: FinanceXApp()),
    ),
  );
}
EOF

cat > lib/app.dart << 'EOF'
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/theme_provider.dart';

/// Root App widget that wires up routing, theme, and localization.
class FinanceXApp extends ConsumerWidget {
  const FinanceXApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeProvider);

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Gelir Gider',
      themeMode: themeState.mode,
      theme: themeState.lightTheme,
      darkTheme: themeState.darkTheme,
      routerConfig: ref.watch(appRouterProvider),
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
    );
  }
}
EOF

cat > lib/core/constants.dart << 'EOF'
/// Constants and environment entry points. Keep secrets out of code; use dart-define.
/// dart-define keys: SUPABASE_URL, SUPABASE_ANON_KEY, SUPABASE_REDIRECT_URL

const kSupabaseUrl = String.fromEnvironment('SUPABASE_URL');
const kSupabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

/// OAuth redirect URL registered on Supabase + platforms (Android/iOS).
const kSupabaseRedirectUrl = String.fromEnvironment('SUPABASE_REDIRECT_URL');

/// App configuration
const kAppName = 'Gelir Gider';

/// Feature flags (configure remotely in production if needed).
class FeatureFlags {
  static const voiceInput = true;
  static const forecasting = true; // Local simple forecasting enabled
  static const pythonForecastApi = false; // Toggle if external FastAPI is used
  static const homeWidget = true;
  static const premiumFeatures = true;
}
EOF

cat > lib/core/services/supabase_service.dart << 'EOF'
import 'package:supabase_flutter/supabase_flutter.dart';

/// Thin wrapper around Supabase initialization and handy shortcuts.
/// Responsible only for setup, not for business logic.
class SupabaseService {
  static Future<void> init({
    required String supabaseUrl,
    required String anonKey,
  }) async {
    await Supabase.initialize(
      url: supabaseUrl,
      anonKey: anonKey,
      // Auth: Persist session by default. Configure LocalStorage in web.
      authFlowType: AuthFlowType.pkce,
    );
  }

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;
}
EOF

cat > lib/core/services/local_db.dart << 'EOF'
import 'dart:async';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// Local SQLite cache for offline-first functionality.
/// This DB stores a denormalized subset of data for offline use.
/// In production, consider SQLCipher or at least app-level encryption for sensitive fields.
class LocalDb {
  static Database? _db;

  static Future<Database> get instance async {
    if (_db != null) return _db!;
    _db = await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, 'gelir_gider_cache.db');

    // Note: For at-rest encryption, consider sqlcipher plugin (platform-specific).
    final db = await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        // Minimal tables for offline cache; remote is authoritative (Supabase).
        await db.execute('''
          CREATE TABLE IF NOT EXISTS wallets (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL,
            currency TEXT NOT NULL DEFAULT 'USD',
            updated_at INTEGER NOT NULL
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS transactions (
            id TEXT PRIMARY KEY,
            wallet_id TEXT NOT NULL,
            type TEXT NOT NULL, -- income|expense|transfer
            category TEXT NOT NULL,
            subcategory TEXT,
            amount REAL NOT NULL,
            currency TEXT NOT NULL DEFAULT 'USD',
            occurred_at INTEGER NOT NULL,
            description TEXT,
            is_upcoming INTEGER NOT NULL DEFAULT 0,
            updated_at INTEGER NOT NULL
          );
        ''');

        await db.execute('CREATE INDEX IF NOT EXISTS idx_tx_occurred ON transactions(occurred_at DESC);');
      },
    );
    return db;
  }

  // Basic cache helpers (example)
  static Future<void> upsertTransactions(List<Map<String, dynamic>> rows) async {
    final db = await instance;
    final batch = db.batch();
    for (final r in rows) {
      batch.insert('transactions', r, conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  static Future<List<Map<String, dynamic>>> getLastNTransactions(int n) async {
    final db = await instance;
    return db.query(
      'transactions',
      orderBy: 'occurred_at DESC',
      limit: n,
    );
  }

  static Future<List<Map<String, dynamic>>> getUpcomingN(int n) async {
    final db = await instance;
    return db.query(
      'transactions',
      where: 'is_upcoming = ?',
      whereArgs: [1],
      orderBy: 'occurred_at ASC',
      limit: n,
    );
  }
}
EOF

cat > lib/core/router/app_router.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/session_controller.dart';
import '../../features/auth/view/sign_in_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/settings/settings_screen.dart';
import '../../features/transactions/view/add_income_screen.dart';
import '../../features/transactions/view/add_expense_screen.dart';
import '../../features/reports/reports_screen.dart';

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
      GoRoute(path: '/settings', builder: (_, __) => const SettingsScreen()),
      GoRoute(path: '/add-income', builder: (_, __) => const AddIncomeScreen()),
      GoRoute(path: '/add-expense', builder: (_, __) => const AddExpenseScreen()),
      GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
    ],
  );
});
EOF

cat > lib/core/theme/theme_provider.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

/// Available theme variants.
enum AppThemeType { material, minimalist, neomorphism, flat, oneUI }

/// Theme state holds mode and selected variant.
class ThemeState {
  final ThemeMode mode;
  final AppThemeType type;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  const ThemeState({
    required this.mode,
    required this.type,
    required this.lightTheme,
    required this.darkTheme,
  });

  ThemeState copyWith({
    ThemeMode? mode,
    AppThemeType? type,
    ThemeData? lightTheme,
    ThemeData? darkTheme,
  }) {
    return ThemeState(
      mode: mode ?? this.mode,
      type: type ?? this.type,
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
    );
  }
}

final themeProvider = StateNotifierProvider<ThemeController, ThemeState>((ref) {
  final initialType = AppThemeType.oneUI;
  return ThemeController(
    ThemeState(
      mode: ThemeMode.system,
      type: initialType,
      lightTheme: _buildTheme(initialType, Brightness.light),
      darkTheme: _buildTheme(initialType, Brightness.dark),
    ),
  );
});

class ThemeController extends StateNotifier<ThemeState> {
  ThemeController(super.state);

  void setMode(ThemeMode mode) => state = state.copyWith(mode: mode);

  void setType(AppThemeType type) => state = state.copyWith(
        type: type,
        lightTheme: _buildTheme(type, Brightness.light),
        darkTheme: _buildTheme(type, Brightness.dark),
      );
}

TextTheme _fonted(TextTheme base) {
  // Global fonts: Prefer Inter/Open Sans/Roboto; iOS uses SF by default as fallback.
  return GoogleFonts.interTextTheme(base);
}

/// Theme factory that emulates selected design languages.
ThemeData _buildTheme(AppThemeType type, Brightness b) {
  final isDark = b == Brightness.dark;
  final colorSeed = switch (type) {
    AppThemeType.material => const Color(0xFF6750A4),
    AppThemeType.minimalist => const Color(0xFF1E88E5),
    AppThemeType.neomorphism => const Color(0xFF6C63FF),
    AppThemeType.flat => const Color(0xFF00BCD4),
    AppThemeType.oneUI => const Color(0xFF0A8F08),
  };

  ThemeData base = ThemeData(
    useMaterial3: true,
    colorSchemeSeed: colorSeed,
    brightness: b,
  );

  // Per theme tweaks
  switch (type) {
    case AppThemeType.material:
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        cardTheme: const CardTheme(elevation: 1),
      );
      break;
    case AppThemeType.minimalist:
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        scaffoldBackgroundColor: isDark ? const Color(0xFF101316) : const Color(0xFFF7F9FB),
        cardTheme: CardTheme(
          elevation: 0,
          color: isDark ? const Color(0xFF13171B) : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
      break;
    case AppThemeType.neomorphism:
      // Soft shadows, subtle elevation
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        scaffoldBackgroundColor: isDark ? const Color(0xFF1A1F24) : const Color(0xFFEFF3F8),
        cardTheme: CardTheme(
          color: isDark ? const Color(0xFF21262C) : const Color(0xFFEFF3F8),
          elevation: 6,
          shadowColor: Colors.black.withOpacity(0.15),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
      );
      break;
    case AppThemeType.flat:
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        cardTheme: const CardTheme(elevation: 0),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      );
      break;
    case AppThemeType.oneUI:
      // Samsung One UI cues: spacious, rounded, clear hierarchy
      base = base.copyWith(
        textTheme: _fonted(base.textTheme),
        cardTheme: CardTheme(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        appBarTheme: AppBarTheme(
          centerTitle: false,
          titleTextStyle: _fonted(base.textTheme).titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      );
      break;
  }

  return base;
}
EOF

cat > lib/features/auth/session_controller.dart << 'EOF'
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/supabase_service.dart';

/// Listenable session state so GoRouter can refresh on auth changes.
class SessionNotifier extends ChangeNotifier {
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;

  SessionNotifier() {
    // Initial
    _isAuthenticated = SupabaseService.auth.currentSession != null;

    // Listen to auth state changes
    SupabaseService.auth.onAuthStateChange.listen((event) {
      final session = event.session;
      _isAuthenticated = session != null;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await SupabaseService.auth.signOut();
  }
}

final sessionProvider = ChangeNotifierProvider<SessionNotifier>((ref) {
  return SessionNotifier();
});
EOF

cat > lib/features/auth/view/sign_in_screen.dart << 'EOF'
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants.dart';
import '../../../core/services/supabase_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

/// Simple auth: Email/password + Google OAuth.
class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  String? _error;

  Future<void> _signInEmail() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await SupabaseService.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _password.text.trim(),
      );
      if (mounted) context.go('/');
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _signUpEmail() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await SupabaseService.auth.signUp(
        email: _email.text.trim(),
        password: _password.text.trim(),
        emailRedirectTo: kSupabaseRedirectUrl,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    try {
      await SupabaseService.auth.signInWithOAuth(
        Provider.google,
        redirectTo: kSupabaseRedirectUrl,
      );
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = tr;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 40),
            Text(t('auth.welcome'), style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(t('auth.subtitle')),
            const SizedBox(height: 24),
            TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(labelText: t('auth.email')),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _password,
              decoration: InputDecoration(labelText: t('auth.password')),
              obscureText: true,
            ),
            const SizedBox(height: 12),
            if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _busy ? null : _signInEmail,
              child: _busy ? const CircularProgressIndicator() : Text(t('auth.signIn')),
            ),
            TextButton(
              onPressed: _busy ? null : _signUpEmail,
              child: Text(t('auth.signUp')),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _busy ? null : _google,
              icon: const Icon(Icons.login),
              label: Text(t('auth.signInGoogle')),
            ),
            const SizedBox(height: 24),
            Text(
              t('auth.onboardingHint'),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}
EOF

cat > lib/features/home/home_screen.dart << 'EOF'
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/services/local_db.dart';
import '../transactions/data/transaction_repository.dart';

/// Home: shows last 3 transactions, next 2 upcoming, and actions.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Map<String, dynamic>> _lastTx = [];
  List<Map<String, dynamic>> _upcoming = [];
  bool _loading = true;

  Future<void> _load() async {
    final last3 = await LocalDb.getLastNTransactions(3);
    final next2 = await LocalDb.getUpcomingN(2);
    setState(() {
      _lastTx = last3;
      _upcoming = next2;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    // Initial pull (in real app, also trigger sync from Supabase).
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = tr;

    return Scaffold(
      appBar: AppBar(
        title: Text(t('home.title')),
        actions: [
          IconButton(
            onPressed: () => context.push('/reports'),
            icon: const Icon(Icons.pie_chart_rounded),
            tooltip: t('home.reports'),
          ),
          IconButton(
            onPressed: () => context.push('/settings'),
            icon: const Icon(Icons.settings_outlined),
            tooltip: t('home.settings'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await TransactionRepository.syncFromSupabase(); // example sync
                await _load();
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _Section(
                    title: t('home.recentTransactions'),
                    child: _TxList(items: _lastTx),
                  ),
                  const SizedBox(height: 16),
                  _Section(
                    title: t('home.upcoming'),
                    child: _TxList(items: _upcoming),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () => context.push('/add-income'),
                          icon: const Icon(Icons.add_card),
                          label: Text(t('home.addIncome')),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => context.push('/add-expense'),
                          icon: const Icon(Icons.remove_circle),
                          label: Text(t('home.addExpense')),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _TxList extends StatelessWidget {
  const _TxList({required this.items});
  final List<Map<String, dynamic>> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Text(
        tr('home.noData'),
        style: Theme.of(context).textTheme.bodySmall,
      );
    }
    return Column(
      children: items.map((e) {
        final amount = (e['amount'] as num).toDouble();
        final isIncome = e['type'] == 'income';
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isIncome ? Colors.green : Colors.red,
            child: Icon(isIncome ? Icons.trending_up : Icons.trending_down, color: Colors.white),
          ),
          title: Text('${e['category']} ${e['subcategory'] ?? ''}'),
          subtitle: Text(DateFormat.yMMMd().format(
            DateTime.fromMillisecondsSinceEpoch(e['occurred_at'] as int),
          )),
          trailing: Text(
            '${isIncome ? '+' : '-'}${amount.toStringAsFixed(2)} ${e['currency']}',
            style: TextStyle(
              color: isIncome ? Colors.green : Colors.red,
              fontWeight: FontWeight.w700,
            ),
          ),
        );
      }).toList(),
    );
  }
}
EOF

cat > lib/features/transactions/data/transaction_repository.dart << 'EOF'
import 'dart:async';
import 'package:uuid/uuid.dart';
import '../../../core/services/local_db.dart';
import '../../../core/services/supabase_service.dart';

/// Repository encapsulates all logic to add/edit/delete transactions,
/// synchronize with Supabase, and manage offline cache coherence.
class TransactionRepository {
  static const _table = 'transactions';
  static const _uuid = Uuid();

  /// Add income/expense to Supabase and cache.
  static Future<void> add({
    required String walletId,
    required String type, // 'income' | 'expense' | 'transfer'
    required String category,
    String? subcategory,
    required double amount,
    String currency = 'USD',
    required DateTime occurredAt,
    String? description,
    bool isUpcoming = false,
  }) async {
    final id = _uuid.v4();
    final row = {
      'id': id,
      'wallet_id': walletId,
      'type': type,
      'category': category,
      'subcategory': subcategory,
      'amount': amount,
      'currency': currency,
      'occurred_at': occurredAt.toUtc().toIso8601String(),
      'description': description,
      'is_upcoming': isUpcoming,
    };

    // Try remote first; if fails, cache-only (queued sync).
    try {
      await SupabaseService.client.from(_table).insert(row);
    } catch (_) {
      // TODO: Queue for sync (add a pending_ops table locally).
    }

    // Cache
    await LocalDb.upsertTransactions([
      {
        'id': id,
        'wallet_id': walletId,
        'type': type,
        'category': category,
        'subcategory': subcategory,
        'amount': amount,
        'currency': currency,
        'occurred_at': occurredAt.millisecondsSinceEpoch,
        'description': description,
        'is_upcoming': isUpcoming ? 1 : 0,
        'updated_at': DateTime.now().millisecondsSinceEpoch,
      }
    ]);
  }

  /// Pulls latest changes from Supabase into local cache.
  static Future<void> syncFromSupabase() async {
    try {
      final data = await SupabaseService.client
          .from(_table)
          .select<List<Map<String, dynamic>>>()
          .order('occurred_at', ascending: false)
          .limit(100); // example paging
      final normalized = data.map((r) {
        return {
          'id': r['id'],
          'wallet_id': r['wallet_id'],
          'type': r['type'],
          'category': r['category'],
          'subcategory': r['subcategory'],
          'amount': r['amount'],
          'currency': r['currency'] ?? 'USD',
          'occurred_at': DateTime.parse(r['occurred_at']).millisecondsSinceEpoch,
          'description': r['description'],
          'is_upcoming': (r['is_upcoming'] ?? false) ? 1 : 0,
          'updated_at': DateTime.now().millisecondsSinceEpoch,
        };
      }).toList();
      await LocalDb.upsertTransactions(normalized);
    } catch (_) {
      // network error: ignore
    }
  }
}
EOF

cat > lib/features/transactions/view/voice_input_button.dart << 'EOF'
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Small widget that captures voice and returns raw text to parent.
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({super.key, required this.onResult, required this.label});
  final void Function(String text) onResult;
  final String label;

  @override
  State<VoiceInputButton> createState() => _VoiceInputButtonState();
}

class _VoiceInputButtonState extends State<VoiceInputButton> {
  final _speech = stt.SpeechToText();
  bool _available = false;
  bool _listening = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    _available = await _speech.initialize();
    setState(() {});
  }

  Future<void> _toggle() async {
    if (!_available) return;
    if (_listening) {
      await _speech.stop();
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    await _speech.listen(onResult: (res) {
      if (res.finalResult) {
        widget.onResult(res.recognizedWords);
        setState(() => _listening = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: _available ? _toggle : null,
      icon: Icon(_listening ? Icons.mic : Icons.mic_none),
      label: Text(widget.label),
    );
  }
}
EOF

cat > lib/features/transactions/view/add_income_screen.dart << 'EOF'
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../wallets/wallet_selector.dart';
import '../data/transaction_repository.dart';
import 'voice_input_button.dart';

class AddIncomeScreen extends StatefulWidget {
  const AddIncomeScreen({super.key});

  @override
  State<AddIncomeScreen> createState() => _AddIncomeScreenState();
}

class _AddIncomeScreenState extends State<AddIncomeScreen> {
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'Salary';
  String? _walletId;
  DateTime _date = DateTime.now();
  bool _busy = false;

  Future<void> _save() async {
    if (_walletId == null) return;
    setState(() => _busy = true);
    await TransactionRepository.add(
      walletId: _walletId!,
      type: 'income',
      category: _category,
      amount: double.tryParse(_amount.text.trim()) ?? 0,
      occurredAt: _date,
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _applyVoiceResult(String text) {
    // Simple NLP stub: Extract first number as amount, rest as description.
    final match = RegExp(r'([0-9]+([.,][0-9]+)?)').firstMatch(text);
    if (match != null) {
      _amount.text = match.group(0)!.replaceAll(',', '.');
      _desc.text = text.replaceFirst(match.group(0)!, '').trim();
    } else {
      _desc.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = tr;

    return Scaffold(
      appBar: AppBar(title: Text(t('income.addIncome'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WalletSelector(onChanged: (id) => setState(() => _walletId = id)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            items: [
              'Salary',
              'Investment',
              'Freelance',
              'Passive',
              'Other',
            ].map((e) => DropdownMenuItem(value: e, child: Text(t('income.$e')))).toList(),
            onChanged: (v) => setState(() => _category = v ?? _category),
            decoration: InputDecoration(labelText: t('income.category')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t('common.amount')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            decoration: InputDecoration(labelText: t('common.description')),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(DateFormat.yMMMd().format(_date))),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: _date,
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Text(t('common.pickDate')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          VoiceInputButton(onResult: _applyVoiceResult, label: t('common.voiceInput')),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy ? const CircularProgressIndicator() : Text(t('common.save')),
          ),
        ],
      ),
    );
  }
}
EOF

cat > lib/features/transactions/view/add_expense_screen.dart << 'EOF'
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../wallets/wallet_selector.dart';
import '../data/transaction_repository.dart';
import 'voice_input_button.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _amount = TextEditingController();
  final _desc = TextEditingController();
  String _category = 'Payments'; // top: Payments|Spending...
  String _subCategory = 'Bill'; // e.g., Bill, CreditCard, Loan, Subscriptions
  String? _walletId;
  DateTime _date = DateTime.now();
  bool _busy = false;

  Future<void> _save() async {
    if (_walletId == null) return;
    setState(() => _busy = true);
    await TransactionRepository.add(
      walletId: _walletId!,
      type: 'expense',
      category: _category,
      subcategory: _subCategory,
      amount: double.tryParse(_amount.text.trim()) ?? 0,
      occurredAt: _date,
      description: _desc.text.trim().isEmpty ? null : _desc.text.trim(),
    );
    if (mounted) Navigator.of(context).pop();
  }

  void _applyVoiceResult(String text) {
    final match = RegExp(r'([0-9]+([.,][0-9]+)?)').firstMatch(text);
    if (match != null) {
      _amount.text = match.group(0)!.replaceAll(',', '.');
      _desc.text = text.replaceFirst(match.group(0)!, '').trim();
    } else {
      _desc.text = text;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = tr;

    final mainCats = {
      'Payments': ['Bill', 'CreditCard', 'Loan', 'Subscriptions'],
      'Spending': ['Grocery', 'Pharmacy', 'Vehicle', 'Education', 'Health', 'Entertainment', 'Vacation'],
    };

    final submap = {
      'Grocery': ['Food', 'Cosmetics', 'Cleaning'],
      'Vehicle': ['Tax', 'Repair', 'Service', 'Fuel'],
    };

    final currentSubs = mainCats[_category]!;
    final subSubs = submap[_subCategory] ?? <String>[];

    return Scaffold(
      appBar: AppBar(title: Text(t('expense.addExpense'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          WalletSelector(onChanged: (id) => setState(() => _walletId = id)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _category,
            items: mainCats.keys
                .map((e) => DropdownMenuItem(value: e, child: Text(t('expense.$e'))))
                .toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _category = v;
                  _subCategory = mainCats[v]!.first;
                });
              }
            },
            decoration: InputDecoration(labelText: t('expense.mainClass')),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _subCategory,
            items: currentSubs
                .map((e) => DropdownMenuItem(value: e, child: Text(t('expense.$e'))))
                .toList(),
            onChanged: (v) => setState(() => _subCategory = v ?? _subCategory),
            decoration: InputDecoration(labelText: t('expense.subClass')),
          ),
          if (subSubs.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: subSubs
                  .map((e) => ActionChip(label: Text(t('expense.$e')), onPressed: () => _desc.text = e))
                  .toList(),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _amount,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(labelText: t('common.amount')),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _desc,
            decoration: InputDecoration(labelText: t('common.description')),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: Text(DateFormat.yMMMd().format(_date))),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: _date,
                  );
                  if (picked != null) setState(() => _date = picked);
                },
                child: Text(t('common.pickDate')),
              ),
            ],
          ),
          const SizedBox(height: 16),
          VoiceInputButton(onResult: _applyVoiceResult, label: t('common.voiceInput')),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _busy ? null : _save,
            child: _busy ? const CircularProgressIndicator() : Text(t('common.save')),
          ),
        ],
      ),
    );
  }
}
EOF

cat > lib/features/wallets/wallet_selector.dart << 'EOF'
import 'package:flutter/material.dart';

/// Stub selector; in production, fetch wallets from Supabase and cache to local DB.
/// For demo, allows entering a Wallet ID or choosing mock options.
class WalletSelector extends StatefulWidget {
  const WalletSelector({super.key, required this.onChanged});
  final void Function(String walletId) onChanged;

  @override
  State<WalletSelector> createState() => _WalletSelectorState();
}

class _WalletSelectorState extends State<WalletSelector> {
  final _controller = TextEditingController(text: 'default-wallet');

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: widget.onChanged,
      decoration: const InputDecoration(
        labelText: 'Wallet ID',
        helperText: 'Enter wallet ID (multi-account support)',
      ),
    );
  }
}
EOF

cat > lib/features/reports/reports_screen.dart << 'EOF'
import 'dart:math';
import 'package:collection/collection.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/services/local_db.dart';

/// Reports with charts, KPI dashboard, and simple insights.
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool _loading = true;
  List<Map<String, dynamic>> _tx = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // In a real app, query by date range and categories.
    final last100 = await LocalDb.getLastNTransactions(100);
    setState(() {
      _tx = last100;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = tr;

    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final income = _tx.where((e) => e['type'] == 'income').toList();
    final expense = _tx.where((e) => e['type'] == 'expense').toList();

    final totalIncome = income.fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());
    final totalExpense = expense.fold<double>(0, (s, e) => s + (e['amount'] as num).toDouble());
    final saving = totalIncome - totalExpense;
    final savingRate = totalIncome == 0 ? 0 : max(0, saving) / totalIncome;

    final byExpenseCategory = groupBy(expense, (e) => e['category'] as String);
    final pieData = byExpenseCategory.entries
        .map((e) => MapEntry(e.key, e.value.fold<double>(0, (s, v) => s + (v['amount'] as num).toDouble())))
        .toList();

    final topExpenseCategory = pieData.sorted((a, b) => b.value.compareTo(a.value)).firstOrNull?.key ?? '-';

    // Simple trend: last N days sum
    final byDay = groupBy(_tx, (e) {
      final dt = DateTime.fromMillisecondsSinceEpoch(e['occurred_at'] as int);
      return DateTime(dt.year, dt.month, dt.day).millisecondsSinceEpoch;
    });
    final trend = byDay.entries.map((e) {
      final sum = e.value.fold<double>(0, (s, v) {
        final sign = v['type'] == 'income' ? 1 : -1;
        return s + sign * (v['amount'] as num).toDouble();
      });
      return MapEntry(e.key, sum);
    }).toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    // Basic insights
    final insights = <String>[];
    if (totalIncome > 0 && totalExpense / totalIncome > 0.4) {
      insights.add(t('reports.debtIncomeWarn'));
    }
    if (savingRate < 0.1) {
      insights.add(t('reports.savingLow'));
    }
    if (pieData.length >= 1) {
      insights.add(t('reports.topSpendingCat', args: [topExpenseCategory]));
    }

    return Scaffold(
      appBar: AppBar(title: Text(t('reports.title'))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // KPI Cards
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _KpiCard(label: t('reports.totalIncome'), value: totalIncome),
              _KpiCard(label: t('reports.totalExpense'), value: totalExpense),
              _KpiCard(label: t('reports.saving'), value: saving),
              _KpiCard(label: t('reports.savingRate'), valueText: '${(savingRate * 100).toStringAsFixed(1)}%'),
            ],
          ),
          const SizedBox(height: 16),

          // Pie Chart (Expense distribution)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t('reports.expenseDistribution'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 2,
                      centerSpaceRadius: 40,
                      sections: [
                        for (final e in pieData)
                          PieChartSectionData(
                            value: e.value,
                            title: e.key,
                            radius: 80,
                            titleStyle: const TextStyle(fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Line Chart (Net trend)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(t('reports.netTrend'), style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 12),
                SizedBox(
                  height: 220,
                  child: LineChart(LineChartData(
                    lineBarsData: [
                      LineChartBarData(
                        isCurved: true,
                        color: Colors.blue,
                        barWidth: 3,
                        spots: [
                          for (var i = 0; i < trend.length; i++)
                            FlSpot(i.toDouble(), trend[i].value),
                        ],
                      ),
                    ],
                    titlesData: const FlTitlesData(show: false),
                    gridData: const FlGridData(show: true),
                    borderData: FlBorderData(show: false),
                  )),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 16),

          // Insights
          if (insights.isNotEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(t('reports.smartInsights'), style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 10),
                  for (final i in insights)
                    ListTile(
                      leading: const Icon(Icons.lightbulb_outline, color: Colors.amber),
                      title: Text(i),
                    )
                ]),
              ),
            ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.label, this.value, this.valueText});
  final String label;
  final double? value;
  final String? valueText;

  @override
  Widget build(BuildContext context) {
    final text = valueText ?? (value ?? 0).toStringAsFixed(2);
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 8),
            Text(text, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ]),
        ),
      ),
    );
  }
}
EOF

cat > lib/features/settings/settings_screen.dart << 'EOF'
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/services/supabase_service.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = tr;
    final theme = ref.watch(themeProvider);
    final themeCtrl = ref.read(themeProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: Text(t('settings.title'))),
      body: ListView(
        children: [
          ListTile(
            title: Text(t('settings.themeMode')),
            trailing: DropdownButton<ThemeMode>(
              value: theme.mode,
              onChanged: (m) => m != null ? themeCtrl.setMode(m) : null,
              items: const [
                DropdownMenuItem(value: ThemeMode.system, child: Text('System')),
                DropdownMenuItem(value: ThemeMode.light, child: Text('Light')),
                DropdownMenuItem(value: ThemeMode.dark, child: Text('Dark')),
              ],
            ),
          ),
          ListTile(
            title: Text(t('settings.themeVariant')),
            trailing: DropdownButton<AppThemeType>(
              value: theme.type,
              onChanged: (v) => v != null ? themeCtrl.setType(v) : null,
              items: const [
                DropdownMenuItem(value: AppThemeType.minimalist, child: Text('Minimalist')),
                DropdownMenuItem(value: AppThemeType.neomorphism, child: Text('Neomorphism')),
                DropdownMenuItem(value: AppThemeType.flat, child: Text('Flat')),
                DropdownMenuItem(value: AppThemeType.material, child: Text('Material')),
                DropdownMenuItem(value: AppThemeType.oneUI, child: Text('One UI')),
              ],
            ),
          ),
          ListTile(
            title: Text(t('settings.language')),
            trailing: DropdownButton<Locale>(
              value: context.locale,
              onChanged: (l) => l != null ? context.setLocale(l) : null,
              items: const [
                DropdownMenuItem(value: Locale('en'), child: Text('English')),
                DropdownMenuItem(value: Locale('tr'), child: Text('Türkçe')),
              ],
            ),
          ),
          const Divider(),
          ListTile(
            title: Text(t('settings.signOut')),
            leading: const Icon(Icons.logout),
            onTap: () async => SupabaseService.auth.signOut(),
          ),
        ],
      ),
    );
  }
}
EOF

cat > assets/translations/en.json << 'EOF'
{
  "auth": {
    "welcome": "Welcome to Gelir Gider",
    "subtitle": "Track income, expenses, debts, and more with smart insights.",
    "email": "Email",
    "password": "Password",
    "signIn": "Sign In",
    "signUp": "Create Account",
    "signInGoogle": "Continue with Google",
    "checkEmail": "Please check your email for confirmation.",
    "onboardingHint": "New here? Create an account and follow the onboarding tips."
  },
  "home": {
    "title": "Dashboard",
    "reports": "Reports",
    "settings": "Settings",
    "recentTransactions": "Recent Transactions",
    "upcoming": "Upcoming",
    "addIncome": "Add Income",
    "addExpense": "Add Expense",
    "noData": "No data available yet."
  },
  "income": {
    "addIncome": "Add Income",
    "category": "Income Category",
    "Salary": "Salary",
    "Investment": "Investment",
    "Freelance": "Freelance",
    "Passive": "Passive Income",
    "Other": "Other"
  },
  "expense": {
    "addExpense": "Add Expense",
    "mainClass": "Main Class",
    "subClass": "Sub Class",
    "Payments": "Payments",
    "Spending": "Spending",
    "Bill": "Bill",
    "CreditCard": "Credit Card",
    "Loan": "Loan",
    "Subscriptions": "Subscriptions",
    "Grocery": "Grocery",
    "Pharmacy": "Pharmacy",
    "Vehicle": "Vehicle",
    "Education": "Education",
    "Health": "Health",
    "Entertainment": "Entertainment",
    "Vacation": "Vacation",
    "Food": "Food",
    "Cosmetics": "Cosmetics",
    "Cleaning": "Cleaning",
    "Tax": "Tax",
    "Repair": "Repair",
    "Service": "Service",
    "Fuel": "Fuel"
  },
  "reports": {
    "title": "Reports & Analytics",
    "totalIncome": "Total Income",
    "totalExpense": "Total Expense",
    "saving": "Saving",
    "savingRate": "Saving Rate",
    "expenseDistribution": "Expense Distribution",
    "netTrend": "Net Trend",
    "smartInsights": "Smart Insights",
    "debtIncomeWarn": "Debt/Income ratio is above 40%. Consider reducing debts.",
    "savingLow": "Your saving rate is below 10%. Consider cutting non-essential spending.",
    "topSpendingCat": "Top spending category: {0}"
  },
  "settings": {
    "title": "Settings",
    "themeMode": "Theme Mode",
    "themeVariant": "Theme Variant",
    "language": "Language",
    "signOut": "Sign Out"
  },
  "common": {
    "amount": "Amount",
    "description": "Description",
    "pickDate": "Pick Date",
    "save": "Save",
    "voiceInput": "Voice Input"
  }
}
EOF

cat > assets/translations/tr.json << 'EOF'
{
  "auth": {
    "welcome": "Gelir Gider'e Hoş Geldiniz",
    "subtitle": "Gelir, gider, borç ve daha fazlasını akıllı içgörülerle takip edin.",
    "email": "E-posta",
    "password": "Şifre",
    "signIn": "Giriş Yap",
    "signUp": "Hesap Oluştur",
    "signInGoogle": "Google ile Devam Et",
    "checkEmail": "Lütfen e-postanızı doğrulama için kontrol edin.",
    "onboardingHint": "Yeni misiniz? Hesap oluşturun ve onboarding ipuçlarını takip edin."
  },
  "home": {
    "title": "Panel",
    "reports": "Raporlar",
    "settings": "Ayarlar",
    "recentTransactions": "Son İşlemler",
    "upcoming": "Yaklaşan",
    "addIncome": "Gelir Ekle",
    "addExpense": "Gider Ekle",
    "noData": "Henüz veri yok."
  },
  "income": {
    "addIncome": "Gelir Ekle",
    "category": "Gelir Kategorisi",
    "Salary": "Maaş",
    "Investment": "Yatırım",
    "Freelance": "Serbest Kazanç",
    "Passive": "Pasif Gelir",
    "Other": "Diğer"
  },
  "expense": {
    "addExpense": "Gider Ekle",
    "mainClass": "Ana Sınıf",
    "subClass": "Alt Sınıf",
    "Payments": "Ödemeler",
    "Spending": "Harcamalar",
    "Bill": "Fatura",
    "CreditCard": "Kredi Kartı",
    "Loan": "Kredi",
    "Subscriptions": "Abonelikler",
    "Grocery": "Market",
    "Pharmacy": "Eczane",
    "Vehicle": "Taşıt",
    "Education": "Eğitim",
    "Health": "Sağlık",
    "Entertainment": "Eğlence",
    "Vacation": "Tatil",
    "Food": "Gıda",
    "Cosmetics": "Kozmetik",
    "Cleaning": "Temizlik",
    "Tax": "Vergi",
    "Repair": "Tamir",
    "Service": "Bakım",
    "Fuel": "Yakıt"
  },
  "reports": {
    "title": "Raporlar ve Analitik",
    "totalIncome": "Toplam Gelir",
    "totalExpense": "Toplam Gider",
    "saving": "Tasarruf",
    "savingRate": "Tasarruf Oranı",
    "expenseDistribution": "Gider Dağılımı",
    "netTrend": "Net Trend",
    "smartInsights": "Akıllı Öneriler",
    "debtIncomeWarn": "Borç/Gelir oranı %40'ın üzerinde. Borçları azaltmayı düşünün.",
    "savingLow": "Tasarruf oranınız %10'un altında. Zorunlu olmayan harcamaları azaltmayı değerlendirin.",
    "topSpendingCat": "En çok harcama kategorisi: {0}"
  },
  "settings": {
    "title": "Ayarlar",
    "themeMode": "Tema Modu",
    "themeVariant": "Tema Varyantı",
    "language": "Dil",
    "signOut": "Çıkış Yap"
  },
  "common": {
    "amount": "Tutar",
    "description": "Açıklama",
    "pickDate": "Tarih Seç",
    "save": "Kaydet",
    "voiceInput": "Sesli Giriş"
  }
}
EOF

cat > assets/sql/schema.sql << 'EOF'
-- Supabase schema for Gelir Gider (core subset).
-- Ensure RLS is enabled on each table and seed policies from rls_policies.sql.

-- Users table is managed by Supabase auth schema.

create table if not exists wallets (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  currency text not null default 'USD',
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table if not exists shared_access (
  id uuid primary key default gen_random_uuid(),
  wallet_id uuid not null references wallets(id) on delete cascade,
  user_id uuid not null references auth.users(id) on delete cascade,
  can_edit boolean not null default false,
  created_at timestamp with time zone default now()
);

-- Unify movements into a single table for simplicity
create table if not exists transactions (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  wallet_id uuid not null references wallets(id) on delete cascade,
  type text not null check (type in ('income','expense','transfer')),
  category text not null,
  subcategory text,
  amount numeric not null,
  currency text not null default 'USD',
  occurred_at timestamp with time zone not null,
  description text,
  is_upcoming boolean not null default false,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Credit cards & debts as separate entities
create table if not exists credit_cards (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  bank_name text,
  card_name text not null,
  last4 text,
  statement_day int,
  due_day int,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

create table if not exists debts (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  total_amount numeric not null,
  remaining_amount numeric not null,
  monthly_payment numeric,
  next_due_date date,
  created_at timestamp with time zone default now(),
  updated_at timestamp with time zone default now()
);

-- Optional: budgets, notifications, forecast_cache tables can be added similarly.
EOF

cat > assets/sql/rls_policies.sql << 'EOF'
-- Enable RLS
alter table wallets enable row level security;
alter table shared_access enable row level security;
alter table transactions enable row level security;
alter table credit_cards enable row level security;
alter table debts enable row level security;

-- Policies: Owner or shared can read/write according to permissions.

-- Wallets: owner full access
create policy "wallets_owner_select" on wallets
for select using (auth.uid() = owner_id);
create policy "wallets_owner_ins" on wallets
for insert with check (auth.uid() = owner_id);
create policy "wallets_owner_upd" on wallets
for update using (auth.uid() = owner_id);
create policy "wallets_owner_del" on wallets
for delete using (auth.uid() = owner_id);

-- Shared access join: allow users listed in shared_access to select wallet
create policy "wallets_shared_select" on wallets
for select using (
  exists (select 1 from shared_access s where s.wallet_id = wallets.id and s.user_id = auth.uid())
);

-- shared_access: an owner can manage shares, sharee can read its own row
create policy "shared_select" on shared_access
for select using (
  user_id = auth.uid() or
  exists (select 1 from wallets w where w.id = wallet_id and w.owner_id = auth.uid())
);
create policy "shared_ins" on shared_access
for insert with check (
  exists (select 1 from wallets w where w.id = wallet_id and w.owner_id = auth.uid())
);
create policy "shared_upd" on shared_access
for update using (
  exists (select 1 from wallets w where w.id = wallet_id and w.owner_id = auth.uid())
);
create policy "shared_del" on shared_access
for delete using (
  exists (select 1 from wallets w where w.id = wallet_id and w.owner_id = auth.uid())
);

-- Transactions: owner or sharee can select; write allowed if owner or sharee with can_edit
create policy "tx_select" on transactions
for select using (
  owner_id = auth.uid() or
  exists (
    select 1 from shared_access s
    join wallets w on w.id = s.wallet_id
    where transactions.wallet_id = s.wallet_id and s.user_id = auth.uid()
  )
);

create policy "tx_insert" on transactions
for insert with check (
  owner_id = auth.uid() or
  exists (
    select 1 from shared_access s
    where s.wallet_id = transactions.wallet_id and s.user_id = auth.uid() and s.can_edit = true
  )
);

create policy "tx_update" on transactions
for update using (
  owner_id = auth.uid() or
  exists (
    select 1 from shared_access s
    where s.wallet_id = transactions.wallet_id and s.user_id = auth.uid() and s.can_edit = true
  )
);

create policy "tx_delete" on transactions
for delete using (
  owner_id = auth.uid() or
  exists (
    select 1 from shared_access s
    where s.wallet_id = transactions.wallet_id and s.user_id = auth.uid() and s.can_edit = true
  )
);

-- Credit cards & debts: owner only (can be extended to shared)
create policy "cc_owner_select" on credit_cards
for select using (owner_id = auth.uid());
create policy "cc_owner_cud" on credit_cards
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());

create policy "debts_owner_select" on debts
for select using (owner_id = auth.uid());
create policy "debts_owner_cud" on debts
for all using (owner_id = auth.uid()) with check (owner_id = auth.uid());
EOF

cat > .github/workflows/flutter-ci.yml << 'EOF'
name: Flutter CI

on:
  push:
    branches: [ main ]
  pull_request:

jobs:
  analyze-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: "3.24.0"
      - name: Install dependencies
        run: flutter pub get
      - name: Analyze
        run: flutter analyze
      - name: Test
        run: flutter test --coverage
EOF

cat > test/unit/example_test.dart << 'EOF'
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('basic arithmetic sanity', () {
    expect(2 + 2, 4);
  });
}
EOF

cat > test/widget/home_smoke_test.dart << 'EOF'
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/app.dart';

void main() {
  testWidgets('App builds', (tester) async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('tr')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        child: const ProviderScope(child: FinanceXApp()),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
EOF

cat > python_service/main.py << 'EOF'
# Optional forecasting/suggestions microservice (FastAPI)
# Deploy separately; enable FeatureFlags.pythonForecastApi to consume.
from fastapi import FastAPI
from pydantic import BaseModel
from typing import List
import uvicorn

app = FastAPI(title="Gelir Gider Forecast API")

class Tx(BaseModel):
  occurred_at: int  # milliseconds
  type: str         # income|expense
  amount: float

class ForecastRequest(BaseModel):
  transactions: List[Tx]
  horizon_months: int = 1

class ForecastResponse(BaseModel):
  predicted_expense: float
  predicted_income: float
  notes: List[str] = []

@app.post("/forecast", response_model=ForecastResponse)
def forecast(data: ForecastRequest):
  # Very naive baseline: average of last N
  incomes = [t.amount for t in data.transactions if t.type == "income"]
  expenses = [t.amount for t in data.transactions if t.type == "expense"]

  avg_income = sum(incomes)/len(incomes) if incomes else 0
  avg_expense = sum(expenses)/len(expenses) if expenses else 0

  notes = []
  if avg_expense > avg_income * 0.9:
    notes.append("Expenses are close to income; consider reducing spending.")
  if avg_income == 0 and avg_expense > 0:
    notes.append("No income detected; ensure data is complete.")

  return ForecastResponse(
    predicted_expense=avg_expense,
    predicted_income=avg_income,
    notes=notes
  )

if __name__ == "__main__":
  uvicorn.run(app, host="0.0.0.0", port=8000)
EOF

echo "All files generated."
EOF

chmod +x bootstrap.sh
echo "bootstrap.sh hazır. Çalıştırmak için: bash bootstrap.sh"