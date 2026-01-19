# 🎨 VISUAL GUIDE - Interfaz de Usuario

## Pantalla 1: HomePage (Página Principal)

```
┌─────────────────────────────┐
│  ◄  Uniformes Tammys     ×  │  ← AppBar (Azul #0000FF)
├─────────────────────────────┤
│                             │
│  ┌───────────────────────┐  │
│  │  Bienvenido a         │  │ ← Banner con gradiente
│  │  Uniformes Tammys     │  │
│  │                       │  │
│  │ Encuentra los         │  │
│  │ uniformes perfectos   │  │
│  └───────────────────────┘  │
│                             │
│  Categorías                 │  ← Título
│  ═════════════════════════  │
│                             │
│  ┌──────────┐ ┌──────────┐  │
│  │ 🎓       │ │ 💼       │  │ ← CategoryCard (Grid 2x1)
│  │          │ │          │  │
│  │ Uniformes│ │ Uniformes│  │ ← Ícono + Título
│  │ Escolares│ │Empresar. │  │ ← Border radius: 12px
│  │          │ │          │  │
│  │ (Imagen) │ │ (Imagen) │  │
│  └──────────┘ └──────────┘  │
│                             │
│  ┌──────────┐ ┌──────────┐  │ ← Tappable (onTap → Detail)
│  │   ...    │ │   ...    │  │
│  └──────────┘ └──────────┘  │
│                             │
└─────────────────────────────┘
```

### Colores Usados:
- **AppBar**: `#0000FF` (Azul)
- **Banner Gradient**: `#0000FF` → `#0000CC`
- **Cards Background**: Blanco con borde gris
- **Text Primary**: `#333333`
- **Text Secondary**: `#666666`

### Interacciones:
- Tap en CategoryCard → CategoryDetailScreen
- Retry button (en caso de error)

---

## Pantalla 2: CategoryDetailScreen (Detalle de Categoría)

```
┌─────────────────────────────┐
│ ◄  Uniformes Escolares   ×  │  ← AppBar con título dinámico
├─────────────────────────────┤
│                             │
│ Uniformes para              │  ← Descripción de la categoría
│ instituciones educativas.   │
│ Contamos con opciones       │
│ para todos los colegios.    │
│                             │
│ ═════════════════════════   │
│                             │
│ Subcategorías               │  ← Título
│                             │
│  ┌──────────┐ ┌──────────┐  │
│  │          │ │          │  │
│  │ Colegio  │ │ Instituto│  │ ← SubCategoryCard
│  │ San      │ │ Técnico  │  │   (Grid 2xN)
│  │ José     │ │          │  │
│  │ (Imagen) │ │ (Imagen) │  │
│  └──────────┘ └──────────┘  │
│                             │
│  ┌──────────┐ ┌──────────┐  │
│  │ Escuela  │ │ Colegio  │  │
│  │ Primaria │ │ Bilingüe │  │
│  │    ABC   │ │          │  │
│  │ (Imagen) │ │ (Imagen) │  │
│  └──────────┘ └──────────┘  │
│                             │
└─────────────────────────────┘
```

### Características:
- AppBar azul con título dinámico
- Descripción de la categoría
- Grid de SubCategoryCard 2×N
- Tappable → Próxima pantalla (TODO)

---

## Estados de Carga

### Estado: LOADING
```
┌─────────────────────────────┐
│  ◄  Uniformes Tammys     ×  │
├─────────────────────────────┤
│                             │
│                             │
│           ⟳                 │ ← CircularProgressIndicator
│                             │
│      Cargando               │ ← Texto de carga
│      categorías...          │
│                             │
│                             │
└─────────────────────────────┘
```

### Estado: ERROR
```
┌─────────────────────────────┐
│  ◄  Uniformes Tammys     ×  │
├─────────────────────────────┤
│                             │
│            ⚠️                │ ← Ícono de error (Rojo)
│                             │
│            Oops!            │
│                             │
│  Error cargando las         │ ← Mensaje de error
│  categorías. Por favor,     │
│  verifica tu conexión.      │
│                             │
│    [Intentar de nuevo]      │ ← Botón rojo para reintentar
│                             │
└─────────────────────────────┘
```

### Estado: EMPTY
```
┌─────────────────────────────┐
│  ◄  Uniformes Tammys     ×  │
├─────────────────────────────┤
│                             │
│            📭                │
│                             │
│   No hay categorías         │
│   disponibles               │
│                             │
│                             │
└─────────────────────────────┘
```

---

## Paleta de Colores Implementada

```
Color Primario:       #0000FF  ████████ Azul Eléctrico
Color Acento:         #EE1D23  ████████ Rojo Vibrante
Color Detalle:        #FFD600  ████████ Amarillo Cierre
Color Fondo:          #FFFFFF  ████████ Blanco Puro
Color Texto Principal: #333333  ████████ Gris Oscuro
Color Texto Secundario: #666666  ████████ Gris Medio
Color Borde:          #E0E0E0  ████████ Gris Claro
```

---

## Sistema de Dimensiones

```
Border Radius:      12.0 px  (Esquinas redondeadas suaves)

Padding/Spacing:
├── paddingSmall:   8.0 px
├── paddingMedium:  16.0 px
└── paddingLarge:   24.0 px

Icon Size:          24.0 px (estándar)
```

---

## Tipografía

```
Títulos (Headings):
├── Fonte: Montserrat
├── Weight: Semi-Bold (w600)
└── Sizes: 24px (H4), 20px (H5), 18px (H6)

Cuerpo (Body):
├── Fonte: Open Sans
├── Weight: Regular (w400)
└── Sizes: 16px (Body), 14px (Caption), 12px (Overline)
```

