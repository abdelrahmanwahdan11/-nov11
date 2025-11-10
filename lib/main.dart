import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/auth_page.dart';
import 'features/cart/cart_page.dart';
import 'features/catalog/catalog_page.dart';
import 'features/compare/compare_page.dart';
import 'features/favorites/favorites_page.dart';
import 'features/home/home_page.dart';
import 'features/notifications/notifications_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/product/product_detail_page.dart';
import 'features/search/search_page.dart';
import 'features/settings/settings_page.dart';
import 'features/support/support_page.dart';
import 'shared/controllers/app_controller.dart';
import 'shared/controllers/cart_controller.dart';
import 'shared/controllers/catalog_controller.dart';
import 'shared/controllers/compare_controller.dart';
import 'shared/controllers/favorites_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appController = AppController();
  await appController.loadPrefs();
  final catalogController = CatalogController();
  await catalogController.loadInitial();
  runApp(
    AppScope(
      appController: appController,
      catalogController: catalogController,
      compareController: CompareController(),
      favoritesController: FavoritesController(),
      cartController: CartController(),
      child: const SmartAirApp(),
    ),
  );
}

class SmartAirApp extends StatefulWidget {
  const SmartAirApp({super.key});

  @override
  State<SmartAirApp> createState() => _SmartAirAppState();
}

class _SmartAirAppState extends State<SmartAirApp> {
  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    return ValueListenableBuilder(
      valueListenable: scope.appController.prefsNotifier,
      builder: (context, prefs, _) {
        final theme = AppTheme(primaryColor: prefs.primaryColor);
        final locale = Locale(prefs.localeCode);
        return MaterialApp(
          title: 'Smart Air',
          debugShowCheckedModeBanner: false,
          theme: theme.buildLightTheme(),
          darkTheme: theme.buildDarkTheme(),
          themeMode: prefs.darkMode ? ThemeMode.dark : ThemeMode.light,
          locale: locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          initialRoute: '/onboarding',
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case '/onboarding':
                return MaterialPageRoute(builder: (_) => const OnboardingPage());
              case '/auth':
                return MaterialPageRoute(builder: (_) => const AuthPage());
              case '/home':
                return MaterialPageRoute(builder: (_) => const HomePage());
              case '/catalog':
                return MaterialPageRoute(builder: (_) => const CatalogPage());
              case '/favorites':
                return MaterialPageRoute(builder: (_) => const FavoritesPage());
              case '/cart':
                return MaterialPageRoute(builder: (_) => const CartPage());
              case '/compare':
                return MaterialPageRoute(builder: (_) => const ComparePage());
              case '/notifications':
                return MaterialPageRoute(builder: (_) => const NotificationsPage());
              case '/settings':
                return MaterialPageRoute(builder: (_) => const SettingsPage());
              case '/support':
                return MaterialPageRoute(builder: (_) => const SupportPage());
              case '/search':
                return MaterialPageRoute(builder: (_) => const SearchPage());
              case '/product':
                final id = settings.arguments as String;
                return MaterialPageRoute(
                  builder: (_) => ProductDetailPage(productId: id),
                );
            }
            return null;
          },
        );
      },
    );
  }
}
