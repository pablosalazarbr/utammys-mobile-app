import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/models/tracked_order.dart';
import 'package:utammys_mobile_app/services/orders_service.dart';
import 'package:utammys_mobile_app/services/orders_storage.dart';
import 'package:utammys_mobile_app/screens/order_detail_screen.dart';
import 'package:utammys_mobile_app/screens/qr_scan_screen.dart';
import 'package:utammys_mobile_app/theme/app_theme.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';
import 'package:utammys_mobile_app/widgets/app_notification.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrdersStorage _storage = OrdersStorage();
  List<TrackedOrder> _orders = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final orders = await _storage.load();
    if (mounted) {
      setState(() {
        _orders = orders;
        _loading = false;
      });
    }
  }

  Future<void> _openDetail(TrackedOrder order) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        settings: const RouteSettings(name: 'order-detail'),
        builder: (_) => OrderDetailScreen(order: order),
      ),
    );
    _load(); // refrescar por si cambió estado o se eliminó
  }

  /// Agrega un pedido por código (viene de texto manual o de un QR).
  Future<void> _addByCode(String rawCode, {required StateSetter sheetSetState}) async {
    final code = OrdersService.extractCode(rawCode);
    if (code.isEmpty) return;
    sheetSetState(() => _adding = true);
    try {
      final order = await OrdersService.fetchByCode(code);
      await _storage.upsert(order);
      if (mounted) Navigator.pop(context); // cerrar sheet
      await _load();
      if (mounted) {
        showAppNotification(context, 'Pedido ${order.orderNumber} agregado');
      }
    } on OrderTrackingException catch (e) {
      sheetSetState(() {
        _adding = false;
        _addError = e.message;
      });
    } catch (e) {
      sheetSetState(() {
        _adding = false;
        _addError = 'Ocurrió un error. Intenta de nuevo.';
      });
    }
  }

  bool _adding = false;
  String? _addError;

  void _showAddSheet() {
    final controller = TextEditingController();
    _adding = false;
    _addError = null;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: context.tSurface,
      routeSettings: const RouteSettings(name: 'add-order-sheet'),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, sheetSetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.tBorder,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text('Agregar un pedido',
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: context.tTextPrimary)),
                  const SizedBox(height: 6),
                  Text(
                    'Ingresa el código de seguimiento de tu correo, o escanea el QR.',
                    style: TextStyle(fontSize: 13, color: context.tTextSecondary),
                  ),
                  const SizedBox(height: 18),
                  TammysTextField(
                    controller: controller,
                    hint: 'Código de seguimiento',
                  ),
                  if (_addError != null) ...[
                    const SizedBox(height: 8),
                    Text(_addError!,
                        style: const TextStyle(color: Colors.red, fontSize: 12)),
                  ],
                  const SizedBox(height: 16),
                  TammysPrimaryButton(
                    label: _adding ? 'Agregando…' : 'Agregar',
                    onPressed: _adding
                        ? null
                        : () => _addByCode(controller.text,
                            sheetSetState: sheetSetState),
                  ),
                  const SizedBox(height: 10),
                  TammysSecondaryButton(
                    label: 'Escanear QR',
                    onPressed: _adding
                        ? null
                        : () async {
                            final raw = await Navigator.push<String>(
                              sheetContext,
                              MaterialPageRoute(
                                settings:
                                    const RouteSettings(name: 'qr-scan'),
                                builder: (_) => const QrScanScreen(),
                              ),
                            );
                            if (raw != null && raw.isNotEmpty) {
                              _addByCode(raw, sheetSetState: sheetSetState);
                            }
                          },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.tScaffold,
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Mis Pedidos',
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: context.tTextPrimary)),
                  IconButton(
                    onPressed: _showAddSheet,
                    icon: Icon(Icons.add_circle_outline,
                        color: context.tTextPrimary),
                    tooltip: 'Agregar pedido',
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const LoadingWidget();
    }
    if (_orders.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined,
                  size: 64, color: context.tTextSecondary),
              const SizedBox(height: 16),
              Text('Aún no sigues ningún pedido',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: context.tTextPrimary)),
              const SizedBox(height: 8),
              Text(
                'Agrega un pedido con el código o el QR que recibiste por correo.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: context.tTextSecondary),
              ),
              const SizedBox(height: 24),
              TammysPrimaryButton(
                label: 'Agregar pedido',
                icon: Icons.add,
                onPressed: _showAddSheet,
              ),
            ],
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 110),
        itemCount: _orders.length,
        itemBuilder: (context, i) => _OrderCard(
          order: _orders[i],
          onTap: () => _openDetail(_orders[i]),
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final TrackedOrder order;
  final VoidCallback onTap;

  const _OrderCard({required this.order, required this.onTap});

  Color _statusColor() {
    switch (order.status) {
      case 'delivered':
        return const Color(0xFF16A34A);
      case 'cancelled':
      case 'payment_failed':
      case 'refunded':
        return const Color(0xFFDC2626);
      case 'pending_payment':
        return const Color(0xFFD97706);
      default:
        return const Color(0xFF2563EB);
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor();
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Material(
        color: context.tSurface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.tBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(order.orderNumber,
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: context.tTextPrimary)),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(order.statusLabel,
                                style: TextStyle(
                                    fontSize: 10.5,
                                    fontWeight: FontWeight.w700,
                                    color: color)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Q${order.total.toStringAsFixed(2)}',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: context.tTextSecondary),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: context.tTextSecondary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
