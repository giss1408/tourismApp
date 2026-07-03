// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../models/user_model.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final user = authProvider.user;
    final localizations = AppLocalizations.of(context);

    // If user is not logged in, show login prompt
    if (user == null) {
      return _buildLoginPrompt(context, authProvider, localizations);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _showSettingsDialog(context, themeProvider, languageProvider, localizations);
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              _showLogoutDialog(context, authProvider, localizations);
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildProfileHeader(user, context, localizations),
          const SizedBox(height: 24),
          _buildStatsSection(localizations),
          const SizedBox(height: 24),
          _buildQuickActions(localizations),
          const SizedBox(height: 24),
          _buildPreferencesSection(context, themeProvider, languageProvider, localizations),
          const SizedBox(height: 24),
          _buildAccountSection(context, authProvider, localizations),
        ],
      ),
    );
  }

  Widget _buildLoginPrompt(BuildContext context, AuthProvider authProvider, AppLocalizations localizations) {
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.profile),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                localizations.welcomeBack,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                localizations.joinUsToExplore,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    // This will trigger the AuthWrapper to show auth screen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    localizations.signInToContinue,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigate to auth screen directly
                },
                child: Text(localizations.createAccount),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(AppUser user, BuildContext context, AppLocalizations localizations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue.shade600,
                    )
                  : null,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.displayName ?? localizations.exploreThe,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user.email ?? localizations.email,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getProviderColor(user.provider),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _getProviderText(user.provider, localizations),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.edit,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              onPressed: () {
                _showEditProfileDialog(context, user, localizations);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsSection(AppLocalizations localizations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.travelStats,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('12', localizations.trips, Icons.flight_takeoff),
                _buildStatItem('8', localizations.countries, Icons.flag),
                _buildStatItem('24', localizations.reviews, Icons.star),
                _buildStatItem('2', localizations.upcoming, Icons.calendar_today),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(
            icon,
            color: Colors.blue.shade600,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(AppLocalizations localizations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.quickActions,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildActionItem(Icons.wallet, localizations.wallet, Colors.green),
                _buildActionItem(Icons.card_giftcard, localizations.rewards, Colors.orange),
                _buildActionItem(Icons.help_center, localizations.help, Colors.purple),
                _buildActionItem(Icons.share, localizations.share, Colors.blue),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildPreferencesSection(BuildContext context, ThemeProvider themeProvider, LanguageProvider languageProvider, AppLocalizations localizations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.preferences,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(localizations.darkMode),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
              },
              secondary: const Icon(Icons.dark_mode),
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(localizations.pushNotifications),
              trailing: const Icon(Icons.chevron_right),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(localizations.language),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    languageProvider.getCurrentLanguageName(),
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              onTap: () {
                _showLanguageDialog(context, languageProvider, localizations);
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: Text(localizations.currency),
              trailing: const Text('USD'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context, AuthProvider authProvider, AppLocalizations localizations) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.account,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.security),
              title: Text(localizations.privacySecurity),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to privacy settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: Text(localizations.paymentMethods),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to payment methods
              },
            ),
            ListTile(
              leading: const Icon(Icons.help_outline),
              title: Text(localizations.helpSupport),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to help & support
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text(localizations.aboutExploreWorld),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // TODO: Navigate to about
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  _showLogoutDialog(context, authProvider, localizations);
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(localizations.logout),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getProviderColor(String? provider) {
    switch (provider) {
      case 'google.com':
        return Colors.red.shade400;
      case 'facebook.com':
        return Colors.blue.shade600;
      default:
        return Colors.green.shade400;
    }
  }

  String _getProviderText(String? provider, AppLocalizations localizations) {
    switch (provider) {
      case 'google.com':
        return 'Google';
      case 'facebook.com':
        return 'Facebook';
      default:
        return localizations.email;
    }
  }

  void _showSettingsDialog(BuildContext context, ThemeProvider themeProvider, LanguageProvider languageProvider, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.settings),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SwitchListTile(
              title: Text(localizations.darkMode),
              value: themeProvider.themeMode == ThemeMode.dark,
              onChanged: (value) {
                themeProvider.toggleTheme(value);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(localizations.language),
              subtitle: Text(languageProvider.getCurrentLanguageName()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Navigator.pop(context);
                _showLanguageDialog(context, languageProvider, localizations);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
        ],
      ),
    );
  }

  void _showLanguageDialog(BuildContext context, LanguageProvider languageProvider, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.language),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: LanguageProvider.supportedLanguages.map((language) {
            return ListTile(
              title: Text(language['nativeName']!),
              trailing: languageProvider.locale.languageCode == language['code']
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                languageProvider.setLocale(Locale(language['code']!));
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.logout),
        content: Text(localizations.areYouSureLogout),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(localizations.logout),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppUser user, AppLocalizations localizations) {
    final nameController = TextEditingController(text: user.displayName);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.editProfile),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue.shade100,
              backgroundImage: user.photoURL != null ? NetworkImage(user.photoURL!) : null,
              child: user.photoURL == null
                  ? Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.blue.shade600,
                    )
                  : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: localizations.displayName,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Implement profile update
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${localizations.profile} ${localizations.save.toLowerCase()}!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: Text(localizations.save),
          ),
        ],
      ),
    );
  }
}