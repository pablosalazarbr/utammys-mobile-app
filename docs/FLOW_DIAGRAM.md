# Diagrama de Flujo - Página Principal

## 1. Flujo de Datos - HomePage

```
┌─────────────────┐
│   HomePage      │ (StatefulWidget)
│   Initializa    │
│  _categoriesFuture
└────────┬────────┘
         │
         │ CategoryService.getCategories()
         │
         ▼
┌─────────────────────────────────────┐
│  CategoryService.getCategories()    │
│  ↓ llama                            │
│  ApiService.getList('categories')  │
└────────┬────────────────────────────┘
         │
         │ HTTP GET /api/categories
         │
         ▼
┌─────────────────────────┐
│  Backend Laravel API    │
│  GET /categories        │
│  Response: {data: [...]}│
└────────┬────────────────┘
         │
         │ JSON Response
         │
         ▼
┌──────────────────────────────────────┐
│  ApiService.getList() parsea JSON   │
│  ↓ extrae array de 'data'           │
│  ↓ retorna List<dynamic>            │
└────────┬─────────────────────────────┘
         │
         │ Map cada item a Category
         │
         ▼
┌──────────────────────────────────────┐
│  Category.fromJson() deserializa    │
│  ↓ crea objetos Category            │
│  ↓ retorna List<Category>           │
└────────┬─────────────────────────────┘
         │
         │ FutureBuilder renderiza
         │
         ▼
┌──────────────────────────────────────┐
│  HomePage renderiza GridView         │
│  ↓ CategoryCard para cada categoría  │
│  ↓ Muestra nombre + imagen + icono   │
└──────────────────────────────────────┘
```

## 2. Flujo al Tocar una Categoría

```
┌─────────────────────────────────┐
│  CategoryCard.onTap()           │
│  ↓ Navigator.push()             │
└────────┬────────────────────────┘
         │
         ▼
┌──────────────────────────────────────────┐
│  CategoryDetailScreen                     │
│  • Recibe Category como parámetro        │
│  • Inicia carga de subcategorías         │
└────────┬─────────────────────────────────┘
         │
         │ CategoryService.getSubCategories(categoryId)
         │
         ▼
┌──────────────────────────────────────┐
│  CategoryService.getSubCategories()  │
│  ↓ ApiService.getList()              │
│  ↓ GET /categories/{id}/sub-categories│
└────────┬───────────────────────────────┘
         │
         │ JSON Response
         │
         ▼
┌──────────────────────────────────────┐
│  SubCategory.fromJson() deserializa │
│  ↓ retorna List<SubCategory>         │
└────────┬───────────────────────────────┘
         │
         │ FutureBuilder renderiza
         │
         ▼
┌──────────────────────────────────────┐
│  CategoryDetailScreen renderiza      │
│  ↓ GridView de SubCategoryCard       │
│  ↓ Muestra subcategorías             │
└──────────────────────────────────────┘
```

## 3. Arquitectura por Capas

```
┌──────────────────────────────────────────┐
│         PRESENTATION LAYER               │
│  (Screens & Widgets)                     │
├──────────────────────────────────────────┤
│  • HomePage                              │
│  • CategoryDetailScreen                  │
│  • CategoryCard (Widget)                 │
│  • SubCategoryCard (Widget)              │
│  • LoadingWidget, ErrorWidget            │
└──────────────────┬───────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│      BUSINESS LOGIC LAYER                │
│  (Services)                              │
├──────────────────────────────────────────┤
│  • CategoryService                       │
│  • getCategories()                       │
│  • getCategoryById()                     │
│  • getSubCategories()                    │
└──────────────────┬───────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│      DATA ACCESS LAYER                   │
│  (API Client)                            │
├──────────────────────────────────────────┤
│  • ApiService                            │
│  • get()                                 │
│  • getList()                             │
│  • post()                                │
└──────────────────┬───────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│      MODELS & SERIALIZATION              │
├──────────────────────────────────────────┤
│  • Category                              │
│  • SubCategory                           │
│  • fromJson(), toJson()                  │
└──────────────────┬───────────────────────┘
                   │
                   ▼
┌──────────────────────────────────────────┐
│      EXTERNAL API (Backend)              │
│  (Laravel REST API)                      │
├──────────────────────────────────────────┤
│  • GET /categories                       │
│  • GET /categories/{id}                  │
│  • GET /categories/{id}/sub-categories   │
└──────────────────────────────────────────┘
```

## 4. Interacción de Componentes

```
main.dart
  │
  ├─→ ThemeData (con colores de Tammys)
  ├─→ MaterialApp
  └─→ HomePage
      │
      ├─→ CategoryService
      │   └─→ ApiService
      │       └─→ HTTP Client
      │
      ├─→ FutureBuilder
      │   │
      │   ├─ Loading → LoadingWidget
      │   ├─ Error → ErrorWidget
      │   └─ Data → GridView
      │       │
      │       └─→ CategoryCard (x2)
      │           │
      │           └─→ onTap
      │               └─→ Navigator.push()
      │                   └─→ CategoryDetailScreen
      │                       │
      │                       ├─→ AppBar
      │                       │
      │                       └─→ FutureBuilder
      │                           │
      │                           └─→ GridView
      │                               └─→ SubCategoryCard (xN)
      │                                   └─→ onTap
      │                                       └─→ ProductScreen (TODO)
      │
      └─→ UI Components
          ├─→ TammysColors
          ├─→ TammysDimensions
          └─→ Widgets reutilizables
```

