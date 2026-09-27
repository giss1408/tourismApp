import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../l10n/app_localizations.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/language_provider.dart';
import '../../repositories/travel_repository.dart';
import '../../services/graphql_service.dart';
import '../../services/push_service.dart';

bool isSocialAccount(AppUser user) =>
    user.provider == 'google.com' || user.provider == 'facebook.com';

void _snack(BuildContext context, String message, {bool error = false}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(message),
    behavior: SnackBarBehavior.floating,
    backgroundColor: error ? Theme.of(context).colorScheme.error : null,
  ));
}

void showLanguageDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  final languageProvider = context.read<LanguageProvider>();
  showDialog(
    context: context,
    builder: (context) => SimpleDialog(
      title: Text(t.language),
      children: LanguageProvider.supportedLanguages.map((language) {
        final selected = languageProvider.locale.languageCode == language['code'];
        return SimpleDialogOption(
          onPressed: () {
            languageProvider.setLocale(Locale(language['code']!));
            Navigator.pop(context);
          },
          child: Row(
            children: [
              Expanded(child: Text(language['nativeName']!)),
              if (selected) Icon(Icons.check, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        );
      }).toList(),
    ),
  );
}

/// Unregisters push notifications, then signs out.
Future<void> signOutEverywhere(BuildContext context) async {
  final auth = context.read<AuthProvider>();
  await context.read<PushService>().disable();
  await auth.signOut();
}

void showLogoutDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.logout),
      content: Text(t.areYouSureLogout),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(dialogContext);
            signOutEverywhere(context);
          },
          child: Text(t.logout),
        ),
      ],
    ),
  );
}

void showAboutAppDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  showAboutDialog(
    context: context,
    applicationName: t.appTitle,
    applicationLegalese: t.translate('aboutAppDescription'),
  );
}

void showEditProfileDialog(BuildContext context, AppUser user) {
  final t = AppLocalizations.of(context);
  final nameController = TextEditingController(text: user.displayName);
  final authProvider = context.read<AuthProvider>();

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.editProfile),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: t.displayName,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (!isSocialAccount(user)) ...[
              EmailVerificationBanner(authProvider: authProvider),
              TextButton.icon(
                icon: const Icon(Icons.lock_outline, size: 18),
                label: Text(t.translate('changePassword')),
                onPressed: () {
                  Navigator.pop(dialogContext);
                  showChangePasswordDialog(context);
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () async {
            final newName = nameController.text.trim();
            if (newName.isEmpty) return;
            final success = await authProvider.updateDisplayName(newName);
            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
            _snack(context, success ? t.translate('profileUpdated') : authProvider.error,
                error: !success);
          },
          child: Text(t.save),
        ),
      ],
    ),
  );
}

void showChangePasswordDialog(BuildContext context) {
  final t = AppLocalizations.of(context);
  final authProvider = context.read<AuthProvider>();
  final currentController = TextEditingController();
  final newController = TextEditingController();
  final confirmController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  InputDecoration field(String key) => InputDecoration(
        labelText: t.translate(key),
        border: const OutlineInputBorder(),
      );

  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(t.translate('changePassword')),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: currentController,
              obscureText: true,
              decoration: field('currentPassword'),
              validator: (v) => (v == null || v.isEmpty) ? t.translate('required') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: newController,
              obscureText: true,
              decoration: field('newPassword'),
              validator: (v) =>
                  (v == null || v.length < 8) ? t.translate('passwordTooShort') : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: confirmController,
              obscureText: true,
              decoration: field('confirmNewPassword'),
              validator: (v) =>
                  v != newController.text ? t.translate('passwordsDoNotMatch') : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(t.cancel),
        ),
        FilledButton(
          onPressed: () async {
            if (!formKey.currentState!.validate()) return;
            final success = await authProvider.changePassword(
              currentController.text,
              newController.text,
            );
            if (!dialogContext.mounted) return;
            Navigator.pop(dialogContext);
            _snack(context, success ? t.translate('passwordUpdated') : authProvider.error,
                error: !success);
          },
          child: Text(t.translate('update')),
        ),
      ],
    ),
  );
}

/// GDPR erasure. Email accounts confirm with their password.
void showDeleteAccountDialog(BuildContext context, AppUser user) {
  final t = AppLocalizations.of(context);
  final passwordController = TextEditingController();
  final needsPassword = !isSocialAccount(user);

  showDialog(
    context: context,
    builder: (dialogContext) {
      var deleting = false;
      var error = '';
      return StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          icon: Icon(Icons.warning_amber_rounded,
              color: Theme.of(dialogContext).colorScheme.error),
          title: Text(t.translate('deleteAccount')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.translate('deleteAccountWarning')),
              if (needsPassword) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: t.password,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              if (error.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(error,
                    style: TextStyle(color: Theme.of(dialogContext).colorScheme.error)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: deleting ? null : () => Navigator.pop(dialogContext),
              child: Text(t.cancel),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(dialogContext).colorScheme.error,
              ),
              onPressed: deleting
                  ? null
                  : () async {
                      setState(() {
                        deleting = true;
                        error = '';
                      });
                      try {
                        await context.read<PushService>().disable();
                        if (!context.mounted) return;
                        await context.read<TravelRepository>().deleteAccount(
                            password: needsPassword ? passwordController.text : null);
                        // Social accounts also live in Firebase.
                        await FirebaseAuth.instance.currentUser?.delete().catchError((_) {});
                        if (!context.mounted) return;
                        Navigator.pop(dialogContext);
                        await context.read<AuthProvider>().signOut();
                      } catch (e) {
                        setState(() {
                          deleting = false;
                          error = e is GraphQlRequestException
                              ? e.userMessage
                              : t.translate('deleteAccountFailed');
                        });
                      }
                    },
              child: Text(t.translate('deleteAccountConfirm')),
            ),
          ],
        ),
      );
    },
  );
}

class EmailVerificationBanner extends StatelessWidget {
  final AuthProvider authProvider;

  const EmailVerificationBanner({super.key, required this.authProvider});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.emailVerified) return const SizedBox.shrink();
    final t = AppLocalizations.of(context);

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
            child: Text(t.translate('emailNotVerified'),
                style: TextStyle(color: Colors.orange.shade800, fontSize: 12)),
          ),
          TextButton(
            onPressed: () async {
              final ok = await authProvider.sendEmailVerification();
              if (context.mounted) {
                _snack(context, ok ? t.translate('verificationEmailSent') : authProvider.error);
              }
            },
            child: Text(t.send),
          ),
        ],
      ),
    );
  }
}
