import 'dart:async';
import 'package:flutter/material.dart';

/// Muestra una notificación interna que "cae" desde la parte superior de la
/// pantalla y se oculta sola. Estilo tarjeta flotante (no banner).
void showAppNotification(
  BuildContext context,
  String message, {
  IconData icon = Icons.check_circle,
  Color accent = const Color(0xFF16A34A),
  Duration duration = const Duration(milliseconds: 2600),
}) {
  final overlay = Overlay.of(context);
  late OverlayEntry entry;
  entry = OverlayEntry(
    builder: (_) => _AppNotification(
      message: message,
      icon: icon,
      accent: accent,
      duration: duration,
      onDismiss: () => entry.remove(),
    ),
  );
  overlay.insert(entry);
}

class _AppNotification extends StatefulWidget {
  final String message;
  final IconData icon;
  final Color accent;
  final Duration duration;
  final VoidCallback onDismiss;

  const _AppNotification({
    required this.message,
    required this.icon,
    required this.accent,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_AppNotification> createState() => _AppNotificationState();
}

class _AppNotificationState extends State<_AppNotification>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  Timer? _timer;
  bool _dismissing = false;

  @override
  void initState() {
    super.initState();
    _c.forward();
    _timer = Timer(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (_dismissing) return;
    _dismissing = true;
    _timer?.cancel();
    if (mounted) await _c.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF1A1A1A);
    final curved = CurvedAnimation(
      parent: _c,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    );

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, -1.3),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(
            opacity: _c,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: GestureDetector(
                onTap: _dismiss,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: (isDark ? Colors.white : Colors.black)
                          .withValues(alpha: 0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withValues(alpha: isDark ? 0.5 : 0.15),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: widget.accent.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                        ),
                        child:
                            Icon(widget.icon, color: widget.accent, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.message,
                          style: TextStyle(
                            color: textColor,
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
