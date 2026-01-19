# Actualización de Utammys Mobile App - Integración con API

## Resumen de Cambios

Se ha actualizado completamente la aplicación móvil `utammys-mobile-app` para que se comporte de manera similar a la tienda web (`utammys-store`), conectándose directamente a los endpoints de la API (`utammys-api`).

## Cambios Realizados

### 1. Modelos Actualizados (Models)

#### `lib/models/school_model.dart`
- **Antes**: Modelo simplificado con solo `id`, `name`, `imageUrl`, `description`
- **Después**: Modelo actualizado con estructura completa de Cliente (School) de la API
  - Campos adicionales: `type`, `city`, `logoUrl`, `email`, `phone`, `address`, `country`, `contactPerson`, `taxId`, `paymentTerms`, `creditLimit`, `isActive`, timestamps
  - Compatible con respuesta de endpoint `GET /shop/clients`

#### `lib/models/category_model.dart`
- Actualizado para soportar categorías jerárquicas (parent-child)
- Campos: `id`, `name`, `description`, `parentId`, `isActive`, `children`
- Compatible con endpoint `GET /shop/categories/tree/full`

#### `lib/models/product_model.dart`
- **Producto**:
  - Cambio de `schoolId` → `clientId`
  - Nueva estructura: `sku`, `categoryId`, `media` (array), `isCustomizable`, `isActive`
  - Eliminados: `imageUrl`, `material`, `careInstructions`, `inStock`, `stockQuantity`
  - Agregados: `sizes` (lista de ProductSize), timestamps

- **ProductSize** (nueva clase):
  - Representa variantes de tamaño con: `id`, `productId`, `size`, `barcode`, `price`, `isAvailable`
  - Reemplaza el concepto anterior de opciones simples

- **CartItem**:
  - Actualizado para usar `ProductSize` en lugar de opciones genéricas
  - Ahora es: `product`, `size`, `quantity`

### 2. Servicios Nuevos y Actualizados

#### `lib/services/school_service.dart` (NUEVO)
Servicio especializado para operaciones de colegios (clientes):
- `getSchools()`: Obtiene todos los colegios disponibles
- `getSchoolById(id)`: Obtiene detalle de un colegio
- `searchSchools(query)`: Búsqueda local por nombre/ciudad
- `getSchoolsByType(type)`: Filtra por tipo (ESCOLAR/EMPRESARIAL)

#### `lib/services/product_service.dart` (ACTUALIZADO)
Ahora consume los endpoints de la API:
- `getClientProducts(clientId)`: Productos de un cliente
- `getProductById(productId)`: Detalle de producto
- `getRandomProducts(limit)`: Productos aleatorios para home
- `getCategories()`: Lista de categorías
- `getCategoriesTree()`: Árbol jerárquico de categorías
- `getCategoryWithProducts(categoryId)`: Categoría con sus productos
- `searchByBarcode(barcode)`: Búsqueda por código de barras
- `getStockByBarcode(barcode)`: Información de stock

#### `lib/services/order_service.dart` (NUEVO)
Servicio para órdenes/compras:
- `completeOrder(orderData)`: Crea una orden (POST /shop/cart/complete)
- `getOrders()`: Obtiene órdenes del usuario
- `getOrderById(orderId)`: Detalle de orden
- `cancelOrder(orderId)`: Cancela una orden

### 3. Pantallas Nuevas y Actualizadas

#### `lib/screens/school_search_screen.dart` (NUEVO)
- Pantalla de búsqueda y selección de colegios
- Integración con `SchoolService` para obtener colegios de la API
- Búsqueda en tiempo real por nombre/ciudad
- Mostrador de tarjetas con información del colegio (nombre, tipo, ciudad)
- Navegación a `SchoolProductsScreen` al seleccionar un colegio

