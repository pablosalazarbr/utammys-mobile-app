import 'package:utammys_mobile_app/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';
import 'package:utammys_mobile_app/services/checkout_service.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

class CheckoutWebviewScreen extends StatefulWidget {
  final String checkoutUrl;
  final String checkoutSessionId;
  final String buyerEmail;
  final String buyerName;
  final Function(Map<String, dynamic>) onPaymentSuccess;
  final Function() onPaymentCancel;
  final Function(String) onPaymentError;

  const CheckoutWebviewScreen({
    super.key,
    required this.checkoutUrl,
    required this.checkoutSessionId,
    required this.buyerEmail,
    required this.buyerName,
    required this.onPaymentSuccess,
    required this.onPaymentCancel,
    required this.onPaymentError,
  });

  @override
  State<CheckoutWebviewScreen> createState() => _CheckoutWebviewScreenState();
}

class _CheckoutWebviewScreenState extends State<CheckoutWebviewScreen> {
  late InAppWebViewController _webViewController;
  bool _isLoading = true;
  String _errorMessage = '';
  bool _isProcessing = false;

  final CheckoutService _checkoutService = CheckoutService();

  @override
  void initState() {
    super.initState();
    _setupWebView();
  }

  void _setupWebView() {
    logDebug('[CheckoutWebview] Inicializando WebView');
    logDebug('[CheckoutWebview] Checkout URL: ${widget.checkoutUrl}');
  }

  /// Manejar eventos de pago desde Recurrente (postMessage)
  Future<void> _handlePaymentEvent(dynamic message) async {
    logDebug('[CheckoutWebview] Evento recibido: $message');

    try {
      Map<String, dynamic> data = {};

      if (message is String) {
        data = jsonDecode(message);
      } else if (message is Map) {
        data = Map<String, dynamic>.from(message);
      }

      final type = data['type'] ?? data['status'];
      logDebug('[CheckoutWebview] Tipo de evento: $type');

      // Pago exitoso
      if (type == 'payment:success' || type == 'success') {
        logDebug('[CheckoutWebview] ✅ Pago exitoso detectado');
        await _handlePaymentSuccess(data);
        return;
      }

      // Pago cancelado
      if (type == 'payment:cancel' || type == 'cancel') {
        logDebug('[CheckoutWebview] ❌ Pago cancelado');
        widget.onPaymentCancel();
        return;
      }

      // Error en el pago
      if (type == 'payment:error' || type == 'error') {
        final error = data['error'] ?? 'Error desconocido';
        logDebug('[CheckoutWebview] ⚠️ Error en pago: $error');
        widget.onPaymentError(error.toString());
        return;
      }
    } catch (e) {
      logDebug('[CheckoutWebview] Error procesando evento: $e');
    }
  }

