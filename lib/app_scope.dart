import 'package:flutter/material.dart';

import 'shared/controllers/app_controller.dart';
import 'shared/controllers/cart_controller.dart';
import 'shared/controllers/catalog_controller.dart';
import 'shared/controllers/compare_controller.dart';
import 'shared/controllers/favorites_controller.dart';
import 'shared/controllers/notifications_controller.dart';

class AppScope extends InheritedWidget {
  const AppScope({
    super.key,
    required this.appController,
    required this.catalogController,
    required this.compareController,
    required this.favoritesController,
    required this.cartController,
    required this.notificationsController,
    required super.child,
  });

  final AppController appController;
  final CatalogController catalogController;
  final CompareController compareController;
  final FavoritesController favoritesController;
  final CartController cartController;
  final NotificationsController notificationsController;

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
        notificationsController != oldWidget.notificationsController;
  }
}
