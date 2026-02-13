import 'package:utammys_mobile_app/models/product_model.dart';

/// Servicio para gestionar el carrito de compras
class CartService {
  static final CartService _instance = CartService._internal();

  final List<CartItem> _cartItems = [];

  CartService._internal();

  factory CartService() {
    return _instance;
  }

  /// Obtener todos los items del carrito
  List<CartItem> get cartItems => _cartItems;

  /// Obtener la cantidad de items en el carrito
  int get itemCount => _cartItems.length;

  /// Obtener el total de items (contando cantidades)
  int get totalQuantity => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  /// Calcular subtotal
  double get subtotal => _cartItems.fold(
    0.0,
    (total, item) => total + (item.product.price ?? item.size?.price ?? 0.0) * item.quantity,
  );

  /// Agregar un item al carrito
  /// Si el producto ya existe con la misma talla Y personalización, suma la cantidad
  void addItem(CartItem item) {
    try {
      // Buscar si el producto ya existe con la misma talla Y personalización
      final existingIndex = _cartItems.indexWhere(
        (cartItem) =>
            cartItem.product.id == item.product.id &&
            cartItem.size?.id == item.size?.id &&
            cartItem.customizationText == item.customizationText,
      );

      if (existingIndex != -1) {
        // Producto existe, incrementar cantidad
        _cartItems[existingIndex] = CartItem(
          product: _cartItems[existingIndex].product,
          size: _cartItems[existingIndex].size,
          quantity: _cartItems[existingIndex].quantity + item.quantity,
          customizationText: _cartItems[existingIndex].customizationText,
          customizationCost: _cartItems[existingIndex].customizationCost,
        );
        print('[CartService] Incrementada cantidad del producto: ${item.product.name}');
      } else {
        // Nuevo producto
        _cartItems.add(item);
        print('[CartService] Producto agregado al carrito: ${item.product.name}');
      }
    } catch (e) {
      print('[CartService] Error al agregar item: $e');
    }
  }

  /// Remover un item del carrito por índice
  void removeItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      print('[CartService] Producto removido: ${_cartItems[index].product.name}');
      _cartItems.removeAt(index);
    }
  }

  /// Actualizar la cantidad de un item
  void updateItemQuantity(int index, int quantity) {
    if (index >= 0 && index < _cartItems.length) {
      if (quantity <= 0) {
        removeItem(index);
      } else {
        final item = _cartItems[index];
        _cartItems[index] = CartItem(
          product: item.product,
          size: item.size,
          quantity: quantity,
          customizationText: item.customizationText,
          customizationCost: item.customizationCost,
        );
        print('[CartService] Cantidad actualizada: ${item.product.name} -> $quantity');
      }
    }
  }

  /// Vaciar el carrito
  void clearCart() {
    _cartItems.clear();
    print('[CartService] Carrito vaciado');
  }

  /// Obtener un item por índice
  CartItem? getItem(int index) {
    if (index >= 0 && index < _cartItems.length) {
      return _cartItems[index];
    }
    return null;
  }
}
