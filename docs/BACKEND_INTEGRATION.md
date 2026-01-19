# 🔗 Guía de Integración con Backend Laravel

## Resumen Rápido

Esta app está **100% lista para conectar con tu API Laravel**. Solo necesitas:

1. Implementar los 3 endpoints especificados
2. Crear la estructura de tablas
3. Configurar el `.env` con la URL de tu API
4. Listo - la app funcionará

---

## Endpoints Requeridos

### 1️⃣ GET /api/categories

**Propósito**: Obtener todas las categorías principales con sus subcategorías

**Método**: `GET`
**URL**: `/api/categories`
**Auth**: No requerida
**Parámetros**: Ninguno

**Respuesta Esperada** (200 OK):
```json
{
  "data": [
    {
      "id": 1,
      "name": "Uniformes Escolares",
      "description": "Uniformes para instituciones educativas",
      "image_url": "https://example.com/image1.jpg",
      "sub_categories": [
        {
          "id": 1,
          "category_id": 1,
          "name": "Colegio San José",
          "image_url": "https://example.com/colegio1.jpg"
        },
        {
          "id": 2,
          "category_id": 1,
          "name": "Instituto Técnico",
          "image_url": "https://example.com/colegio2.jpg"
        }
      ]
    },
    {
      "id": 2,
      "name": "Uniformes Empresariales",
      "description": "Uniformes corporativos y profesionales",
      "image_url": "https://example.com/image2.jpg",
      "sub_categories": [
        {
          "id": 3,
          "category_id": 2,
          "name": "Empresa ABC",
          "image_url": "https://example.com/empresa1.jpg"
        }
      ]
    }
  ]
}
```

**Errores Posibles**:
- `500` - Error del servidor
- `404` - No hay categorías

---

### 2️⃣ GET /api/categories/{id}

**Propósito**: Obtener una categoría específica con sus detalles

**Método**: `GET`
**URL**: `/api/categories/{id}`
**Auth**: No requerida
**Parámetros**:
- `id` (URL) - ID de la categoría

**Respuesta Esperada** (200 OK):
```json
{
  "id": 1,
  "name": "Uniformes Escolares",
  "description": "Uniformes para instituciones educativas",
  "image_url": "https://example.com/image1.jpg",
  "sub_categories": [
    {
      "id": 1,
      "category_id": 1,
      "name": "Colegio San José",
      "image_url": "https://example.com/colegio1.jpg"
    }
  ]
}
```

**Errores Posibles**:
- `404` - Categoría no encontrada
- `500` - Error del servidor

---

### 3️⃣ GET /api/categories/{id}/sub-categories

**Propósito**: Obtener solo las subcategorías de una categoría

**Método**: `GET`
**URL**: `/api/categories/{id}/sub-categories`
**Auth**: No requerida
**Parámetros**:
- `id` (URL) - ID de la categoría padre

**Respuesta Esperada** (200 OK):
```json
{
  "data": [
    {
      "id": 1,
      "category_id": 1,
      "name": "Colegio San José",
      "image_url": "https://example.com/colegio1.jpg"
    },
    {
      "id": 2,
      "category_id": 1,
      "name": "Instituto Técnico",
      "image_url": "https://example.com/colegio2.jpg"
    }
  ]
}
```

**Errores Posibles**:
- `404` - Categoría no encontrada
- `500` - Error del servidor

---

## Estructura de Base de Datos (Recomendada)

### Tabla: `categories`

```sql
CREATE TABLE categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  image_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

-- Insertar dos categorías principales
INSERT INTO categories (name, description) VALUES
('Uniformes Escolares', 'Uniformes para instituciones educativas'),
('Uniformes Empresariales', 'Uniformes corporativos y profesionales');
```

### Tabla: `sub_categories`

```sql
CREATE TABLE sub_categories (
  id INT PRIMARY KEY AUTO_INCREMENT,
  category_id INT NOT NULL,
  name VARCHAR(255) NOT NULL,
  image_url VARCHAR(255),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
);

-- Insertar subcategorías de ejemplo
INSERT INTO sub_categories (category_id, name) VALUES
(1, 'Colegio San José'),
(1, 'Instituto Técnico'),
(1, 'Escuela Primaria ABC'),
(2, 'Empresa ABC'),
(2, 'Empresa XYZ'),
(2, 'Clínica MedSalud');
```

