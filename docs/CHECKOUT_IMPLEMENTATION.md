# Checkout con Recurrente - Implementación en Flutter

## 📋 Descripción

Sistema de checkout integrado con Recurrente para procesar pagos de forma segura en la aplicación móvil. El flujo es similar al de la tienda web y utiliza un WebView embebido para mostrar el formulario de pago de Recurrente.

## 🏗️ Arquitectura

### Componentes Principales

#### 1. **CheckoutService** (`lib/services/checkout_service.dart`)
Servicio para comunicarse con la API del backend y gestionar sesiones de checkout.

**Métodos principales:**
- `initializeCheckoutSession()` - Crea una sesión de checkout en Recurrente
- `verifyCheckoutStatus()` - Verifica si una orden fue creada después del pago

**Modelos:**
- `CheckoutRequest` - Datos para inicializar el checkout
- `CartItem` - Item del carrito
- `CheckoutSessionData` - Respuesta con datos de la sesión

#### 2. **ConnectivityService** (`lib/services/connectivity_service.dart`)
Validar conexión a internet antes de proceder con el checkout.

**Métodos principales:**
- `hasInternetConnection()` - Verifica si hay conexión activa
- `getConnectionType()` - Obtiene el tipo de conexión (WiFi, Mobile, etc.)
- `onConnectivityChanged()` - Stream para monitorear cambios

#### 3. **CheckoutScreen** (`lib/screens/checkout_screen.dart`)
Pantalla con 2 pasos para el checkout:

**Step 1: Información de Envío**
- Formulario para datos del cliente (nombre, email, teléfono)
- Selección de método de envío (pickup o delivery)
- Si es delivery: dirección, ciudad, barrio
- Validación de campos
- Verificación de conectividad antes de proceder

**Step 2: Pago**
- WebView embebido con el formulario de Recurrente
- Manejo de eventos de pago (éxito, cancelación, error)
- Verificación de orden creada

#### 4. **CheckoutWebviewScreen** (`lib/screens/checkout_webview_screen.dart`)
WebView que embebe el formulario de Recurrente.

**Características:**
- Carga del HTML de Recurrente en un iframe nativo
- Escucha de eventos postMessage desde el iframe
- Detección de URLs de redirección (success/cancel)
- Procesamiento automático de confirmación de pago
- Inyección de JavaScript para comunicación

#### 5. **OrderConfirmationScreen** (`lib/screens/order_confirmation_screen.dart`)
Pantalla de confirmación después de un pago exitoso.

Muestra:
- Número de orden
- Datos del cliente
- Método de envío
- Total pagado
- Próximos pasos

## 🚀 Flujo de Pago Completo

```
1. Usuario en Carrito
    ↓
2. Presiona "Proceder a Pago"
    ↓
3. CheckoutScreen - Step 1 (Información)
    ├─ Completa nombre, email, teléfono
    ├─ Selecciona método de envío
    └─ Verifica conexión a internet
    ↓
4. Presiona "Continuar al Pago"
    ├─ Valida campos Step 1
    ├─ Verifica conectividad
    └─ POST /shop/cart/initialize-checkout
    ↓
5. CheckoutScreen - Step 2 (Pago)
    └─ Muestra CheckoutWebviewScreen
    ↓
6. CheckoutWebviewScreen
    ├─ Carga URL de Recurrente
    ├─ Usuario completa tarjeta
    └─ Usuario presiona "Pagar"
    ↓
7. Recurrente procesa pago
    ├─ Envía evento al WebView (postMessage)
    ├─ Webhook notifica al backend
    └─ Backend crea orden
    ↓
8. WebView detecta evento de éxito
    ├─ Verifica orden con backend
    └─ Muestra OrderConfirmationScreen
    ↓
9. OrderConfirmationScreen
    └─ Muestra confirmación y retorna al inicio
```

## 📦 Dependencias Agregadas

### En `pubspec.yaml`:
```yaml
dependencies:
  flutter_inappwebview: ^6.0.0  # WebView nativo
  connectivity_plus: ^6.0.0      # Verificación de conectividad
```

### Instalación:
```bash
flutter pub get
```

## ⚙️ Configuración Requerida

### 1. Variables de Entorno (`.env`)
La aplicación utiliza `API_URL` del archivo `.env`:
```
API_URL=http://localhost:8000/api
```

### 2. Endpoints API Necesarios

**POST `/shop/cart/initialize-checkout`**
- Crea sesión de checkout en Recurrente
- Request:
  ```json
  {
    "buyer_name": "Juan Perez",
    "buyer_email": "juan@example.com",
    "buyer_phone": "71234567",
    "shipping_method": "delivery",
    "shipping_address": "Dirección completa",
    "shipping_city": "Guatemala",
    "shipping_neighborhood": "Zona 1",
    "items": [
      {
        "product_id": 1,
        "product_size_id": 5,
        "quantity": 2,
        "customization_text": "Texto personalizado"
      }
    ]
  }
  ```
- Response:
  ```json
  {
    "success": true,
    "data": {
      "session_id": "ch_xxx",
      "checkout_url": "https://checkout.recurrente.com/...",
      "amount": 250.00,
      "created_at": "2024-01-29T10:30:00Z"
    }
  }
  ```

