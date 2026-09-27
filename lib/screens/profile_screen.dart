import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../providers/auth_provider.dart';
import 'profile/profile_dialogs.dart';
import 'profile/profile_sections.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final user = context.watch<AuthProvider>().user;

    return Scaffold(
      appBar: AppBar(
        title: Text(t.profile),
        actions: [
          if (user != null)
            IconButton(
              tooltip: t.logout,
              icon: const Icon(Icons.logout),
              onPressed: () => showLogoutDialog(context),
            ),
        ],
      ),
      // Only reachable while signed in (see AuthWrapper).
      body: user == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                ProfileHeader(user: user),
                const SizedBox(height: 16),
                const TravelStatsCard(),
                const SizedBox(height: 16),
                const PreferencesCard(),
                const SizedBox(height: 16),
                const SupportCard(),
                const SizedBox(height: 16),
                PrivacyCard(user: user),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () => showLogoutDialog(context),
                  icon: const Icon(Icons.logout),
                  label: Text(t.logout),
                ),
              ],
            ),
    );
  }
}
