import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'app_scope.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'features/air_quality/air_quality_page.dart';
import 'features/auth/auth_page.dart';
import 'features/cart/cart_page.dart';
import 'features/catalog/catalog_page.dart';
import 'features/compare/compare_page.dart';
import 'features/diagnostics/diagnostics_page.dart';
import 'features/favorites/favorites_page.dart';
import 'features/environment/environment_schedule_page.dart';
import 'features/energy/energy_page.dart';
import 'features/home/home_page.dart';
import 'features/notifications/notifications_page.dart';
import 'features/onboarding/onboarding_page.dart';
import 'features/product/product_detail_page.dart';
import 'features/search/search_page.dart';
import 'features/settings/settings_page.dart';
import 'features/support/support_page.dart';
import 'features/maintenance/maintenance_page.dart';
import 'features/comfort/comfort_page.dart';
import 'features/wellness/wellness_page.dart';
import 'shared/controllers/air_quality_controller.dart';
import 'shared/controllers/app_controller.dart';
import 'shared/controllers/cart_controller.dart';
import 'shared/controllers/catalog_controller.dart';
import 'shared/controllers/compare_controller.dart';
import 'shared/controllers/environment_controller.dart';
import 'shared/controllers/environment_schedule_controller.dart';
import 'shared/controllers/energy_usage_controller.dart';
import 'shared/controllers/favorites_controller.dart';
import 'shared/controllers/notifications_controller.dart';
import 'shared/controllers/maintenance_controller.dart';
import 'shared/controllers/diagnostics_controller.dart';
import 'shared/controllers/comfort_controller.dart';
import 'shared/controllers/wellness_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appController = AppController();
  await appController.loadPrefs();
  final catalogController = CatalogController();
  await catalogController.loadInitial();
  final cartController = CartController();
  await cartController.loadPrefs();
  final notificationsController = NotificationsController();
  await notificationsController.load();
  final environmentController = EnvironmentController(appController)
    ..bootstrap();
  final environmentScheduleController =
      EnvironmentScheduleController(environmentController);
  await environmentScheduleController.load();
  final airQualityController = AirQualityController();
  await airQualityController.load();
  final energyUsageController = EnergyUsageController();
  await energyUsageController.load();
  final maintenanceController = MaintenanceController();
  await maintenanceController.load();
  final diagnosticsController = DiagnosticsController();
  await diagnosticsController.load();
  final comfortController = ComfortController();
  await comfortController.load();
  final wellnessController = WellnessController();
  await wellnessController.load();
  runApp(
    AppScope(
      appController: appController,
      catalogController: catalogController,
      compareController: CompareController(),
      favoritesController: FavoritesController(),
      cartController: cartController,
      notificationsController: notificationsController,
      environmentController: environmentController,
      environmentScheduleController: environmentScheduleController,
      airQualityController: airQualityController,
      energyUsageController: energyUsageController,
      maintenanceController: maintenanceController,
      diagnosticsController: diagnosticsController,
      comfortController: comfortController,
      wellnessController: wellnessController,
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
        final initialRoute = !prefs.onboardingSeen
            ? '/onboarding'
            : (prefs.isLoggedIn || prefs.isGuest)
                ? '/home'
                : '/auth';
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
          initialRoute: initialRoute,
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
              case '/air-quality':
                return MaterialPageRoute(builder: (_) => const AirQualityPage());
              case '/energy':
                return MaterialPageRoute(builder: (_) => const EnergyPage());
              case '/maintenance':
                return MaterialPageRoute(
                    builder: (_) => const MaintenancePage());
              case '/diagnostics':
                return MaterialPageRoute(
                    builder: (_) => const DiagnosticsPage());
              case '/comfort':
                return MaterialPageRoute(
                    builder: (_) => const ComfortPage());
              case '/wellness':
                return MaterialPageRoute(
                    builder: (_) => const WellnessPage());
              case '/environment-schedules':
                return MaterialPageRoute(
                  builder: (_) => const EnvironmentSchedulePage(),
                );
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
