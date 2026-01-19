import 'package:utammys_mobile_app/services/api_service.dart';

class OrderService {
  /// Completa una compra (crea una orden)
  /// [cartItems] - Estructura esperada por la API
  static Future<Map<String, dynamic>> completeOrder(Map<String, dynamic> orderData) async {
    try {
      final response = await ApiService.post('shop/cart/complete', orderData);
      if (response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      return response;
    } catch (e) {
      throw Exception('Error completing order: $e');
    }
  }

  /// Obtiene órdenes del usuario autenticado (requiere token)
  static Future<List<Map<String, dynamic>>> getOrders() async {
    try {
      final response = await ApiService.getList('orders');
      return response.cast<Map<String, dynamic>>();
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  /// Obtiene detalle de una orden específica
  static Future<Map<String, dynamic>> getOrderById(int orderId) async {
    try {
      final response = await ApiService.get('orders/$orderId');
      if (response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      return response;
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  /// Cancela una orden
  static Future<Map<String, dynamic>> cancelOrder(int orderId) async {
    try {
      final response = await ApiService.post('orders/$orderId/cancel', {});
      if (response.containsKey('data')) {
        return response['data'] as Map<String, dynamic>;
      }
      return response;
    } catch (e) {
      throw Exception('Error canceling order: $e');
    }
  }
}
