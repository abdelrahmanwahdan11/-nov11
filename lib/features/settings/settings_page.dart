import 'package:flutter/material.dart';

import '../../app_scope.dart';
import '../../core/utils/context_extensions.dart';
import '../../shared/models/app_prefs.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.getString('settings'))),
      body: ValueListenableBuilder<AppPrefs>(
        valueListenable: scope.appController.prefsNotifier,
        builder: (context, prefs, _) {
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              ListTile(
                title: Text(l10n.getString('theme')),
                trailing: Switch(
                  value: prefs.darkMode,
                  onChanged: scope.appController.updateDarkMode,
                ),
              ),
              ListTile(
                title: Text(l10n.getString('language')),
                subtitle: Text(prefs.localeCode == 'ar'
                    ? l10n.getString('languageArabic')
                    : l10n.getString('languageEnglish')),
                onTap: () {
                  final next = prefs.localeCode == 'en' ? 'ar' : 'en';
                  scope.appController.updateLocale(next);
                },
              ),
              ListTile(
                title: Text(l10n.getString('colorPicker')),
                subtitle: Row(
                  children: [
                    _ColorDot(
                      color: Colors.limeAccent.shade200,
                      selected: prefs.primaryColor.value == Colors.limeAccent.shade200.value,
                      onTap: () {
                        scope.appController.updateColor(Colors.limeAccent.shade200);
                      },
                    ),
                    const SizedBox(width: 12),
                    _ColorDot(
                      color: const Color(0xFFBDE6FF),
                      selected: prefs.primaryColor.value == const Color(0xFFBDE6FF).value,
                      onTap: () {
                        scope.appController.updateColor(const Color(0xFFBDE6FF));
                      },
                    ),
                    const SizedBox(width: 12),
                    _ColorDot(
                      color: const Color(0xFFC9FF4D),
                      selected: prefs.primaryColor.value == const Color(0xFFC9FF4D).value,
                      onTap: () {
                        scope.appController.updateColor(const Color(0xFFC9FF4D));
                      },
                    ),
                  ],
                ),
              ),
              ListTile(
                title: Text(l10n.getString('clearPreferences')),
                trailing: const Icon(Icons.delete_outline),
                onTap: () async {
                  await scope.appController.clearPrefs();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.getString('preferencesCleared'))),
                  );
                },
              ),
              ListTile(
                title: Text(l10n.getString('support')),
                onTap: () => Navigator.of(context).pushNamed('/support'),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({required this.color, required this.onTap, required this.selected});

  final Color color;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
          border: Border.all(
            color: selected ? Theme.of(context).colorScheme.primary : Colors.black12,
            width: selected ? 2 : 1,
          ),
        ),
      ),
    );
  }
}
