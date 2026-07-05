// screens/profile_screen.dart
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/language_provider.dart';
import '../providers/payment_methods_provider.dart';
import '../models/user_model.dart';
import '../l10n/app_localizations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final authProvider = context.watch<AuthProvider>();
    final languageProvider = context.watch<LanguageProvider>();
    final paymentMethodsProvider = context.watch<PaymentMethodsProvider>();
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
          _buildAccountSection(
            context,
            authProvider,
            paymentMethodsProvider,
            localizations,
          ),
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
                  ? Icon(Icons.person, size: 40, color: Colors.blue.shade600)
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
              subtitle: Text(
                languageProvider.getCurrentLanguageName(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                _showLanguageDialog(context, languageProvider, localizations);
              },
            ),
            ListTile(
              leading: const Icon(Icons.currency_exchange),
              title: Text(localizations.currency),
              subtitle: const Text(
                'USD',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(
    BuildContext context,
    AuthProvider authProvider,
    PaymentMethodsProvider paymentMethodsProvider,
    AppLocalizations localizations,
  ) {
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
                _showPaymentMethodsSheet(
                  context,
                  paymentMethodsProvider,
                  localizations,
                );
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
                _showAboutDialog(context, localizations);
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

  Future<void> _showPaymentMethodsSheet(
    BuildContext context,
    PaymentMethodsProvider paymentMethodsProvider,
    AppLocalizations localizations,
  ) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        return Consumer<PaymentMethodsProvider>(
          builder: (context, methodsProvider, _) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.paymentMethods,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (!methodsProvider.isLoaded)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (methodsProvider.methods.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: Text(localizations.noPaymentMethodsYet),
                    )
                  else
                    ...methodsProvider.methods.map(
                      (method) => Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.blue.shade50,
                            child: Icon(
                              Icons.credit_card,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          title: Text(method.maskedLabel),
                          subtitle: Text('${method.holderName} • ${method.expiryLabel}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (method.isDefault)
                                Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    localizations.defaultLabel,
                                    style: TextStyle(
                                      color: Colors.green.shade800,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                )
                              else
                                IconButton(
                                  icon: const Icon(Icons.check_circle_outline),
                                  tooltip: localizations.setDefault,
                                  onPressed: () {
                                    methodsProvider.setDefault(method.id);
                                  },
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: localizations.removeMethod,
                                onPressed: () {
                                  methodsProvider.removeMethod(method.id);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        methodsProvider.addMockMethod();
                      },
                      icon: const Icon(Icons.add),
                      label: Text(localizations.addMockPaymentMethod),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(localizations.darkMode),
                value: themeProvider.themeMode == ThemeMode.dark,
                onChanged: (value) {
                  themeProvider.toggleTheme(value);
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
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
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: LanguageProvider.supportedLanguages.map((language) {
              return ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                title: Text(
                  language['nativeName']!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
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

  void _showAboutDialog(BuildContext context, AppLocalizations localizations) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(localizations.aboutExploreWorld),
        content: Text(localizations.aboutActivityDescription),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(localizations.cancel),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, AppUser user, AppLocalizations localizations) {
    final nameController = TextEditingController(text: user.displayName);
    final authProvider = context.read<AuthProvider>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(localizations.editProfile),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Center(
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.blue.shade100,
                  backgroundImage:
                      user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null
                      ? Icon(Icons.person, size: 40, color: Colors.blue.shade600)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              // Display name
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: localizations.displayName,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              // Email verification banner (only for unverified email accounts)
              if (user.provider != 'google.com' &&
                  user.provider != 'facebook.com')
                _EmailVerificationBanner(authProvider: authProvider),
              const SizedBox(height: 4),
              // Change password link (only for email accounts)
              if (user.provider != 'google.com' &&
                  user.provider != 'facebook.com')
                TextButton.icon(
                  icon: const Icon(Icons.lock_outline, size: 18),
                  label: const Text('Change password'),
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _showChangePasswordDialog(context, authProvider);
                  },
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(localizations.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              final newName = nameController.text.trim();
              if (newName.isEmpty) return;
              final success = await authProvider.updateDisplayName(newName);
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Display name updated.'
                      : authProvider.error),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: success ? null : Colors.red,
                ),
              );
            },
            child: Text(localizations.save),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Change password'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: currentController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Current password',
                  border: OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: newController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'New password',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => (v == null || v.length < 6)
                    ? 'Minimum 6 characters'
                    : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: confirmController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Confirm new password',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v != newController.text
                    ? 'Passwords do not match'
                    : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (!formKey.currentState!.validate()) return;
              final success = await authProvider.changePassword(
                currentController.text,
                newController.text,
              );
              if (!dialogContext.mounted) return;
              Navigator.pop(dialogContext);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success
                      ? 'Password updated successfully.'
                      : authProvider.error),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: success ? null : Colors.red,
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

class _EmailVerificationBanner extends StatelessWidget {
  final AuthProvider authProvider;
  const _EmailVerificationBanner({required this.authProvider});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.emailVerified) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Email not verified.',
              style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
            ),
          ),
          TextButton(
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            onPressed: () async {
              final ok = await authProvider.sendEmailVerification();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(ok
                        ? 'Verification email sent.'
                        : authProvider.error),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            child: const Text('Send', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
