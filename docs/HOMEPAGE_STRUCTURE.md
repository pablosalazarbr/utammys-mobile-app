# Guía de Estructura - Página Principal

## Descripción General

Se ha implementado una estructura completa y **API-ready** para la página principal de Uniformes Tammys con las siguientes características:

- **Dos categorías principales**: Uniformes Escolares y Uniformes Empresariales
- **Subcategorías dinámicas**: Cada categoría puede tener múltiples subcategorías (colegios, empresas, etc.)
- **Carga desde API**: Los datos se obtienen de endpoints REST específicos
- **Manejo de estados**: Carga, error, y datos vacíos
- **Diseño siguiendo la identidad visual**: Colores, tipografía y componentes según visual_guide.md

## Estructura de Archivos

```
lib/
├── main.dart                          # Punto de entrada y HomePage
├── models/
│   └── category_model.dart           # Modelos: Category, SubCategory
├── screens/
│   └── category_detail_screen.dart   # Pantalla de detalle de categoría
├── services/
│   ├── api_service.dart              # Servicio HTTP genérico (actualizado)
│   └── category_service.dart         # Servicio específico para categorías
└── widgets/
    └── ui_components.dart            # Componentes reutilizables UI
```

## Componentes Creados

### 1. **Modelos de Datos** (`lib/models/category_model.dart`)

#### `Category`
```dart
Category(
  id: 1,
  name: 'Uniformes Escolares',
  description: 'Uniformes para instituciones educativas',
  imageUrl: 'https://...',
  subCategories: [...]
)
```

**Métodos:**
- `fromJson()` - Convierte JSON de API a modelo Dart
- `toJson()` - Convierte modelo Dart a JSON para enviar a API

#### `SubCategory`
```dart
SubCategory(
  id: 1,
  categoryId: 1,
  name: 'Colegio XYZ',
  imageUrl: 'https://...'
)
```

### 2. **Servicios API**

#### `ApiService` (Actualizado - `lib/services/api_service.dart`)

Nuevos métodos:
- `get()` - GET request que devuelve `Map<String, dynamic>`
- `getList()` - GET request que devuelve `List<dynamic>` (maneja respuestas con estructura `{data: [...]}`)
- `post()` - POST request

#### `CategoryService` (`lib/services/category_service.dart`)

Métodos disponibles:
```dart
// Obtener todas las categorías
CategoryService.getCategories()
→ GET /categories
← List<Category>

// Obtener una categoría específica
CategoryService.getCategoryById(int id)
→ GET /categories/{id}
← Category

// Obtener subcategorías de una categoría
CategoryService.getSubCategories(int categoryId)
→ GET /categories/{categoryId}/sub-categories
← List<SubCategory>
```

### 3. **Componentes UI** (`lib/widgets/ui_components.dart`)

#### `CategoryCard`
Tarjeta grande para categorías principales. Soporta:
- Imagen de fondo
- Ícono
- Título
- Color de fondo personalizado

#### `SubCategoryCard`
Tarjeta compacta para subcategorías. Muestra:
- Imagen de fondo
- Título en overlay inferior

#### `LoadingWidget`
Widget reutilizable que muestra estado de carga

#### `ErrorWidget`
Widget reutilizable que muestra errores con botón de reintentar

#### `TammysColors` & `TammysDimensions`
Constantes de diseño siguiendo la identidad visual:
- Colores: Azul (#0000FF), Rojo (#EE1D23), Amarillo (#FFD600)
- Border radius: 12px
- Padding: 8, 16, 24px

### 4. **Pantallas**

#### `HomePage` (actualizada en `lib/main.dart`)
- Banner de bienvenida con gradiente
- Grid de categorías principales
- Manejo de estados (loading, error, vacío)
- Navega a detalle al tocar una categoría

#### `CategoryDetailScreen` (`lib/screens/category_detail_screen.dart`)
- Muestra descripción de categoría
- Grid de subcategorías
- Carga subcategorías desde API
- Botones para navegar a productos (TODO)

## Flujo de Datos

```
HomePage
  ↓
CategoryService.getCategories()
  ↓
ApiService.getList('categories')
  ↓
[Crea List<Category> desde JSON]
  ↓
Renderiza Grid de CategoryCard
  ↓
Al tocar una categoría
  ↓
CategoryDetailScreen
  ↓
CategoryService.getSubCategories(categoryId)
  ↓
Renderiza Grid de SubCategoryCard
```

## Integración con API Backend (Laravel)

### Endpoints Esperados

**1. Obtener todas las categorías**
```
GET /api/categories
Response:
{
  "data": [
    {
      "id": 1,
      "name": "Uniformes Escolares",
      "description": "...",
      "image_url": "https://...",
      "sub_categories": [
        {
          "id": 1,
          "category_id": 1,
          "name": "Colegio XYZ",
          "image_url": "https://..."
        }
      ]
    }
  ]
}
```

**2. Obtener categoría específica**
```
GET /api/categories/{id}
Response:
{
  "id": 1,
  "name": "Uniformes Escolares",
  "description": "...",
  "image_url": "https://...",
  "sub_categories": [...]
}
```

**3. Obtener subcategorías de una categoría**
```
GET /api/categories/{id}/sub-categories
Response:
{
  "data": [
    {
      "id": 1,
      "category_id": 1,
      "name": "Colegio XYZ",
      "image_url": "https://..."
    }
  ]
}
```

## Configuración

### Variables de Entorno (`.env`)

```
API_BASE_URL=https://tu-api.com/api
```

El `ApiService` lee automáticamente esta variable en tiempo de ejecución.

## Próximos Pasos

1. **Productos**: Crear pantalla de listado de productos para cada subcategoría
   - Modelo: `Product`
   - Servicio: `ProductService`
   - Pantalla: `ProductListScreen`

2. **Carrito**: Implementar carrito de compras
   - Modelo: `CartItem`
   - Servicio: `CartService`

3. **Checkout**: Crear flujo de compra
   - Pantalla: `CheckoutScreen`
   - Pantalla: `OrderConfirmationScreen`

4. **Búsqueda**: Agregar búsqueda global de productos

## Notas de Desarrollo

- **Sin autenticación**: La app funciona sin login. Todos los datos son públicos.
- **Caché**: Considera agregar caché local para mejor rendimiento (usando `hive` o `sqflite`)
- **Imágenes**: Las imágenes se descargan desde URLs. Considera agregar caché de imágenes
- **Errores**: El manejo de errores es genérico. Personaliza según necesidades del backend
- **Validación**: Los modelos validan tipos básicos. Agregar validaciones más estrictas si es necesario
