# Preguntas Frecuentes y Configuración - Utammys Mobile App

## ❓ Preguntas Frecuentes

### P: ¿Qué cambio debe hacerse para que funcione con mi API?

**R:** Principalmente debes asegurar que:

1. **El archivo `.env` esté correctamente configurado**:
   ```
   API_BASE_URL=http://tu-servidor.com/api
   ```

2. **Verificar que los endpoints coincidan**:
   - La app espera endpoints en `/shop/...` (públicos)
   - Asegúrate de que tu API Laravel tiene estas rutas configuradas

3. **CORS habilitado** (si accedes desde dispositivo físico o emulador):
   - En `config/cors.php`:
   ```php
   'allowed_origins' => ['*'],
   ```

### P: ¿Qué pasa si quiero agregar autenticación de usuario?

**R:** Debes:

1. Crear un `AuthService` que llame a `POST /auth/login`
2. Guardar el token en `SharedPreferences`
3. Pasar el token en headers en `ApiService`:
   ```dart
   'Authorization': 'Bearer $token',
   ```

### P: ¿Cómo cargo imágenes en la app?

**R:** Las imágenes se cargan desde URLs de la API:

```dart
// Si el campo media es un array:
final imageUrl = product.media?.first;

// O usar el método auxiliar:
final imageUrl = product.getFirstImage();

// Mostrar con Image.network:
Image.network(imageUrl, fit: BoxFit.cover)
```

### P: ¿Qué estructura debe tener mi API para que funcione?

**R:** Los modelos de la app esperan esta estructura:

**Cliente (School)**:
```json
{
  "id": 1,
  "name": "Colegio San José",
  "type": "ESCOLAR",
  "city": "Guatemala",
  "logo_url": "/images/colegios/1.png",
  "email": "contacto@colegio.com",
  "phone": "+502 1234 5678",
  "address": "Calle Principal 123",
  "country": "Guatemala",
  "contact_person": "Director",
  "tax_id": "123456789",
  "payment_terms": "30 días",
  "credit_limit": 100000.00,
  "is_active": true,
  "created_at": "2024-01-18T10:00:00Z",
  "updated_at": "2024-01-18T10:00:00Z"
}
```

**Producto**:
```json
{
  "id": 1,
  "client_id": 1,
  "category_id": 2,
  "sku": "UNIF-ESC-001",
  "name": "Uniforme Escolar Completo",
  "description": "Incluye camisa, pantalón y corbata",
  "media": [
    "/images/products/1.jpg",
    "/images/products/1-alt.jpg"
  ],
  "is_customizable": true,
  "is_active": true,
  "sizes": [
    {
      "id": 1,
      "product_id": 1,
      "size": "XS",
      "barcode": "1234567890001",
      "price": 350.00,
      "is_available": true,
      "created_at": "2024-01-18T10:00:00Z",
      "updated_at": "2024-01-18T10:00:00Z"
    }
  ],
  "created_at": "2024-01-18T10:00:00Z",
  "updated_at": "2024-01-18T10:00:00Z"
}
```

### P: ¿Qué validaciones hacer antes de enviar una orden?

**R:** En `CheckoutScreen`, asegurar:

1. **Todos los campos requeridos estén completos**
2. **Email sea válido**:
   ```dart
   RegExp(r'^[^@]+@[^@]+\.[^@]+$').hasMatch(email)
   ```
3. **Teléfono tenga formato válido**
4. **Carrito no esté vacío**

### P: ¿Cómo manejar timeouts de la API?

**R:** Agregar timeout en `ApiService`:

```dart
final response = await http.get(
  url,
  headers: {...},
).timeout(
  const Duration(seconds: 30),
  onTimeout: () => throw TimeoutException('Request timeout'),
);
```

### P: ¿Cómo implementar estado global para el carrito?

**R:** Usar `Provider`:

```dart
// pubspec.yaml
dependencies:
  provider: ^6.0.0

// services/cart_provider.dart
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => _items;

  void addToCart(CartItem item) {
    _items.add(item);
    notifyListeners();
  }

  void removeFromCart(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  double getTotal() {
    return _items.fold(0, (sum, item) => sum + item.getTotalPrice());
  }
}

// En main.dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => CartProvider()),
  ],
  child: const MyApp(),
)
```

