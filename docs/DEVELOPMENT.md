# Guía de Desarrollo - Fase 1: Página Principal

## Resumen Ejecutivo

Se ha implementado una estructura completa y **production-ready** para la página principal con:
- ✅ Dos categorías principales (Escolares y Empresariales)
- ✅ Subcategorías dinámicas por categoría
- ✅ Carga desde API REST
- ✅ Manejo robusto de errores
- ✅ Identidad visual implementada
- ✅ Código 100% type-safe (Dart null-safety)

## Estado Actual

### Archivos Creados
```
✅ lib/models/category_model.dart          # Modelos Category, SubCategory
✅ lib/services/category_service.dart      # Lógica de negocio
✅ lib/services/api_service.dart           # Cliente HTTP mejorado
✅ lib/widgets/ui_components.dart          # Componentes UI reutilizables
✅ lib/screens/category_detail_screen.dart # Pantalla de detalle
✅ lib/main.dart                           # HomePage actualizada
✅ test/category_model_test.dart           # Pruebas unitarias
```

### Documentación Creada
```
✅ HOMEPAGE_STRUCTURE.md     # Estructura técnica detallada
✅ HOMEPAGE_IMPLEMENTATION.md # Guía de implementación
✅ FLOW_DIAGRAM.md            # Diagramas de flujo y arquitectura
✅ DEVELOPMENT.md             # Este archivo
```

## Archivos por Eliminar/Renombrar

Luego de verificar que todo funcione, considera:

1. **Archivos antiguos a eliminar:**
   ```
   - lib/screens/  (si existía otra estructura)
   - lib/models/   (si existía otra estructura)
   ```

## Próximos Pasos de Desarrollo

### Fase 2: Pantalla de Productos (Siguiente Sprint)

#### 1. Crear Modelo de Producto
```dart
// lib/models/product_model.dart
class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final List<String> images;
  final List<Size> availableSizes;
  final List<String> colors;
  // ... más campos según necesidad
}

class Size {
  final String size;
  final int stock;
}
```

#### 2. Crear Servicio de Productos
```dart
// lib/services/product_service.dart
class ProductService {
  static Future<List<Product>> getProductsBySubCategory(int subCategoryId) async {
    // GET /api/sub-categories/{id}/products
  }

  static Future<Product> getProductById(int id) async {
    // GET /api/products/{id}
  }
}
```

#### 3. Crear Pantalla de Productos
```dart
// lib/screens/product_list_screen.dart
class ProductListScreen extends StatefulWidget {
  final SubCategory subCategory;
  
  // Muestra grid de productos
  // Filtros: precio, tamaño, color
  // Búsqueda local
}
```

#### 4. Actualizar NavigationDetail
```dart
// En category_detail_screen.dart
SubCategoryCard(
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductListScreen(
          subCategory: subCategory,
        ),
      ),
    );
  },
)
```

### Fase 3: Detalle de Producto

#### 1. Crear DetailScreen
```dart
// lib/screens/product_detail_screen.dart
class ProductDetailScreen extends StatefulWidget {
  final Product product;
  
  // Galería de imágenes con zoom
  // Selector de talla y color
  // Cantidad
  // Botón "Agregar al carrito"
}
```

#### 2. Agregar Funcionalidad de Carrito
```dart
// lib/services/cart_service.dart
class CartService {
  static List<CartItem> _cart = [];
  
  static void addToCart(CartItem item) { ... }
  static void removeFromCart(int productId) { ... }
  static double getTotalPrice() { ... }
}
```

### Fase 4: Checkout y Compra

#### 1. Pantalla de Carrito
```dart
// lib/screens/cart_screen.dart
class CartScreen extends StatefulWidget {
  // Listado de items
  // Resumen de precios
  // Botón "Proceder al checkout"
}
```

#### 2. Pantalla de Checkout
```dart
// lib/screens/checkout_screen.dart
class CheckoutScreen extends StatefulWidget {
  // Formulario de datos de envío
  // Método de pago
  // Resumen de orden
}
```

#### 3. Confirmación de Orden
```dart
// lib/screens/order_confirmation_screen.dart
class OrderConfirmationScreen extends StatelessWidget {
  // Número de orden
  // Estado de entrega
  // Botón para volver al home
}
```

## Configuración para Ejecutar Localmente

### 1. Instalar Dependencias
```bash
flutter pub get
```

### 2. Crear archivo `.env`
```dotenv
API_BASE_URL=http://localhost:8000/api
```

### 3. Ejecutar la App
```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Web
flutter run -d web
```

### 4. Ejecutar Pruebas
```bash
# Todas las pruebas
flutter test

# Pruebas específicas
flutter test test/category_model_test.dart

# Con cobertura
flutter test --coverage
```

## Estructura del Backend Esperada (Laravel)

