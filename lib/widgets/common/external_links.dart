import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../l10n/app_localizations.dart';

/// Opens [url] outside the app, with a message when nothing can open it.
Future<void> openExternalUrl(BuildContext context, String url) async {
  final uri = Uri.tryParse(url);
  final messenger = ScaffoldMessenger.maybeOf(context);
  final failure = AppLocalizations.of(context).translate('linkOpenFailed');
  final opened = uri != null &&
      await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!opened) {
    messenger?.showSnackBar(SnackBar(content: Text(failure)));
  }
}

/// WhatsApp chat with [number] (international, without '+'), with an
/// optional pre-filled [message].
Future<void> openWhatsApp(BuildContext context, String number,
    {String message = ''}) {
  final digits = number.replaceAll(RegExp(r'[^0-9]'), '');
  final text = message.isEmpty ? '' : '?text=${Uri.encodeComponent(message)}';
  return openExternalUrl(context, 'https://wa.me/$digits$text');
}

/// Green WhatsApp button, hidden when no number is configured.
class WhatsAppButton extends StatelessWidget {
  final String number;
  final String label;
  final String message;

  const WhatsAppButton({
    super.key,
    required this.number,
    required this.label,
    this.message = '',
  });

  @override
  Widget build(BuildContext context) {
    if (number.isEmpty) return const SizedBox.shrink();
    return FilledButton.icon(
      style: FilledButton.styleFrom(
        backgroundColor: const Color(0xFF25D366),
        foregroundColor: Colors.white,
      ),
      onPressed: () => openWhatsApp(context, number, message: message),
      icon: const Icon(Icons.chat_outlined),
      label: Text(label),
    );
  }
}