---

## Implementación en Laravel

### 1. Crear Models

```php
// app/Models/Category.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Category extends Model
{
    protected $fillable = ['name', 'description', 'image_url'];

    public function subCategories(): HasMany
    {
        return $this->hasMany(SubCategory::class);
    }
}
```

```php
// app/Models/SubCategory.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SubCategory extends Model
{
    protected $fillable = ['category_id', 'name', 'image_url'];

    public function category(): BelongsTo
    {
        return $this->belongsTo(Category::class);
    }
}
```

### 2. Crear Controllers

```php
// app/Http/Controllers/API/CategoryController.php
<?php

namespace App\Http\Controllers\API;

use App\Models\Category;
use App\Models\SubCategory;
use Illuminate\Http\Response;

class CategoryController extends Controller
{
    /**
     * GET /api/categories
     * Obtener todas las categorías con subcategorías
     */
    public function index()
    {
        $categories = Category::with('subCategories')->get();
        
        return response()->json([
            'data' => $categories
        ]);
    }

    /**
     * GET /api/categories/{id}
     * Obtener categoría específica
     */
    public function show(Category $category)
    {
        return response()->json($category->load('subCategories'));
    }

    /**
     * GET /api/categories/{id}/sub-categories
     * Obtener subcategorías de una categoría
     */
    public function getSubCategories(Category $category)
    {
        return response()->json([
            'data' => $category->subCategories
        ]);
    }
}
```

### 3. Crear Routes

```php
// routes/api.php
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\CategoryController;

Route::prefix('api')->group(function () {
    // Categorías
    Route::get('/categories', [CategoryController::class, 'index']);
    Route::get('/categories/{category}', [CategoryController::class, 'show']);
    Route::get('/categories/{category}/sub-categories', [CategoryController::class, 'getSubCategories']);
    
    // Próximas rutas para productos, órdenes, etc.
});
```

### 4. Crear Migrations

```php
// database/migrations/xxxx_xx_xx_create_categories_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('categories', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->text('description')->nullable();
            $table->string('image_url')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('categories');
    }
};
```

```php
// database/migrations/xxxx_xx_xx_create_sub_categories_table.php
<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('sub_categories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('category_id')->constrained()->onDelete('cascade');
            $table->string('name');
            $table->string('image_url')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('sub_categories');
    }
};
```

### 5. Crear Seeders (Opcional)

```php
// database/seeders/CategorySeeder.php
<?php

namespace Database\Seeders;

use App\Models\Category;
use App\Models\SubCategory;
use Illuminate\Database\Seeder;

class CategorySeeder extends Seeder
{
    public function run()
    {
        // Crear categorías principales
        $escolares = Category::create([
            'name' => 'Uniformes Escolares',
            'description' => 'Uniformes para instituciones educativas',
            'image_url' => 'https://example.com/image1.jpg'
        ]);

        $empresariales = Category::create([
            'name' => 'Uniformes Empresariales',
            'description' => 'Uniformes corporativos y profesionales',
            'image_url' => 'https://example.com/image2.jpg'
        ]);

        // Crear subcategorías para Escolares
        SubCategory::create([
            'category_id' => $escolares->id,
            'name' => 'Colegio San José',
            'image_url' => 'https://example.com/colegio1.jpg'
        ]);

        SubCategory::create([
            'category_id' => $escolares->id,
            'name' => 'Instituto Técnico',
            'image_url' => 'https://example.com/colegio2.jpg'
        ]);

        // Crear subcategorías para Empresariales
        SubCategory::create([
            'category_id' => $empresariales->id,
            'name' => 'Empresa ABC',
            'image_url' => 'https://example.com/empresa1.jpg'
        ]);
    }
}
```

---

## Configuración de la App Flutter

### 1. Archivo `.env`

```env
API_BASE_URL=http://localhost:8000/api
```

