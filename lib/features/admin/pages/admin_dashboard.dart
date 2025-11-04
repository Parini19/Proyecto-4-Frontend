import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import 'movies_management_page.dart';
import 'screenings_management_page.dart';
import 'users_management_page.dart';
import '../../movies/pages/movies_page_new.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    _DashboardOverview(),
    MoviesManagementPage(),
    ScreeningsManagementPage(),
    UsersManagementPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Row(
        children: [
          // Side Navigation
          _buildSideNav(isDark),

          // Main Content
          Expanded(
            child: _pages[_selectedIndex],
          ),
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
                      Text(
                        'Cinema Management',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
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
                  icon: Icons.movie,
                  label: 'Películas',
                  index: 1,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.event,
                  label: 'Funciones',
                  index: 2,
                  isDark: isDark,
                ),
                _buildNavItem(
                  icon: Icons.people,
                  label: 'Usuarios',
                  index: 3,
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
                      MaterialPageRoute(builder: (context) => MoviesPageNew()),
                    );
                  },
                  isDark: isDark,
                ),
                _buildQuickAction(
                  icon: Icons.analytics,
                  label: 'Reportes',
                  onTap: () {},
                  isDark: isDark,
                ),
                _buildQuickAction(
                  icon: Icons.settings,
                  label: 'Configuración',
                  onTap: () {},
                  isDark: isDark,
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
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MoviesPageNew()),
              );
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
  }) {
    return ListTile(
      dense: true,
      leading: Icon(icon, color: AppColors.textSecondary, size: 20),
      title: Text(
        label,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.textSecondary,
        ),
      ),
      onTap: onTap,
    );
  }
}

// Dashboard Overview Widget
class _DashboardOverview extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Stats Cards Row
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.movie,
                    title: 'Películas',
                    value: '24',
                    change: '+3',
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
                    value: '48',
                    change: '+8',
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
                    icon: Icons.confirmation_number,
                    title: 'Boletos Vendidos',
                    value: '342',
                    change: '+12%',
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
                    icon: Icons.attach_money,
                    title: 'Ingresos Hoy',
                    value: '\$4,280',
                    change: '+18%',
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

            // Recent Activity Section
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

            // Quick Stats Row
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
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textTertiary,
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
