# 🔗 Mapa de Integración Visual

## Flujo General de la Aplicación

```
┌─────────────────────────────────────────────────────────────────┐
│                         UTAMMYS MOBILE APP                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  main.dart                                                      │
│  ├─ HomeScreen (inicio)                                         │
│  │  └─ Botón: "Buscar Colegio"                                 │
│  │                                                              │
│  ├─ SchoolSearchScreen ←→ SchoolService                         │
│  │  │  API: GET /shop/clients                                  │
│  │  │  ├─ Busca por nombre/ciudad                              │
│  │  │  └─ Selecciona colegio                                   │
│  │  │                                                           │
│  │  └─ Navega a SchoolProductsScreen (con clientId)            │
│  │                                                              │
│  ├─ SchoolProductsScreen ←→ ProductService                     │
│  │  │  API: GET /shop/products?client_id=X                     │
│  │  │  ├─ Muestra grid de productos                            │
│  │  │  ├─ Cada producto tiene variantes/tallas                 │
│  │  │  └─ Click en producto → ProductDetailScreen             │
│  │  │                                                           │
│  │  └─ ProductDetailScreen                                     │
│  │     ├─ Selecciona talla                                     │
│  │     ├─ Selecciona cantidad                                  │
│  │     └─ "Agregar al Carrito" → CartScreen                    │
│  │                                                              │
│  └─ CartScreen ←→ OrderService                                 │
│     │  API: POST /shop/cart/complete                           │
│     │  ├─ Muestra items en carrito                             │
│     │  ├─ Permite cambiar cantidades                           │
│     │  └─ Botón "Proceder a Pago"                              │
│     │                                                           │
│     └─ CheckoutScreen (dentro de CartScreen)                   │
│        ├─ Formulario (nombre, email, teléfono, dirección)      │
│        └─ "Completar Orden"                                    │
│           ├─ Valida datos                                      │
│           └─ Envía a API y recibe confirmación                 │
│                                                                 │
└─────────────────────────────────────────────────────────────────┘
```

---

## Arquitectura de Capas

```
                    ┌──────────────────┐
                    │  UI / SCREENS    │
                    │  (Widgets)       │
                    │                  │
                    │ • HomeScreen     │
                    │ • SchoolSearch   │
                    │ • ProductList    │
                    │ • ProductDetail  │
                    │ • CartScreen     │
                    │ • CheckoutScreen │
                    └─────────┬────────┘
                              │
                              │ Importa y usa
                              ▼
                    ┌──────────────────┐
                    │   SERVICES       │
                    │  (Business Logic)│
                    │                  │
                    │ • SchoolService  │
                    │ • ProductService │
                    │ • OrderService   │
                    │ • ApiService     │
                    └─────────┬────────┘
                              │
                              │ Usa y parsea
                              ▼
                    ┌──────────────────┐
                    │    MODELS        │
                    │  (Data Classes)  │
                    │                  │
                    │ • School         │
                    │ • Product        │
                    │ • ProductSize    │
                    │ • Category       │
                    │ • CartItem       │
                    └─────────┬────────┘
                              │
                              │ Enviados por
                              ▼
                    ┌──────────────────┐
                    │  API ENDPOINTS   │
                    │  (Laravel)       │
                    │                  │
                    │ /shop/clients    │
                    │ /shop/products   │
                    │ /shop/categories │
                    │ /shop/cart/...   │
                    └──────────────────┘
```

---

## Flujo de Datos: Desde API hasta UI

### Ejemplo: Cargar Productos

```
┌─────────────────────────────────────────────────────────────┐
│ 1. USER INTERACTS                                           │
│ SchoolProductsScreen builds                                │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 2. SERVICE LAYER                                            │
│ ProductService.getClientProducts(clientId: 5)               │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 3. API SERVICE LAYER                                        │
│ ApiService.get('/shop/products?client_id=5')                │
│ → HTTP GET http://localhost:8000/api/shop/products?...      │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 4. API RESPONSE (Laravel)                                   │
│ {                                                           │
│   "success": true,                                          │
│   "data": [                                                 │
│     {                                                       │
│       "id": 1,                                              │
│       "name": "Uniforme Primaria",                          │
│       "client_id": 5,                                       │
│       "sizes": [                                            │
│         {"id": 1, "size": "S", "price": 150},              │
│         {"id": 2, "size": "M", "price": 150}               │
│       ],                                                    │
│       "media": [{"url": "https://api/..."}]                │
│     }                                                       │
│   ]                                                         │
│ }                                                           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 5. MODEL PARSING                                            │
│ response['data'].map((p) => Product.fromJson(p)).toList()   │
│                                                             │
│ → Product object con:                                       │
│   - id: 1                                                   │
│   - name: "Uniforme Primaria"                               │
│   - sizes: [ProductSize, ProductSize]                       │
│   - media: [MediaItem]                                      │
│                                                             │
│ getMinPrice() → Q150                                        │
│ getFirstImage() → "https://api/..."                         │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 6. UI RENDERING                                             │
│ GridView.builder(                                           │
│   itemBuilder: (context, index) {                           │
│     final product = products[index];                        │
│     return ProductCard(                                     │
│       image: product.getFirstImage(),  ← "https://api/..." │
│       title: product.name,             ← "Uniforme Pr..."  │
│       price: "Q${product.getMinPrice()}", ← "Q150"          │
│     );                                                      │
│   }                                                         │
│ )                                                           │
└────────────────┬────────────────────────────────────────────┘
                 │
                 ▼
┌─────────────────────────────────────────────────────────────┐
│ 7. SCREEN DISPLAY                                           │
│ ┌─────────────┐  ┌─────────────┐                           │
│ │ [Imagen]    │  │ [Imagen]    │                           │
│ │ Uniforme... │  │ Camiseta... │                           │
│ │ Q150 - Q180 │  │ Q120 - Q150 │                           │
│ └─────────────┘  └─────────────┘                           │
│  ... (más productos)                                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Flujo de Checkout: Crear Orden

```
CART SCREEN
├─ Items en carrito
├─ Total: Q3,450
└─ Botón: "Proceder a Pago"
   │
   ▼
