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
