import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/helpers/image_url_helper.dart';
import 'package:utammys_mobile_app/models/product_model.dart';
import 'package:utammys_mobile_app/services/cart_service.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';
import 'package:utammys_mobile_app/theme/app_theme.dart';
import 'package:utammys_mobile_app/services/orders_service.dart';
import 'checkout_screen.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  late CartService _cartService;

  @override
  void initState() {
    super.initState();
    _cartService = CartService();
  }

  @override
  Widget build(BuildContext context) {
    final cartItems = _cartService.cartItems;
    final subtotal = _calculateSubtotal(cartItems);
    final total = subtotal;

    return Scaffold(
      backgroundColor: context.tScaffold,
      appBar: AppBar(
        backgroundColor: context.tScaffold,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: context.tTextPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: cartItems.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Tu bolsa está vacía',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TammysColors.primary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Continuar comprando',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            )
          : SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Items Section
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tus Artículos',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 12),
                            ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: cartItems.length,
                              itemBuilder: (context, index) {
                                final item = cartItems[index];
                                return CartItemWidget(
                                  item: item,
                                  onQuantityChanged: (newQuantity) {
                                    setState(() {
                                      if (newQuantity <= 0) {
                                        _cartService.removeItem(index);
                                      } else {
                                        _cartService.updateItemQuantity(index, newQuantity);
                                      }
                                    });
                                  },
                                  onRemove: () {
                                    setState(() {
                                      _cartService.removeItem(index);
                                    });
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),

                      // Order Summary Section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Container(
                          decoration: BoxDecoration(
                            color: context.tSurface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: context.tDivider,
                              width: 1,
                            ),
                          ),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Resumen de Pedido',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 16),
                              SummaryRow(
                                label: 'Subtotal',
                                value: 'Q${subtotal.toStringAsFixed(2)}',
                              ),
                              const SizedBox(height: 16),
                              Divider(color: TammysColors.divider, thickness: 1),
                              const SizedBox(height: 12),
                              SummaryRow(
                                label: 'Total',
                                value: 'Q${total.toStringAsFixed(2)}',
                                emphasized: true,
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
                
      bottomNavigationBar: cartItems.isEmpty
          ? null
          : _buildCheckoutBar(context, subtotal),
    );
  }

  Widget _buildCheckoutBar(BuildContext context, double subtotal) {
    return Container(
      decoration: BoxDecoration(
        color: context.tSurface,
        border: Border(
          top: BorderSide(color: context.tDivider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TammysPrimaryButton(
            label: 'Proceder a Pago',
            icon: Icons.arrow_forward,
            onPressed: () {
              if (_cartService.cartItems.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tu bolsa está vacía'),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              // Navegar a checkout
              Navigator.push(
                context,
                MaterialPageRoute(
                  settings: const RouteSettings(name: 'checkout'),
                  builder: (context) => CheckoutScreen(
                    cartItems: _cartService.cartItems,
                    cartTotal: subtotal,
                  ),
                ),
              ).then((orderData) {
                if (orderData != null && orderData is Map<String, dynamic>) {
                  // Vaciar el carrito tras la compra exitosa
                  setState(() {
                    _cartService.clearCart();
                  });
                  // Guardar el pedido en "Mis Pedidos" para seguimiento
                  OrdersService.saveFromCheckout(orderData);
                  // Mostrar pantalla de confirmación
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      settings:
                          const RouteSettings(name: 'order-confirmation'),
                      builder: (context) => OrderConfirmationScreen(
                        orderData: orderData,
                        buyerName:
                            orderData['buyer_name'] as String? ?? 'Cliente',
                      ),
                    ),
                  );
                }
              });
            },
          ),
        ),
      ),
    );
  }

  double _calculateSubtotal(List<CartItem> cartItems) {
    return cartItems.fold(
      0.0,
      (total, item) => total + item.getTotalPrice(),
    );
  }
}

class CartItemWidget extends StatelessWidget {
  final CartItem item;
  final Function(int) onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemWidget({
    super.key,
    required this.item,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: context.tSurface,
        border: Border.all(color: context.tBorder),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: item.product.media != null && item.product.media!.isNotEmpty
                ? Image.network(
                    ImageUrlHelper.buildImageUrl(item.product.media!.first),
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.image_not_supported,
                        color: Colors.grey[400],
                      );
                    },
                  )
                : Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          // Información del producto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: context.tTextPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (item.size != null)
                  Text(
                    'Talla: ${item.size!.size}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                const SizedBox(height: 8),
                if (item.customizationText != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Personalización: ${item.customizationText}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.blue[700],
                          ),
                        ),
                        Text(
                          '+Q${item.customizationCost.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.blue[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                Text(
                  'Q${(item.size?.price ?? item.product.getMinPrice() ?? 0.0).toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: context.tTextPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Controles de cantidad y eliminar
          Column(
            children: [
              // Cantidad
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: item.quantity > 1
                          ? () => onQuantityChanged(item.quantity - 1)
                          : null,
                      icon: const Icon(Icons.remove, size: 18),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                    SizedBox(
                      width: 24,
                      child: Center(
                        child: Text(
                          '${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => onQuantityChanged(item.quantity + 1),
                      icon: const Icon(Icons.add, size: 18),
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                      padding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              // Botón eliminar
              IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline, color: Colors.red, size: 18),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
