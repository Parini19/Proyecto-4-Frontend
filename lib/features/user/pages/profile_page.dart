import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _isEditing = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final user = _authService.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _emailController.text = user.email ?? '';
      // Phone would come from Firestore user profile
      _phoneController.text = '';
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Here you would save to Firestore
      await Future.delayed(Duration(seconds: 1)); // Simulated save

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Perfil actualizado exitosamente'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );

      setState(() {
        _isEditing = false;
        _isSaving = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al actualizar perfil'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = _authService.currentUser;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
              tooltip: 'Editar perfil',
            ),
        ],
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // Profile Picture
          Center(
            child: Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.primaryGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
                if (_isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
                          width: 3,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 20,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          SizedBox(height: 32),

          // Form
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Información Personal',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                // Name
                TextFormField(
                  controller: _nameController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'Nombre completo',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusMD,
                    ),
                    filled: !_isEditing,
                    fillColor: !_isEditing
                        ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                        : null,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa tu nombre';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16),

                // Email
                TextFormField(
                  controller: _emailController,
                  enabled: false, // Email cannot be changed
                  decoration: InputDecoration(
                    labelText: 'Correo electrónico',
                    prefixIcon: Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusMD,
                    ),
                    filled: true,
                    fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                    helperText: 'El correo no se puede modificar',
                  ),
                ),

                SizedBox(height: 16),

                // Phone
                TextFormField(
                  controller: _phoneController,
                  enabled: _isEditing,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: Icon(Icons.phone_outlined),
                    border: OutlineInputBorder(
                      borderRadius: AppSpacing.borderRadiusMD,
                    ),
                    filled: !_isEditing,
                    fillColor: !_isEditing
                        ? (isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant)
                        : null,
                  ),
                  keyboardType: TextInputType.phone,
                ),

                SizedBox(height: 32),

                // Save/Cancel buttons
                if (_isEditing) ...[
                  Row(
                    children: [
                      Expanded(
                        child: CinemaButton(
                          text: 'Cancelar',
                          onPressed: () {
                            _loadUserData();
                            setState(() => _isEditing = false);
                          },
                          variant: ButtonVariant.secondary,
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: CinemaButton(
                          text: _isSaving ? 'Guardando...' : 'Guardar',
                          onPressed: _isSaving ? null : _saveProfile,
                          icon: Icons.check,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                ],

                Divider(height: 48),

                // Account Settings
                Text(
                  'Configuración de Cuenta',
                  style: AppTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),

                _buildSettingsTile(
                  icon: Icons.lock_outline,
                  title: 'Cambiar contraseña',
                  subtitle: 'Actualiza tu contraseña',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Funcionalidad próximamente'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  isDark: isDark,
                ),

                _buildSettingsTile(
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  subtitle: 'Gestiona tus preferencias',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Funcionalidad próximamente'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  isDark: isDark,
                ),

                _buildSettingsTile(
                  icon: Icons.language,
                  title: 'Idioma',
                  subtitle: 'Español',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Funcionalidad próximamente'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  isDark: isDark,
                ),

                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Ayuda y soporte',
                  subtitle: 'Preguntas frecuentes',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Funcionalidad próximamente'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  isDark: isDark,
                ),

                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'Acerca de',
                  subtitle: 'Versión 1.0.0',
                  onTap: () {
                    showAboutDialog(
                      context: context,
                      applicationName: 'Cinema App',
                      applicationVersion: '1.0.0',
                      applicationIcon: Icon(Icons.movie, size: 48, color: AppColors.primary),
                    );
                  },
                  isDark: isDark,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSpacing.borderRadiusMD,
          child: Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: AppSpacing.borderRadiusMD,
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusSM,
                  ),
                  child: Icon(icon, color: AppColors.primary, size: 24),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
}
