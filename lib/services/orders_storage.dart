import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:utammys_mobile_app/models/tracked_order.dart';

/// Guarda localmente los pedidos que el usuario sigue (sin necesidad de cuenta).
class OrdersStorage {
  static const String _key = 'tracked_orders';

  Future<List<TrackedOrder>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final orders = list
          .whereType<Map<String, dynamic>>()
          .map(TrackedOrder.fromJson)
          .toList();
      // Más recientes primero (por fecha de guardado)
      orders.sort((a, b) => b.savedAt.compareTo(a.savedAt));
      return orders;
    } catch (_) {
      return [];
    }
  }

  Future<void> _saveAll(List<TrackedOrder> orders) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _key,
      jsonEncode(orders.map((e) => e.toJson()).toList()),
    );
  }

  /// Agrega o actualiza por [trackingCode]. Conserva el `savedAt` original.
  Future<List<TrackedOrder>> upsert(TrackedOrder order) async {
    final orders = await load();
    final idx = orders.indexWhere((o) => o.trackingCode == order.trackingCode);
    if (idx >= 0) {
      orders[idx] = order.copyWithSavedAt(orders[idx].savedAt);
    } else {
      orders.add(order);
    }
    await _saveAll(orders);
    return load();
  }

  Future<List<TrackedOrder>> remove(String trackingCode) async {
    final orders = await load();
    orders.removeWhere((o) => o.trackingCode == trackingCode);
    await _saveAll(orders);
    return orders;
  }

  Future<bool> exists(String trackingCode) async {
    final orders = await load();
    return orders.any((o) => o.trackingCode == trackingCode);
  }
}