#### `lib/screens/school_products_screen.dart` (ACTUALIZADO)
- Ahora llama a `ProductService.getClientProducts()` en lugar de endpoint antiguo
- Manejo de imágenes desde URLs de la API
- Visualización de rango de precios (min-max) desde tamaños disponibles
- Muestra cantidad de variantes en lugar de cantidad en stock

#### `lib/screens/cart_screen.dart` (ACTUALIZADO)
- Estructura completamente nueva con dos pantallas:
  1. **CartScreen**: Visualización del carrito
  2. **CheckoutScreen**: Formulario de compra con validación

Características:
- Gestión de cantidad (incrementar/decrementar)
- Eliminar items del carrito
- Resumen automático de totales
- Formulario con validación para datos de entrega
- Integración lista para llamar a `OrderService.completeOrder()`

### 4. Configuración

#### `.env` (ACTUALIZADO)
```
API_BASE_URL=http://localhost:8000/api
```

Asegúrate de actualizar la URL según tu entorno:
- **Desarrollo local**: `http://localhost:8000/api`
- **Desarrollo remoto**: `http://tu-servidor.com/api`

## Flujo de la Aplicación

```
1. Home Screen / Main Screen
   ↓
2. School Search Screen (buscar colegio)
   ↓ (seleccionar colegio)
3. School Products Screen (ver productos del colegio)
   ↓ (añadir productos al carrito)
4. Cart Screen (ver carrito)
   ↓ (proceder al pago)
5. Checkout Screen (ingresar datos y completar compra)
   ↓ (enviar orden a API)
6. Orden completada
```

## Endpoints API Consumidos

### Tienda Pública (shop)
- `GET /shop/clients` - Lista de colegios disponibles
- `GET /shop/clients/{id}` - Detalle de colegio
- `GET /shop/products` - Lista de productos
- `GET /shop/products/{id}` - Detalle de producto
- `GET /shop/products/random` - Productos aleatorios
- `GET /shop/categories` - Categorías
- `GET /shop/categories/tree/full` - Árbol de categorías
- `GET /shop/products/search/barcode` - Búsqueda por barcode
- `GET /shop/inventory/stock` - Stock disponible
- `POST /shop/cart/complete` - Completar compra

## Próximos Pasos Recomendados

1. **Actualizar main.dart**: Integrar `SchoolSearchScreen` en la navegación principal
2. **Crear un estado global**: Usar Provider o Riverpod para gestionar cliente seleccionado y carrito
3. **Autenticación**: Implementar login si es requerido por tu API
4. **Persistencia de carrito**: Usar SharedPreferences o Hive para guardar carrito localmente
5. **Manejo de errores mejorado**: Agregar retry logic, timeout handling
6. **Imágenes**: Implementar caching de imágenes con `cached_network_image`
7. **Payment Gateway**: Integrar pasarela de pago (si aplica)

## Cambios Necesarios en main.dart

Para integrar la nueva pantalla de búsqueda:

```dart
// En tu navegación principal, agregar:
SchoolSearchScreen() // Para seleccionar colegio
CartScreen() // Para ver carrito
```

## Notas Importantes

- La app ahora está completamente integrada con los endpoints públicos de `/shop`
- Los modelos coinciden con la estructura real de la API
- Los servicios manejan correctamente las respuestas con estructura `{success, data, message}`
- Las imágenes se cargan desde URLs de la API (requiere que la API las sirva correctamente)
- El checkout está preparado para enviar los datos en el formato esperado por `POST /shop/cart/complete`

## Troubleshooting

**Problema**: No aparecen los colegios
- Verificar que `API_BASE_URL` en `.env` sea correcto
- Revisar que el endpoint `/shop/clients` de la API esté funcionando

**Problema**: Las imágenes no se cargan
- Verificar que los paths en `media` sean correctos
- Asegurar que la API sirve las imágenes correctamente

**Problema**: Error al crear orden
- Revisar la estructura esperada por `POST /shop/cart/complete`
- Ajustar el payload en `OrderService.completeOrder()`
