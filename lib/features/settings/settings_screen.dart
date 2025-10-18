import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gelir_gider/core/services/supabase_service.dart';
import 'package:gelir_gider/core/theme/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const t = tr;
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
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('System'),
                ),
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
                DropdownMenuItem(
                  value: AppThemeType.minimalist,
                  child: Text('Minimalist'),
                ),
                DropdownMenuItem(
                  value: AppThemeType.neomorphism,
                  child: Text('Neomorphism'),
                ),
                DropdownMenuItem(value: AppThemeType.flat, child: Text('Flat')),
                DropdownMenuItem(
                  value: AppThemeType.material,
                  child: Text('Material'),
                ),
                DropdownMenuItem(
                  value: AppThemeType.oneUI,
                  child: Text('One UI'),
                ),
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
