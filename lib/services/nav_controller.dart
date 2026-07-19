import 'package:flutter/material.dart';

/// Controlador de la navegación principal por pestañas y del pill flotante global.
///
/// La visibilidad del pill se decide según la RUTA actual (vía [NavPillObserver],
/// que corre fuera de la fase de build), no desde las pantallas — así se evita el
/// error "setState during build" que impedía ocultarlo.
class NavController {
  NavController._();
  static final NavController instance = NavController._();

  /// Navegador raíz, para navegar desde el pill (que vive fuera del árbol de rutas).
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  /// Rutas donde el pill NO debe mostrarse.
  static const Set<String> hiddenRoutes = {
    'product-detail',
    'checkout',
    'order-confirmation',
    'privacy',
    'order-detail',
    'qr-scan',
    'add-order-sheet',
  };

  /// Si el pill debe mostrarse en la ruta actual.
  final ValueNotifier<bool> pillVisible = ValueNotifier<bool>(true);

  /// Pestaña activa para resaltar: 0 Home, 1 Buscar, 2 Bolsa, 3 Configuración.
  final ValueNotifier<int> activeIndex = ValueNotifier<int>(0);

  /// Nombre de la ruta actual (para no re-navegar a la misma pestaña).
  String? currentRouteName = '/';

  /// Sincroniza el estado del pill con la ruta en el tope de la pila.
  void syncWithRoute(String? routeName) {
    currentRouteName = routeName;
    pillVisible.value = !hiddenRoutes.contains(routeName);
    switch (routeName) {
      case '/':
        activeIndex.value = 0;
        break;
      case '/school-search':
        activeIndex.value = 1;
        break;
      case '/cart':
        activeIndex.value = 2;
        break;
      case '/orders':
        activeIndex.value = 3;
        break;
      case '/settings':
        activeIndex.value = 4;
        break;
    }
  }

  NavigatorState? get _nav => navigatorKey.currentState;

  /// Home: vuelve a la raíz de la pila.
  void goHome() {
    if (currentRouteName == '/') return;
    _nav?.popUntil((r) => r.isFirst);
  }

  void goSearch() {
    if (currentRouteName == '/school-search') return;
    // Comportamiento de pestaña: raíz (Home) + la pantalla, una sola instancia.
    _nav?.pushNamedAndRemoveUntil('/school-search', (r) => r.isFirst);
  }

  void goCart() {
    if (currentRouteName == '/cart') return;
    _nav?.pushNamed('/cart');
  }

  void goOrders() {
    if (currentRouteName == '/orders') return;
    _nav?.pushNamedAndRemoveUntil('/orders', (r) => r.isFirst);
  }

  void goSettings() {
    if (currentRouteName == '/settings') return;
    _nav?.pushNamedAndRemoveUntil('/settings', (r) => r.isFirst);
  }
}

/// Observa cambios de ruta para actualizar la visibilidad y el resaltado del pill.
/// Los callbacks del observer corren fuera de la fase de build, por lo que es
/// seguro mutar los notifiers aquí.
class NavPillObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      NavController.instance.syncWithRoute(route.settings.name);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) =>
      NavController.instance.syncWithRoute(previousRoute?.settings.name);

  // Nota: NO sincronizamos en didRemove. Durante pushNamedAndRemoveUntil se
  // remueven rutas intermedias mientras la nueva ya está en el tope (manejada
  // por didPush); sincronizar aquí resaltaría la pestaña equivocada.

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      NavController.instance.syncWithRoute(newRoute?.settings.name);
}