  /// Procesar pago exitoso
  Future<void> _handlePaymentSuccess(Map<String, dynamic> data) async {
    setState(() => _isProcessing = true);

    try {
      logDebug('[CheckoutWebview] Verificando orden con el backend...');

      // Esperar a que el webhook de Recurrente procese la orden
      // Hacer polling hasta que se cree
      await Future.delayed(const Duration(seconds: 2));

      final orderData = await _checkoutService.verifyCheckoutStatus(
        checkoutId: widget.checkoutSessionId,
        email: widget.buyerEmail,
      );

      if (orderData.isNotEmpty && orderData['order_id'] != null) {
        logDebug('[CheckoutWebview] ✅ Orden verificada: ${orderData['order_id']}');
        widget.onPaymentSuccess(orderData);
      } else {
        logDebug('[CheckoutWebview] ⚠️ Orden no encontrada, pero el pago fue exitoso');
        // El pago fue exitoso aunque no encontremos la orden de inmediato
        // Mostrar un mensaje de éxito igual
        widget.onPaymentSuccess({
          'payment_status': 'completed',
          'message': 'Pago completado. Tu orden está siendo procesada.',
        });
      }
    } catch (e) {
      logDebug('[CheckoutWebview] Error verificando orden: $e');
      widget.onPaymentError(e.toString());
    } finally {
      setState(() => _isProcessing = false);
    }
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
          onPressed: () {
            _webViewController.goBack();
          },
        ),
        title: const Text(
          'Formulario de Pago',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Stack(
        children: [
          // WebView
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri(widget.checkoutUrl),
            ),
            onWebViewCreated: (controller) {
              _webViewController = controller;
              logDebug('[CheckoutWebview] WebView creado');

              // Configurar handlers para postMessage
              _webViewController.addJavaScriptHandler(
                handlerName: 'payment',
                callback: _handlePaymentEvent,
              );
            },
            onLoadStart: (controller, url) {
              logDebug('[CheckoutWebview] Cargando: $url');
              setState(() => _isLoading = true);
            },
            onLoadStop: (controller, url) {
              logDebug('[CheckoutWebview] Cargado: $url');
              setState(() => _isLoading = false);

              // Inyectar script para capturar postMessage
              _injectPaymentListener(controller);
            },
            onReceivedError: (controller, request, error) {
              logDebug('[CheckoutWebview] Error: ${error.description}');
              setState(() {
                _errorMessage = 'Error cargando formulario de pago';
              });
            },
            onProgressChanged: (controller, progress) {
              logDebug('[CheckoutWebview] Progreso: $progress%');
            },
            shouldOverrideUrlLoading:
                (controller, navigationAction) async {
              logDebug('[CheckoutWebview] URL: ${navigationAction.request.url}');

              // Detectar URLs de retorno
              final url = navigationAction.request.url.toString();

              // Success URL
              if (url.contains('/checkout/payment-processing') ||
                  url.contains('payment-processing')) {
                logDebug('[CheckoutWebview] ✅ Detectada URL de éxito');
                await _handlePaymentSuccess({
                  'status': 'success',
                  'message': 'Pago completado',
                });
                return NavigationActionPolicy.CANCEL;
              }

              // Cancel URL
              if (url.contains('/carrito') || url.contains('cart')) {
                logDebug('[CheckoutWebview] ❌ Detectada URL de cancelación');
                widget.onPaymentCancel();
                return NavigationActionPolicy.CANCEL;
              }

              return NavigationActionPolicy.ALLOW;
            },
            initialSettings: InAppWebViewSettings(
              useShouldOverrideUrlLoading: true,
              mediaPlaybackRequiresUserGesture: false,
              javaScriptEnabled: true,
              javaScriptCanOpenWindowsAutomatically: true,
            ),
          ),

          // Loading Indicator
          if (_isLoading)
            Container(
              color: Colors.black26,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(TammysColors.primary),
                ),
              ),
            ),

          // Processing Indicator (después del pago)
          if (_isProcessing)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation(TammysColors.primary),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Confirmando tu pago...',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Error Message
          if (_errorMessage.isNotEmpty)
            Container(
              color: Colors.black26,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _errorMessage,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: TammysColors.primary,
                          ),
                          onPressed: () {
                            setState(() => _errorMessage = '');
                          },
                          child: const Text(
                            'Reintentar',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Inyectar script para escuchar postMessage de Recurrente
  Future<void> _injectPaymentListener(InAppWebViewController controller) async {
    const script = '''
      (function() {
        console.log('[Recurrente] Escuchador de postMessage instalado');

        function sendToFlutter(payload) {
          try {
            if (window.flutter_inappwebview && window.flutter_inappwebview.callHandler) {
              window.flutter_inappwebview.callHandler('payment', JSON.stringify(payload));
            }
          } catch (e) {
            console.log('[Recurrente] Error enviando a Flutter:', e);
          }
        }

        window.addEventListener('message', function(event) {
          console.log('[Recurrente] Evento recibido:', event.data);
          sendToFlutter(event.data);
        }, false);

        // También escuchar directamente en Recurrente
        if (window.Recurrente) {
          console.log('[Recurrente] Objeto Recurrente disponible');
        }
      })();
    ''';

    try {
      await controller.evaluateJavascript(source: script);
      logDebug('[CheckoutWebview] Script de postMessage inyectado');
    } catch (e) {
      logDebug('[CheckoutWebview] Error inyectando script: $e');
    }
  }
}
