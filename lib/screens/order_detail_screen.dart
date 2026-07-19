import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:utammys_mobile_app/models/tracked_order.dart';
import 'package:utammys_mobile_app/services/orders_service.dart';
import 'package:utammys_mobile_app/services/orders_storage.dart';
import 'package:utammys_mobile_app/theme/app_theme.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

/// Pasos del ciclo de vida (para la barra de progreso).
const _steps = [
  ('confirmed', 'Confirmado'),
  ('processing', 'En preparación'),
  ('ready', 'Listo'),
  ('shipped', 'Enviado'),
  ('delivered', 'Entregado'),
];

class OrderDetailScreen extends StatefulWidget {
  final TrackedOrder order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late TrackedOrder _order;
  bool _refreshing = false;
  bool _removed = false;

  @override
  void initState() {
    super.initState();
    _order = widget.order;
    _refresh();
  }

  Future<void> _refresh() async {
    setState(() => _refreshing = true);
    try {
      final fresh = await OrdersService.fetchByCode(_order.trackingCode);
      await OrdersStorage().upsert(fresh);
      if (mounted) setState(() => _order = fresh);
    } catch (_) {
      // Mantener lo que tenemos si falla la actualización.
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  Future<void> _remove() async {
    await OrdersStorage().remove(_order.trackingCode);
    _removed = true;
    if (mounted) Navigator.pop(context, true);
  }

  bool get _isNegative =>
      ['cancelled', 'refunded', 'payment_failed', 'pending_payment']
          .contains(_order.status);

  int get _currentStep => _steps.indexWhere((s) => s.$1 == _order.status);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tScaffold,
      appBar: AppBar(
        backgroundColor: context.tScaffold,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.tTextPrimary, size: 20),
          onPressed: () => Navigator.pop(context, _removed),
        ),
        actions: [
          if (_refreshing)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(Icons.refresh, color: context.tTextPrimary),
              onPressed: _refresh,
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        children: [
          Text(
            'Pedido ${_order.orderNumber}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: context.tTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          _StatusBadge(status: _order.status, label: _order.statusLabel),
          const SizedBox(height: 28),

          if (!_isNegative && _currentStep >= 0) ...[
            _StatusTimeline(currentStep: _currentStep),
            const SizedBox(height: 28),
          ],

          // Artículos
          Text('Artículos',
              style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: context.tTextPrimary)),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: context.tSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: context.tBorder),
            ),
            child: Column(
              children: [
                for (int i = 0; i < _order.items.length; i++) ...[
                  if (i > 0) Divider(height: 1, color: context.tDivider),
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_order.items[i].name,
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: context.tTextPrimary)),
                              const SizedBox(height: 2),
                              Text(
                                [
                                  if (_order.items[i].size != null)
                                    'Talla ${_order.items[i].size}',
                                  'Cantidad ${_order.items[i].quantity}',
                                ].join(' · '),
                                style: TextStyle(
                                    fontSize: 12,
                                    color: context.tTextSecondary),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          'Q${(_order.items[i].price * _order.items[i].quantity).toStringAsFixed(2)}',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: context.tTextPrimary),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_order.items.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text('Sin detalle de artículos',
                        style: TextStyle(color: context.tTextSecondary)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Total
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.tCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: SummaryRow(
              label: 'Total',
              value: 'Q${_order.total.toStringAsFixed(2)}',
              emphasized: true,
            ),
          ),
          const SizedBox(height: 24),

          // Código de seguimiento
          Text('Código de seguimiento',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: context.tTextSecondary)),
          const SizedBox(height: 6),
          GestureDetector(
            onTap: () {
              Clipboard.setData(ClipboardData(text: _order.trackingCode));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Código copiado')),
              );
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: context.tSurface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: context.tBorder),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _order.trackingCode,
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12.5,
                        color: context.tTextPrimary,
                      ),
                    ),
                  ),
                  Icon(Icons.copy, size: 18, color: context.tTextSecondary),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Eliminar
          TextButton.icon(
            onPressed: _remove,
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text('Dejar de seguir este pedido',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  final String label;
  const _StatusBadge({required this.status, required this.label});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (status) {
      case 'delivered':
        color = const Color(0xFF16A34A);
        break;
      case 'cancelled':
      case 'payment_failed':
      case 'refunded':
        color = const Color(0xFFDC2626);
        break;
      case 'pending_payment':
        color = const Color(0xFFD97706);
        break;
      default:
        color = const Color(0xFF2563EB);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w700, color: color),
      ),
    );
  }
}

class _StatusTimeline extends StatelessWidget {
  final int currentStep;
  const _StatusTimeline({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final active = context.tBrand;
    final inactive = context.tBorder;
    return Row(
      children: [
        for (int i = 0; i < _steps.length; i++) ...[
          Expanded(
            child: Column(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i <= currentStep ? active : Colors.transparent,
                    border: Border.all(
                      color: i <= currentStep ? active : inactive,
                      width: 2,
                    ),
                  ),
                  child: i <= currentStep
                      ? Icon(Icons.check,
                          size: 15, color: context.tOnBrand)
                      : null,
                ),
                const SizedBox(height: 6),
                Text(
                  _steps[i].$2,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 9.5,
                    fontWeight:
                        i <= currentStep ? FontWeight.w700 : FontWeight.w400,
                    color: i <= currentStep
                        ? context.tTextPrimary
                        : context.tTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