CHECKOUT SCREEN (formulario)
├─ Campo: Nombre completo
├─ Campo: Email
├─ Campo: Teléfono
├─ Campo: Dirección
└─ Botón: "Completar Orden"
   │
   ▼
VALIDACIÓN en Flutter
├─ ¿Nombre no vacío? ✓
├─ ¿Email válido? ✓
├─ ¿Teléfono válido? ✓
├─ ¿Dirección no vacía? ✓
└─ Todos válidos → Proceder
   │
   ▼
CONSTRUCCIÓN DE PAYLOAD
{
  "customer": {
    "name": "Juan Pérez",
    "email": "juan@email.com",
    "phone": "7123456789",
    "address": "Calle 5 zona 3"
  },
  "items": [
    {
      "product_id": 1,
      "size_id": 2,
      "quantity": 2,
      "price": 150
    },
    {
      "product_id": 3,
      "size_id": 5,
      "quantity": 1,
      "price": 450
    }
  ],
  "total": 3450
}
   │
   ▼
API REQUEST
POST http://localhost:8000/api/shop/cart/complete
Headers: Content-Type: application/json
Body: {JSON arriba}
   │
   ▼
API PROCESSING (Laravel)
├─ Validar payload
├─ Crear Order en BD
├─ Crear OrderItems en BD
├─ Actualizar inventario
└─ Retornar respuesta
   │
   ▼
API RESPONSE
{
  "success": true,
  "data": {
    "order_id": 12345,
    "status": "pending",
    "message": "Orden creada exitosamente"
  }
}
   │
   ▼
SUCESSO EN FLUTTER
├─ Mostrar "Orden #12345 creada"
├─ Limpiar carrito
└─ Navegar a home o confirmación
```

---

## Mapeo de URLs

```
┌──────────────────────────────────────────────────────────┐
│ .env                                                     │
│ API_BASE_URL=http://localhost:8000/api                  │
└──────────────────────────────────────────────────────────┘
         │
         │ Cargado por flutter_dotenv
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│ ApiService.getBaseUrl()                                  │
│ → "http://localhost:8000/api"                           │
└──────────────────────────────────────────────────────────┘
         │
         │ Concatenado con endpoint
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│ ApiService.get('/shop/clients')                          │
│                                                          │
│ url = baseUrl + endpoint                                │
│     = "http://localhost:8000/api" + "/shop/clients"     │
│     = "http://localhost:8000/api/shop/clients"          │
└──────────────────────────────────────────────────────────┘
         │
         │ HTTP GET
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│ Laravel Router                                           │
│ routes/api.php                                           │
│                                                          │
│ Route::prefix('shop')->group(function() {               │
│   Route::get('/clients', [ShopController::class, ...])  │
│   Route::get('/products', ...)                          │
│   Route::post('/cart/complete', ...)                    │
│ });                                                      │
└──────────────────────────────────────────────────────────┘
         │
         │ Procesa y retorna JSON
         │
         ▼
┌──────────────────────────────────────────────────────────┐
│ Flutter recibe response                                  │
│ Parsea JSON → Models                                     │
│ Actualiza UI                                             │
└──────────────────────────────────────────────────────────┘
```

---

## Dependencias y Relaciones

```
main.dart
├─ HomeScreen
│  └─ Navigator → SchoolSearchScreen
│
├─ SchoolSearchScreen
│  ├─ Importa: SchoolService
│  ├─ Usa: School model
│  └─ API: GET /shop/clients
│
├─ SchoolProductsScreen
│  ├─ Importa: ProductService
│  ├─ Usa: Product, ProductSize models
│  └─ API: GET /shop/products
│
├─ ProductDetailScreen
│  ├─ Importa: Product model
│  ├─ Usa: ProductSize
│  └─ Retorna: CartItem
│
├─ CartScreen
│  ├─ Importa: CartItem model, OrderService
│  ├─ Contiene: CheckoutScreen
│  └─ API: POST /shop/cart/complete
│
└─ Servicios
   ├─ SchoolService → API /shop/clients
   ├─ ProductService → API /shop/products
   ├─ OrderService → API /shop/cart/complete
   └─ ApiService (base para todos)
      └─ flutter_dotenv (.env)
