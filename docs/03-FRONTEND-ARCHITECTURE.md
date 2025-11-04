# Frontend Architecture Documentation

**Proyecto:** Cinema Management System - Frontend (Flutter)
**Framework:** Flutter 3.35.4 / Dart 3.9.2+
**Arquitectura:** Clean Architecture
**Última actualización:** 2025-11-03

---

## Tabla de Contenidos

1. [Visión General](#visión-general)
2. [Clean Architecture en Flutter](#clean-architecture-en-flutter)
3. [Estructura de Directorios](#estructura-de-directorios)
4. [Core Layer](#core-layer)
5. [Features Layer](#features-layer)
6. [State Management](#state-management)
7. [Routing & Navigation](#routing--navigation)
8. [Services Layer](#services-layer)
9. [User Session Management](#user-session-management)
10. [Plataformas Soportadas](#plataformas-soportadas)
11. [Dependencias](#dependencias)
12. [Mejores Prácticas](#mejores-prácticas)
13. [Próximos Pasos](#próximos-pasos)

---

## Visión General

El frontend del Cinema Management System está construido con **Flutter** siguiendo principios de **Clean Architecture**, separando la lógica de negocio de la presentación y permitiendo escalabilidad y mantenibilidad.

### Principios Fundamentales

- **Separación de Capas:** Core (dominio) independiente de UI
- **Testeable:** Lógica de negocio sin dependencia de widgets
- **Multiplataforma:** Web, Android, iOS con una sola codebase
- **State Management:** Riverpod preparado para escalabilidad
- **Type Safety:** Aprovechamiento de Dart's strong typing

---

## Clean Architecture en Flutter

```
┌─────────────────────────────────────────────────────────────┐
│                  PRESENTATION LAYER                          │
│                    (lib/features/)                           │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Auth Pages  │  │ Movie Pages  │  │  User Pages  │     │
│  │  (Widgets)   │  │  (Widgets)   │  │  (Widgets)   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                            │                                │
│                            ↓                                │
└─────────────────────────────────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                    APPLICATION LAYER                         │
│                      (lib/core/)                            │
│                                                             │
│  ┌──────────────────────────────────────────────────┐     │
│  │             Business Logic                        │     │
│  │  (Services, State Management)                    │     │
│  └──────────────────────────────────────────────────┘     │
│                            │                                │
└─────────────────────────────────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                     DOMAIN LAYER                             │
│                  (lib/core/entities/)                        │
│                                                             │
│  ┌──────────────────────────────────────────────────┐     │
│  │              Domain Entities                      │     │
│  │  (User, Movie, Booking, FoodCombo, etc.)         │     │
│  └──────────────────────────────────────────────────┘     │
│                                                             │
└─────────────────────────────────────────────────────────────┘
                             │
                             ↓
┌─────────────────────────────────────────────────────────────┐
│                  INFRASTRUCTURE LAYER                        │
│                (lib/core/api_client.dart)                    │
│                                                             │
│  ┌──────────────┐  ┌──────────────────────────────┐       │
│  │  API Client  │  │   External Integrations      │       │
│  │    (Dio)     │  │   (Backend REST API)         │       │
│  └──────────────┘  └──────────────────────────────┘       │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

---

## Estructura de Directorios

```
C:\Users\Guillermo Parini\Documents\Cinema Frontend\Proyecto-4-Frontend/
├── lib/
│   ├── main.dart                      # Entry point (ProviderScope)
│   ├── app.dart                       # Main app widget & routing
│   │
│   ├── core/                          # CORE LAYER
│   │   ├── config.dart                # App configuration (API URL)
│   │   ├── api_client.dart            # HTTP client (Dio)
│   │   │
│   │   ├── entities/                  # DOMAIN ENTITIES
│   │   │   ├── user.dart              # User model
│   │   │   ├── movie_list.dart        # Movie data (static)
│   │   │   └── food_list.dart         # Food data (static)
│   │   │
│   │   └── services/                  # BUSINESS LOGIC SERVICES
│   │       └── user_service.dart      # User authentication & management
│   │
│   └── features/                      # PRESENTATION LAYER
│       ├── auth/
│       │   └── login_page.dart        # Login UI
│       ├── home/
│       │   └── home_page.dart         # Home/Dashboard UI
│       ├── movies/
│       │   └── movies_page.dart       # Movies listing UI
│       └── users/
│           └── users_page.dart        # Users management UI
│
├── web/                               # Web platform files
│   └── index.html
│
├── android/                           # Android platform files
├── ios/                               # iOS platform files
├── linux/                             # Linux platform files
├── windows/                           # Windows platform files
├── macos/                             # macOS platform files
│
├── docs/                              # Documentation
├── test/                              # Tests
│
├── pubspec.yaml                       # Dependencies
├── analysis_options.yaml              # Linting rules
└── README.md
```

---

## Core Layer

### config.dart

**Responsabilidad:** Configuración centralizada de la aplicación

```dart
class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://localhost:7238',
  );
}
```

**Uso:**
```bash
flutter run -d chrome --web-port=5173 --dart-define=API_BASE_URL=https://api.production.com
```

---

### api_client.dart

**Responsabilidad:** Cliente HTTP para comunicación con backend

```dart
import 'package:dio/dio.dart';

class ApiClient {
  final Dio _dio;
  final String baseUrl;

  ApiClient({String? baseUrl})
      : baseUrl = baseUrl ?? AppConfig.apiBaseUrl,
        _dio = Dio(BaseOptions(
          baseUrl: baseUrl ?? AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 5),
          receiveTimeout: const Duration(seconds: 10),
        ));

  // Health check
  Future<Map<String, dynamic>> health() async {
    final response = await _dio.get('/health');
    return response.data;
  }

  // Get movies
  Future<List<MovieDto>> getMovies() async {
    final response = await _dio.get('/api/movies');
    return (response.data as List)
        .map((json) => MovieDto.fromJson(json))
        .toList();
  }
}
```

**Ventajas de Dio:**
- Interceptors para logging y autenticación
- Timeout configuration
- Cancelación de requests
- Better error handling

**TODO: Agregar interceptor para JWT token:**
```dart
_dio.interceptors.add(InterceptorsWrapper(
  onRequest: (options, handler) {
    final token = UserSession.instance.token;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  },
));
```

---

### entities/user.dart

**Responsabilidad:** Modelo de dominio para usuario

```dart
class User {
  final String uid;
  final String email;
  final String displayName;
  final bool emailVerified;
  final bool disabled;

  User({
    required this.uid,
    required this.email,
    required this.displayName,
    this.emailVerified = false,
    this.disabled = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      emailVerified: json['emailVerified'] as bool? ?? false,
      disabled: json['disabled'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'emailVerified': emailVerified,
      'disabled': disabled,
    };
  }
}
```

---

### entities/movie_list.dart

**Responsabilidad:** Datos estáticos de películas (temporal)

```dart
final List<Map<String, String>> movieList = [
  {
    'title': 'Demon Slayer Castillo Infinito',
    'poster': 'https://...',
    'isNew': 'true',
    'duration': '120 min',
    'classification': 'PG-13',
  },
  // ... más películas
];
```

**⚠️ TODO:** Reemplazar con datos dinámicos desde API usando `MovieService`.

---

### entities/food_list.dart

**Responsabilidad:** Datos estáticos de alimentos (temporal)

```dart
final List<Map<String, dynamic>> foodList = [
  {
    'name': 'Palomitas Grandes',
    'image': 'https://...',
    'price': 1200,  // Colones
  },
  // ... más items
];
```

**⚠️ TODO:** Reemplazar con datos dinámicos desde API usando `FoodComboService`.

---

### services/user_service.dart

**Responsabilidad:** Lógica de autenticación y gestión de usuarios

```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserService {
  final String baseUrl;

  UserService(this.baseUrl);

  // Login
  Future<LoginResponse> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/FirebaseTest/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Login failed: ${response.body}');
    }
  }

  // Fetch all users (admin)
  Future<List<User>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/FirebaseTest/get-all-users'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => User.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch users');
    }
  }
}
```

**LoginResponse:**
```dart
class LoginResponse {
  final bool success;
  final String message;
  final String? uid;
  final String? email;
  final String? displayName;
  final String? role;
  final String? token;

  LoginResponse({
    required this.success,
    required this.message,
    this.uid,
    this.email,
    this.displayName,
    this.role,
    this.token,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      success: json['success'] as bool,
      message: json['message'] as String,
      uid: json['uid'] as String?,
      email: json['email'] as String?,
      displayName: json['displayName'] as String?,
      role: json['role'] as String?,
      token: json['token'] as String?,
    );
  }
}
```

**⚠️ TODO:** Migrar de `http` a `Dio` para consistencia.

---

## Features Layer

### auth/login_page.dart

**Responsabilidad:** UI de autenticación

```dart
class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userService = UserService(AppConfig.apiBaseUrl);
      final response = await userService.login(
        _emailController.text,
        _passwordController.text,
      );

      if (response.success) {
        // Guardar sesión
        UserSession.instance.setUserData(
          uid: response.uid!,
          email: response.email!,
          displayName: response.displayName!,
          role: response.role!,
          token: response.token!,
        );

        // Navegar según rol
        if (response.role?.toLowerCase() == 'admin') {
          Navigator.pushNamed(context, '/admin');
        } else {
          Navigator.pushNamed(context, '/picker');
        }
      } else {
        setState(() => _errorMessage = response.message);
      }
    } catch (e) {
      setState(() => _errorMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'El email es requerido';
                    }
                    if (!value.contains('@')) {
                      return 'Email inválido';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contraseña es requerida';
                    }
                    return null;
                  },
                ),
                if (_errorMessage != null)
                  Text(_errorMessage!, style: TextStyle(color: Colors.red)),
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleLogin,
                  child: _isLoading
                      ? CircularProgressIndicator()
                      : Text('Iniciar sesión'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

**Validaciones:**
- Email requerido y formato válido
- Password requerido
- Loading state durante autenticación
- Error handling con mensajes al usuario

---

### home/home_page.dart

**Responsabilidad:** Dashboard principal (ejemplo con Riverpod)

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final api = ref.read(apiClientProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Cinema Home')),
      body: Center(
        child: Column(
          children: [
            Text('API Base URL: ${AppConfig.apiBaseUrl}'),
            ElevatedButton(
              onPressed: () async {
                try {
                  final result = await api.health();
                  print('Health check: $result');
                } catch (e) {
                  print('Error: $e');
                }
              },
              child: Text('Test Health'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### movies/movies_page.dart

**Responsabilidad:** Listado de películas desde API

```dart
class MoviesPage extends ConsumerStatefulWidget {
  @override
  _MoviesPageState createState() => _MoviesPageState();
}

class _MoviesPageState extends ConsumerState<MoviesPage> {
  List<MovieDto> _movies = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  Future<void> _loadMovies() async {
    try {
      final api = ref.read(apiClientProvider);
      final movies = await api.getMovies();
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(child: Text('Error: $_error'));
    }

    return ListView.builder(
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return ListTile(
          title: Text(movie.title),
          subtitle: Text('Year: ${movie.year}'),
        );
      },
    );
  }
}
```

---

## State Management

### Estrategias Actuales

| Scope | Método | Implementación |
|-------|--------|----------------|
| **Global User Session** | Singleton | `UserSession.instance` |
| **Feature State** | StatefulWidget | `setState()` |
| **Dependency Injection** | Riverpod Provider | `apiClientProvider` |
| **Navigation** | MaterialApp routes | `Navigator.pushNamed()` |

---

### UserSession Singleton (app.dart)

```dart
class UserSession {
  static final UserSession _instance = UserSession._internal();
  static UserSession get instance => _instance;

  factory UserSession() => _instance;
  UserSession._internal();

  String? _uid;
  String? _email;
  String? _displayName;
  String? _role;
  String? _token;
  bool _isLoggedIn = false;

  // Getters
  String? get uid => _uid;
  String? get email => _email;
  String? get displayName => _displayName;
  String? get role => _role;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isAdmin => _role?.toLowerCase() == 'admin';

  // Set user data
  void setUserData({
    required String uid,
    required String email,
    required String displayName,
    required String role,
    required String token,
  }) {
    _uid = uid;
    _email = email;
    _displayName = displayName;
    _role = role;
    _token = token;
    _isLoggedIn = true;
  }

  // Clear session (logout)
  void clearSession() {
    _uid = null;
    _email = null;
    _displayName = null;
    _role = null;
    _token = null;
    _isLoggedIn = false;
  }
}
```

**⚠️ Limitaciones:**
- No persiste entre reinicios de app
- No reactivo (no notifica cambios automáticamente)

**✅ Solución Recomendada:** Migrar a Riverpod StateNotifier + flutter_secure_storage

---

### Riverpod Integration (Preparado)

**main.dart:**
```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    ProviderScope(
      child: const CinemaApp(),
    ),
  );
}
```

**Providers existentes:**
```dart
// lib/features/home/home_page.dart
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());
```

**⚠️ TODO:** Expandir uso de Riverpod para:
- User session state
- Movie list state
- Shopping cart state
- Seat selection state

---

## Routing & Navigation

### Rutas Actuales (MaterialApp)

**app.dart:**
```dart
class CinemaApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cinema App',
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Colors.red,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LandingPage(),
        '/login': (context) => LoginPage(),
        '/admin': (context) => AdminProtectedRoute(),
        '/picker': (context) => MoviePicker(),
        '/food': (context) => FoodPage(),
        '/about': (context) => AboutUsPage(),
      },
    );
  }
}
```

**Navegación:**
```dart
// Navegar a otra ruta
Navigator.pushNamed(context, '/login');

// Navegar y reemplazar (no volver atrás)
Navigator.pushReplacementNamed(context, '/admin');

// Volver atrás
Navigator.pop(context);
```

---

### Route Guards (Admin Protection)

**AdminProtectedRoute:**
```dart
class AdminProtectedRoute extends StatefulWidget {
  @override
  _AdminProtectedRouteState createState() => _AdminProtectedRouteState();
}

class _AdminProtectedRouteState extends State<AdminProtectedRoute> {
  @override
  void initState() {
    super.initState();
    _checkAuthorization();
  }

  void _checkAuthorization() {
    final session = UserSession.instance;

    if (!session.isLoggedIn) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return;
    }

    if (!session.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/picker');
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = UserSession.instance;

    if (!session.isLoggedIn || !session.isAdmin) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(
        child: Column(
          children: [
            Text('Welcome, ${session.displayName}!'),
            Text('Role: ${session.role}'),
            ElevatedButton(
              onPressed: () {
                session.clearSession();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

### GoRouter (Preparado, no activo)

**⚠️ TODO:** Migrar a GoRouter para:
- Navegación declarativa
- Deep linking
- Route guards más elegantes
- Type-safe routes

**Ejemplo de configuración GoRouter:**
```dart
final goRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => LandingPage(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => LoginPage(),
    ),
    GoRoute(
      path: '/admin',
      redirect: (context, state) {
        if (!UserSession.instance.isAdmin) return '/login';
        return null;
      },
      builder: (context, state) => AdminDashboard(),
    ),
  ],
);
```

---

## Services Layer

### Servicios Actuales

| Servicio | Propósito | Estado |
|----------|-----------|--------|
| **UserService** | Autenticación y gestión de usuarios | ✅ Implementado |
| **ApiClient** | HTTP client base | ✅ Implementado |

---

### Servicios Pendientes (TODO)

| Servicio | Propósito | Prioridad |
|----------|-----------|-----------|
| **MovieService** | CRUD de películas | Alta |
| **ScreeningService** | Gestión de proyecciones | Alta |
| **BookingService** | Reservas y asientos | Alta |
| **FoodComboService** | Combos de alimentos | Media |
| **FoodOrderService** | Órdenes de comida | Media |
| **PaymentService** | Procesamiento de pagos | Baja (Mock) |

---

## User Session Management

### Persistencia de Token (TODO)

**Problema:** Token se pierde al reiniciar app.

**Solución:** Usar `flutter_secure_storage`

**Instalación:**
```yaml
dependencies:
  flutter_secure_storage: ^9.0.0
```

**Implementación:**
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }

  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }

  static Future<void> deleteToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

**Uso en login:**
```dart
final token = response.token!;
await SecureStorage.saveToken(token);
UserSession.instance.setUserData(...);
```

**Restaurar sesión al iniciar app:**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final token = await SecureStorage.getToken();
  if (token != null) {
    // Verificar token con backend
    // Restaurar UserSession
  }
  runApp(MyApp());
}
```

---

## Plataformas Soportadas

### Web (Primaria)

**Configuración:**
- Puerto: 5173
- Browser: Chrome
- Hot reload: Sí

**Comando:**
```bash
flutter run -d chrome --web-port=5173 --dart-define=API_BASE_URL=https://localhost:7238
```

**Build:**
```bash
flutter build web
```

**Deployment:**
- Firebase Hosting
- GitHub Pages
- Netlify/Vercel

---

### Android

**Build APK:**
```bash
flutter build apk --release
```

**Build AAB (Play Store):**
```bash
flutter build appbundle --release
```

**Signing:** Configurar en `android/app/build.gradle`

---

### iOS

**Requisitos:**
- macOS con Xcode
- Apple Developer Account

**Build:**
```bash
flutter build ios --release
```

---

## Dependencias

### Producción

```yaml
dependencies:
  flutter:
    sdk: flutter

  # State Management
  flutter_riverpod: ^3.0.0

  # Navigation
  go_router: ^16.2.1

  # HTTP Client
  dio: ^5.9.0
  http: ^1.1.0  # Legacy, migrar a Dio

  # Logging
  logger: ^2.6.1

  # UI
  cupertino_icons: ^1.0.8
```

### Desarrollo

```yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
```

### Dependencias Futuras (TODO)

```yaml
  # Secure storage
  flutter_secure_storage: ^9.0.0

  # Image handling
  cached_network_image: ^3.3.0

  # Date/Time
  intl: ^0.19.0

  # Forms
  flutter_form_builder: ^9.0.0

  # Charts (admin dashboard)
  fl_chart: ^0.66.0

  # QR Code
  qr_flutter: ^4.1.0

  # Animations
  animations: ^2.0.11
```

---

## Mejores Prácticas

### 1. Estructura de Archivos
- Agrupar por feature, no por tipo
- Un widget por archivo (excepto widgets pequeños privados)
- Nombres descriptivos: `login_page.dart`, no `page1.dart`

### 2. State Management
- **Local state:** `setState()` para widgets simples
- **App state:** Riverpod para estado compartido
- **Persistent state:** flutter_secure_storage para tokens

### 3. Error Handling
```dart
try {
  final result = await service.fetchData();
  setState(() => _data = result);
} on DioException catch (e) {
  if (e.response?.statusCode == 401) {
    // Redirect to login
  } else {
    // Show error message
  }
} catch (e) {
  // Generic error handling
}
```

### 4. Responsive Design
```dart
ConstrainedBox(
  constraints: BoxConstraints(maxWidth: 600),
  child: content,
)
```

### 5. Performance
- Usar `const` constructors donde sea posible
- Lazy loading de imágenes
- Pagination para listas largas

---

## Próximos Pasos

1. ✅ Migrar completamente a Riverpod para state management
2. ✅ Implementar GoRouter para navegación
3. ✅ Agregar flutter_secure_storage para tokens
4. ✅ Crear MovieService, BookingService, etc.
5. ✅ Reemplazar datos estáticos por API calls
6. ✅ Implementar tests unitarios y de widgets
7. ✅ Agregar interceptor de autenticación a Dio
8. ✅ Implementar refresh token logic
9. ✅ Optimizar performance (lazy loading, caching)
10. ✅ Build para Android/iOS

---

**Mantenido por:** Equipo de Desarrollo Cinema System
**Última revisión:** 2025-11-03
