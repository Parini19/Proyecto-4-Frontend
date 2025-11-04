# Cinema Frontend - Documentación

**Framework:** Flutter 3.35.4 / Dart 3.9.2+
**Última actualización:** 2025-11-03

---

## 📚 Documentación del Frontend

Esta carpeta contiene la documentación específica del frontend Flutter del Cinema Management System.

---

## 📖 Documentos

### [03-FRONTEND-ARCHITECTURE.md](./03-FRONTEND-ARCHITECTURE.md)

Documentación completa de la arquitectura del frontend incluyendo:
- Clean Architecture en Flutter
- Estructura de directorios
- Core Layer (entities, services, config)
- Features Layer (UI pages)
- State Management (Riverpod)
- Routing & Navigation
- Plataformas soportadas (Web, Android, iOS)
- Dependencias y mejores prácticas

---

## 🔗 Documentación Completa del Proyecto

Para ver la documentación completa del sistema (backend + frontend), visita:

**📁 Ubicación:** `C:\Users\Guillermo Parini\Documents\Cinema\docs\`

### Documentos Principales:

| Documento | Descripción |
|-----------|-------------|
| [README.md](../../Cinema/docs/README.md) | Índice principal de documentación |
| [00-PROJECT-OVERVIEW.md](../../Cinema/docs/00-PROJECT-OVERVIEW.md) | Visión general del sistema |
| [01-WORK-PLAN.md](../../Cinema/docs/01-WORK-PLAN.md) | Plan de trabajo detallado |
| [02-BACKEND-ARCHITECTURE.md](../../Cinema/docs/02-BACKEND-ARCHITECTURE.md) | Arquitectura backend (.NET) |
| **[03-FRONTEND-ARCHITECTURE.md](./03-FRONTEND-ARCHITECTURE.md)** | **Arquitectura frontend (este doc)** |
| [04-API-DOCUMENTATION.md](../../Cinema/docs/04-API-DOCUMENTATION.md) | Documentación de API |
| [RESUMEN-EJECUTIVO.md](../../Cinema/docs/RESUMEN-EJECUTIVO.md) | Resumen ejecutivo del proyecto |

---

## 🚀 Quick Start

### Requisitos
- Flutter SDK 3.35.4+
- Dart 3.9.2+
- VS Code o Android Studio
- Chrome (para desarrollo web)

### Setup Inicial

```bash
# 1. Instalar dependencias
flutter pub get

# 2. Ejecutar en Chrome (Web)
flutter run -d chrome --web-port=5173 --dart-define=API_BASE_URL=https://localhost:7238

# 3. Ejecutar en Android
flutter run -d android

# 4. Build para producción (Web)
flutter build web
```

---

## 🏗️ Estructura del Proyecto

```
lib/
├── main.dart                      # Entry point
├── app.dart                       # Main app widget
│
├── core/                          # CORE LAYER
│   ├── config.dart                # Configuración (API URL)
│   ├── api_client.dart            # HTTP client (Dio)
│   ├── entities/                  # Modelos de datos
│   │   ├── user.dart
│   │   ├── movie_list.dart
│   │   └── food_list.dart
│   └── services/                  # Servicios de negocio
│       └── user_service.dart
│
└── features/                      # FEATURES LAYER
    ├── auth/
    │   └── login_page.dart
    ├── home/
    │   └── home_page.dart
    ├── movies/
    │   └── movies_page.dart
    └── users/
        └── users_page.dart
```

---

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter_riverpod: ^3.0.0     # State management
  go_router: ^16.2.1           # Navigation (preparado)
  dio: ^5.9.0                  # HTTP client
  http: ^1.1.0                 # HTTP legacy
  logger: ^2.6.1               # Logging
```

---

## 🎯 Estado Actual

### ✅ Implementado
- [x] Clean Architecture base
- [x] Login page con validación
- [x] Admin dashboard con route guards
- [x] Movie picker/cartelera (datos estáticos)
- [x] Seat selection interactivo
- [x] Food ordering page
- [x] UserService para autenticación
- [x] ApiClient con Dio
- [x] Session management (Singleton)
- [x] Routing básico

### ⚠️ Pendiente
- [ ] Migración a Riverpod para state management global
- [ ] Migración a GoRouter
- [ ] Integración con API real (reemplazar datos estáticos)
- [ ] Persistencia de token (flutter_secure_storage)
- [ ] MovieService, ScreeningService, BookingService
- [ ] Tests (unit, widget, integration)
- [ ] Build para Android/iOS

---

## 🔧 Configuración

### Variables de Entorno

El frontend usa `--dart-define` para configurar el API URL:

