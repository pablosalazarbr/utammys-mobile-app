import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/services/nav_controller.dart';
import 'package:utammys_mobile_app/services/cart_service.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

/// Barra de navegación global estilo "floating pill" con efecto glassmorphism.
///
/// Vive una sola vez en `MaterialApp.builder`, por encima de todas las rutas,
/// así que no se reconstruye al navegar. Su visibilidad la decide
/// [NavController] según la ruta actual, o se oculta con el teclado abierto.
class FloatingNavPill extends StatelessWidget {
  const FloatingNavPill({super.key});

  @override
  Widget build(BuildContext context) {
    final keyboardOpen = MediaQuery.of(context).viewInsets.bottom > 0;

    return ValueListenableBuilder<bool>(
      valueListenable: NavController.instance.pillVisible,
      builder: (context, pillVisible, _) {
        final visible = pillVisible && !keyboardOpen;

        return Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            ignoring: !visible,
            child: AnimatedSlide(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOutCubic,
              offset: visible ? Offset.zero : const Offset(0, 1.6),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 220),
                opacity: visible ? 1 : 0,
                child: const Padding(
                  padding: EdgeInsets.fromLTRB(12, 0, 12, 20),
                  child: _PillBar(),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _PillBar extends StatelessWidget {
  const _PillBar();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final glassColor = (isDark ? const Color(0xFF1C1C1E) : Colors.white)
        .withValues(alpha: isDark ? 0.62 : 0.72);
    final borderColor =
        (isDark ? Colors.white : Colors.black).withValues(alpha: 0.10);

    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          decoration: BoxDecoration(
            color: glassColor,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: ValueListenableBuilder<int>(
            valueListenable: NavController.instance.activeIndex,
            builder: (context, active, _) {
              return Row(
                children: [
                  Expanded(
                    child: _PillItem(
                      icon: Icons.home_outlined,
                      activeIcon: Icons.home,
                      isActive: active == 0,
                      onTap: NavController.instance.goHome,
                    ),
                  ),
                  Expanded(
                    child: _PillItem(
                      icon: Icons.search,
                      activeIcon: Icons.search,
                      isActive: active == 1,
                      onTap: NavController.instance.goSearch,
                    ),
                  ),
                  Expanded(
                    child: _PillItem(
                      icon: Icons.shopping_bag_outlined,
                      activeIcon: Icons.shopping_bag,
                      isActive: active == 2,
                      badgeCount: CartService().totalQuantity,
                      onTap: NavController.instance.goCart,
                    ),
                  ),
                  Expanded(
                    child: _PillItem(
                      icon: Icons.receipt_long_outlined,
                      activeIcon: Icons.receipt_long,
                      isActive: active == 3,
                      onTap: NavController.instance.goOrders,
                    ),
                  ),
                  Expanded(
                    child: _PillItem(
                      icon: Icons.settings_outlined,
                      activeIcon: Icons.settings,
                      isActive: active == 4,
                      onTap: NavController.instance.goSettings,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PillItem extends StatelessWidget {
  final IconData icon;
  final IconData activeIcon;
  final bool isActive;
  final VoidCallback onTap;
  final int badgeCount;

  const _PillItem({
    required this.icon,
    required this.activeIcon,
    required this.isActive,
    required this.onTap,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final activeColor = scheme.primary;
    final inactiveColor = scheme.onSurface.withValues(alpha: 0.55);
    final color = isActive ? activeColor : inactiveColor;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: isActive
                ? activeColor.withValues(alpha: 0.12)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(isActive ? activeIcon : icon, color: color, size: 26),
              if (badgeCount > 0)
                Positioned(
                  right: -9,
                  top: -7,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                    decoration: BoxDecoration(
                      color: TammysColors.accent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints:
                        const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      badgeCount > 99 ? '99+' : '$badgeCount',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
