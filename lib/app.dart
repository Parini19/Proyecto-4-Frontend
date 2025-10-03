import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_page.dart';
import 'features/movies/movies_page.dart';
import 'core/entities/movie_list.dart';
import 'core/entities/food_list.dart';

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
        '/admin': (context) => AdminDashboard(),
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
                onPressed: () => Navigator.pushNamed(context, '/picker'),
                child: Text('Cartelera'),
              ),
            ),
            SizedBox(height: 10),
            SizedBox(
              width: 220,
              child: ElevatedButton(
                onPressed: () => Navigator.pushNamed(context, '/food'),
                child: Text('Dulcería'),
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
                    color: Colors.redAccent,
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Center(
                      child: Text(
                        'ESTRENO',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text(
                    movie['title'] ?? '',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  height: 400,
                  width: 300,
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie['poster'] ?? '',
                        fit: BoxFit.cover,
                        height: 400,
                        width: 300,
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Duración: ${movie['duration'] ?? ''}',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                      Text(
                        'Clasificación: ${movie['classification'] ?? ''}',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: ElevatedButton(
                    child: Text('VER HORARIOS'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SeatSelectionPage(
                            movieTitle: movie['title'] ?? '',
                            posterUrl: movie['poster'] ?? '',
                            duration: movie['duration'],
                            classification: movie['classification'],
                          ),
                        ),
                      );
                    },
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

class LoginPage extends StatelessWidget {
  final TextEditingController userController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: userController,
              decoration: InputDecoration(
                labelText: 'Username',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              style: TextStyle(color: Colors.white),
            ),
            TextField(
              controller: passController,
              decoration: InputDecoration(
                labelText: 'Password',
                labelStyle: TextStyle(color: Colors.white),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
              ),
              obscureText: true,
              style: TextStyle(color: Colors.white),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Dummy admin login
                if (userController.text == 'admin' &&
                    passController.text == 'admin') {
                  Navigator.pushReplacementNamed(context, '/admin');
                }
              },
              child: Text('Login'),
            ),
          ],
        ),
      ),
    );
  }
}

class AdminDashboard extends StatelessWidget {
  const AdminDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Center(
        child: Text(
          'Manage Movies & Tickets',
          style: TextStyle(fontSize: 22, color: Colors.white),
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
                    content: Text('Ticket bought for ${movies[index]}!'),
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
                      builder: (_) => AlertDialog(
                        title: Text(
                          'Contacto',
                          style: TextStyle(color: Colors.black),
                        ),
                        content: Text(
                          'Email: contacto@cinemaapp.com\nTel: +123456789',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  },
                  child: Text('Contacto'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          'Quiénes somos',
                          style: TextStyle(color: Colors.black),
                        ),
                        content: Text(
                          'Somos un equipo dedicado a mejorar tu experiencia en el cine.',
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    );
                  },
                  child: Text('Quiénes somos'),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: Text(
                          'Legales',
                          style: TextStyle(color: Colors.black),
                        ),
                        content: Text(
                          'Todos los derechos reservados. Consulta nuestros términos y condiciones.',
                          style: TextStyle(color: Colors.black),
                        ),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(food['image'], fit: BoxFit.cover),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      food['name'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 4),
                    Text(
                      '₡${food['price']}',
                      style: TextStyle(fontSize: 15, color: Colors.redAccent),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              if (quantities[index] > 0) quantities[index]--;
                            });
                          },
                        ),
                        Text(
                          '${quantities[index]}',
                          style: TextStyle(fontSize: 16, color: Colors.white),
                        ),
                        IconButton(
                          icon: Icon(Icons.add, color: Colors.white),
                          onPressed: () {
                            setState(() {
                              quantities[index]++;
                            });
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    ElevatedButton(
                      onPressed: quantities[index] > 0
                          ? () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${food['name']} agregado al carrito (${quantities[index]})',
                                  ),
                                ),
                              );
                            }
                          : null,
                      child: Text('Agregar al carrito'),
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
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                      if (widget.duration != null)
                        Text(
                          'Duración: ${widget.duration}',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                        ),
                      if (widget.classification != null)
                        Text(
                          'Clasificación: ${widget.classification}',
                          style: TextStyle(fontSize: 14, color: Colors.white70),
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
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 24,
                        alignment: Alignment.center,
                        child: Text(
                          getRowLetter(row),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      SizedBox(width: 6),
                      Expanded(
                        child: Row(
                          children: List.generate(cols, (col) {
                            int seatNumber = cols - col;
                            bool isSelected = selectedSeats[row][col];
                            return Expanded(
                              child: Column(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedSeats[row][col] = !isSelected;
                                      });
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 2,
                                        horizontal: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: isSelected
                                            ? Colors.green
                                            : Colors.grey[700],
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1,
                                        ),
                                      ),
                                      height: 32,
                                      child: Center(
                                        child: Icon(
                                          isSelected
                                              ? Icons.event_seat
                                              : Icons.event_seat_outlined,
                                          color: Colors.white,
                                          size: 22,
                                        ),
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    '$seatNumber',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }),
                        ),
                      ),
                    ],
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
                              'Procediendo al pago de $selectedCount asientos...',
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
