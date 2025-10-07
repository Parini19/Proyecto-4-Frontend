import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_page.dart';
import 'features/movies/movies_page.dart';
import 'core/entities/movie_list.dart';
import 'core/entities/food_list.dart';
import 'core/services/user_service.dart';
import 'core/config.dart';

// Clase singleton para manejar la sesión del usuario
class UserSession {
  static final UserSession _instance = UserSession._internal();
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

  // Método para inicializar la sesión después del login
  void setUserData({
    required String uid,
    required String email,
    String? displayName,
    String? role,
    String? token,
  }) {
    _uid = uid;
    _email = email;
    _displayName = displayName;
    _role = role;
    _token = token;
    _isLoggedIn = true;
  }

  // Método para cerrar sesión
  void clearSession() {
    _uid = null;
    _email = null;
    _displayName = null;
    _role = null;
    _token = null;
    _isLoggedIn = false;
  }
}

// class CinemaApp extends StatelessWidget {
//   const CinemaApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final router = GoRouter(
//       routes: [
//         GoRoute(path: '/', builder: (_, __) => const HomePage()),
//         GoRoute(path: '/movies', builder: (_, __) => const MoviesPage()),
//       ],
//     );

//     return MaterialApp.router(
//       title: 'Cinema Web',
//       theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
//       routerConfig: router,
//     );
//   }
// }

