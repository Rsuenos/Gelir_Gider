import 'dart:async';

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

/// Small widget that captures voice and returns raw text to parent.
class VoiceInputButton extends StatefulWidget {
  const VoiceInputButton({
    required this.onResult,
    required this.label,
    super.key,
  });
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
    unawaited(_init());
  }

  Future<void> _init() async {
    final available = await _speech.initialize();
    if (!mounted) return;
    setState(() => _available = available);
  }

  Future<void> _toggle() async {
    if (!_available) return;
    if (_listening) {
      await _speech.stop();
      if (!mounted) return;
      setState(() => _listening = false);
      return;
    }
    setState(() => _listening = true);
    final started = await _speech.listen(
      onResult: (res) {
        if (!res.finalResult) return;
        widget.onResult(res.recognizedWords);
        if (!mounted) return;
        setState(() => _listening = false);
      },
    );
    if (started != true && mounted) {
      setState(() => _listening = false);
    }
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