Cambiar según tu ambiente:
- **Desarrollo**: `http://localhost:8000/api`
- **Staging**: `https://staging-api.example.com/api`
- **Producción**: `https://api.example.com/api`

### 2. Para Emulador Android

Si ejecutas el backend en localhost:

```env
API_BASE_URL=http://10.0.2.2:8000/api
```

(10.0.2.2 es la IP especial del host en el emulador de Android)

### 3. Para Dispositivo Físico

Usa la IP local de tu computadora:

```env
API_BASE_URL=http://192.168.1.100:8000/api
```

---

## Testing de Endpoints

### Usando cURL

```bash
# GET todas las categorías
curl -X GET "http://localhost:8000/api/categories"

# GET una categoría específica
curl -X GET "http://localhost:8000/api/categories/1"

# GET subcategorías
curl -X GET "http://localhost:8000/api/categories/1/sub-categories"
```

### Usando Postman

1. Crear una colección llamada "Tammys API"
2. Agregar 3 requests GET:
   - `GET {{base_url}}/categories`
   - `GET {{base_url}}/categories/1`
   - `GET {{base_url}}/categories/1/sub-categories`

---

## Validación en Flutter

Una vez configurado, ejecutar:

```bash
# Ver logs de HTTP
flutter run -v

# En la app, debería ver:
# "Cargando categorías..."
# → Petición HTTP GET
# → Respuesta JSON parseda
# → Grid de categorías renderizado
```

---

## Headers HTTP

La app envía estos headers:

```
Content-Type: application/json
Accept: application/json
```

Si tu backend requiere otros headers (como Auth, Custom-Header, etc.), modifica `lib/services/api_service.dart`:

```dart
headers: {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'Authorization': 'Bearer $token',  // Si requiere token
  'X-Custom-Header': 'value',       // Headers personalizados
}
```

---

## CORS (Si es necesario)

Si la app se ejecuta en Web y el backend tiene restricciones CORS:

**Backend (Laravel)**:
```bash
composer require fruitcake/laravel-cors
```

```php
// config/cors.php
'allowed_origins' => ['*'],  // Para desarrollo
'allowed_methods' => ['GET', 'POST', 'PUT', 'DELETE'],
'allowed_headers' => ['*'],
```

---

## Checklist de Integración

- [ ] Base de datos creada (categories, sub_categories)
- [ ] Models creados (Category, SubCategory)
- [ ] Controllers creados (CategoryController)
- [ ] Routes registradas
- [ ] Migrations ejecutadas
- [ ] Seeders ejecutados (datos de prueba)
- [ ] Endpoints testados con cURL/Postman
- [ ] `.env` configurado en la app Flutter
- [ ] `flutter pub get` ejecutado
- [ ] App ejecutada y funciona

---

## Próximas Integraciones

### Fase 2: Productos
```
GET /api/sub-categories/{id}/products
GET /api/products/{id}
```

### Fase 3: Carrito y Órdenes
```
POST /api/orders
GET /api/orders/{id}
```

### Fase 4: Autenticación (Si se requiere)
```
POST /api/auth/login
POST /api/auth/logout
GET /api/user
```

---

## Troubleshooting

### Error: "Failed to load data: 404"
→ Verificar que la ruta existe en `routes/api.php`
→ Verificar que la base de datos tiene datos

### Error: "CORS error"
→ Configurar CORS en Laravel
→ O acceder directamente desde app nativa (no Web)

### Error: "Connection refused"
→ Backend no está ejecutándose
→ Verificar IP en `.env`
→ Para emulador Android: usar `10.0.2.2`

### Datos no aparecen
→ Verificar estructura JSON según lo especificado
→ Ejecutar `flutter run -v` para ver logs HTTP
→ Validar respuesta con Postman primero

---

## Recursos Útiles

- [Documentación Laravel API Resources](https://laravel.com/docs/eloquent-resources)
- [Documentación Flutter HTTP](https://flutter.dev/docs/cookbook/networking/fetch-data)
- [JSON en Dart](https://dart.dev/guides/json)
- [CORS en Laravel](https://github.com/fruitcake/laravel-cors)

---

**¡Tu backend está listo para conectar con la app!** 🚀
