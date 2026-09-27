import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/consent_provider.dart';
import 'external_links.dart';

/// Asks once whether usage statistics may be collected (GDPR opt-in).
Future<void> showConsentDialogIfNeeded(BuildContext context) async {
  final consent = context.read<ConsentProvider>();
  if (!consent.needsAnswer) return;
  final t = AppLocalizations.of(context);
  final privacyUrl = context.read<AppSettingsProvider>().settings.privacyPolicyUrl;
  final allowed = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.privacy_tip_outlined),
      title: Text(t.translate('consentTitle')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.translate('consentBody')),
          if (privacyUrl.isNotEmpty)
            TextButton(
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              onPressed: () => openExternalUrl(context, privacyUrl),
              child: Text(t.translate('privacyPolicy')),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(t.translate('consentDecline')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(t.translate('consentAccept')),
        ),
      ],
    ),
  );
  await consent.setAnalyticsAllowed(allowed ?? false);
}