class CinemaApp extends StatelessWidget {
  const CinemaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Movie Ticket App',
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
          ),
        ),
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

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Imagen agregada antes del texto y los botones
            Container(
              width: 180,
              height: 180,
              margin: EdgeInsets.only(bottom: 20),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://scontent.fsjo7-1.fna.fbcdn.net/v/t39.30808-6/470143680_2539048689619989_5880941406184717988_n.jpg?_nc_cat=109&ccb=1-7&_nc_sid=127cfc&_nc_ohc=4wFZp2nKYP0Q7kNvwH2WWls&_nc_oc=AdlmOUKzNTYj1n_3h3JdfQ9tvcU74DtHjVVQTJjnW2fNtm7mu2wtdOoqLA2D38Yq3wP0TjEoU5QT_WfRSouH-C2U&_nc_zt=23&_nc_ht=scontent.fsjo7-1.fna&_nc_gid=QAd3F8wAtEZ3G9g34CTGZA&oh=00_AfbdvyAiL9x0wzHSZKs4OhvuoWX6dIu-d6W9_nlFQwB3yA&oe=68E4B4D8',
                  fit: BoxFit.cover,
                ),
              ),
            ),
            Text(
              '¡Compra boletos fácilmente!',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/login'),
                child: Text('Iniciar sesión'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/about'),
                child: Text('Conócenos'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoviePicker extends StatelessWidget {
  const MoviePicker({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cartelera')),
      body: ListView.builder(
        itemCount: movieList.length,
        itemBuilder: (context, index) {
          final movie = movieList[index];
          return Card(
            color: Colors.black,
            margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            elevation: 4,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (movie['isNew'] == 'true')
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                        topRight: Radius.circular(8),
                      ),
                    ),
                    child: Text(
                      'ESTRENO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          movie['poster']!,
                          width: 80,
                          height: 120,
                          fit: BoxFit.cover,
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              movie['title']!,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Duración: ${movie['duration']}',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                            Text(
                              'Clasificación: ${movie['classification']}',
                              style: TextStyle(color: Colors.grey[400]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SeatSelectionPage(
                              movieTitle: movie['title']!,
                              posterUrl: movie['poster']!,
                              duration: movie['duration'],
                              classification: movie['classification'],
                            ),
                          ),
                        );
                      },
                      child: Text('Comprar boletos'),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Text(
                        'Horarios: ',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      Expanded(
                        child: Text(
                          '14:30, 17:00, 19:30, 22:00',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _message;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _message = null;
    });

    try {
      final userService = UserService(AppConfig.apiBaseUrl);
      final response = await userService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      setState(() {
        _message = response.message;
        _isSuccess = response.success;
        _isLoading = false;
      });

      if (response.success) {
        // Guardar datos del usuario en la sesión
        UserSession().setUserData(
          uid: response.uid!,
          email: response.email!,
          displayName: response.displayName,
          role: response.role,
          token: response.token,
        );
        
        // Clear form on success
        _emailController.clear();
        _passwordController.clear();
        
        // Show additional success info
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bienvenido ${response.displayName ?? response.email}! Rol: ${response.role ?? "Sin rol"}'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );
        
        // Navigate based on user role
        print('DEBUG: User role: "${response.role}"');
        print('DEBUG: Role toLowerCase: "${response.role?.toLowerCase()}"');
        print('DEBUG: Is admin check: ${response.role?.toLowerCase() == 'admin'}');
        
        if (response.role?.toLowerCase() == 'admin') {
          print('DEBUG: Navigating to /admin');
          Navigator.pushNamed(context, '/admin');
        } else {
          print('DEBUG: Navigating to /picker');
          Navigator.pushNamed(context, '/picker');
        }
      }
    } catch (e) {
      setState(() {
        _message = 'Error: $e';
        _isSuccess = false;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Inicio de sesión')),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 400),
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Cinema Login',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu email';
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                        return 'Por favor ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu contraseña';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _login,
                      child: _isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Iniciar sesión'),
                    ),
                  ),
                  if (_message != null) ...[
                    SizedBox(height: 16),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _isSuccess ? Colors.green.shade100 : Colors.red.shade100,
                        border: Border.all(
                          color: _isSuccess ? Colors.green : Colors.red,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _isSuccess ? Icons.check_circle : Icons.error,
                            color: _isSuccess ? Colors.green : Colors.red,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _message!,
                              style: TextStyle(
                                color: _isSuccess ? Colors.green.shade700 : Colors.red.shade700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminProtectedRoute extends StatefulWidget {
  @override
  _AdminProtectedRouteState createState() => _AdminProtectedRouteState();
}

class _AdminProtectedRouteState extends State<AdminProtectedRoute> {
  bool _isLoading = true;
  bool _hasAccess = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    try {
      final userSession = UserSession();
      
      print('DEBUG AdminRoute: isLoggedIn: ${userSession.isLoggedIn}');
      print('DEBUG AdminRoute: user role: "${userSession.role}"');
      print('DEBUG AdminRoute: isAdmin: ${userSession.isAdmin}');
      
      // Verificar si el usuario está logueado
      if (!userSession.isLoggedIn) {
        setState(() {
          _isLoading = false;
          _hasAccess = false;
          _errorMessage = 'Debes iniciar sesión para acceder a esta página.';
        });
        
        // Redirigir al login después de 2 segundos
        Future.delayed(Duration(seconds: 2), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
        return;
      }
      
      // Verificar si el usuario es administrador
      if (!userSession.isAdmin) {
        setState(() {
          _isLoading = false;
          _hasAccess = false;
          _errorMessage = 'Acceso denegado. Solo administradores pueden acceder a esta página.';
        });
        
        // Redirigir al inicio después de 3 segundos
        Future.delayed(Duration(seconds: 3), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/picker');
          }
        });
        return;
      }
      
      // El usuario es admin, permitir acceso
      setState(() {
        _isLoading = false;
        _hasAccess = true;
      });
      
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasAccess = false;
        _errorMessage = 'Error verificando permisos: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text('Verificando acceso...')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Verificando permisos de administrador...'),
            ],
          ),
        ),
      );
    }

    if (!_hasAccess) {
      return Scaffold(
        appBar: AppBar(title: Text('Acceso Denegado')),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.security,
                  size: 64,
                  color: Colors.red,
                ),
                SizedBox(height: 16),
                Text(
                  'Acceso Restringido',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 8),
                Text(
                  _errorMessage ?? 'No tienes permisos para acceder a esta página.',
                  style: TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                  child: Text('Ir al Login'),
                ),
                SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pushReplacementNamed(context, '/'),
                  child: Text('Volver al Inicio'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Si tiene acceso, mostrar el AdminDashboard
    return AdminDashboard();
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  void _logout(BuildContext context) {
    // Limpiar la sesión del usuario
    UserSession().clearSession();
    
    // Mostrar mensaje de confirmación
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sesión cerrada exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
    
    // Redirigir al inicio
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    final userSession = UserSession();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Bienvenido, ${userSession.displayName ?? userSession.email}',
              style: TextStyle(fontSize: 24, color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            Text(
              'Panel de Administración',
              style: TextStyle(fontSize: 22, color: Colors.white),
            ),
            SizedBox(height: 8),
            Text(
              'Gestión de Películas y Boletos',
              style: TextStyle(fontSize: 16, color: Colors.grey[400]),
            ),
            SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _logout(context),
              icon: Icon(Icons.logout),
              label: Text('Cerrar Sesión'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[600],
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MoviePicker2 extends StatelessWidget {
  final List<String> movies = [
    'Inception',
    'Interstellar',
    'The Dark Knight',
    'Avengers: Endgame',
    'Parasite',
  ];

  MoviePicker2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Cartelera')),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(movies[index], style: TextStyle(color: Colors.white)),
            trailing: ElevatedButton(
              child: Text('Buy Ticket'),
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Ticket purchased for ${movies[index]}'),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Conócenos')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Menú de botones en fila
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey[850],
                        title: Text('Contacto', style: TextStyle(color: Colors.white)),
                        content: Text(
                          'Email: info@cinema.com\nTeléfono: +1234567890\nDirección: Calle Cinema 123',
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Contacto'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey[850],
                        title: Text('Quiénes somos', style: TextStyle(color: Colors.white)),
                        content: Text(
                          'Somos una empresa dedicada a brindar la mejor experiencia cinematográfica.',
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Quiénes somos'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: Colors.grey[850],
                        title: Text('Legales', style: TextStyle(color: Colors.white)),
                        content: Text(
                          'Términos y condiciones de uso. Políticas de privacidad.',
                          style: TextStyle(color: Colors.white),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Cerrar'),
                          ),
                        ],
                      ),
                    );
                  },
                  child: Text('Legales'),
                ),
              ],
            ),
            SizedBox(height: 30),
            Text(
              'Somos un equipo apasionado por el cine y la tecnología. '
              '¡Nuestra aplicación hace que comprar boletos de cine sea fácil y rápido!',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}

class FoodPage extends StatefulWidget {
  const FoodPage({super.key});

  @override
  _FoodPageState createState() => _FoodPageState();
}

class _FoodPageState extends State<FoodPage> {
  List<int> quantities = List.filled(foods.length, 0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Dulcería')),
      body: Padding(
        padding: EdgeInsets.all(8),
        child: GridView.builder(
          itemCount: foods.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemBuilder: (context, index) {
            final food = foods[index];
            return Card(
              color: Colors.grey[850],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          food['image'],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      food['name'],
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '\₡${food['price']}',
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: quantities[index] > 0
                              ? () {
                                  setState(() {
                                    quantities[index]--;
                                  });
                                }
                              : null,
                          icon: Icon(Icons.remove, color: Colors.red),
                          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.grey[700],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${quantities[index]}',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              quantities[index]++;
                            });
                          },
                          icon: Icon(Icons.add, color: Colors.green),
                          constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                          padding: EdgeInsets.zero,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class SeatSelectionPage extends StatefulWidget {
  final String movieTitle;
  final String posterUrl;
  final String? duration;
  final String? classification;

  const SeatSelectionPage({
    super.key,
    required this.movieTitle,
    required this.posterUrl,
    this.duration,
    this.classification,
  });

  @override
  _SeatSelectionPageState createState() => _SeatSelectionPageState();
}

class _SeatSelectionPageState extends State<SeatSelectionPage> {
  static const int rows = 6;
  static const int cols = 10;
  List<List<bool>> selectedSeats = List.generate(
    rows,
    (_) => List.filled(cols, false),
  );

  int get selectedCount =>
      selectedSeats.expand((row) => row).where((s) => s).length;

  String getRowLetter(int row) => String.fromCharCode(65 + row); // A, B, C...

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Selecciona tus asientos')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    widget.posterUrl,
                    width: 60,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.movieTitle,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.duration != null)
                        Text(
                          'Duración: ${widget.duration}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                      if (widget.classification != null)
                        Text(
                          'Clasificación: ${widget.classification}',
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Text(
              'Pantalla',
              style: TextStyle(color: Colors.redAccent, fontSize: 16),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 8),
              height: 8,
              width: double.infinity,
              color: Colors.redAccent,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: rows,
                itemBuilder: (context, row) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          child: Text(
                            getRowLetter(row),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(cols, (col) {
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedSeats[row][col] = !selectedSeats[row][col];
                                  });
                                },
                                child: Container(
                                  width: 24,
                                  height: 24,
                                  margin: EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: selectedSeats[row][col]
                                        ? Colors.red
                                        : Colors.grey[700],
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: selectedSeats[row][col]
                                          ? Colors.red
                                          : Colors.grey[600]!,
                                    ),
                                  ),
                                  child: selectedSeats[row][col]
                                      ? Icon(
                                          Icons.check,
                                          color: Colors.white,
                                          size: 16,
                                        )
                                      : null,
                                ),
                              );
                            }),
                          ),
                        ),
                        SizedBox(width: 8),
                        SizedBox(
                          width: 20,
                          child: Text(
                            getRowLetter(row),
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Asientos seleccionados: $selectedCount',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: selectedCount > 0
                    ? () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Boletos comprados: $selectedCount asientos para ${widget.movieTitle}',
                            ),
                          ),
                        );
                      }
                    : null,
                child: Text('Proceder al pago'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
