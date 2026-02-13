import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Modelo para los datos de la sesión de checkout
class CheckoutSessionData {
  final String sessionId;
  final String checkoutUrl;
  final double amount;
  final String createdAt;

  CheckoutSessionData({
    required this.sessionId,
    required this.checkoutUrl,
    required this.amount,
    required this.createdAt,
  });

  factory CheckoutSessionData.fromJson(Map<String, dynamic> json) {
    return CheckoutSessionData(
      sessionId: json['session_id'] ?? json['id'] ?? '',
      checkoutUrl: json['checkout_url'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: json['created_at'] ?? DateTime.now().toIso8601String(),
    );
  }
}

/// Solicitud para inicializar una sesión de checkout
class CheckoutRequest {
  final String buyerName;
  final String buyerEmail;
  final String buyerPhone;
  final String shippingMethod; // 'pickup' o 'delivery'
  final String? shippingAddress;
  final String? shippingCity;
  final String? shippingNeighborhood;
  final List<CheckoutCartItem> items;

  CheckoutRequest({
    required this.buyerName,
    required this.buyerEmail,
    required this.buyerPhone,
    required this.shippingMethod,
    this.shippingAddress,
    this.shippingCity,
    this.shippingNeighborhood,
    required this.items,
  });

  /// Convertir a JSON para enviar a la API
  Map<String, dynamic> toJson() {
    return {
      'buyer_name': buyerName,
      'buyer_email': buyerEmail,
      'buyer_phone': buyerPhone,
      'shipping_method': shippingMethod,
      if (shippingAddress != null) 'shipping_address': shippingAddress,
      if (shippingCity != null) 'shipping_city': shippingCity,
      if (shippingNeighborhood != null)
        'shipping_neighborhood': shippingNeighborhood,
      'items': items.map((item) => item.toJson()).toList(),
    };
  }
}

/// Modelo de item del carrito
class CheckoutCartItem {
  final int productId;
  final int productSizeId;
  final int quantity;
  final String? customizationText;

  CheckoutCartItem({
    required this.productId,
    required this.productSizeId,
    required this.quantity,
    this.customizationText,
  });

  Map<String, dynamic> toJson() {
    return {
      'product_id': productId,
      'product_size_id': productSizeId,
      'quantity': quantity,
      'customization_text': customizationText ?? '',
    };
  }
}

class CheckoutService {
  static final CheckoutService _instance = CheckoutService._internal();

  factory CheckoutService() {
    return _instance;
  }

  CheckoutService._internal();

  final String _apiUrl = dotenv.env['API_BASE_URL'] ?? 'https://api.uniformestamys.com/api';

  /// Crear una sesión de checkout en Recurrente
  /// 
  /// Devuelve los datos de la sesión incluyendo la URL del formulario embebido
  /// Lanza una excepción si algo falla
  Future<CheckoutSessionData> initializeCheckoutSession(
    CheckoutRequest request,
  ) async {
    try {
      print('[CheckoutService] Inicializando sesión de checkout...');
      print('[CheckoutService] API URL: $_apiUrl');
      print('[CheckoutService] Buyer Email: ${request.buyerEmail}');
      print('[CheckoutService] Items count: ${request.items.length}');

      final url = Uri.parse('$_apiUrl/shop/cart/initialize-checkout');

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(request.toJson()),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout: No se pudo conectar con el servidor');
        },
      );

      print('[CheckoutService] Response status: ${response.statusCode}');
      print('[CheckoutService] Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['success'] == true && data['data'] != null) {
          final sessionData = CheckoutSessionData.fromJson(data['data']);
          print('[CheckoutService] ✅ Sesión creada: ${sessionData.sessionId}');
          return sessionData;
        } else {
          throw Exception(
            data['message'] ?? 'No se pudo crear la sesión de pago',
          );
        }
      } else if (response.statusCode == 422) {
        // Errores de validación
        final data = jsonDecode(response.body);
        final errors = data['errors'] ?? {};
        String errorMessage = 'Validación fallida:\n';
        errors.forEach((key, value) {
          errorMessage += '- $key: ${value.first}\n';
        });
        throw Exception(errorMessage);
      } else {
        final data = jsonDecode(response.body);
        throw Exception(
          data['message'] ?? 'Error: ${response.statusCode}',
        );
      }
    } catch (e) {
      print('[CheckoutService] ❌ Error: $e');
      rethrow;
    }
  }

  /// Verificar el estado de un checkout y obtener la orden creada
  /// Se usa después de que el webhook de Recurrente procesa el pago
  Future<Map<String, dynamic>> verifyCheckoutStatus({
    required String checkoutId,
    required String email,
  }) async {
    try {
      print('[CheckoutService] Verificando estado del checkout: $checkoutId');

      final url = Uri.parse('$_apiUrl/shop/orders/latest')
          .replace(queryParameters: {'email': email});

      final response = await http.get(
        url,
        headers: {
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () {
          throw Exception('Timeout verificando orden');
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('[CheckoutService] ✅ Orden verificada');
          return data['data'] ?? {};
        }
      }

      return {};
    } catch (e) {
      print('[CheckoutService] ⚠️ Error verificando estado: $e');
      return {};
    }
  }
}
