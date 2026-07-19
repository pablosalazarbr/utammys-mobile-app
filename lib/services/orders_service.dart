import 'package:utammys_mobile_app/models/tracked_order.dart';
import 'package:utammys_mobile_app/services/api_service.dart';
import 'package:utammys_mobile_app/services/orders_storage.dart';
import 'package:utammys_mobile_app/utils/logger.dart';

/// URL pública de la tienda (para abrir el seguimiento en web).
const String kStoreBaseUrl = 'https://uniformestamys.com';

/// Excepción amigable para mostrar en UI.
class OrderTrackingException implements Exception {
  final String message;
  OrderTrackingException(this.message);
  @override
  String toString() => message;
}

class OrdersService {
  /// Consulta un pedido por su código de seguimiento en el backend.
  static Future<TrackedOrder> fetchByCode(String code) async {
    try {
      final res = await ApiService.get('shop/orders/track/$code');
      if (res['success'] == true && res['data'] != null) {
        return TrackedOrder.fromApi(res['data'] as Map<String, dynamic>);
      }
      throw OrderTrackingException(
        (res['message'] ?? 'No encontramos ese pedido').toString(),
      );
    } on OrderTrackingException {
      rethrow;
    } catch (e) {
      logDebug('[OrdersService] fetchByCode error: $e');
      final msg = e.toString();
      if (msg.contains('404')) {
        throw OrderTrackingException(
          'No encontramos un pedido con ese código. Verifícalo e intenta de nuevo.',
        );
      }
      throw OrderTrackingException(
        'No pudimos conectar con el servidor. Revisa tu conexión.',
      );
    }
  }

  /// Extrae el código de un texto escaneado: acepta la URL
  /// `.../orden/{code}` o el código en crudo.
  static String extractCode(String raw) {
    final text = raw.trim();
    final uri = Uri.tryParse(text);
    if (uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.pathSegments.isNotEmpty) {
      final segs = uri.pathSegments;
      final idx = segs.indexOf('orden');
      if (idx >= 0 && idx + 1 < segs.length) return segs[idx + 1];
      return segs.last;
    }
    return text;
  }

  /// URL de seguimiento en la tienda para un código.
  static String trackingUrl(String code) => '$kStoreBaseUrl/orden/$code';

  /// Guarda un pedido tras una compra exitosa (a partir del orderData del checkout).
  /// Intenta traer el detalle en vivo; si falla, guarda un snapshot mínimo.
  static Future<void> saveFromCheckout(Map<String, dynamic> orderData) async {
    final code = orderData['tracking_code']?.toString();
    if (code == null || code.isEmpty) return;

    final storage = OrdersStorage();
    try {
      final order = await fetchByCode(code);
      await storage.upsert(order);
    } catch (_) {
      final snapshot = TrackedOrder(
        trackingCode: code,
        orderNumber: (orderData['order_number'] ?? '—').toString(),
        status: 'confirmed',
        statusLabel: 'Confirmado',
        total: TrackedOrder.parseAmount(
            orderData['total_amount'] ?? orderData['total']),
        buyerName: orderData['buyer_name']?.toString(),
        createdAt: DateTime.now(),
        savedAt: DateTime.now(),
      );
      await storage.upsert(snapshot);
    }
  }
}