**GET `/shop/orders/latest?email=usuario@example.com`**
- Obtiene la última orden creada para un email
- Response:
  ```json
  {
    "success": true,
    "data": {
      "order_id": "ORD-2024-000001",
      "total": 250.00,
      "shipping_method": "delivery",
      "status": "pending"
    }
  }
  ```

**Webhook: POST `/webhooks/recurrente`**
- Recurrente notifica al backend cuando se completa el pago
- Debe crear la orden automáticamente

### 3. Configuración de Recurrente en Backend

El backend ya tiene configurado:
- `config('services.recurrente.api_url')`
- `config('services.recurrente.public_key')`
- `config('services.recurrente.secret_key')`

### 4. HTTPS y Seguridad

⚠️ **IMPORTANTE**: 
- En producción, el `checkout_url` DEBE ser HTTPS
- Flutter WebView rechaza contenido inseguro
- El API debe estar disponible vía HTTPS
- Los datos de la tarjeta NO se transmiten por la app (van directamente a Recurrente)

## 🔄 Flujo de Conectividad

### Verificación de Internet

```dart
// Antes de proceder al pago
final connectivityService = ConnectivityService();
final hasInternet = await connectivityService.hasInternetConnection();

if (!hasInternet) {
  // Mostrar error
  showSnackBar('Se requiere conexión a internet para completar el pago');
  return;
}
```

### Manejo de Desconexiones

Si el usuario pierde internet durante:

1. **Creación de sesión**: Se muestra error y vuelve a Step 1
2. **Pago en WebView**: WebView muestra error (intenta reconectar automáticamente)
3. **Verificación de orden**: Reintenta automáticamente

## 🧪 Testing Manual

### 1. Test con Pickup (Envío Gratis)
```
Nombre: Test User
Email: test@example.com
Teléfono: 71234567
Envío: Recoger en tienda
→ Total: Q100.00 (sin envío)
```

### 2. Test con Delivery
```
Nombre: Test User
Email: test@example.com
Teléfono: 71234567
Envío: Entrega a Domicilio
Dirección: Dirección test
Ciudad: Guatemala
→ Total: Q145.00 (incluyendo Q45 de envío)
```

### 3. Información de Prueba de Recurrente
```
Tarjeta de Prueba: 4111111111111111
Expiración: 12/25
CVC: 123
Nombre: TEST USER
```

## 📱 Screenshots esperados

### Step 1: Información de Envío
- Header con "Checkout - Paso 1"
- Campos: Nombre, Email, Teléfono
- Radio buttons para Pickup/Delivery
- Campos condicionales para Delivery
- Resumen de compra
- Botones: "Continuar al Pago" y "Volver al Carrito"

### Step 2: Pago
- Loading mientras se crea sesión
- WebView con formulario de Recurrente embebido
- O error si no se pudo crear sesión

### Confirmación
- Ícono de éxito (check verde)
- Número de orden
- Datos de envío
- Total pagado
- Botones: "Volver al Inicio" y "Ver Número de Orden"

## 🐛 Solución de Problemas

### Error: "No se encontró el contenedor #embedded-checkout"
**Causa**: El WebView no se renderizó correctamente
**Solución**: Verificar que `currentStep == 2` antes de renderizar WebView

### Error: "Timeout en API"
**Causa**: API no responde o está lenta
**Solución**: Aumentar timeout en `CheckoutService` (actualmente 30 segundos)

### Error: "WebView rechaza contenido inseguro"
**Causa**: URL no es HTTPS
**Solución**: Asegurar que el `checkout_url` sea HTTPS en producción

### No se detecta evento de pago
**Causa**: Recurrente no envía postMessage correctamente
**Solución**: Verificar configuración de Recurrente y revisar logs

### Orden no se encuentra después del pago
**Causa**: El webhook aún no ha procesado la orden
**Solución**: El servicio reintenta automáticamente durante 15 segundos

## 📝 Notas de Desarrollo

- El modelo `CartItemData` es similar a `CartItem` del servicio pero optimizado para el checkout
- `ConnectivityService` es singleton para evitar múltiples listeners
- Los errores se muestran como SnackBars al usuario
- El backend es responsable de crear la orden vía webhook
- La app solo verifica que la orden fue creada

## 🔐 Seguridad

✅ **Implementado:**
- Validación de campos en Step 1
- Verificación de conectividad
- Los datos de tarjeta NO tocan el servidor de la app
- HTTPS para comunicación con API (en producción)
- JWT para autenticación (si es requerido por API)

❌ **NO implementado aquí** (responsabilidad del backend):
- Rate limiting en endpoints
- Validación PCI DSS adicional
- Logs de auditoría

## 📚 Referencias

- [Documentación de Recurrente](https://docs.recurrente.com)
- [flutter_inappwebview](https://pub.dev/packages/flutter_inappwebview)
- [connectivity_plus](https://pub.dev/packages/connectivity_plus)
- [CheckoutView.vue](../utammys-store/src/views/CheckoutView.vue) - Implementación web equivalente

## ✅ Checklist de Implementación

- [x] Crear servicios (Checkout, Connectivity)
- [x] Crear pantalla de checkout con 2 pasos
- [x] Integrar WebView con Recurrente
- [x] Validación de conectividad
- [x] Manejo de eventos de pago
- [x] Pantalla de confirmación
- [x] Integración con carrito
- [ ] Testing en dispositivo real
- [ ] Testing con pagos reales en Recurrente
- [ ] Publicación en App Store/Play Store
