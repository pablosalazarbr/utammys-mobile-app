import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/services/connectivity_service.dart';
import 'package:utammys_mobile_app/services/checkout_service.dart';
import 'package:utammys_mobile_app/models/product_model.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';
import 'checkout_webview_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final List<CartItem> cartItems;
  final double cartTotal;
  final int? clientId;

  const CheckoutScreen({
    super.key,
    required this.cartItems,
    required this.cartTotal,
    this.clientId,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  // Servicios
  final ConnectivityService _connectivityService = ConnectivityService();
  final CheckoutService _checkoutService = CheckoutService();

  // Estados
  int _currentStep = 1;
  bool _isProcessing = false;
  String _errorMessage = '';

  // Form Step 1: Información de envío
  late TextEditingController _fullNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  late TextEditingController _cityController;
  late TextEditingController _neighborhoodController;

  String _shippingMethod = 'pickup'; // 'pickup' o 'delivery'

  // Datos de la sesión de checkout
  CheckoutSessionData? _checkoutSessionData;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
  }

  void _initializeControllers() {
    _fullNameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _addressController = TextEditingController();
    _cityController = TextEditingController();
    _neighborhoodController = TextEditingController();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _neighborhoodController.dispose();
    super.dispose();
  }

  /// Validar Step 1
  bool _validateStep1() {
    if (_fullNameController.text.isEmpty) {
      _showError('Por favor ingresa tu nombre completo');
      return false;
    }
    if (_emailController.text.isEmpty ||
        !_emailController.text.contains('@')) {
      _showError('Por favor ingresa un email válido');
      return false;
    }
    if (_phoneController.text.isEmpty) {
      _showError('Por favor ingresa tu teléfono');
      return false;
    }
    if (_shippingMethod == 'delivery') {
      if (_addressController.text.isEmpty) {
        _showError('Por favor ingresa tu dirección');
        return false;
      }
      if (_cityController.text.isEmpty) {
        _showError('Por favor ingresa tu ciudad');
        return false;
      }
    }
    return true;
  }

  /// Ir al siguiente paso
  Future<void> _goToNextStep() async {
    if (!_validateStep1()) return;

    // Verificar conectividad ANTES de proceder
    final hasInternet = await _connectivityService.hasInternetConnection();
    if (!hasInternet) {
      _showError(
        '⚠️ Sin conexión a internet\n\n'
        'Se requiere conexión activa para completar el pago con Recurrente.',
      );
      return;
    }

    setState(() => _currentStep = 2);
    _initializeCheckoutSession();
  }

  /// Inicializar sesión de checkout en Recurrente
  Future<void> _initializeCheckoutSession() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = '';
    });

    try {
      // Construir items del carrito
      final items = widget.cartItems.map((item) {
        return CheckoutCartItem(
          productId: item.product.id,
          productSizeId: item.size?.id ?? item.product.id,
          quantity: item.quantity,
          customizationText: item.customizationText,
        );
      }).toList();

      // Construir request de checkout
      final checkoutRequest = CheckoutRequest(
        buyerName: _fullNameController.text,
        buyerEmail: _emailController.text,
        buyerPhone: _phoneController.text,
        shippingMethod: _shippingMethod,
        shippingAddress: _shippingMethod == 'delivery'
            ? _addressController.text
            : null,
        shippingCity:
            _shippingMethod == 'delivery' ? _cityController.text : null,
        shippingNeighborhood: _neighborhoodController.text.isNotEmpty
            ? _neighborhoodController.text
            : null,
        items: items,
      );

      // Llamar al servicio
      final sessionData =
          await _checkoutService.initializeCheckoutSession(checkoutRequest);

      setState(() {
        _checkoutSessionData = sessionData;
        _isProcessing = false;
      });

      print('[CheckoutScreen] ✅ Sesión creada: ${sessionData.sessionId}');
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isProcessing = false;
        _currentStep = 1;
      });
      _showError('Error creando sesión de pago:\n\n$e');
    }
  }

  /// Mostrar error al usuario
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 5),
      ),
    );
  }

  /// Construir Step 1: Información de envío
  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Text(
              'Información de Envío',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 24),

            // Información Personal
            const Text(
              'Información Personal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Nombre Completo
            TextField(
              controller: _fullNameController,
              decoration: InputDecoration(
                hintText: 'Nombre Completo',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Email
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Teléfono
            TextField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: 'Teléfono',
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Método de Envío
            const Text(
              'Método de Envío',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),

            // Radio buttons para método de envío
            RadioListTile<String>(
              title: const Text('Recoger en tienda'),
              subtitle: const Text('Gratis'),
              value: 'pickup',
              groupValue: _shippingMethod,
              onChanged: (value) {
                setState(() => _shippingMethod = value ?? 'pickup');
              },
              contentPadding: EdgeInsets.zero,
              activeColor: TammysColors.primary,
            ),
            const SizedBox(height: 8),
            RadioListTile<String>(
              title: const Text('Entrega a domicilio'),
              subtitle: const Text('Q45.00'),
              value: 'delivery',
              groupValue: _shippingMethod,
              onChanged: (value) {
                setState(() => _shippingMethod = value ?? 'delivery');
              },
              contentPadding: EdgeInsets.zero,
              activeColor: TammysColors.primary,
            ),

            // Campos condicionales para delivery
            if (_shippingMethod == 'delivery') ...[
              const SizedBox(height: 20),
              const Text(
                'Dirección de Entrega',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Dirección
              TextField(
                controller: _addressController,
                minLines: 2,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Dirección completa',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Ciudad
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'Ciudad',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Barrio/Zona (opcional)
              TextField(
                controller: _neighborhoodController,
                decoration: InputDecoration(
                  hintText: 'Barrio/Zona (opcional)',
                  hintStyle: TextStyle(color: Colors.grey[400]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey[300]!),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Método de Entrega
              const Text(
                'Método de Entrega',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Opción Retiro en Tienda
              GestureDetector(
                onTap: () {
                  setState(() {
                    _shippingMethod = 'pickup';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _shippingMethod == 'pickup' ? const Color(0xFF8B4513) : Colors.grey[300]!,
                      width: _shippingMethod == 'pickup' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _shippingMethod == 'pickup' ? const Color(0xFF8B4513).withOpacity(0.05) : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _shippingMethod == 'pickup' ? const Color(0xFF8B4513) : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _shippingMethod == 'pickup'
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Retiro en Tienda',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Recoge en nuestras instalaciones',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'GRATIS',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Opción Entrega a Domicilio
              GestureDetector(
                onTap: () {
                  setState(() {
                    _shippingMethod = 'delivery';
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _shippingMethod == 'delivery' ? const Color(0xFF8B4513) : Colors.grey[300]!,
                      width: _shippingMethod == 'delivery' ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    color: _shippingMethod == 'delivery' ? const Color(0xFF8B4513).withOpacity(0.05) : Colors.white,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _shippingMethod == 'delivery' ? const Color(0xFF8B4513) : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: _shippingMethod == 'delivery'
                            ? Center(
                                child: Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF8B4513),
                                  ),
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Entrega a Domicilio',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Te lo llevamos a tu dirección',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        'Q45.00',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF8B4513),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 32),

            // Resumen de orden
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de Compra',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Subtotal (${widget.cartItems.length} items)',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      Text(
                        'Q${widget.cartTotal.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (_shippingMethod == 'delivery') ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Envío',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Text(
                          'Q45.00',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        'Q${(_shippingMethod == 'delivery' ? widget.cartTotal + 45.0 : widget.cartTotal).toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: TammysColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botones
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TammysColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _goToNextStep,
                child: const Text(
                  'Continuar al Pago',
                  style: TextStyle(
                    color: Colors.white,
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
                  side: const BorderSide(color: TammysColors.primary),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Volver al Carrito',
                  style: TextStyle(
                    color: TammysColors.primary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construir Step 2: Formulario de pago embebido
  Widget _buildStep2() {
    if (_isProcessing) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation(TammysColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Preparando formulario de pago...',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: TammysColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _currentStep = 1;
                    _errorMessage = '';
                  });
                },
                child: const Text(
                  'Volver a Información',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    if (_checkoutSessionData == null) {
      return Center(
        child: Text(
          'Error: No se pudo cargar la sesión de pago',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      );
    }

    // Mostrar WebView con Recurrente
    return CheckoutWebviewScreen(
      checkoutUrl: _checkoutSessionData!.checkoutUrl,
      checkoutSessionId: _checkoutSessionData!.sessionId,
      buyerEmail: _emailController.text,
      buyerName: _fullNameController.text,
      onPaymentSuccess: (orderData) {
        // Navegar a pantalla de confirmación
        Navigator.pop(context, orderData);
      },
      onPaymentCancel: () {
        _showError('Pago cancelado');
        setState(() => _currentStep = 1);
      },
      onPaymentError: (error) {
        _showError('Error en el pago: $error');
        setState(() => _currentStep = 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout - Paso $_currentStep',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _currentStep == 1 ? _buildStep1() : _buildStep2(),
    );
  }
}
