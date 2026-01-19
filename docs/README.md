# Uniformes Tammys - Mobile App

Una aplicación móvil Flutter para la venta de uniformes escolares y empresariales. Catálogo dinámico que se integra con una API Laravel.

## Características Implementadas ✅

- 📱 Soporte multiplataforma (Android & iOS)
- 🔌 Integración con API REST (Laravel)
- 🎨 Identidad visual personalizada (colores Tammys)
- 👕 Catálogo de uniformes con categorías y subcategorías
- 🔄 Carga dinámica desde API
- ⚡ Componentes reutilizables
- 🛡️ Type-safe (Dart null-safety)
- 📊 Manejo robusto de estados

## Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) (SDK 3.0.0 or higher)
- [Dart](https://dart.dev/get-dart) (comes with Flutter)
- [Android Studio](https://developer.android.com/studio) (for Android development)
- [Xcode](https://developer.apple.com/xcode/) (for iOS development - macOS only)

## Getting Started

### 1. Clone the repository

```bash
git clone https://github.com/pablosalazarbr/utammys-mobile-app.git
cd utammys-mobile-app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Configure API settings

Create a `.env` file in the root directory based on `.env.example`:

```bash
cp .env.example .env
```

Edit the `.env` file and set your Laravel API base URL:


## Requisitos Previos

Antes de comenzar, asegúrate de tener instalado:

- [Flutter](https://flutter.dev/docs/get-started/install) (SDK 3.0.0 o superior)
- [Dart](https://dart.dev/get-dart) (incluido con Flutter)
- [Android Studio](https://developer.android.com/studio) (para desarrollo Android)
- [Xcode](https://developer.apple.com/xcode/) (para desarrollo iOS - solo macOS)

## Guía de Inicio Rápido

### 1. Clonar el repositorio

```bash
git clone https://github.com/tu-usuario/utammys-mobile-app.git
cd utammys-mobile-app
```

### 2. Instalar dependencias

```bash
flutter pub get
```

### 3. Configurar variables de entorno

Copia el archivo `.env.example` a `.env`:

```bash
cp .env.example .env
```

Edita el archivo `.env` con la URL de tu API Laravel:

```env
API_BASE_URL=https://tu-api.com/api
```

### 4. Ejecutar la app

#### Android:
```bash
flutter run
```

#### iOS (solo macOS):
```bash
cd ios
pod install
cd ..
flutter run
```

## Estructura del Proyecto

```
lib/
├── main.dart                          # Punto de entrada
├── models/
│   └── category_model.dart           # Modelos de categorías
├── screens/
│   ├── category_detail_screen.dart   # Detalle de categoría
│   └── ...
├── services/
│   ├── api_service.dart              # Cliente HTTP (mejorado)
│   ├── category_service.dart         # Lógica de categorías
│   └── ...
└── widgets/
    └── ui_components.dart            # Componentes reutilizables

test/
├── category_model_test.dart          # Pruebas de modelos
└── ...
```

## Arquitectura de la App

```
Presentation Layer (UI)
    ↓
Business Logic Layer (Services)
    ↓
Data Access Layer (API)
    ↓
Laravel REST API
```

## Pantallas Implementadas

### ✅ HomePage (Página Principal)
- Banner de bienvenida con gradiente
- Grid de 2 categorías principales:
  - Uniformes Escolares
  - Uniformes Empresariales
- Carga dinámica desde API
- Manejo de estados (loading, error, vacío)

### ✅ CategoryDetailScreen (Detalle de Categoría)
- Descripción de la categoría
- Grid de subcategorías
- Carga dinámicas de subcategorías
- Navegación a próximas pantallas

## Servicios Implementados

### CategoryService
```dart
// Obtener todas las categorías
await CategoryService.getCategories()
// GET /api/categories → List<Category>

// Obtener una categoría específica
await CategoryService.getCategoryById(id)
// GET /api/categories/{id} → Category

// Obtener subcategorías
await CategoryService.getSubCategories(categoryId)
// GET /api/categories/{id}/sub-categories → List<SubCategory>
```

### ApiService (Mejorado)
```dart
// GET request
await ApiService.get('endpoint')

// GET request lista
await ApiService.getList('endpoint')

// POST request
await ApiService.post('endpoint', data)
```

## Componentes UI

- `CategoryCard` - Tarjeta de categoría principal
- `SubCategoryCard` - Tarjeta de subcategoría
- `LoadingWidget` - Indicador de carga
- `ErrorWidget` - Pantalla de error
- `TammysColors` - Paleta de colores
- `TammysDimensions` - Sistema de dimensiones

## Documentación Adicional

- 📖 [HOMEPAGE_STRUCTURE.md](HOMEPAGE_STRUCTURE.md) - Estructura técnica detallada
- 📖 [HOMEPAGE_IMPLEMENTATION.md](HOMEPAGE_IMPLEMENTATION.md) - Guía de implementación
- 📖 [FLOW_DIAGRAM.md](FLOW_DIAGRAM.md) - Diagramas de flujo y arquitectura
- 📖 [DEVELOPMENT.md](DEVELOPMENT.md) - Guía de desarrollo futuro
- 🎨 [visual_guide.md](visual_guide.md) - Identidad visual
- 🏗️ [ARCHITECTURE.md](ARCHITECTURE.md) - Arquitectura general

## Construir para Producción

### Android

```bash
flutter build apk --release
# o para app bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

Luego abre `ios/Runner.xcworkspace` en Xcode para archivar y publicar en la App Store.

## Desarrollo

### Modo debug
```bash
flutter run
```

### Ejecutar pruebas
```bash
flutter test
```

### Formatear código
```bash
dart format lib/
```

### Analizar código
```bash
flutter analyze
```

## Variables de Entorno

| Variable | Descripción | Ejemplo |
|----------|-------------|---------|
| `API_BASE_URL` | URL base de la API | `https://api.example.com/api` |

## Próximas Fases

- **Fase 2**: Pantalla de productos por subcategoría
- **Fase 3**: Detalle de producto con carrito
- **Fase 4**: Checkout y compra
- **Fase 5**: Autenticación y perfil de usuario

## Contribuir

1. Fork el repositorio
2. Crea una rama para tu feature (`git checkout -b feature/mi-feature`)
3. Commit tus cambios (`git commit -m 'Agregar feature'`)
4. Push a la rama (`git push origin feature/mi-feature`)
5. Abre un Pull Request

## Licencia

Este proyecto está bajo la licencia MIT.

## Support

For support, please contact the development team or open an issue in the repository.