## 5. Estados de la Aplicación

```
HomePage
├─ LOADING
│  ├─ Muestra: CircularProgressIndicator
│  └─ Mensaje: "Cargando categorías..."
│
├─ ERROR
│  ├─ Muestra: Ícono de error + mensaje
│  ├─ Botón: "Intentar de nuevo"
│  └─ onRetry: Reinicia FutureBuilder
│
├─ EMPTY
│  ├─ Muestra: Ícono vacío + mensaje
│  └─ Mensaje: "No hay categorías disponibles"
│
└─ SUCCESS
   ├─ Muestra: Banner + Grid de categorías
   └─ Interacción: onTap → CategoryDetailScreen

CategoryDetailScreen
├─ LOADING
│  └─ Muestra: "Cargando subcategorías..."
│
├─ ERROR
│  └─ Botón: "Intentar de nuevo"
│
├─ EMPTY
│  └─ Muestra: "No hay subcategorías disponibles"
│
└─ SUCCESS
   └─ Muestra: Grid de subcategorías
```

## 6. Flujo de Navegación

```
┌──────────────┐
│  HomePage    │
│ (Stack: [0]) │
└────┬─────────┘
     │ Navigator.push(CategoryDetailScreen)
     │
     ▼
┌──────────────────────────┐
│ CategoryDetailScreen     │
│ (Stack: [0, 1])          │
└────┬─────────────────────┘
     │ Navigator.pop() ← BackButton
     │
     ▼
┌──────────────┐
│  HomePage    │
│ (Stack: [0]) │
└──────────────┘
```

## 7. Estructura de JSON - Respuesta API

```
GET /api/categories

{
  "data": [
    {
      "id": 1,
      "name": "Uniformes Escolares",
      "description": "Uniformes para instituciones...",
      "image_url": "https://...",
      "sub_categories": [
        {
          "id": 1,
          "category_id": 1,
          "name": "Colegio San José",
          "image_url": "https://..."
        },
        {
          "id": 2,
          "category_id": 1,
          "name": "Instituto Técnico",
          "image_url": "https://..."
        }
      ]
    },
    {
      "id": 2,
      "name": "Uniformes Empresariales",
      "description": "Uniformes corporativos...",
      "image_url": "https://...",
      "sub_categories": [
        {
          "id": 3,
          "category_id": 2,
          "name": "Empresa ABC",
          "image_url": "https://..."
        }
      ]
    }
  ]
}
```

## 8. Métodos HTTP Utilizados

```
┌─────────────────────────────────────────┐
│  CategoryService.getCategories()        │
├─────────────────────────────────────────┤
│  GET /api/categories                    │
│  Headers:                               │
│  - Content-Type: application/json       │
│  - Accept: application/json             │
│  Response: List<Category>               │
└─────────────────────────────────────────┘

┌────────────────────────────────────────────┐
│  CategoryService.getSubCategories(id)      │
├────────────────────────────────────────────┤
│  GET /api/categories/{id}/sub-categories   │
│  Headers:                                  │
│  - Content-Type: application/json          │
│  - Accept: application/json                │
│  Response: List<SubCategory>               │
└────────────────────────────────────────────┘
```

## 9. Manejo de Errores

```
try {
  final response = await http.get(url, headers);
  
  if (response.statusCode == 200) {
    return json.decode(response.body);  ✓ Éxito
  } else {
    throw Exception(
      'Failed: ${response.statusCode} - ${response.body}'
    );  ✗ Error HTTP
  }
} catch (e) {
  throw Exception('Error: $e');  ✗ Error de conexión/parsing
}
```

## 10. Ciclo de Vida de la Página

```
main()
  ↓ dotenv.load()
  ↓ runApp(MyApp)
  ↓
MyApp (build)
  ↓ MaterialApp
  ↓ theme (TammysColors)
  ↓ home: HomePage()
  ↓
HomePage (initState)
  ↓ _categoriesFuture = CategoryService.getCategories()
  ↓
HomePage (build)
  ↓ AppBar + FutureBuilder
  ↓ Loading/Error/Data
  ↓
Si Data:
  ↓ Banner + GridView
  ↓ CategoryCard (×2)
  ↓ User Interaction
  ↓ Navigator.push(CategoryDetailScreen)
  ↓
CategoryDetailScreen (initState)
  ↓ _subCategoriesFuture = CategoryService.getSubCategories()
  ↓
CategoryDetailScreen (build)
  ↓ AppBar + FutureBuilder
  ↓ GridView de SubCategoryCard
  ↓
Usuario toca SubCategoryCard
  ↓ Mostrar SnackBar (placeholder)
  ↓ TODO: ProductScreen
```
