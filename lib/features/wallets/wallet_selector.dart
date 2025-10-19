import 'package:flutter/material.dart';

/// Stub selector; in production, fetch wallets from Supabase and cache to the
/// local DB.
/// For demo, allows entering a Wallet ID or choosing mock options.
class WalletSelector extends StatefulWidget {
  const WalletSelector({required this.onChanged, super.key});
  final void Function(String walletId) onChanged;

  @override
  State<WalletSelector> createState() => _WalletSelectorState();
}

class _WalletSelectorState extends State<WalletSelector> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: 'default-wallet');

    // Ensure parent widgets receive an initial value without extra user input.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(_controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

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
