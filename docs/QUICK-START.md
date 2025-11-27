# 🎬 Cinema App - Quick Start Guide

**Estado:** ✅ UI Base Lista para Probar
**Fecha:** 2025-11-03

---

## 🚀 Ejecutar la App AHORA

```bash
# 1. Instalar dependencias (si no lo has hecho)
flutter pub get

# 2. Ejecutar en Chrome
flutter run -d chrome --web-port=5173

# 3. O ejecutar en Android
flutter run -d android
```

---

## ✨ Lo que Acabas de Obtener

### 🎨 **Design System Profesional**
- ✅ Paleta de colores Cinema (rojo #DC2626 + tema oscuro)
- ✅ Sistema tipográfico completo
- ✅ Espaciado consistente (base 8px)
- ✅ Theme Material Design 3

### 🧩 **6 Componentes Reutilizables**
- ✅ `CinemaButton` - Botones con 5 variantes
- ✅ `CinemaCard` - Cards consistentes
- ✅ `CinemaTextField` - Inputs con validación
- ✅ `EmptyState` - Estados vacíos
- ✅ `ErrorView` - Manejo de errores
- ✅ `LoadingIndicator` - Cargando

### 🎬 **Movies UI Completa**
- ✅ Página de cartelera moderna
- ✅ Filtros por género
- ✅ Lista horizontal de películas
- ✅ Grid de próximos estrenos
- ✅ Bottom sheet de detalle
- ✅ 5 películas mock con datos reales

---

## 📁 Archivos Nuevos Creados

```
lib/
├── core/
│   ├── theme/                    # Design System
│   │   ├── app_colors.dart       ← Paleta de colores
│   │   ├── app_typography.dart   ← Sistema tipográfico
│   │   ├── app_spacing.dart      ← Espaciado y radios
│   │   └── app_theme.dart        ← Theme completo
│   │
│   ├── widgets/                  # Componentes base
│   │   ├── cinema_button.dart
│   │   ├── cinema_card.dart
│   │   ├── cinema_text_field.dart
│   │   ├── empty_state.dart
│   │   ├── error_view.dart
│   │   └── loading_indicator.dart
│   │
│   └── models/
│       └── movie.dart            ← Modelo + Mock data
│
└── features/
    └── movies/
        ├── widgets/
        │   └── movie_card.dart   ← Card de película
        └── pages/
            └── movies_page_new.dart  ← Página principal
```

---

## 🎯 Para Probar la Nueva UI

### Opción 1: Actualizar main.dart (Recomendado)

Reemplaza `lib/main.dart` con:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'features/movies/pages/movies_page_new.dart';

void main() {
  runApp(const ProviderScope(child: CinemaApp()));
}

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const MoviesPageNew(),
    );
  }
}
```

Luego ejecuta:
```bash
flutter run -d chrome --web-port=5173
```

---

## 🎨 Vista Previa de UI

### Página de Cartelera
- **AppBar** con gradient rojo a negro
- **Filtros** de género (chips horizontales)
- **"En Cartelera"** - Scroll horizontal de películas
- **"Próximos Estrenos"** - Grid 2 columnas

### Movie Card
- Poster con aspect ratio 2:3
- Badge "NUEVO" si es estreno
- Rating con estrella
- Título, género, duración
- Clasificación (PG-13, R)

### Movie Detail (Bottom Sheet)
- Poster grande
- Título y metadata
- Sinopsis completa
- Director y género
- Horarios disponibles (chips)
- Botón grande "Comprar Boletos"

---

## 🎬 Películas Mock Incluidas

1. **Demon Slayer: Castillo Infinito**
   - Anime, PG-13, 120min, ⭐4.8
   - 4 horarios disponibles

2. **Los Extraños: Capítulo 2**
   - Terror, R, 98min, ⭐3.5
   - 3 horarios disponibles

3. **The Dark Knight**
   - Acción, PG-13, 152min, ⭐4.9
   - 3 horarios disponibles

4. **Avengers: Endgame**
   - Acción, PG-13, 181min, ⭐4.7
   - 3 horarios disponibles

5. **Parasite**
   - Drama, R, 132min, ⭐4.6
   - 3 horarios disponibles

---

## 🔧 Personalizar

### Cambiar Color Primario

Edita `lib/core/theme/app_colors.dart`:
```dart
static const Color primary = Color(0xFFDC2626);  // Tu color aquí
```

### Cambiar Fuente

Edita `lib/core/theme/app_typography.dart`:
```dart
static const String fontFamily = 'Roboto';  // Tu fuente aquí
```

(Recuerda agregar la fuente en `pubspec.yaml`)

---

## 📖 Documentación Completa

Para más detalles, ver:
- `docs/NEW-UI-IMPLEMENTATION.md` - Documentación completa de la UI
- `docs/03-FRONTEND-ARCHITECTURE.md` - Arquitectura del frontend

---

## 🐛 Troubleshooting

### Error: "No se pueden encontrar los imports"
```bash
flutter pub get
flutter clean
flutter pub get
```

### Error: "Las imágenes no cargan"
Verifica tu conexión a internet (las imágenes son de URLs externas)

### La app se ve diferente
Asegúrate de estar usando `AppTheme.darkTheme` en MaterialApp

---

## 🚀 Próximos Pasos

Ahora que tienes la UI base:

1. **Probar todo** - Navega por la app, abre detalles
2. **Personalizar** - Ajusta colores/fuentes si quieres
3. **Agregar más páginas:**
   - Login moderna
   - Seat Selection (selección de asientos)
   - Food Menu (menú de comidas)
   - Admin Dashboard

4. **Conectar con API** (cuando tengas Firebase)
   - Reemplazar `mockMovies` con llamadas al backend
   - Implementar Riverpod providers

---

## ✅ Checklist

- [ ] Ejecutar `flutter pub get`
- [ ] Actualizar `main.dart` con el código de arriba
- [ ] Ejecutar `flutter run -d chrome --web-port=5173`
- [ ] Ver la Movies Page funcionando
- [ ] Hacer tap en una película
- [ ] Ver el bottom sheet con detalle
- [ ] Probar filtros de género
- [ ] Scroll horizontal y vertical

---

## 🎉 ¡Listo!

Has avanzado MUCHÍSIMO hoy:
- ✅ Design System completo
- ✅ Componentes reutilizables
- ✅ UI moderna de Movies
- ✅ Arquitectura escalable

**¿Qué sigue?** Decide si quieres:
- A) Crear Seat Selection UI
- B) Crear Food Menu UI
- C) Crear Login Page moderna
- D) Crear Admin Dashboard

---

**Creado por:** Claude Code
**Fecha:** 2025-11-03
