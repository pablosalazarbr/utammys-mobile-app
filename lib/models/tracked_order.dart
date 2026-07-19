/// Modelo de un pedido en seguimiento (guardado localmente y/o traído del API).
class TrackedOrder {
  final String trackingCode;
  final String orderNumber;
  final String status; // valor de máquina: pending/paid/processing/shipped/delivered/cancelled
  final String statusLabel; // etiqueta legible
  final double total;
  final String? buyerName;
  final String? shippingMethod;
  final DateTime? createdAt;
  final List<TrackedOrderItem> items;

  /// Cuándo se agregó/guardó en el dispositivo.
  final DateTime savedAt;

  TrackedOrder({
    required this.trackingCode,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.total,
    this.buyerName,
    this.shippingMethod,
    this.createdAt,
    this.items = const [],
    required this.savedAt,
  });

  static double _toDouble(dynamic v) {
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  /// Helper público para parsear montos (String o num) desde otras capas.
  static double parseAmount(dynamic v) => _toDouble(v);

  static DateTime? _toDate(dynamic v) {
    if (v is String && v.isNotEmpty) return DateTime.tryParse(v);
    return null;
  }

  /// Desde la respuesta del API (GET /shop/orders/track/{code}).
  factory TrackedOrder.fromApi(Map<String, dynamic> json, {DateTime? savedAt}) {
    return TrackedOrder(
      trackingCode: (json['tracking_code'] ?? '').toString(),
      orderNumber:
          (json['order_number'] ?? json['order_id'] ?? '—').toString(),
      status: (json['status'] ?? 'pending').toString(),
      statusLabel:
          (json['status_label'] ?? json['status'] ?? 'Pendiente').toString(),
      total: _toDouble(json['total']),
      buyerName: json['buyer_name']?.toString(),
      shippingMethod: json['shipping_method']?.toString(),
      createdAt: _toDate(json['created_at']),
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TrackedOrderItem.fromJson)
          .toList(),
      savedAt: savedAt ?? DateTime.now(),
    );
  }

  /// Desde/hacia JSON local (shared_preferences).
  factory TrackedOrder.fromJson(Map<String, dynamic> json) {
    return TrackedOrder(
      trackingCode: (json['tracking_code'] ?? '').toString(),
      orderNumber: (json['order_number'] ?? '—').toString(),
      status: (json['status'] ?? 'pending').toString(),
      statusLabel: (json['status_label'] ?? 'Pendiente').toString(),
      total: _toDouble(json['total']),
      buyerName: json['buyer_name']?.toString(),
      shippingMethod: json['shipping_method']?.toString(),
      createdAt: _toDate(json['created_at']),
      items: (json['items'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TrackedOrderItem.fromJson)
          .toList(),
      savedAt: _toDate(json['saved_at']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking_code': trackingCode,
      'order_number': orderNumber,
      'status': status,
      'status_label': statusLabel,
      'total': total,
      'buyer_name': buyerName,
      'shipping_method': shippingMethod,
      'created_at': createdAt?.toIso8601String(),
      'items': items.map((e) => e.toJson()).toList(),
      'saved_at': savedAt.toIso8601String(),
    };
  }

  TrackedOrder copyWithSavedAt(DateTime savedAt) => TrackedOrder(
        trackingCode: trackingCode,
        orderNumber: orderNumber,
        status: status,
        statusLabel: statusLabel,
        total: total,
        buyerName: buyerName,
        shippingMethod: shippingMethod,
        createdAt: createdAt,
        items: items,
        savedAt: savedAt,
      );
}

class TrackedOrderItem {
  final String name;
  final String? size;
  final int quantity;
  final double price;

  TrackedOrderItem({
    required this.name,
    this.size,
    required this.quantity,
    required this.price,
  });

  factory TrackedOrderItem.fromJson(Map<String, dynamic> json) {
    return TrackedOrderItem(
      name: (json['name'] ?? json['product_name'] ?? 'Producto').toString(),
      size: json['size']?.toString(),
      quantity: (json['quantity'] is num)
          ? (json['quantity'] as num).toInt()
          : int.tryParse('${json['quantity']}') ?? 1,
      price: TrackedOrder._toDouble(json['price']),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'size': size,
        'quantity': quantity,
        'price': price,
      };
}
