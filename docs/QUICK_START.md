# ⚡ QUICK START - Uniformes Tammys Mobile App

## En 5 Minutos

### Paso 1: Clonar y Setup
```bash
cd utammys-mobile-app
flutter pub get
cp .env.example .env
```

### Paso 2: Configurar API
Edita `.env`:
```env
API_BASE_URL=https://tu-api.com/api
```

### Paso 3: Ejecutar
```bash
flutter run
```

### Paso 4: Ver en Acción
✅ HomePage con 2 categorías
✅ Toca una categoría → Ver subcategorías
✅ ¡Listo!

---

## Archivo de Referencia Rápida

| Necesito... | Archivo |
|------------|---------|
| Empezar | [README.md](README.md) |
| Entender estructura | [FLOW_DIAGRAM.md](FLOW_DIAGRAM.md) |
| Ver código | [HOMEPAGE_STRUCTURE.md](HOMEPAGE_STRUCTURE.md) |
| Ver UI | [UI_VISUAL_GUIDE.md](UI_VISUAL_GUIDE.md) |
| Conectar backend | [BACKEND_INTEGRATION.md](BACKEND_INTEGRATION.md) |
| Próximos pasos | [DEVELOPMENT.md](DEVELOPMENT.md) |
| Todo | [INDEX.md](INDEX.md) |

---

## Estructura de Carpetas

```
lib/
├── main.dart                    ← HomePage aquí
├── models/
│   └── category_model.dart     ← Category, SubCategory
├── services/
│   ├── api_service.dart        ← HTTP client
│   └── category_service.dart   ← Lógica de categorías
├── screens/
│   └── category_detail_screen.dart ← Detalles
└── widgets/
    └── ui_components.dart      ← Componentes UI
```

---

## API Endpoints Esperados

```
GET /api/categories                          → List<Category>
GET /api/categories/{id}                    → Category
GET /api/categories/{id}/sub-categories     → List<SubCategory>
```

---

## Colores Implementados

```
🔵 Azul:     #0000FF  (Principal)
🔴 Rojo:     #EE1D23  (Acciones)
🟡 Amarillo: #FFD600  (Detalles)
⚪ Blanco:   #FFFFFF  (Fondo)
```

---

## Estados de la App

```
LOADING  → Círculo de carga
ERROR    → Pantalla de error con botón de reintentar
EMPTY    → Mensaje "No hay categorías"
SUCCESS  → Grid de categorías + navegación
```

---

## Flujo Simple

```
HomePage
    ↓ Tap categoría
CategoryDetailScreen
    ↓ Tap subcategoría
ProductScreen (próxima fase)
```

---

## Verificación Rápida

```bash
# Ver si compila
flutter analyze

# Ejecutar pruebas
flutter test

# Ver logs HTTP
flutter run -v
```

---

## Troubleshooting Rápido

| Problema | Solución |
|----------|----------|
| Error de compilación | `flutter pub get` |
| API no conecta | Verificar `.env` con URL correcta |
| UI desalineada | Ejecutar en dispositivo (no emulador) |
| Tests fallan | `flutter pub get` y `flutter test` de nuevo |

---

## Información Clave

```
✅ Listo para usar
✅ API-ready
✅ Type-safe (Dart)
✅ Documentado
✅ Sin autenticación
✅ Escalable
```

---

## Contacto Rápido

- Preguntas de estructura: Ver [ARCHITECTURE.md](ARCHITECTURE.md)
- Preguntas de código: Ver [HOMEPAGE_STRUCTURE.md](HOMEPAGE_STRUCTURE.md)
- Preguntas de backend: Ver [BACKEND_INTEGRATION.md](BACKEND_INTEGRATION.md)
- Preguntas de todo: Ver [INDEX.md](INDEX.md)

---

## Próximo Paso

**Implementar backend con 3 endpoints y conectar API.**

---

¡Listo! 🚀
