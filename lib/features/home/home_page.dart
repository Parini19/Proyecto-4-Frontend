import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/data/movies_data.dart';
import '../../core/models/movie_model.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/user_service.dart';
import '../../core/providers/theme_provider.dart';
import '../../core/providers/movies_provider.dart';
import '../../core/providers/cinema_provider.dart';
import '../../core/widgets/floating_chat_bubble.dart';
import '../auth/login_page.dart';
import '../movies/pages/movie_details_page.dart';
import '../booking/pages/food_menu_page.dart';
import '../admin/pages/admin_dashboard.dart';
import '../cinema/pages/cinema_selection_page.dart';
import '../user/pages/my_tickets_page.dart';
import '../user/pages/purchase_history_page.dart';
import '../user/pages/promotions_page.dart';
import '../user/pages/profile_page.dart';

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

    // Auto-change hero every 8 seconds - will be bounded by actual movie count
    _heroTimer = Timer.periodic(Duration(seconds: 8), (timer) {
      if (mounted) {
        setState(() {
          // Will be properly bounded in _buildHeroSectionContent
          _currentHeroIndex = _currentHeroIndex + 1;
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

  void _searchMovies(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Get all movies from the provider
    try {
      final allMoviesAsync = ref.read(moviesProvider);
      await allMoviesAsync.when(
        data: (movies) {
          setState(() {
            _searchResults = movies.where((movie) {
              return movie.title.toLowerCase().contains(query.toLowerCase()) ||
                  movie.genre.toLowerCase().contains(query.toLowerCase());
            }).toList();
          });
        },
        loading: () {},
        error: (error, stack) {
          setState(() {
            _searchResults = [];
          });
        },
      );
    } catch (e) {
      setState(() {
        _searchResults = [];
      });
    }
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

    // Watch the movie providers
    final nowPlayingMoviesAsync = ref.watch(nowPlayingFilteredByCinemaProvider);
    final upcomingMoviesAsync = ref.watch(upcomingFilteredByCinemaProvider);
    final popularMoviesAsync = ref.watch(popularFilteredByCinemaProvider);

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
                  child: _buildHeroSectionWithProvider(size, isDark, popularMoviesAsync),
                ),

                // Cinema Selection Banner
                SliverToBoxAdapter(
                  child: _buildCinemaSelectionBanner(ref, isDark, size),
                ),

                // En Cartelera Section
                SliverToBoxAdapter(
                  child: Container(
                    key: _carteleraKey,
                    child: nowPlayingMoviesAsync.when(
                      data: (movies) => _buildSection(
                        title: 'En Cartelera',
                        movies: movies,
                        isDark: isDark,
                        size: size,
                      ),
                      loading: () => _buildLoadingSection(isDark),
                      error: (error, stack) => _buildErrorSection('Error al cargar películas en cartelera', isDark),
                    ),
                  ),
                ),

                // Próximos Estrenos Section
                SliverToBoxAdapter(
                  child: Container(
                    key: _proximosKey,
                    child: upcomingMoviesAsync.when(
                      data: (movies) => _buildSection(
                        title: 'Próximos Estrenos',
                        movies: movies,
                        isDark: isDark,
                        size: size,
                      ),
                      loading: () => _buildLoadingSection(isDark),
                      error: (error, stack) => _buildErrorSection('Error al cargar próximos estrenos', isDark),
                    ),
                  ),
                ),

                // Más Populares Section
                SliverToBoxAdapter(
                  child: Container(
                    key: _popularesKey,
                    child: popularMoviesAsync.when(
                      data: (movies) => _buildSection(
                        title: 'Más Populares',
                        movies: movies,
                        isDark: isDark,
                        size: size,
                      ),
                      loading: () => _buildLoadingSection(isDark),
                      error: (error, stack) => _buildErrorSection('Error al cargar películas populares', isDark),
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

          // Mobile Bottom Navigation (Thumb-zone friendly)
          if (size.width < 768) _buildMobileBottomNav(isDark),

          // Chat IA flotante
          const FloatingChatBubble(),
        ],
      ),
    );
  }

  // Mobile Bottom Navigation Bar - Thumb-zone accessible
  Widget _buildMobileBottomNav(bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: Offset(0, -5),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildBottomNavItem(
                icon: Icons.home_rounded,
                label: 'Inicio',
                isActive: true,
                isDark: isDark,
                onTap: () {
                  _scrollController.animateTo(
                    0,
                    duration: Duration(milliseconds: 500),
                    curve: Curves.easeInOut,
                  );
                },
              ),
              _buildBottomNavItem(
                icon: Icons.movie_outlined,
                label: 'Cartelera',
                isActive: false,
                isDark: isDark,
                onTap: () {
                  _scrollToSection(_carteleraKey);
                },
              ),
              if (_authService.isAuthenticated) ...[
                _buildBottomNavItem(
                  icon: Icons.confirmation_number_outlined,
                  label: 'Boletos',
                  isActive: false,
                  isDark: isDark,
                  onTap: () {
                    // TODO: Navigate to tickets page
                  },
                ),
                _buildBottomNavItem(
                  icon: Icons.person_outline,
                  label: 'Perfil',
                  isActive: false,
                  isDark: isDark,
                  onTap: () {
                    // Show user menu
                  },
                ),
              ] else ...[
                _buildBottomNavItem(
                  icon: Icons.local_offer_outlined,
                  label: 'Ofertas',
                  isActive: false,
                  isDark: isDark,
                  onTap: () {
                    // TODO: Navigate to promotions
                  },
                ),
                _buildBottomNavItem(
                  icon: Icons.login,
                  label: 'Entrar',
                  isActive: false,
                  isDark: isDark,
                  onTap: () {
                    Navigator.pushNamed(context, '/login');
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavItem({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: isActive
                    ? AppColors.primary
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              ),
              SizedBox(height: 4),
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? AppColors.primary
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                ),
              ),
            ],
          ),
        ),
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
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildNavLink('Inicio', true, isDark),
                          _buildNavLink('Cartelera', false, isDark),
                          _buildNavLink('Próximos', false, isDark),
                          if (_authService.isAuthenticated) ...[
                            _buildNavLink('Mis Boletos', false, isDark),
                            _buildNavLink('Historial', false, isDark),
                          ],
                          _buildNavLink('Promociones', false, isDark),
                          _buildNavLink('Dulcería', false, isDark),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                ]
                else
                  // Spacer to push right-side elements to the end
                  const Spacer(),

                // Theme Toggle Button
                _buildThemeToggle(isDark),

                SizedBox(width: 8),

                // Search Icon/Bar - Fixed width to prevent layout shift
                if (_isSearching)
                  Container(
                    width: MediaQuery.of(context).size.width > 768 ? 400 : 250,
                    height: 40,
                    margin: EdgeInsets.symmetric(horizontal: 8),
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
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => MyTicketsPage()),
            );
          } else if (text == 'Historial') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PurchaseHistoryPage()),
            );
          } else if (text == 'Promociones') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PromotionsPage()),
            );
          } else if (text == 'Dulcería') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FoodMenuPage()),
            );
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
            value: 'history',
            child: Row(
              children: [
                Icon(Icons.history, size: 20),
                SizedBox(width: 12),
                Text('Historial'),
              ],
            ),
          ),
          if (_userService.isAdmin()) ...[
            PopupMenuDivider(),
            PopupMenuItem(
              value: 'admin',
              child: Row(
                children: [
                  Icon(Icons.admin_panel_settings, size: 20, color: AppColors.primary),
                  SizedBox(width: 12),
                  Text(
                    'Panel de Admin',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
          } else if (value == 'admin') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => AdminDashboard()),
            );
          } else if (value == 'profile') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ProfilePage()),
            );
          } else if (value == 'history') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => PurchaseHistoryPage()),
            );
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

    // Safe color handling
    final hasColors = movie.colors.isNotEmpty;
    final defaultColors = ['#1a1a1a', '#3a3a3a'];
    final gradientColors = hasColors
        ? movie.colors.map((colorHex) => Color(int.parse(colorHex.replaceFirst('#', '0xff')))).toList()
        : defaultColors.map((colorHex) => Color(int.parse(colorHex.replaceFirst('#', '0xff')))).toList();

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
                  boxShadow: [
                    BoxShadow(
                      color: gradientColors[0].withOpacity(0.3),
                      blurRadius: 12,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradiente de fondo (fallback si no hay poster)
                      if (movie.posterUrl == null || movie.posterUrl!.isEmpty)
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: gradientColors,
                            ),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.movie_outlined,
                              size: 64,
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                        )
                      // Imagen del poster
                      else
                        Image.network(
                          movie.posterUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: gradientColors,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.movie_outlined,
                                  size: 64,
                                  color: Colors.white.withOpacity(0.2),
                                ),
                              ),
                            );
                          },
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
            ListTile(
              leading: Icon(Icons.restaurant_menu),
              title: Text('Dulcería'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FoodMenuPage()),
                );
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
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MyTicketsPage()),
                  );
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
              if (_userService.isAdmin()) ...[
                Divider(),
                ListTile(
                  leading: Icon(Icons.admin_panel_settings, color: AppColors.primary),
                  title: Text(
                    'Panel de Admin',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => AdminDashboard()),
                    );
                  },
                ),
              ],
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

  // Helper widget for loading state
  Widget _buildLoadingSection(bool isDark) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(32),
      child: Center(
        child: CircularProgressIndicator(
          color: AppColors.primary,
        ),
      ),
    );
  }

  // Helper widget for error state
  Widget _buildErrorSection(String message, bool isDark) {
    return Container(
      height: 300,
      padding: EdgeInsets.all(32),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: AppColors.error,
            ),
            SizedBox(height: 16),
            Text(
              message,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // Hero section with provider support
  Widget _buildHeroSectionWithProvider(Size size, bool isDark, AsyncValue<List<MovieModel>> popularMoviesAsync) {
    return popularMoviesAsync.when(
      data: (movies) {
        final heroMovies = movies.take(3).toList();
        return _buildHeroSectionContent(size, isDark, heroMovies);
      },
      loading: () => _buildLoadingSection(isDark),
      error: (error, stack) => _buildErrorSection('Error al cargar destacados', isDark),
    );
  }

  // Existing hero section content (extracted for reuse) - RESPONSIVE VERSION
  Widget _buildHeroSectionContent(Size size, bool isDark, List<MovieModel> heroMovies) {
    if (heroMovies.isEmpty) {
      return SizedBox.shrink();
    }

    // Ensure index is within bounds
    final safeIndex = heroMovies.length > 0 ? (_currentHeroIndex % heroMovies.length) : 0;
    final currentHeroMovie = heroMovies[safeIndex];

    // Detect screen size for responsive design
    final isMobile = size.width < 768;
    final isTablet = size.width >= 768 && size.width < 1024;
    final isDesktop = size.width >= 1024;

    // Mobile: Portrait-optimized with overlay (current design works well)
    if (isMobile) {
      return _buildMobileHero(size, isDark, currentHeroMovie, heroMovies);
    }

    // Desktop: Cinematic wide-screen hero with side poster card
    return _buildDesktopHero(size, isDark, currentHeroMovie, heroMovies);
  }

  // Mobile Hero: Optimized for portrait screens (vertical layout)
  Widget _buildMobileHero(Size size, bool isDark, MovieModel movie, List<MovieModel> heroMovies) {
    // Safe bounds check for current hero index
    final safeHeroIndex = heroMovies.isNotEmpty ? (_currentHeroIndex % heroMovies.length) : 0;

    // Safe color handling
    final hasColors = movie.colors.isNotEmpty;
    final defaultColors = ['#1a1a1a', '#3a3a3a'];
    final gradientColors = hasColors
        ? movie.colors.map((colorHex) => Color(int.parse(colorHex.replaceFirst('#', '0xff')))).toList()
        : defaultColors.map((colorHex) => Color(int.parse(colorHex.replaceFirst('#', '0xff')))).toList();

    return Container(
      height: size.height * 0.65,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image with Gradient
          AnimatedSwitcher(
            duration: Duration(milliseconds: 800),
            child: Container(
              key: ValueKey(safeHeroIndex),
              width: double.infinity,
              height: size.height * 0.65,
              decoration: BoxDecoration(
                image: (movie.posterUrl != null && movie.posterUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(movie.posterUrl!),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      )
                    : null,
                gradient: (movie.posterUrl == null || movie.posterUrl!.isEmpty)
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                      (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Content
          Positioned(
            left: 20,
            right: 20,
            bottom: 32,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  movie.title,
                  style: AppTypography.displaySmall.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 32,
                    color: Colors.white,
                    shadows: [
                      Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 15),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 12),
                // Info Row
                Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        SizedBox(width: 4),
                        Text(
                          movie.rating,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8)],
                          ),
                        ),
                      ],
                    ),
                    Text(
                      movie.genre.split(',').first.trim(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8)],
                      ),
                    ),
                    Text(
                      movie.duration,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        shadows: [Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 8)],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),
                // Button
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MovieDetailsPage(movie: movie),
                      ),
                    );
                  },
                  icon: Icon(Icons.play_arrow, size: 24),
                  label: Padding(
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    child: Text(
                      'Ver Detalles',
                      style: AppTypography.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    elevation: 8,
                    shadowColor: AppColors.primary.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),

          // Navigation Dots
          if (heroMovies.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              child: Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(
                    heroMovies.length,
                    (index) => GestureDetector(
                      onTap: () {
                        if (heroMovies.isNotEmpty) {
                          setState(() {
                            _currentHeroIndex = index % heroMovies.length;
                          });
                        }
                      },
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 300),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: safeHeroIndex == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: safeHeroIndex == index
                              ? AppColors.primary
                              : Colors.white.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Desktop Hero: Cinematic wide-screen with poster card on side
  Widget _buildDesktopHero(Size size, bool isDark, MovieModel movie, List<MovieModel> heroMovies) {
    // Safe bounds check for current hero index
    final safeHeroIndex = heroMovies.isNotEmpty ? (_currentHeroIndex % heroMovies.length) : 0;

    // Safe color handling
    final hasColors = movie.colors.isNotEmpty;
    final defaultColors = ['#1a1a1a', '#3a3a3a'];
    final gradientColors = hasColors
        ? movie.colors.map((colorHex) => Color(int.parse(colorHex.replaceFirst('#', '0xff')))).toList()
        : defaultColors.map((colorHex) => Color(int.parse(colorHex.replaceFirst('#', '0xff')))).toList();

    return Container(
      height: 600,
      width: double.infinity,
      child: Stack(
        children: [
          // Background Image (Blurred poster for backdrop effect)
          AnimatedSwitcher(
            duration: Duration(milliseconds: 1000),
            child: Container(
              key: ValueKey(safeHeroIndex),
              width: double.infinity,
              height: 600,
              decoration: BoxDecoration(
                image: (movie.posterUrl != null && movie.posterUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(movie.posterUrl!),
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      )
                    : null,
                gradient: (movie.posterUrl == null || movie.posterUrl!.isEmpty)
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: gradientColors,
                      )
                    : null,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.black.withOpacity(0.8),
                      Colors.black.withOpacity(0.7),
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.4, 0.6, 1.0],
                  ),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        (isDark ? AppColors.darkBackground : AppColors.lightBackground).withOpacity(0.3),
                        (isDark ? AppColors.darkBackground : AppColors.lightBackground),
                      ],
                      stops: [0.6, 0.85, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Content - Left side with poster and info
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 80, vertical: 60),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Poster Card
                  AnimatedSwitcher(
                    duration: Duration(milliseconds: 800),
                    child: Container(
                      key: ValueKey(safeHeroIndex),
                      width: 280,
                      height: 420,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: (movie.posterUrl == null || movie.posterUrl!.isEmpty)
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: gradientColors,
                              )
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 30,
                            offset: Offset(0, 15),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: (movie.posterUrl != null && movie.posterUrl!.isNotEmpty)
                            ? Image.network(
                                movie.posterUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: gradientColors,
                                      ),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.movie_outlined,
                                        size: 80,
                                        color: Colors.white.withOpacity(0.5),
                                      ),
                                    ),
                                  );
                                },
                              )
                            : Container(
                                child: Center(
                                  child: Icon(
                                    Icons.movie_outlined,
                                    size: 80,
                                    color: Colors.white.withOpacity(0.5),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  SizedBox(width: 60),

                  // Movie Info
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Classification Badge
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary, width: 1.5),
                          ),
                          child: Text(
                            movie.classification,
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),

                        // Title
                        Text(
                          movie.title,
                          style: AppTypography.displayLarge.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 56,
                            color: Colors.white,
                            height: 1.1,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.8),
                                blurRadius: 20,
                              ),
                            ],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 24),

                        // Rating, Genre, Duration
                        Row(
                          children: [
                            // Rating
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.amber.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.star, color: Colors.amber, size: 20),
                                  SizedBox(width: 6),
                                  Text(
                                    movie.rating,
                                    style: AppTypography.titleMedium.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 20),
                            // Genre
                            Text(
                              movie.genre,
                              style: AppTypography.titleMedium.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(width: 20),
                            // Duration
                            Row(
                              children: [
                                Icon(Icons.access_time, color: Colors.white.withOpacity(0.7), size: 20),
                                SizedBox(width: 6),
                                Text(
                                  movie.duration,
                                  style: AppTypography.titleMedium.copyWith(
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 24),

                        // Description
                        if (movie.description != null && movie.description!.isNotEmpty)
                          Container(
                            constraints: BoxConstraints(maxWidth: 600),
                            child: Text(
                              movie.description!,
                              style: AppTypography.bodyLarge.copyWith(
                                color: Colors.white.withOpacity(0.85),
                                height: 1.6,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        SizedBox(height: 32),

                        // Action Buttons
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MovieDetailsPage(movie: movie),
                                  ),
                                );
                              },
                              icon: Icon(Icons.play_arrow, size: 28),
                              label: Padding(
                                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 12),
                                child: Text(
                                  'Ver Detalles',
                                  style: AppTypography.titleMedium.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shadowColor: AppColors.primary.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Navigation Dots - Bottom Center
          if (heroMovies.isNotEmpty)
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      heroMovies.length,
                      (index) => GestureDetector(
                        onTap: () {
                          if (heroMovies.isNotEmpty) {
                            setState(() {
                              _currentHeroIndex = index % heroMovies.length;
                            });
                          }
                        },
                        child: AnimatedContainer(
                          duration: Duration(milliseconds: 300),
                          margin: EdgeInsets.symmetric(horizontal: 4),
                          width: safeHeroIndex == index ? 32 : 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: safeHeroIndex == index
                                ? AppColors.primary
                                : Colors.white.withOpacity(0.4),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // Previous/Next Arrows for Desktop
          if (heroMovies.length > 1)
            Positioned(
              left: 32,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: () {
                    if (heroMovies.isNotEmpty) {
                      setState(() {
                        _currentHeroIndex = (_currentHeroIndex - 1 + heroMovies.length) % heroMovies.length;
                      });
                    }
                  },
                  icon: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    padding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
          if (heroMovies.length > 1)
            Positioned(
              right: 32,
              top: 0,
              bottom: 0,
              child: Center(
                child: IconButton(
                  onPressed: () {
                    if (heroMovies.isNotEmpty) {
                      setState(() {
                        _currentHeroIndex = (_currentHeroIndex + 1) % heroMovies.length;
                      });
                    }
                  },
                  icon: Icon(Icons.arrow_forward_ios, color: Colors.white, size: 32),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withOpacity(0.5),
                    padding: EdgeInsets.all(16),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Cinema Selection Banner
  Widget _buildCinemaSelectionBanner(WidgetRef ref, bool isDark, Size size) {
    final selectedCinema = ref.watch(selectedCinemaProvider);
    final horizontalPadding = _getHorizontalPadding(size.width);

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 24,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CinemaSelectionPage(),
              ),
            );
          },
          borderRadius: AppSpacing.borderRadiusLG,
          child: Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              gradient: selectedCinema != null
                  ? AppColors.primaryGradient
                  : LinearGradient(
                      colors: [
                        AppColors.secondary.withOpacity(0.8),
                        AppColors.primary.withOpacity(0.6),
                      ],
                    ),
              borderRadius: AppSpacing.borderRadiusLG,
              boxShadow: [
                BoxShadow(
                  color: (selectedCinema != null ? AppColors.primary : AppColors.secondary)
                      .withOpacity(0.3),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppSpacing.borderRadiusMD,
                  ),
                  child: Icon(
                    selectedCinema != null ? Icons.location_on : Icons.add_location_alt,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        selectedCinema != null ? selectedCinema.name : '¿Dónde quieres ver tu película?',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        selectedCinema != null
                            ? '${selectedCinema.city} • Toca para cambiar'
                            : 'Selecciona tu cine para ver funciones',
                        style: AppTypography.bodySmall.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
