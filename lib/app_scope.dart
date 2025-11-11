import 'package:flutter/material.dart';

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

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.appController,
    required this.catalogController,
    required this.compareController,
    required this.favoritesController,
    required this.cartController,
    required this.notificationsController,
    required this.environmentController,
    required this.environmentScheduleController,
    required this.airQualityController,
    required this.energyUsageController,
    required this.maintenanceController,
    required this.diagnosticsController,
    required this.comfortController,
    required super.child,
  });

  final AppController appController;
  final CatalogController catalogController;
  final CompareController compareController;
  final FavoritesController favoritesController;
  final CartController cartController;
  final NotificationsController notificationsController;
  final EnvironmentController environmentController;
  final EnvironmentScheduleController environmentScheduleController;
  final AirQualityController airQualityController;
  final EnergyUsageController energyUsageController;
  final MaintenanceController maintenanceController;
  final DiagnosticsController diagnosticsController;
  final ComfortController comfortController;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found');
    return scope!;
  }

  @override
  bool updateShouldNotify(covariant AppScope oldWidget) {
    return appController != oldWidget.appController ||
        catalogController != oldWidget.catalogController ||
        compareController != oldWidget.compareController ||
        favoritesController != oldWidget.favoritesController ||
        cartController != oldWidget.cartController ||
        notificationsController != oldWidget.notificationsController ||
        environmentController != oldWidget.environmentController ||
        environmentScheduleController !=
            oldWidget.environmentScheduleController ||
        airQualityController != oldWidget.airQualityController ||
        energyUsageController != oldWidget.energyUsageController ||
        maintenanceController != oldWidget.maintenanceController ||
        diagnosticsController != oldWidget.diagnosticsController ||
        comfortController != oldWidget.comfortController;
  }
}
