import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/l10n/app_localizations.dart';
import '../../core/theme/design_tokens.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/models/app_prefs.dart';
import '../../shared/widgets/color_picker_grid.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.getString('settings'))),
      body: ValueListenableBuilder<AppPrefs>(
        valueListenable: scope.appController.prefsNotifier,
        builder: (context, prefs, _) {
          final palette = DesignTokens.primaryPalette;
          final hasSession = prefs.isGuest || prefs.isLoggedIn;
          final displayName = prefs.userName?.isNotEmpty == true
              ? prefs.userName!
              : (prefs.isGuest ? l10n.getString('guestLabel') : l10n.getString('guestWelcome'));
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(l10n.getString('appearance'), style: context.textTheme.headlineMedium),
              const SizedBox(height: 12),
              SwitchListTile.adaptive(
                value: prefs.darkMode,
                onChanged: scope.appController.updateDarkMode,
                title: Text(l10n.getString('darkMode')),
                subtitle: Text(l10n.getString('darkModeHint')),
              ),
              const SizedBox(height: 16),
              Text(l10n.getString('primaryColor'), style: context.textTheme.titleMedium),
              const SizedBox(height: 12),
              ColorPickerGrid(
                colors: palette,
                selected: prefs.primaryColor,
                onSelected: scope.appController.updateColor,
              ),
              const SizedBox(height: 32),
              Text(l10n.getString('language'), style: context.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: AppLocalizations.supportedLocales.map((locale) {
                  final selected = prefs.localeCode == locale.languageCode;
                  final label = locale.languageCode == 'ar'
                      ? l10n.getString('languageArabic')
                      : l10n.getString('languageEnglish');
                  return ChoiceChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (value) {
                      if (value) {
                        scope.appController.updateLocale(locale.languageCode);
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              Text(l10n.getString('account'), style: context.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: prefs.primaryColor.withOpacity(0.2),
                    child: Text(
                      displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                      style: context.textTheme.titleMedium,
                    ),
                  ),
                  title: Text(displayName),
                  subtitle: Text(
                    hasSession
                        ? (prefs.isGuest ? l10n.getString('guestLabel') : l10n.getString('memberLabel'))
                        : l10n.getString('noAccount'),
                  ),
                  trailing: TextButton(
                    onPressed: hasSession
                        ? () async {
                            await scope.appController.signOut();
                            if (!mounted) return;
                            Navigator.of(context).pushNamedAndRemoveUntil('/auth', (route) => false);
                          }
                        : null,
                    child: Text(l10n.getString('logout')),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.support_agent),
                title: Text(l10n.getString('support')),
                subtitle: Text(l10n.getString('supportSubtitle')),
                onTap: () => Navigator.of(context).pushNamed('/support'),
              ),
              const SizedBox(height: 24),
              OutlinedButton.icon(
                onPressed: () async {
                  await scope.appController.clearPrefs();
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.getString('preferencesCleared'))),
                  );
                  Navigator.of(context).pushNamedAndRemoveUntil('/onboarding', (route) => false);
                },
                icon: const Icon(Icons.delete_outline),
                label: Text(l10n.getString('clearPreferences')),
              ),
            ],
          );
        },
      ),
    );
  }
}
