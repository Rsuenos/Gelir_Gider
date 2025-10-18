import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:gelir_gider/core/constants.dart';
import 'package:gelir_gider/core/services/supabase_service.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on Exception catch (e) {
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
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _busy = false);
    }
  }

  Future<void> _google() async {
    try {
      await SupabaseService.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kSupabaseRedirectUrl,
      );
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } on Exception catch (e) {
      setState(() => _error = e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    const t = tr;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 40),
            Text(
              t('auth.welcome'),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
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
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _busy ? null : _signInEmail,
              child: _busy
                  ? const CircularProgressIndicator()
                  : Text(t('auth.signIn')),
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