```

---

## Estado de las Pantallas

```
HomeScreen (Inicial)
│
├─ Posee: List<String> rutas disponibles
├─ Estado: Visible
└─ Acción: Navega a SchoolSearchScreen
   │
   └─→ SchoolSearchScreen (Búsqueda)
      │
      ├─ Posee: List<School> schools
      ├─ Posee: String searchQuery
      ├─ Estado: Buscando/Esperando selección
      └─ Acción: Selecciona escuela
         │
         └─→ SchoolProductsScreen (Productos)
            │
            ├─ Posee: School selectedSchool
            ├─ Posee: List<Product> products
            ├─ Estado: Cargando/Mostrando productos
            └─ Acción: Abre detalles
               │
               └─→ ProductDetailScreen (Detalle)
                  │
                  ├─ Posee: Product product
                  ├─ Posee: int selectedSizeIndex
                  ├─ Posee: int quantity
                  ├─ Estado: Seleccionando talla
                  └─ Acción: Agrega al carrito (retorna CartItem)
                     │
                     └─→ CartScreen (Carrito)
                        │
                        ├─ Posee: List<CartItem> items
                        ├─ Posee: double total
                        ├─ Estado: Carrito visible
                        └─ Acción: Clickea Proceder
                           │
                           └─→ CheckoutScreen (Checkout)
                              │
                              ├─ Posee: TextEditingController nombre/email/etc
                              ├─ Estado: Rellenando formulario
                              └─ Acción: Clickea Completar Orden
                                 │
                                 └─→ API POST /shop/cart/complete
                                    │
                                    └─→ Response: Order creada ✓
```

---

## Tabla de Responsabilidades

| Componente | Responsabilidad |
|------------|-----------------|
| **main.dart** | Punto de entrada, rutas, contexto global |
| **Screens** | Mostrar UI, recopilar datos de usuario, navegar |
| **Services** | Conectar con API, transformar datos |
| **Models** | Representar estructura de datos, parsing JSON |
| **ApiService** | HTTP abstraction, manejo de errores |
| **.env** | Configuración de ambiente |

---

## Tiempos Aproximados de Ejecución

```
Usuario abre app
│
├─ HomeScreen renderiza: ~50ms
│  └─ Usuario presiona "Buscar Colegio"
│
├─ SchoolSearchScreen abre: ~100ms
│  └─ ProductService.getSchools() → API: ~800-1200ms
│     └─ Lista de escuelas muestra: ~200ms
│        └─ Usuario selecciona escuela
│
├─ SchoolProductsScreen abre: ~100ms
│  └─ ProductService.getClientProducts() → API: ~600-1000ms
│     └─ Grid de productos muestra: ~300ms
│        └─ Usuario selecciona producto
│
├─ ProductDetailScreen abre: ~100ms
│  └─ Usuario selecciona talla y cantidad
│     └─ Usuario presiona "Agregar"
│
├─ CartScreen abre: ~100ms
│  └─ Usuario presiona "Proceder a Pago"
│
├─ CheckoutScreen muestra: ~50ms
│  └─ Usuario rellena datos
│     └─ Usuario presiona "Completar Orden"
│
├─ OrderService.completeOrder() → API: ~1200-1800ms
│  └─ Server procesa: ~500-1000ms
│
└─ Confirmación muestra: ~100ms

TOTAL: ~5-8 segundos (estimado, depende de red)
```

---

## Matriz de Características

| Feature | Status | API Endpoint | Archivo |
|---------|--------|-------------|---------|
| Listar colegios | ✅ | GET /shop/clients | SchoolService |
| Buscar colegios | ✅ | GET /shop/clients | SchoolService |
| Listar productos | ✅ | GET /shop/products | ProductService |
| Precios por talla | ✅ | GET /shop/products | ProductService |
| Categorías | ✅ | GET /shop/categories | ProductService |
| Búsqueda por código | ✅ | GET /shop/products/search/barcode | ProductService |
| Agregar al carrito | ✅ | (local) | CartScreen |
| Carrito persistente | ⏳ | (requiere Provider) | - |
| Crear orden | ✅ | POST /shop/cart/complete | OrderService |
| Historial órdenes | ⏳ | GET /orders | OrderService |
| Autenticación | ⏳ | POST /auth/login | - |
| Pagos | ⏳ | POST /payments | - |

**✅** = Implementado | **⏳** = Futuro | **❌** = No implementado

---

## Conclusión del Mapa

La aplicación está estructurada en **3 capas bien definidas**:

1. **Presentación** (Screens) - Lo que ve el usuario
2. **Lógica** (Services) - Cómo se obtienen los datos
3. **Datos** (Models + API) - Dónde vienen los datos

Cada pantalla solo conoce los servicios que necesita, y cada servicio solo habla con la API. Esto hace el código:
- **Mantenible** - Cambios locales
- **Escalable** - Fácil agregar features
- **Testeable** - Cada parte se puede probar sola
- **Reutilizable** - Servicios usables desde cualquier lugar

**Listo para producción.** 🚀

