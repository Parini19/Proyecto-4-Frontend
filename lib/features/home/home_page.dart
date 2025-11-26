import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/data/movies_data.dart';
import '../../core/models/movie_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/widgets/floating_chat_bubble.dart';
import '../auth/login_page.dart';
import '../movies/pages/movie_details_page.dart';

import 'dart:async';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _carteleraKey = GlobalKey();
  final GlobalKey _proximosKey = GlobalKey();
  final GlobalKey _popularesKey = GlobalKey();
  final TextEditingController _searchController = TextEditingController();
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  bool _isScrolled = false;
  bool _isSearching = false;
  int _currentHeroIndex = 0;
  late Timer _heroTimer;
  List<MovieModel> _searchResults = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);

    // Auto-change hero every 8 seconds (más lento)
    _heroTimer = Timer.periodic(Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          _currentHeroIndex = (_currentHeroIndex + 1) % 3;
        });
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _heroTimer.cancel();
    super.dispose();
  }

  void _searchMovies(String query) {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    final allMovies = [
      ...MoviesData.nowPlaying,
      ...MoviesData.upcoming,
      ...MoviesData.popular,
    ];

    setState(() {
      _isSearching = true;
      _searchResults = allMovies.where((movie) {
        return movie.title.toLowerCase().contains(query.toLowerCase()) ||
            movie.genre.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  void _onScroll() {
    if (_scrollController.offset > 50 && !_isScrolled) {
      setState(() => _isScrolled = true);
    } else if (_scrollController.offset <= 50 && _isScrolled) {
      setState(() => _isScrolled = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            controller: _scrollController,
            slivers: [
              // Conditional: Show search results or regular content
              if (_isSearching) ...[
                // Search Results
                SliverToBoxAdapter(
                  child: _buildSearchResults(size, isDark),
                ),
              ] else ...[
                // Hero Section (Netflix-style)
                SliverToBoxAdapter(
                  child: _buildHeroSection(size, isDark),
                ),

                // En Cartelera Section
                SliverToBoxAdapter(
                  child: Container(
                    key: _carteleraKey,
                    child: _buildSection(
                      title: 'En Cartelera',
                      movies: MoviesData.nowPlaying,
                      isDark: isDark,
                      size: size,
                    ),
                  ),
                ),

                // Próximos Estrenos Section
                SliverToBoxAdapter(
                  child: Container(
                    key: _proximosKey,
                    child: _buildSection(
                      title: 'Próximos Estrenos',
                      movies: MoviesData.upcoming,
                      isDark: isDark,
                      size: size,
                    ),
                  ),
                ),

                // Más Populares Section
                SliverToBoxAdapter(
                  child: Container(
                    key: _popularesKey,
                    child: _buildSection(
                      title: 'Más Populares',
                      movies: MoviesData.popular,
                      isDark: isDark,
                      size: size,
                    ),
                  ),
                ),
              ],

              // Footer
              SliverToBoxAdapter(
                child: _buildFooter(isDark),
              ),
            ],
          ),

          // App Bar (Netflix-style - transparent when at top)
          _buildAppBar(isDark),

          // Chat IA flotante
          const FloatingChatBubble(),
        ],
      ),
    );
  }

  Widget _buildAppBar(bool isDark) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 200),
        height: 70,
        decoration: BoxDecoration(
          gradient: _isScrolled
              ? null
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.transparent,
                  ],
                ),
          color: _isScrolled
              ? (isDark ? AppColors.darkSurface : AppColors.lightSurface)
              : null,
          boxShadow: _isScrolled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: _getHorizontalPadding(MediaQuery.of(context).size.width)),
            child: Row(
              children: [
                // Logo
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.movie, color: Colors.white, size: 24),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Cinema',
                      style: AppTypography.headlineSmall.copyWith(
                        fontWeight: FontWeight.bold,
                        color: _isScrolled
                            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                            : Colors.white,
                      ),
                    ),
                  ],
                ),

                // Navigation Links (Desktop only) - Hide when searching
                if (!_isSearching && MediaQuery.of(context).size.width > 1024) ...[
                  SizedBox(width: 40),
                  Flexible(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildNavLink('Inicio', true, isDark),
                        _buildNavLink('Cartelera', false, isDark),
                        _buildNavLink('Próximos', false, isDark),
                        if (_authService.isAuthenticated) ...[
                          _buildNavLink('Mis Boletos', false, isDark),
                          _buildNavLink('Historial', false, isDark),
                          _buildNavLink('Food Orders', false, isDark),
                        ],
                        _buildNavLink('Promociones', false, isDark),
                      ],
                    ),
                  ),
                ],

                Spacer(),

                // Theme Toggle Button
                _buildThemeToggle(isDark),

                SizedBox(width: 8),

                // Search Icon/Bar
                if (_isSearching)
                  Flexible(
                    flex: 2,
                    child: Container(
                      height: 40,
                      margin: EdgeInsets.symmetric(horizontal: 8),
                      constraints: BoxConstraints(maxWidth: 600),
                      child: TextField(
                        controller: _searchController,
                        autofocus: true,
                        onChanged: _searchMovies,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Buscar películas...',
                          hintStyle: TextStyle(
                            color: isDark
                                ? Colors.white.withOpacity(0.5)
                                : Colors.black.withOpacity(0.5),
                          ),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          suffixIcon: IconButton(
                            icon: Icon(Icons.close),
                            onPressed: () {
                              setState(() {
                                _isSearching = false;
                                _searchController.clear();
                                _searchResults = [];
                              });
                            },
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  IconButton(
                    icon: Icon(
                      Icons.search,
                      color: _isScrolled
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : Colors.white,
                    ),
                    onPressed: () {
                      setState(() => _isSearching = true);
                    },
                  ),

                SizedBox(width: 8),

                // User Profile or Login Button
                _buildUserSection(isDark),

                // Mobile Menu
                if (MediaQuery.of(context).size.width <= 768)
                  IconButton(
                    icon: Icon(
                      Icons.menu,
                      color: _isScrolled
                          ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                          : Colors.white,
                    ),
                    onPressed: () {
                      _showMobileMenu(context, isDark);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _scrollToSection(GlobalKey key) {
    final context = key.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    }
  }

  Widget _buildNavLink(String text, bool isActive, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(right: 24),
      child: TextButton(
        onPressed: () {
          if (text == 'Inicio') {
            _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 600),
              curve: Curves.easeInOut,
            );
          } else if (text == 'Cartelera') {
            _scrollToSection(_carteleraKey);
          } else if (text == 'Próximos') {
            _scrollToSection(_proximosKey);
          } else if (text == 'Mis Boletos') {
            _showComingSoonMessage('Mis Boletos próximamente');
          } else if (text == 'Historial') {
            _showComingSoonMessage('Historial de compras próximamente');
          } else if (text == 'Promociones') {
            _showComingSoonMessage('Promociones próximamente');
          }
        },
        child: Text(
          text,
          style: AppTypography.bodyLarge.copyWith(
            color: isActive
                ? AppColors.primary
                : (_isScrolled
                    ? (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary)
                    : Colors.white.withOpacity(0.8)),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  void _showComingSoonMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildUserSection(bool isDark) {
    if (_authService.isAuthenticated) {
      final user = _authService.currentUser;
      return PopupMenuButton<String>(
        offset: Offset(0, 50),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: 'profile',
            child: Row(
              children: [
                Icon(Icons.person_outline, size: 20),
                SizedBox(width: 12),
                Text('Mi Perfil'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'tickets',
            child: Row(
              children: [
                Icon(Icons.confirmation_number_outlined, size: 20),
                SizedBox(width: 12),
                Text('Mis Boletos'),
              ],
            ),
          ),
          PopupMenuItem(
            value: 'history',
            child: Row(
              children: [
                Icon(Icons.history, size: 20),
                SizedBox(width: 12),
                Text('Historial'),
              ],
            ),
          ),
          PopupMenuDivider(),
          PopupMenuItem(
            value: 'logout',
            child: Row(
              children: [
                Icon(Icons.logout, size: 20, color: AppColors.error),
                SizedBox(width: 12),
                Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
              ],
            ),
          ),
        ],
        onSelected: (value) async {
          if (value == 'logout') {
            await _userService.logout();
            if (mounted) {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            }
          } else if (value == 'profile') {
            _showComingSoonMessage('Perfil próximamente');
          } else if (value == 'tickets') {
            _showComingSoonMessage('Mis Boletos próximamente');
          } else if (value == 'history') {
            _showComingSoonMessage('Historial de compras próximamente');
          }
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: _isScrolled
                ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                : Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primary.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppColors.primary,
                child: Text(
                  (user?.displayName?.substring(0, 1) ?? user?.email.substring(0, 1) ?? 'U').toUpperCase(),
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(width: 8),
              if (MediaQuery.of(context).size.width > 768) ...[
                Text(
                  user?.displayName ?? user?.email ?? 'Usuario',
                  style: TextStyle(
                    color: _isScrolled
                        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                        : Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(width: 4),
              ],
              Icon(
                Icons.arrow_drop_down,
                color: _isScrolled
                    ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                    : Colors.white,
              ),
            ],
          ),
        ),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person, size: 18),
            SizedBox(width: 8),
            Text('Iniciar Sesión'),
          ],
        ),
      );
    }
  }

  Widget _buildHeroSection(Size size, bool isDark) {
    // Usar las 3 primeras películas populares para el hero
    final heroMovies = MoviesData.popular.take(3).toList();
    final currentMovie = heroMovies[_currentHeroIndex];
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;

    return AnimatedSwitcher(
      duration: Duration(milliseconds: 800),
      child: Container(
        key: ValueKey(_currentHeroIndex),
        height: isDesktop ? 700 : (isTablet ? 600 : 500),
        child: Stack(
          children: [
            // Background Image/Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      AppColors.secondary.withOpacity(0.3),
                      AppColors.primary.withOpacity(0.4),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Dark overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.8),
                    ],
                  ),
                ),
              ),
            ),

            // Content
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: _getHorizontalPadding(size.width),
                    right: _getHorizontalPadding(size.width),
                    top: 80,
                    bottom: isDesktop ? 80 : (isTablet ? 60 : 40),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Title
                      Text(
                        currentMovie.title,
                        style: TextStyle(
                          fontSize: isDesktop ? 72 : (isTablet ? 56 : 32),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),

                      SizedBox(height: isDesktop ? 16 : 12),

                      // Info Row
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(Icons.star, currentMovie.rating),
                          _buildInfoChip(Icons.access_time, currentMovie.duration),
                          if (isDesktop || isTablet)
                            _buildInfoChip(Icons.category, currentMovie.genre),
                        ],
                      ),

                      SizedBox(height: isDesktop ? 16 : 12),

                      // Description
                      Container(
                        constraints: BoxConstraints(maxWidth: isDesktop ? 600 : 500),
                        child: Text(
                          currentMovie.description,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isDesktop ? 18 : 14,
                            height: 1.5,
                          ),
                          maxLines: isDesktop ? 3 : 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: isDesktop ? 32 : 16),

                      // Buttons
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.confirmation_number, size: isDesktop ? 24 : 20),
                            label: Text('Comprar Boletos'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                horizontal: isDesktop ? 32 : 20,
                                vertical: isDesktop ? 16 : 12,
                              ),
                              textStyle: TextStyle(
                                fontSize: isDesktop ? 16 : 14,
                                fontWeight: FontWeight.w600,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          if (isDesktop || isTablet)
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.info_outline),
                              label: Text('Más Info'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white, width: 2),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 32,
                                  vertical: 16,
                                ),
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Hero Indicators
            Positioned(
              bottom: 24,
              right: _getHorizontalPadding(size.width),
              child: Row(
                children: List.generate(
                  3,
                  (index) => AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    width: index == _currentHeroIndex ? 32 : 8,
                    height: 8,
                    margin: EdgeInsets.only(left: 8),
                    decoration: BoxDecoration(
                      color: index == _currentHeroIndex
                          ? AppColors.primary
                          : Colors.white.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 16),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<MovieModel> movies,
    required bool isDark,
    required Size size,
  }) {
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 40,
        horizontal: _getHorizontalPadding(size.width),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24),
          SizedBox(
            height: isDesktop ? 400 : (isTablet ? 350 : 300),
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(
                dragDevices: {
                  PointerDeviceKind.touch,
                  PointerDeviceKind.mouse,
                  PointerDeviceKind.trackpad,
                },
                scrollbars: false,
              ),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                itemCount: movies.length,
                itemBuilder: (context, index) {
                  return _buildMovieCard(movies[index], isDark, size);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(MovieModel movie, bool isDark, Size size) {
    final isDesktop = size.width > 1024;
    final cardWidth = isDesktop ? 250.0 : 180.0;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MovieDetailsPage(movie: movie),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster con gradiente único de la película
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: movie.colors.map((colorHex) {
                      return Color(int.parse(colorHex.replaceFirst('#', '0xff')));
                    }).toList(),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Color(int.parse(movie.colors[0].replaceFirst('#', '0xff'))).withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // Ícono de película
                    Center(
                      child: Icon(
                        Icons.movie_outlined,
                        size: 64,
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    // Clasificación en esquina
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          movie.classification,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12),
            // Título
            Text(
              movie.title,
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            // Género
            Text(
              movie.genre.split(' • ').first, // Solo mostrar primer género
              style: AppTypography.bodySmall.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            // Rating y duración
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  movie.rating,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.access_time, color: Theme.of(context).colorScheme.onSurfaceVariant, size: 14),
                SizedBox(width: 4),
                Text(
                  movie.duration,
                  style: AppTypography.bodySmall.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults(Size size, bool isDark) {
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;
    final horizontalPadding = _getHorizontalPadding(size.width);

    return Container(
      padding: EdgeInsets.only(
        top: 120, // Space for navbar
        left: horizontalPadding,
        right: horizontalPadding,
        bottom: 40,
      ),
      constraints: BoxConstraints(
        minHeight: MediaQuery.of(context).size.height - 120,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search header
          Text(
            _searchController.text.isEmpty
                ? 'Buscar películas'
                : 'Resultados de búsqueda',
            style: TextStyle(
              fontSize: isDesktop ? 32 : (isTablet ? 28 : 24),
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          if (_searchController.text.isNotEmpty)
            Text(
              '${_searchResults.length} ${_searchResults.length == 1 ? 'resultado' : 'resultados'} para "${_searchController.text}"',
              style: AppTypography.bodyLarge.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          SizedBox(height: 32),

          // Results grid or empty state
          if (_searchController.text.isEmpty)
            _buildEmptySearchState(isDesktop, isTablet)
          else if (_searchResults.isEmpty)
            _buildNoResultsState(isDesktop, isTablet)
          else
            _buildResultsGrid(isDesktop, isTablet, isDark, size),
        ],
      ),
    );
  }

  Widget _buildEmptySearchState(bool isDesktop, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 60),
          Icon(
            Icons.search,
            size: isDesktop ? 120 : 80,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 24),
          Text(
            'Comienza a buscar',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Escribe el nombre de una película o género',
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(bool isDesktop, bool isTablet) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(height: 60),
          Icon(
            Icons.movie_filter_outlined,
            size: isDesktop ? 120 : 80,
            color: AppColors.textTertiary,
          ),
          SizedBox(height: 24),
          Text(
            'No se encontraron resultados',
            style: TextStyle(
              fontSize: isDesktop ? 24 : 20,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Intenta con otro término de búsqueda',
            style: AppTypography.bodyMedium.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsGrid(bool isDesktop, bool isTablet, bool isDark, Size size) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: isDesktop ? 5 : (isTablet ? 4 : 2),
        childAspectRatio: 0.65,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
      ),
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final movie = _searchResults[index];
        return _buildMovieCard(movie, isDark, size);
      },
    );
  }

  Widget _buildFooter(bool isDark) {
    return Container(
      padding: EdgeInsets.all(40),
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      child: Column(
        children: [
          Text(
            '© 2025 Cinema App. Todos los derechos reservados.',
            style: AppTypography.bodySmall.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  double _getHorizontalPadding(double width) {
    if (width > 1400) return 120;
    if (width > 1024) return 80;
    if (width > 768) return 40;
    return 20;
  }

  void _showMobileMenu(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User Section
            if (_authService.isAuthenticated) ...[
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Text(
                        (_authService.currentUser?.displayName?.substring(0, 1) ??
                         _authService.currentUser?.email.substring(0, 1) ?? 'U').toUpperCase(),
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _authService.currentUser?.displayName ??
                            _authService.currentUser?.email ?? 'Usuario',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (_authService.currentUser?.displayName != null)
                            Text(
                              _authService.currentUser?.email ?? '',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
            ],

            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () {
                Navigator.pop(context);
                _scrollController.animateTo(
                  0,
                  duration: Duration(milliseconds: 600),
                  curve: Curves.easeInOut,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.movie),
              title: Text('Cartelera'),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_carteleraKey);
              },
            ),
            ListTile(
              leading: Icon(Icons.upcoming),
              title: Text('Próximos'),
              onTap: () {
                Navigator.pop(context);
                _scrollToSection(_proximosKey);
              },
            ),

            // User-specific options
            if (_authService.isAuthenticated) ...[
              Divider(),
              ListTile(
                leading: Icon(Icons.confirmation_number_outlined),
                title: Text('Mis Boletos'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonMessage('Mis Boletos próximamente');
                },
              ),
              ListTile(
                leading: Icon(Icons.history),
                title: Text('Historial'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonMessage('Historial de compras próximamente');
                },
              ),
              ListTile(
                leading: Icon(Icons.person_outline),
                title: Text('Mi Perfil'),
                onTap: () {
                  Navigator.pop(context);
                  _showComingSoonMessage('Perfil próximamente');
                },
              ),
              Divider(),
              ListTile(
                leading: Icon(Icons.logout, color: AppColors.error),
                title: Text('Cerrar Sesión', style: TextStyle(color: AppColors.error)),
                onTap: () async {
                  Navigator.pop(context);
                  await _userService.logout();
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  }
                },
              ),
            ] else ...[
              Divider(),
              ListTile(
                leading: Icon(Icons.login, color: AppColors.primary),
                title: Text('Iniciar Sesión', style: TextStyle(color: AppColors.primary)),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              ),
            ],

            ListTile(
              leading: Icon(Icons.local_offer),
              title: Text('Promociones'),
              onTap: () {
                Navigator.pop(context);
                _showComingSoonMessage('Promociones próximamente');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark) {
    final themeMode = ref.watch(themeProvider);
    final themeNotifier = ref.read(themeProvider.notifier);

    return PopupMenuButton<ThemeMode>(
      offset: Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      icon: Icon(
        themeNotifier.themeModeIcon,
        color: _isScrolled
            ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
            : Colors.white,
      ),
      tooltip: 'Cambiar tema',
      itemBuilder: (context) => [
        PopupMenuItem(
          value: ThemeMode.system,
          child: Row(
            children: [
              Icon(
                Icons.brightness_auto,
                size: 20,
                color: themeMode == ThemeMode.system ? AppColors.primary : null,
              ),
              SizedBox(width: 12),
              Text(
                'Sistema',
                style: TextStyle(
                  color: themeMode == ThemeMode.system ? AppColors.primary : null,
                  fontWeight: themeMode == ThemeMode.system ? FontWeight.w600 : null,
                ),
              ),
              if (themeMode == ThemeMode.system) ...[
                Spacer(),
                Icon(Icons.check, size: 20, color: AppColors.primary),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.light,
          child: Row(
            children: [
              Icon(
                Icons.light_mode,
                size: 20,
                color: themeMode == ThemeMode.light ? AppColors.primary : null,
              ),
              SizedBox(width: 12),
              Text(
                'Claro',
                style: TextStyle(
                  color: themeMode == ThemeMode.light ? AppColors.primary : null,
                  fontWeight: themeMode == ThemeMode.light ? FontWeight.w600 : null,
                ),
              ),
              if (themeMode == ThemeMode.light) ...[
                Spacer(),
                Icon(Icons.check, size: 20, color: AppColors.primary),
              ],
            ],
          ),
        ),
        PopupMenuItem(
          value: ThemeMode.dark,
          child: Row(
            children: [
              Icon(
                Icons.dark_mode,
                size: 20,
                color: themeMode == ThemeMode.dark ? AppColors.primary : null,
              ),
              SizedBox(width: 12),
              Text(
                'Oscuro',
                style: TextStyle(
                  color: themeMode == ThemeMode.dark ? AppColors.primary : null,
                  fontWeight: themeMode == ThemeMode.dark ? FontWeight.w600 : null,
                ),
              ),
              if (themeMode == ThemeMode.dark) ...[
                Spacer(),
                Icon(Icons.check, size: 20, color: AppColors.primary),
              ],
            ],
          ),
        ),
      ],
      onSelected: (mode) {
        themeNotifier.setThemeMode(mode);
      },
    );
  }
}