---

## Componentes Reutilizables

### CategoryCard
```
┌─────────────────┐
│                 │
│ 🎓              │  ← Ícono personalizado
│                 │
│  Uniformes      │  ← Título
│  Escolares      │  ← Text Theme: headlineSmall
│                 │
│ (Background)    │  ← Imagen o color
│                 │
└─────────────────┘
  Border: 1px gris
  Sombra: Ligera
  Radius: 12px
```

### SubCategoryCard
```
┌─────────────────┐
│                 │
│   (Imagen)      │
│   con overlay    │
│   degradado      │
│                 │
│ ┌─────────────┐ │
│ │ Colegio San │ │  ← Título en overlay inferior
│ │ José        │ │  ← Fondo oscuro translúcido
│ └─────────────┘ │
└─────────────────┘
  Radius: 12px
  Sombra: Ligera
```

### LoadingWidget
```
      ⟳
      
   Cargando...
```

### ErrorWidget
```
        ⚠️
        
      Oops!
      
Error cargando las
categorías.

[Intentar de nuevo]
```

---

## Flujo Visual de Navegación

```
┌──────────────────┐
│   HomePage       │
│                  │
│ Banner           │
│ Grid:            │
│ [Escolares]      │
│ [Empresariales]  │
└────────┬─────────┘
         │ Tap en una categoría
         ▼
┌──────────────────────┐
│ CategoryDetailScreen  │
│                      │
│ Descripción          │
│ Grid:                │
│ [Colegio 1]          │
│ [Colegio 2]          │
│ [Colegio 3]          │
│ [Colegio 4]          │
└────────┬─────────────┘
         │ Tap en subcategoría (TODO)
         ▼
┌──────────────────────┐
│ ProductListScreen    │  ← Próxima fase
│ (Por implementar)    │
└──────────────────────┘
```

---

## Responsividad

### En móvil (360dp - 480dp)
```
Grid: 2 columnas
CategoryCard:  Ajusta automáticamente
SubCategoryCard: Ajusta automáticamente
```

### En tablet (600dp+)
```
Grid: 2-3 columnas (diseño actual soporta ambos)
Cards: Se escalan proporcionalmente
```

---

## Animaciones (Opcionales para futuro)

```
PageTransition:     Slide (por defecto en Navigator)
CardTap:            Color change + scale pequeño
Loading:            Rotación continua
ErrorRetry:         Bounce en botón
```

---

## Accesibilidad

- ✅ Contraste suficiente (WCAG AA)
- ✅ Tamaños de fuente legibles
- ✅ Espaciado adecuado
- ✅ Iconografía clara
- ✅ Estados visuales claros (loading, error)

---

## Comparación: Mockup vs Implementación

| Elemento | Visual Guide | Implementado | Status |
|----------|-------------|--------------|--------|
| Colores Primarios | ✅ Definidos | ✅ Implementados | ✓ |
| Border Radius | ✅ 12px | ✅ 12px | ✓ |
| Tipografía | ✅ Open Sans | ✅ Open Sans | ✓ |
| Grid Layout | ✅ 2 columnas | ✅ 2 columnas | ✓ |
| Componentes | ✅ Definidos | ✅ Creados | ✓ |
| Navegación | ✅ Especificada | ✅ Implementada | ✓ |
| Estados | ✅ Considerados | ✅ Manejados | ✓ |

---

## Mockup Completo: HomePage

```
╔═════════════════════════════════════════════════════╗
║ ◄  Uniformes Tammys                             ×  ║ 24px
╠═════════════════════════════════════════════════════╣
║                                                   ║
║ ┌───────────────────────────────────────────────┐  ║
║ │  Bienvenido a                                 │  │ Gradient
║ │  Uniformes Tammys                             │  │ #0000FF
║ │                                               │  │ to
║ │  Encuentra los uniformes perfectos para ti    │  │ #0000CC
║ │                                               │  │
║ └───────────────────────────────────────────────┘  │ 16px
║                                                   ║
║ Categorías                                      ║ 16px
║ ═══════════════════════════════════════════════  ║
║                                                   ║
║  ┌──────────────────────┐ ┌──────────────────┐  ║
║  │                      │ │                  │  ║
║  │       🎓             │ │      💼          │  │ 48px
║  │                      │ │                  │  │
║  │  Uniformes Escolares │ │ Uniformes        │  │
║  │                      │ │ Empresariales    │  │
║  │                      │ │                  │  │
║  │   (Background        │ │ (Background      │  │
║  │    Imagen)           │ │  Imagen)         │  │
║  │                      │ │                  │  │
║  └──────────────────────┘ └──────────────────┘  │ 16px
║                                                   ║
║  ┌──────────────────────┐ ┌──────────────────┐  ║
║  │     🎓               │ │      💼          │  │
║  │                      │ │                  │  │
║  │                      │ │                  │  │
║  │   (Background        │ │ (Background      │  │
║  │    Imagen)           │ │  Imagen)         │  │
║  │                      │ │                  │  │
║  └──────────────────────┘ └──────────────────┘  │
║                                                   ║
║ (Scroll continúa)                              ║
╚═════════════════════════════════════════════════════╝
```

---

## Notas de Diseño

1. **Limpieza Visual**: Fondo blanco, espaciado generoso
2. **Jerarquía**: AppBar azul > Banner > Cards
3. **Interactividad**: Bordes suaves, sombras sutiles
4. **Accesibilidad**: Colores contrastantes, texto legible
5. **Marca**: Colores Tammys consistentes en toda la app

---

**Última actualización**: Enero 7, 2025
**Version**: 1.0 - Alpha
