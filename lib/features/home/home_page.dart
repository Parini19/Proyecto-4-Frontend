import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../core/theme/app_spacing.dart';
import '../auth/login_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _scrollController = ScrollController();
  bool _isScrolled = false;
  int _currentHeroIndex = 0;
  late Timer _heroTimer;

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
    _heroTimer.cancel();
    super.dispose();
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
              // Hero Section (Netflix-style)
              SliverToBoxAdapter(
                child: _buildHeroSection(size, isDark),
              ),

              // En Cartelera Section
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'En Cartelera',
                  isDark: isDark,
                  size: size,
                ),
              ),

              // Próximos Estrenos Section
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Próximos Estrenos',
                  isDark: isDark,
                  size: size,
                ),
              ),

              // Más Populares Section
              SliverToBoxAdapter(
                child: _buildSection(
                  title: 'Más Populares',
                  isDark: isDark,
                  size: size,
                ),
              ),

              // Footer
              SliverToBoxAdapter(
                child: _buildFooter(isDark),
              ),
            ],
          ),

          // App Bar (Netflix-style - transparent when at top)
          _buildAppBar(isDark),
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

                SizedBox(width: 40),

                // Navigation Links (Desktop only)
                if (MediaQuery.of(context).size.width > 768)
                  Expanded(
                    child: Row(
                      children: [
                        _buildNavLink('Inicio', true, isDark),
                        _buildNavLink('Cartelera', false, isDark),
                        _buildNavLink('Próximos', false, isDark),
                        _buildNavLink('Promociones', false, isDark),
                      ],
                    ),
                  ),

                Spacer(),

                // Search Icon
                IconButton(
                  icon: Icon(
                    Icons.search,
                    color: _isScrolled
                        ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                        : Colors.white,
                  ),
                  onPressed: () {},
                ),

                SizedBox(width: 8),

                // Login Button
                ElevatedButton(
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
                ),

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

  Widget _buildNavLink(String text, bool isActive, bool isDark) {
    return Padding(
      padding: EdgeInsets.only(right: 24),
      child: TextButton(
        onPressed: () {},
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

  Widget _buildHeroSection(Size size, bool isDark) {
    final heroMovies = [
      {
        'title': 'Oppenheimer',
        'description': 'La historia del físico J. Robert Oppenheimer y su papel en el desarrollo de la bomba atómica.',
        'rating': '8.5',
        'duration': '180 min',
        'genre': 'Drama • Biografía',
      },
      {
        'title': 'Barbie',
        'description': 'Después de ser expulsada de Barbieland, Barbie y Ken se embarcan en una aventura en el mundo real.',
        'rating': '7.8',
        'duration': '114 min',
        'genre': 'Comedia • Aventura',
      },
      {
        'title': 'Avatar 2',
        'description': 'Jake Sully y Neytiri han formado una familia y están haciendo todo lo posible por mantenerse juntos.',
        'rating': '7.9',
        'duration': '192 min',
        'genre': 'Ciencia Ficción • Aventura',
      },
    ];

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
                  padding: EdgeInsets.symmetric(
                    horizontal: _getHorizontalPadding(size.width),
                    vertical: 80,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Title
                      Text(
                        currentMovie['title']!,
                        style: TextStyle(
                          fontSize: isDesktop ? 72 : (isTablet ? 56 : 40),
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.1,
                        ),
                      ),

                      SizedBox(height: 16),

                      // Info Row
                      Wrap(
                        spacing: 16,
                        runSpacing: 8,
                        children: [
                          _buildInfoChip(Icons.star, currentMovie['rating']!),
                          _buildInfoChip(Icons.access_time, currentMovie['duration']!),
                          _buildInfoChip(Icons.category, currentMovie['genre']!),
                        ],
                      ),

                      SizedBox(height: 16),

                      // Description
                      Container(
                        constraints: BoxConstraints(maxWidth: isDesktop ? 600 : 500),
                        child: Text(
                          currentMovie['description']!,
                          style: AppTypography.bodyLarge.copyWith(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: isDesktop ? 18 : 16,
                            height: 1.5,
                          ),
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      SizedBox(height: 32),

                      // Buttons
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          ElevatedButton.icon(
                            onPressed: () {},
                            icon: Icon(Icons.play_arrow, size: 28),
                            label: Text('Ver Ahora'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
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
    required bool isDark,
    required Size size,
  }) {
    final isDesktop = size.width > 1024;
    final isTablet = size.width > 768 && size.width <= 1024;
    final isMobile = size.width <= 768;

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
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 8,
              itemBuilder: (context, index) {
                return _buildMovieCard(index, isDark, size);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieCard(int index, bool isDark, Size size) {
    final isDesktop = size.width > 1024;
    final cardWidth = isDesktop ? 250.0 : 180.0;

    return Container(
      width: cardWidth,
      margin: EdgeInsets.only(right: 16),
      child: InkWell(
        onTap: () {},
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Poster
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withOpacity(0.3),
                      AppColors.secondary.withOpacity(0.2),
                    ],
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.movie,
                    size: 64,
                    color: Colors.white.withOpacity(0.3),
                  ),
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Película ${index + 1}',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.star, color: Colors.amber, size: 16),
                SizedBox(width: 4),
                Text(
                  '${7 + (index % 3) * 0.5}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
              color: AppColors.textSecondary,
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
      builder: (context) => Container(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Inicio'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.movie),
              title: Text('Cartelera'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.upcoming),
              title: Text('Próximos'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: Icon(Icons.local_offer),
              title: Text('Promociones'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