## 🔧 Configuración

### Variables de Entorno

Edita `.env`:

```
# URL base de la API
API_BASE_URL=http://localhost:8000/api

# Opcional: Configuración adicional
APP_NAME=Utammys Shop
APP_VERSION=1.0.0
ENABLE_DEBUG=true
```

### Configuración de Build

**Para Android** (`android/app/build.gradle`):
```gradle
minSdkVersion 21
targetSdkVersion 34
```

**Para iOS** (`ios/Podfile`):
```ruby
platform :ios, '11.0'
```

### Permisos Requeridos

**AndroidManifest.xml**:
```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
```

**Info.plist**:
```xml
<key>NSLocalNetworkUsageDescription</key>
<string>App necesita acceso a la red para conectarse a la API</string>
<key>NSBonjourServices</key>
<array>
  <string>_http._tcp</string>
</array>
```

## 📱 Testing

### Pruebas de Endpoints

Usar Postman con colección `utammys-api/POSTMAN_COLLECTION.json`:

```bash
# Obtener colegios
GET http://localhost:8000/api/shop/clients

# Obtener productos
GET http://localhost:8000/api/shop/products?client_id=1

# Crear orden
POST http://localhost:8000/api/shop/cart/complete
Content-Type: application/json

{
  "client_id": 1,
  "customer_name": "Juan Pérez",
  "customer_email": "juan@example.com",
  "customer_phone": "+502 1234 5678",
  "delivery_address": "Calle Principal 123",
  "items": [
    {
      "product_id": 1,
      "product_size_id": 1,
      "quantity": 2,
      "unit_price": 350.00
    }
  ],
  "total": 700.00
}
```

### Debugging

Habilitar logs en `ApiService`:

```dart
static Future<Map<String, dynamic>> get(String endpoint) async {
  final url = Uri.parse('$baseUrl/$endpoint');
  print('🔵 GET: $url');
  
  try {
    final response = await http.get(url, headers: {...});
    print('✅ Response: ${response.statusCode}');
    print('📦 Body: ${response.body}');
    return json.decode(response.body);
  } catch (e) {
    print('❌ Error: $e');
    rethrow;
  }
}
```

## 🚀 Deployment

### Preparación antes de producción

1. **Cambiar API_BASE_URL** a tu servidor de producción
2. **Actualizar versionCode** en `pubspec.yaml`
3. **Deshabilitar logs de debug**
4. **Generar key signing para Android**:
   ```bash
   keytool -genkey -v -keystore ~/key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias key
   ```
5. **Compilar release**:
   ```bash
   flutter build apk --release
   # o para iOS
   flutter build ios --release
   ```

### Monitoreo en Producción

Implementar logging remoto:

```dart
// lib/services/logger_service.dart
class LoggerService {
  static Future<void> logError(String error, StackTrace stackTrace) async {
    // Enviar a servicio de logging (ej: Sentry, Firebase Crashlytics)
    print('Error logged: $error\n$stackTrace');
  }
}
```

## 📋 Checklist de Implementación

- [ ] Actualizar `.env` con URL correcta de API
- [ ] Verificar que endpoints `/shop/...` existan en API Laravel
- [ ] Probar conexión básica con `SchoolService.getSchools()`
- [ ] Integrar `SchoolSearchScreen` en navegación principal
- [ ] Configurar estado global del carrito (Provider)
- [ ] Implementar autenticación si es requerida
- [ ] Agregar manejo de errores mejorado
- [ ] Configurar caching de imágenes
- [ ] Probar flujo completo: Buscar → Ver Productos → Carrito → Checkout
- [ ] Verificar estructura de payload para creación de órdenes
- [ ] Documentar variables de entorno del servidor
- [ ] Preparar para producción

## 📞 Soporte

Si tienes preguntas específicas sobre la integración:

1. Verificar logs en la consola Flutter
2. Usar `flutter logs` para logs de dispositivo
3. Revisar respuesta de API en Postman
4. Comparar estructura de datos esperada vs. real de API

## 📚 Documentación Relacionada

- [API Integration Summary](./API_INTEGRATION_SUMMARY.md)
- [Integration Examples](./INTEGRATION_EXAMPLES.md)
- [API Laravel Documentation](../utammys-api/README.md)
- [Store Web Documentation](../utammys-store/README.md)
