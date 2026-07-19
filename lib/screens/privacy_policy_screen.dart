import 'package:flutter/material.dart';
import 'package:utammys_mobile_app/widgets/ui_components.dart';

/// Política de Privacidad (versión nativa, mismo contenido que uniformestamys.com/privacidad).
/// Se mantiene dentro de la app para que esté siempre disponible (sin depender de red)
/// y para cumplir con los requisitos de la App Store.
class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TammysColors.background,
      appBar: AppBar(
        backgroundColor: TammysColors.background,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.05),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: TammysColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Política de Privacidad',
          style: TextStyle(
            color: TammysColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Última actualización: julio 2026',
              style: TextStyle(
                fontSize: 12,
                color: TammysColors.textSecondary,
                letterSpacing: 1,
              ),
            ),
            SizedBox(height: 24),
            _Section(
              title: '1. Introducción',
              body:
                  'En Uniformes Tamys ("nosotros", "la Compañía") nos comprometemos a proteger tu '
                  'privacidad. Esta política explica cómo recopilamos, utilizamos y protegemos tu '
                  'información cuando usas nuestro sitio web, nuestra aplicación móvil (iOS y Android) '
                  'y nuestra tienda en línea. Aplica por igual a todos estos canales.',
            ),
            _Section(
              title: '2. Información que Recopilamos',
              bullets: [
                'Información de contacto: nombre, correo electrónico, teléfono y dirección al realizar una compra.',
                'Información de compra: productos, cantidades, personalizaciones, dirección y método de entrega.',
                'Información institucional: datos relevantes si compras como parte de un colegio o empresa.',
              ],
            ),
            _Section(
              title: '3. Uso de la Información',
              bullets: [
                'Procesar y entregar tus órdenes.',
                'Comunicarnos sobre tus compras y brindar atención al cliente.',
                'Mejorar nuestros productos, servicios y tu experiencia.',
                'Cumplir con obligaciones legales y prevenir fraude.',
              ],
            ),
            _Section(
              title: '4. Pagos',
              body:
                  'Los pagos son procesados de forma segura por Recurrente. Los datos de tu tarjeta se '
                  'ingresan directamente en su formulario cifrado (SSL/TLS) y nunca son almacenados por '
                  'nosotros.',
            ),
            _Section(
              title: '5. Compartición de Información',
              body:
                  'No vendemos ni alquilamos tu información. Solo la compartimos con proveedores que nos '
                  'ayudan a operar (como el procesador de pagos), cuando la ley lo requiere, o con la '
                  'institución correspondiente si compras a través de ella.',
            ),
            _Section(
              title: '6. Tus Derechos',
              body:
                  'Puedes acceder, corregir o solicitar la eliminación de tu información personal, y optar '
                  'por no recibir comunicaciones de marketing, escribiéndonos a info@uniformestamys.com.',
            ),
            _Section(
              title: '7. Contacto',
              body:
                  'Email: info@uniformestamys.com\n'
                  'Teléfono: (502) 2318-1032 / (502) 2318-1033\n'
                  'WhatsApp: (502) 3003-9946\n'
                  'Dirección: Km. 14.5, Carretera a El Salvador, C.C. Gran Plaza, bodega 116, Guatemala.',
            ),
          ],
        ),
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final String? body;
  final List<String>? bullets;

  const _Section({required this.title, this.body, this.bullets});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: TammysColors.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          if (body != null)
            Text(
              body!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: TammysColors.textSecondary,
              ),
            ),
          if (bullets != null)
            ...bullets!.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('•  ',
                        style: TextStyle(
                            fontSize: 14, color: TammysColors.textSecondary)),
                    Expanded(
                      child: Text(
                        b,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.6,
                          color: TammysColors.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
