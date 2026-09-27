import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/app_settings_provider.dart';
import '../../providers/booking_provider.dart';
import '../../providers/consent_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../providers/language_provider.dart';
import '../../providers/payment_methods_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/common/external_links.dart';
import '../travel_info_screen.dart';
import 'payment_methods_sheet.dart';
import 'profile_dialogs.dart';

/// Card with a bold title, used by every profile section.
class ProfileCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const ProfileCard({super.key, required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            ...children,
          ],
        ),
      ),
    );
  }
}

class ProfileHeader extends StatelessWidget {
  final AppUser user;

  const ProfileHeader({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final colors = Theme.of(context).colorScheme;
    final provider = switch (user.provider) {
      'google.com' => 'Google',
      'facebook.com' => 'Facebook',
      _ => t.email,
    };
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: colors.primaryContainer,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? Icon(Icons.person, size: 36, color: colors.onPrimaryContainer)
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.displayName ?? '',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(user.email ?? '',
                      style: TextStyle(color: Theme.of(context).hintColor, fontSize: 14)),
                  const SizedBox(height: 8),
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(provider),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              tooltip: t.editProfile,
              icon: const Icon(Icons.edit),
              onPressed: () => showEditProfileDialog(context, user),
            ),
          ],
        ),
      ),
    );
  }
}

/// Real figures from the traveller's bookings and favourites.
class TravelStatsCard extends StatelessWidget {
  const TravelStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final bookings = context.watch<BookingProvider>().bookings;
    final favorites = context.watch<FavoritesProvider>().favoriteDestinationIds.length;
    final today = DateUtils.dateOnly(DateTime.now());
    final active = bookings.where((b) => b.status != 'Cancelled');
    final trips = active.where((b) => b.checkOutDate.isBefore(today)).length;
    final upcoming = active.where((b) => !b.checkOutDate.isBefore(today)).length;

    return ProfileCard(
      title: t.travelStats,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _Stat(value: '$trips', label: t.trips, icon: Icons.flight_takeoff),
            _Stat(value: '$upcoming', label: t.upcoming, icon: Icons.calendar_today),
            _Stat(value: '$favorites', label: t.translate('favorites'), icon: Icons.favorite),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _Stat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: colors.primaryContainer,
          child: Icon(icon, color: colors.onPrimaryContainer, size: 22),
        ),
        const SizedBox(height: 8),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Theme.of(context).hintColor)),
      ],
    );
  }
}

class PreferencesCard extends StatelessWidget {
  const PreferencesCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final theme = context.watch<ThemeProvider>();
    final language = context.watch<LanguageProvider>();
    return ProfileCard(
      title: t.preferences,
      children: [
        SwitchListTile(
          title: Text(t.darkMode),
          value: theme.themeMode == ThemeMode.dark,
          onChanged: theme.toggleTheme,
          secondary: const Icon(Icons.dark_mode),
        ),
        ListTile(
          leading: const Icon(Icons.language),
          title: Text(t.language),
          subtitle: Text(language.getCurrentLanguageName()),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => showLanguageDialog(context),
        ),
      ],
    );
  }
}

class SupportCard extends StatelessWidget {
  const SupportCard({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final settings = context.watch<AppSettingsProvider>().settings;
    return ProfileCard(
      title: t.helpSupport,
      children: [
        if (settings.supportWhatsapp.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.chat_outlined, color: Color(0xFF25D366)),
            title: Text(t.translate('supportWhatsApp')),
            subtitle: Text(t.translate('supportWhatsAppSubtitle')),
            onTap: () => openWhatsApp(context, settings.supportWhatsapp,
                message: t.translate('supportWhatsAppMessage')),
          ),
        if (settings.supportEmail.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.mail_outline),
            title: Text(t.translate('supportEmail')),
            subtitle: Text(settings.supportEmail),
            onTap: () => openExternalUrl(context, 'mailto:${settings.supportEmail}'),
          ),
        ListTile(
          leading: const Icon(Icons.flight_takeoff),
          title: Text(t.translate('travelInfoTitle')),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const TravelInfoScreen()),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: Text(t.aboutExploreWorld),
          onTap: () => showAboutAppDialog(context),
        ),
      ],
    );
  }
}

class PrivacyCard extends StatelessWidget {
  final AppUser user;

  const PrivacyCard({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final settings = context.watch<AppSettingsProvider>().settings;
    final consent = context.watch<ConsentProvider>();
    return ProfileCard(
      title: t.translate('privacyAndLegal'),
      children: [
        SwitchListTile(
          secondary: const Icon(Icons.insights_outlined),
          title: Text(t.translate('usageStatistics')),
          subtitle: Text(t.translate('usageStatisticsSubtitle')),
          value: consent.analyticsAllowed == true,
          onChanged: consent.setAnalyticsAllowed,
        ),
        if (settings.privacyPolicyUrl.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(t.translate('privacyPolicy')),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => openExternalUrl(context, settings.privacyPolicyUrl),
          ),
        if (settings.termsUrl.isNotEmpty)
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: Text(t.translate('termsOfSale')),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => openExternalUrl(context, settings.termsUrl),
          ),
        if (kDebugMode)
          // Demo feature; real payments use the Stripe payment sheet.
          ListTile(
            leading: const Icon(Icons.payment),
            title: Text(t.paymentMethods),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showPaymentMethodsSheet(
              context,
              context.read<PaymentMethodsProvider>(),
              t,
            ),
          ),
        ListTile(
          leading: Icon(Icons.delete_forever_outlined,
              color: Theme.of(context).colorScheme.error),
          title: Text(t.translate('deleteAccount'),
              style: TextStyle(color: Theme.of(context).colorScheme.error)),
          onTap: () => showDeleteAccountDialog(context, user),
        ),
      ],
    );
  }
}
