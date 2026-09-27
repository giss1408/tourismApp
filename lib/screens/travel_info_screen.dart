import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';

/// What European travellers need to prepare before flying to Côte d'Ivoire.
class TravelInfoScreen extends StatelessWidget {
  const TravelInfoScreen({super.key});

  static const _sections = <(IconData, String)>[
    (Icons.badge_outlined, 'Visa'),
    (Icons.vaccines_outlined, 'Health'),
    (Icons.payments_outlined, 'Money'),
    (Icons.wb_sunny_outlined, 'Season'),
    (Icons.translate, 'Language'),
    (Icons.power_outlined, 'Power'),
    (Icons.shield_outlined, 'Safety'),
  ];

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(localizations.translate('travelInfoTitle'))),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            localizations.translate('travelInfoIntro'),
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 12),
          for (final (icon, key) in _sections)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: CircleAvatar(
                  backgroundColor: colors.primaryContainer,
                  child: Icon(icon, color: colors.onPrimaryContainer),
                ),
                title: Text(
                  localizations.translate('travelInfo${key}Title'),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(localizations.translate('travelInfo${key}Body')),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Home screen entry point to [TravelInfoScreen].
class TravelInfoCard extends StatelessWidget {
  const TravelInfoCard({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.secondaryContainer,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Icon(Icons.flight_takeoff, color: colors.onSecondaryContainer),
        title: Text(
          localizations.translate('travelInfoCardTitle'),
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: colors.onSecondaryContainer,
          ),
        ),
        subtitle: Text(
          localizations.translate('travelInfoCardSubtitle'),
          style: TextStyle(color: colors.onSecondaryContainer),
        ),
        trailing: Icon(Icons.chevron_right, color: colors.onSecondaryContainer),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const TravelInfoScreen()),
        ),
      ),
    );
  }
}