```bash
flutter run --dart-define=API_BASE_URL=https://api.production.com
```

**Default:** `https://localhost:7238` (desarrollo)

### Archivo de Configuración

**`lib/core/config.dart`:**
```dart
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://localhost:7238',
  );
}
```

---

## 🎨 Tema

El app usa **Material Design 3** con tema oscuro:

```dart
ThemeData(
  brightness: Brightness.dark,
  primaryColor: Colors.red,
  scaffoldBackgroundColor: Colors.black,
)
```

---

## 🔐 Autenticación

### UserSession (Singleton)

Gestión global de sesión de usuario:

```dart
UserSession.instance.setUserData(
  uid: '...',
  email: '...',
  displayName: '...',
  role: '...',
  token: '...',
);

// Verificar si es admin
if (UserSession.instance.isAdmin) {
  // Acceso admin
}

// Logout
UserSession.instance.clearSession();
```

**⚠️ Limitación:** La sesión no persiste entre reinicios. Se pierde el token.

**✅ Solución:** Implementar `flutter_secure_storage` (pendiente).

---

## 📱 Plataformas

### Web (Primaria)
- **Puerto:** 5173
- **Browser:** Chrome
- **Hot reload:** ✅ Sí

### Android
- **Min SDK:** 21 (Android 5.0)
- **Target SDK:** 34 (Android 14)
- **Build:** `flutter build apk`

### iOS
- **Min Version:** 12.0
- **Build:** `flutter build ios`

---

## 🧪 Testing

### Ejecutar Tests

```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests
flutter drive --target=test_driver/app.dart
```

**Estado:** Framework configurado, tests pendientes.

---

## 📊 Performance

### Optimizaciones Recomendadas

1. **Imágenes:**
   - Usar `cached_network_image` para caché
   - Lazy loading de imágenes

2. **Listas:**
   - Implementar paginación
   - Usar `ListView.builder` (ya implementado)

3. **State:**
   - Minimizar rebuilds innecesarios
   - Usar `const` constructors

4. **Code:**
   - Tree shaking habilitado
   - Code splitting con lazy loading

---

## 🚀 Deployment

### Web (Firebase Hosting)

```bash
# Build
flutter build web --release

# Deploy
firebase deploy --only hosting
```

### Android (Play Store)

```bash
# Build AAB
flutter build appbundle --release

# Firmar y subir a Play Console
```

### iOS (App Store)

```bash
# Build
flutter build ios --release

# Usar Xcode para archive y upload
```

---

## 🔗 Links Útiles

- **Flutter Docs:** https://docs.flutter.dev
- **Riverpod Docs:** https://riverpod.dev
- **Dio Documentation:** https://pub.dev/packages/dio
- **GoRouter Guide:** https://pub.dev/packages/go_router

---

## 📝 Convenciones de Código

### Naming
- **Archivos:** `snake_case.dart`
- **Clases:** `PascalCase`
- **Variables/métodos:** `camelCase`
- **Constantes:** `camelCase` o `SCREAMING_SNAKE_CASE`

### Widgets
- Un widget por archivo (excepto widgets pequeños privados)
- Usar `const` constructors siempre que sea posible
- Preferir `StatelessWidget` sobre `StatefulWidget` cuando no haya estado

### Async
```dart
Future<void> loadData() async {
  try {
    final data = await service.fetchData();
    setState(() => _data = data);
  } catch (e) {
    // Handle error
  }
}
```

---

## 🐛 Troubleshooting

### Error: No se puede conectar con el backend
1. Verificar que backend está corriendo en `https://localhost:7238`
2. Verificar CORS configurado en backend
3. Verificar certificado SSL (aceptar en navegador)

### Error: Token expirado
1. Hacer logout y login nuevamente
2. Verificar que token no ha expirado (60 min)

### Hot reload no funciona
1. Reiniciar flutter: `r` en terminal
2. Hot restart: `R` en terminal
3. Detener y volver a ejecutar

---

## 👥 Contribuir

### Workflow
1. Crear branch: `feature/nombre-feature`
2. Desarrollar feature
3. Ejecutar tests: `flutter test`
4. Ejecutar linter: `flutter analyze`
5. Crear Pull Request

### Code Review
- Todo código debe pasar por code review
- Debe cumplir con linting rules
- Tests deben pasar

---

## 📞 Soporte

Para más información, consulta la **documentación completa del proyecto** en:

`C:\Users\Guillermo Parini\Documents\Cinema\docs\`

---

**Mantenido por:** Equipo de Desarrollo Cinema System
**Última revisión:** 2025-11-03
