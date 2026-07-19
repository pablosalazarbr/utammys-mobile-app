import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/theme/app_theme.dart';

class OrderConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;
  final String buyerName;

  const OrderConfirmationScreen({
    super.key,
    required this.orderData,
    required this.buyerName,
  });

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState extends State<OrderConfirmationScreen> {
  @override
  Widget build(BuildContext context) {
    final orderData = widget.orderData;
    final orderId = orderData['order_id'] ?? 'N/A';
    final total = orderData['total'] ?? 0.0;
    final shippingMethod =
        orderData['shipping_method'] ?? 'pickup';

    return Scaffold(
      backgroundColor: context.tScaffold,
      appBar: AppBar(
        backgroundColor: context.tScaffold,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Confirmación de Orden',
          style: TextStyle(
            color: context.tTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 48,
                  color: Colors.green[600],
                ),
              ),

              const SizedBox(height: 24),

              // Success Message
              Text(
                '¡Gracias por tu Compra!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: context.tTextPrimary,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'Tu pago fue procesado exitosamente',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: context.tTextSecondary,
                ),
              ),

              const SizedBox(height: 32),

              // Order Details Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(color: context.tBorder),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Número de Orden
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Número de Orden',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.tTextSecondary,
                          ),
                        ),
                        Text(
                          orderId.toString(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.tTextPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Cliente
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Cliente',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.tTextSecondary,
                          ),
                        ),
                        Text(
                          widget.buyerName,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.tTextPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Método de Envío
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Envío',
                          style: TextStyle(
                            fontSize: 13,
                            color: context.tTextSecondary,
                          ),
                        ),
                        Text(
                          shippingMethod == 'delivery'
                              ? 'Entrega a Domicilio'
                              : 'Recoger en Tienda',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.tTextPrimary,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(),
                    const SizedBox(height: 12),

                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: context.tTextPrimary,
                          ),
                        ),
                        Text(
                          'Q${(total is double ? total : double.parse(total.toString())).toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: context.tTextPrimary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Info Box
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[100]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Próximos Pasos',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      shippingMethod == 'delivery'
                          ? 'Tu pedido será entregado en la dirección registrada. '
                              'Recibirás una confirmación por email con los detalles de envío.'
                          : 'Tu pedido está listo para recoger en nuestra tienda. '
                              'Te contactaremos cuando esté disponible.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Buttons
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Navegar a Home/Carrito
                    Navigator.of(context)
                        .popUntil((route) => route.isFirst);
                  },
                  child: Text(
                    'Volver al Inicio',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: context.tBrand),
                  ),
                  onPressed: () {
                    // Compartir número de orden
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Tu Número de Orden'),
                        content: Text(
                          orderId.toString(),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text(
                    'Ver Número de Orden',
                    style: TextStyle(
                      color: context.tBrand,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