### Rutas Recomendadas
```php
// routes/api.php

Route::apiResource('categories', CategoryController::class);
Route::get('categories/{id}/sub-categories', [CategoryController::class, 'getSubCategories']);

Route::apiResource('sub-categories', SubCategoryController::class);
Route::get('sub-categories/{id}/products', [SubCategoryController::class, 'getProducts']);

Route::apiResource('products', ProductController::class);

Route::post('orders', [OrderController::class, 'store']);
Route::get('orders/{id}', [OrderController::class, 'show']);
```

### Respuesta Esperada: GET /categories
```json
{
  "data": [
    {
      "id": 1,
      "name": "Uniformes Escolares",
      "description": "Uniformes para instituciones educativas",
      "image_url": "https://...",
      "sub_categories": [
        {
          "id": 1,
          "category_id": 1,
          "name": "Colegio San José",
          "image_url": "https://..."
        }
      ]
    },
    {
      "id": 2,
      "name": "Uniformes Empresariales",
      "description": "Uniformes corporativos",
      "image_url": "https://...",
      "sub_categories": [
        {
          "id": 2,
          "category_id": 2,
          "name": "Empresa ABC",
          "image_url": "https://..."
        }
      ]
    }
  ]
}
```

## Checklist de Validación

### ✅ Validaciones Implementadas
- [x] Modelos con deserialización JSON
- [x] Servicio API genérico
- [x] Servicio específico de categorías
- [x] Página principal con carga dinámica
- [x] Pantalla de detalle de categoría
- [x] Componentes UI reutilizables
- [x] Manejo de estados (loading, error, vacío)
- [x] Identidad visual implementada
- [x] Pruebas unitarias de modelos
- [x] Documentación completa

### ⚠️ Validaciones Pendientes
- [ ] Pruebas de integración con API real
- [ ] Pruebas en dispositivos reales (Android)
- [ ] Pruebas en dispositivos reales (iOS)
- [ ] Optimización de imágenes
- [ ] Caché local de datos
- [ ] Manejo de conexión offline

### 🔮 Futuras Mejoras
- [ ] Caché con `hive` o `sqflite`
- [ ] Infinite scroll en listas
- [ ] Búsqueda global con debounce
- [ ] Favoritos locales
- [ ] Sincronización con backend
- [ ] Push notifications
- [ ] Analytics

## Commandos Útiles

```bash
# Limpiar build
flutter clean

# Obtener dependencias
flutter pub get

# Actualizar dependencias
flutter pub upgrade

# Verificar errores de análisis
flutter analyze

# Formatear código
dart format lib/

# Ejecutar pruebas con cobertura
flutter test --coverage

# Construir APK (Android)
flutter build apk --release

# Construir IPA (iOS)
flutter build ios --release

# Publicar en Play Store (después de setup)
flutter pub get
flutter build appbundle --release

# Publicar en App Store (después de setup)
flutter build ios --release
```

## Variantes de Compilación

### Debug
```bash
flutter run
```

### Release
```bash
flutter run --release
```

### Profile
```bash
flutter run --profile
```

## Variables de Entorno Disponibles

```
API_BASE_URL        # URL base del backend (requerida)
API_TIMEOUT         # Timeout en segundos (opcional, default: 30)
LOG_LEVEL           # Nivel de logs: DEBUG, INFO, WARNING, ERROR
DEBUG_MODE          # true/false para habilitar logs detallados
```

## Estructura de Carpetas Recomendada

```
lib/
├── main.dart
├── config/
│   ├── theme.dart              # Tema y colores
│   └── constants.dart          # Constantes de la app
├── models/
│   ├── category_model.dart
│   ├── product_model.dart
│   └── order_model.dart
├── services/
│   ├── api_service.dart
│   ├── category_service.dart
│   ├── product_service.dart
│   └── cart_service.dart
├── screens/
│   ├── home_screen.dart
│   ├── category_detail_screen.dart
│   ├── product_list_screen.dart
│   ├── product_detail_screen.dart
│   ├── cart_screen.dart
│   ├── checkout_screen.dart
│   └── order_confirmation_screen.dart
├── widgets/
│   ├── ui_components.dart
│   ├── product_card.dart
│   ├── cart_item_widget.dart
│   └── custom_app_bar.dart
└── utils/
    ├── validators.dart
    ├── formatters.dart
    └── extensions.dart

test/
├── category_model_test.dart
├── product_model_test.dart
├── services/
│   └── category_service_test.dart
└── widgets/
    └── ui_components_test.dart
```

## Notas Importantes

1. **Sin Autenticación (por ahora)**: La app funciona sin login. Todos los datos son públicos.
2. **API-Ready**: Cada componente está diseñado para conectar con cualquier API REST
3. **Type-Safe**: Código 100% tipado con Dart null-safety
4. **Modular**: Fácil de extender y mantener
5. **Testeable**: Código diseñado para pruebas unitarias e integración

## Contacto y Dudas

Para consultas sobre la implementación, revisar:
- `HOMEPAGE_STRUCTURE.md` - Detalles técnicos
- `FLOW_DIAGRAM.md` - Diagramas y flujos
- Comentarios en el código (bien documentado)

---

**Última actualización:** Enero 7, 2025
**Versión:** 1.0 - Alpha
