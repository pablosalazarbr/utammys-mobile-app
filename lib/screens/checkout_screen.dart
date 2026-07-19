import 'package:utammys_mobile_app/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/services/connectivity_service.dart';
import 'package:utammys_mobile_app/services/checkout_service.dart';
import 'package:utammys_mobile_app/models/product_model.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';
import 'package:utammys_mobile_app/theme/app_theme.dart';
import 'checkout_webview_screen.dart';
import 'privacy_policy_screen.dart';

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
  // Costo fijo de envío a domicilio (Q). TODO: obtener del backend.
  static const double _kDeliveryFee = 45.0;

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

      logDebug('[CheckoutScreen] ✅ Sesión creada: ${sessionData.sessionId}');
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
    final sectionLabelStyle = TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: context.tTextPrimary,
    );
    final total = _shippingMethod == 'delivery'
        ? widget.cartTotal + _kDeliveryFee
        : widget.cartTotal;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Información de Envío',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: context.tTextPrimary,
              ),
            ),
            const SizedBox(height: 24),

            // Información Personal
            Text('Información Personal', style: sectionLabelStyle),
            const SizedBox(height: 12),
            TammysTextField(
              controller: _fullNameController,
              hint: 'Nombre Completo',
            ),
            const SizedBox(height: 12),
            TammysTextField(
              controller: _emailController,
              hint: 'Email',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TammysTextField(
              controller: _phoneController,
              hint: 'Teléfono',
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 24),

            // Método de Envío (selector único)
            Text('Método de Envío', style: sectionLabelStyle),
            const SizedBox(height: 12),
            ShippingOptionTile(
              title: 'Retiro en Tienda',
              subtitle: 'Recoge en nuestras instalaciones',
              trailingLabel: 'GRATIS',
              selected: _shippingMethod == 'pickup',
              onTap: () => setState(() => _shippingMethod = 'pickup'),
            ),
            const SizedBox(height: 12),
            ShippingOptionTile(
              title: 'Entrega a Domicilio',
              subtitle: 'Te lo llevamos a tu dirección',
              trailingLabel: 'Q${_kDeliveryFee.toStringAsFixed(2)}',
              selected: _shippingMethod == 'delivery',
              onTap: () => setState(() => _shippingMethod = 'delivery'),
            ),

            // Campos condicionales para delivery
            if (_shippingMethod == 'delivery') ...[
              const SizedBox(height: 20),
              Text('Dirección de Entrega', style: sectionLabelStyle),
              const SizedBox(height: 12),
              TammysTextField(
                controller: _addressController,
                hint: 'Dirección completa',
                minLines: 2,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TammysTextField(
                controller: _cityController,
                hint: 'Ciudad',
              ),
              const SizedBox(height: 12),
              TammysTextField(
                controller: _neighborhoodController,
                hint: 'Barrio/Zona (opcional)',
              ),
            ],

            const SizedBox(height: 32),

            // Resumen de orden
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: context.tCard,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen de Compra', style: sectionLabelStyle),
                  const SizedBox(height: 12),
                  SummaryRow(
                    label: 'Subtotal (${widget.cartItems.length} items)',
                    value: 'Q${widget.cartTotal.toStringAsFixed(2)}',
                  ),
                  if (_shippingMethod == 'delivery') ...[
                    const SizedBox(height: 8),
                    SummaryRow(
                      label: 'Envío',
                      value: 'Q${_kDeliveryFee.toStringAsFixed(2)}',
                    ),
                  ],
                  const SizedBox(height: 8),
                  const Divider(),
                  const SizedBox(height: 8),
                  SummaryRow(
                    label: 'Total',
                    value: 'Q${total.toStringAsFixed(2)}',
                    emphasized: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Botones
            TammysPrimaryButton(
              label: 'Continuar al Pago',
              onPressed: _goToNextStep,
            ),
            const SizedBox(height: 12),
            TammysSecondaryButton(
              label: 'Volver a la Bolsa',
              onPressed: () => Navigator.pop(context),
            ),
            const SizedBox(height: 16),
            // Aviso de privacidad + enlace a la política
            Center(
              child: Text.rich(
                TextSpan(
                  text: 'Al continuar aceptas nuestra ',
                  style: TextStyle(
                    fontSize: 12,
                    color: context.tTextSecondary,
                  ),
                  children: [
                    WidgetSpan(
                      alignment: PlaceholderAlignment.middle,
                      child: GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            settings: const RouteSettings(name: 'privacy'),
                            builder: (context) => const PrivacyPolicyScreen(),
                          ),
                        ),
                        child: Text(
                          'Política de Privacidad',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: context.tTextPrimary,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
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
        // Adjuntar el nombre real del comprador y navegar a confirmación
        Navigator.pop(context, {
          ...orderData,
          'buyer_name': _fullNameController.text,
        });
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
      backgroundColor: context.tScaffold,
      appBar: AppBar(
        backgroundColor: context.tScaffold,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.tTextPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Checkout - Paso $_currentStep',
          style: TextStyle(
            color: context.tTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _currentStep == 1 ? _buildStep1() : _buildStep2(),
    );
  }
}
