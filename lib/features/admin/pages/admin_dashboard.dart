import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/services/user_service.dart';
import '../../../core/services/booking_service.dart';
import '../../../core/providers/service_providers.dart';
import '../../../core/providers/movies_provider.dart';
import '../../../core/models/food_item.dart';
import '../../../core/widgets/floating_chat_bubble.dart';
import 'movies_management_page.dart';
import 'screenings_management_page.dart';
import 'theater_rooms_management_page.dart';
import 'users_management_page.dart';
import 'food_combos_management_page.dart';
import 'food_orders_management_page.dart';
import 'audit_log_management_page.dart';
import 'reports_page.dart';
import 'settings_page.dart';
import '../presentation/pages/cinema_management_page.dart';
import '../../home/home_page.dart';
import '../../auth/login_page.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;
  final UserService _userService = UserService();

  final List<Widget> _pages = [
    _DashboardOverview(),
    CinemaManagementPage(),
    MoviesManagementPage(),
    ScreeningsManagementPage(),
    TheaterRoomsManagementPage(),
    FoodCombosManagementPage(),
    FoodOrdersManagementPage(),
    UsersManagementPage(),
    AuditLogManagementPage()
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            children: [
              // Side Navigation
              _buildSideNav(isDark),

              // Main Content
              Expanded(
                child: _pages[_selectedIndex],
              ),
            ],
          ),

          // Chat IA flotante
          const FloatingChatBubble(),
        ],
      ),
    );
  }

  Widget _buildSideNav(bool isDark) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.cinemaGradient : null,
        color: isDark ? null : AppColors.lightSurfaceElevated,
        border: Border(
          right: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Admin Header
          Container(
            padding: AppSpacing.paddingLG,
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    shape: BoxShape.circle,
                    boxShadow: isDark ? AppColors.glowShadow : null,
                  ),
                  child: Icon(
                    Icons.admin_panel_settings,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin Panel',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Builder(
                        builder: (context) {
                          final isDark = Theme.of(context).brightness == Brightness.dark;
                          return Text(
                            'Cinema Management',
                            style: AppTypography.bodySmall.copyWith(
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: AppSpacing.paddingMD,
              children: [
                _buildNavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  index: 0,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.business,
                  label: 'Cines / Sedes',
                  index: 1,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.movie,
                  label: 'Películas',
                  index: 2,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.event,
                  label: 'Funciones',
                  index: 3,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.meeting_room,
                  label: 'Salas de Cine',
                  index: 4,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.fastfood,
                  label: 'Food Combos',
                  index: 5,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.receipt_long,
                  label: 'Órdenes de Comida',
                  index: 6,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.people,
                  label: 'Usuarios',
                  index: 7,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.history,
                  label: 'Bitácora',
                  index: 8,
                  isDark: isDark,
                ),

                SizedBox(height: AppSpacing.lg),
                Divider(),
                SizedBox(height: AppSpacing.md),

                // Quick Actions
                Text(
                  'ACCESOS RÁPIDOS',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                SizedBox(height: AppSpacing.sm),
                _buildQuickAction(
                  icon: Icons.web,
                  label: 'Ver Sitio Web',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => HomePage()),
                    );
                  },
                  isDark: isDark,
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                  ),
                ),
                _buildQuickAction(
                  icon: Icons.analytics,
                  label: 'Reportes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ReportsPage()),
                    );
                  },
                  isDark: isDark,
                  gradient: LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                ),
                _buildQuickAction(
                  icon: Icons.settings,
                  label: 'Configuración',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SettingsPage()),
                    );
                  },
                  isDark: isDark,
                  gradient: LinearGradient(
                    colors: [Color(0xFF06B6D4), Color(0xFF0891B2)],
                  ),
                ),
              ],
            ),
          ),

          Divider(height: 1),

          // Logout
          ListTile(
            leading: Icon(Icons.logout, color: AppColors.error),
            title: Text(
              'Cerrar Sesión',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
            onTap: () async {
              await _userService.logout();
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _selectedIndex == index;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppColors.primary : AppColors.textSecondary,
        ),
        title: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            color: isSelected ? AppColors.primary : null,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
        selected: isSelected,
        selectedTileColor: AppColors.primary.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMD,
        ),
        onTap: () {
          setState(() => _selectedIndex = index);
        },
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required LinearGradient gradient,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppSpacing.borderRadiusMD,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: AppSpacing.borderRadiusMD,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(AppSpacing.xs),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: AppSpacing.borderRadiusXS,
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    label,
                    style: AppTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Icon(Icons.arrow_forward_ios, color: Colors.white.withOpacity(0.7), size: 14),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DashboardOverview extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final moviesAsync = ref.watch(moviesProvider);
    final screeningsAsync = ref.watch(screeningsProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          SizedBox(width: AppSpacing.sm),
          CircleAvatar(
            radius: 18,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          SizedBox(width: AppSpacing.md),
        ],
      ),
      body: moviesAsync.when(
        loading: () => Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
        data: (movies) {
          return screeningsAsync.when(
            loading: () => Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error: $error')),
            data: (screenings) {
              final totalMovies = movies.length;
              final totalFoodItems = mockFoodItems.length;

              // Filter screenings for today
              final now = DateTime.now();
              final today = DateTime(now.year, now.month, now.day);
              final tomorrow = today.add(Duration(days: 1));
              final todayScreenings = screenings.where((s) =>
                s.startTime.isAfter(today) && s.startTime.isBefore(tomorrow)
              ).length;

              return SingleChildScrollView(
                padding: AppSpacing.pagePadding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.movie,
                            title: 'Películas',
                            value: '$totalMovies',
                            change: 'Total',
                            isPositive: true,
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.primaryDark],
                            ),
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.event,
                            title: 'Funciones Hoy',
                            value: '$todayScreenings',
                            change: 'Activas',
                            isPositive: true,
                            gradient: LinearGradient(
                              colors: [AppColors.secondary, AppColors.secondaryDark],
                            ),
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.fastfood,
                            title: 'Combos Dulcería',
                            value: '$totalFoodItems',
                            change: 'Disponibles',
                            isPositive: true,
                            gradient: LinearGradient(
                              colors: [AppColors.success, Color(0xFF059669)],
                            ),
                            isDark: isDark,
                          ),
                        ),
                        SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: _buildStatCard(
                            icon: Icons.local_movies,
                            title: 'Funciones Totales',
                            value: '${screenings.length}',
                            change: 'Sistema',
                            isPositive: true,
                            gradient: LinearGradient(
                              colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                            ),
                            isDark: isDark,
                          ),
                        ),
                      ],
                    ),

            SizedBox(height: AppSpacing.xl),

            Text(
              'Actividad Reciente',
              style: AppTypography.titleLarge.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.md),

            _buildActivityCard(
              icon: Icons.movie_creation,
              title: 'Nueva Película Agregada',
              subtitle: '"Oppenheimer" fue agregada al catálogo',
              time: 'Hace 2 horas',
              color: AppColors.primary,
              isDark: isDark,
            ),

            _buildActivityCard(
              icon: Icons.calendar_today,
              title: 'Función Programada',
              subtitle: '5 nuevas funciones para el fin de semana',
              time: 'Hace 4 horas',
              color: AppColors.secondary,
              isDark: isDark,
            ),

            _buildActivityCard(
              icon: Icons.people,
              title: 'Nuevo Usuario Registrado',
              subtitle: '15 nuevos usuarios hoy',
              time: 'Hace 1 hora',
              color: AppColors.success,
              isDark: isDark,
            ),

            SizedBox(height: AppSpacing.xl),
            Row(
              children: [
                Expanded(
                  child: _buildQuickStatCard(
                    title: 'Ocupación Promedio',
                    value: '78%',
                    icon: Icons.event_seat,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildQuickStatCard(
                    title: 'Película Más Vista',
                    value: 'Avatar 2',
                    icon: Icons.star,
                    isDark: isDark,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildQuickStatCard(
                    title: 'Sala Más Usada',
                    value: 'Sala 3',
                    icon: Icons.meeting_room,
                    isDark: isDark,
                  ),
                ),
              ],
            ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String change,
    required bool isPositive,
    required LinearGradient gradient,
    required bool isDark,
  }) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: Colors.white.withOpacity(0.9), size: 32),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.xs,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: AppSpacing.borderRadiusSM,
                ),
                child: Row(
                  children: [
                    Icon(
                      isPositive ? Icons.trending_up : Icons.trending_down,
                      color: Colors.white,
                      size: 14,
                    ),
                    SizedBox(width: 4),
                    Text(
                      change,
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.md),
          Text(
            value,
            style: AppTypography.displaySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String time,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusSM,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.labelSmall.copyWith(
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStatCard({
    required String title,
    required String value,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 28),
          SizedBox(height: AppSpacing.sm),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
