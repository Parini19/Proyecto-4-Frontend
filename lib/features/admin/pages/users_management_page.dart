import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../../../core/entities/user.dart';
import '../../../core/services/user_service.dart';

class UsersManagementPage extends StatefulWidget {
  const UsersManagementPage({super.key});

  @override
  State<UsersManagementPage> createState() => _UsersManagementPageState();
}

class _UsersManagementPageState extends State<UsersManagementPage> {
  List<User> _users = [];
  List<User> _filteredUsers = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final users = await _userService.getAllUsers();
      
      setState(() {
        _users = users;
        _filteredUsers = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los usuarios: $e';
        _isLoading = false;
      });
    }
  }

  void _filterUsers(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredUsers = _users;
      } else {
        _filteredUsers = _users.where((user) {
          return user.displayName.toLowerCase().contains(query.toLowerCase()) ||
                 user.email.toLowerCase().contains(query.toLowerCase()) ||
                 (user.role?.toLowerCase().contains(query.toLowerCase()) ?? false);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Column(
        children: [
          // Header
          _buildHeader(context),
          
          // Content
          Expanded(
            child: _isLoading
                ? _buildLoadingIndicator()
                : _error != null
                    ? _buildErrorWidget()
                    : _buildContentBody(context),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        gradient: isDark ? AppColors.cinemaGradient : null,
        color: isDark ? null : AppColors.lightSurfaceElevated,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  shape: BoxShape.circle,
                  boxShadow: isDark ? AppColors.glowShadow : null,
                ),
                child: Icon(
                  Icons.people,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Gestión de Usuarios',
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Administra los usuarios registrados en el sistema',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CinemaButton(
                text: 'Agregar Usuario',
                onPressed: () => _showAddEditDialog(),
                icon: Icons.person_add,
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xl),
          
          // Search and Stats
          Row(
            children: [
              // Search Bar
              Expanded(
                flex: 2,
                child: CinemaTextField(
                  label: 'Buscar usuarios...',
                  prefixIcon: Icons.search,
                  onChanged: _filterUsers,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              
              // Stats Cards
              Expanded(
                child: _buildStatCard(
                  'Total Usuarios',
                  _users.length.toString(),
                  Icons.people,
                  AppColors.primary,
                  isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Activos',
                  _users.where((u) => u.isActiveUser).length.toString(),
                  Icons.check_circle,
                  AppColors.success,
                  isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Administradores',
                  _users.where((u) => u.isAdmin).length.toString(),
                  Icons.admin_panel_settings,
                  AppColors.warning,
                  isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color, bool isDark) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        gradient: isDark ? null : LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
        ),
        color: isDark ? color.withOpacity(0.1) : null,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: AppSpacing.xs),
              Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.headlineMedium.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text(
            'Cargando usuarios...',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          SizedBox(height: AppSpacing.lg),
          Text(
            'Error al cargar los usuarios',
            style: AppTypography.titleLarge.copyWith(
              color: AppColors.error,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            _error ?? 'Ha ocurrido un error inesperado',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.xl),
          CinemaButton(
            text: 'Reintentar',
            onPressed: _loadUsers,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody(BuildContext context) {
    if (_filteredUsers.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoResultsFound();
    }

    if (_filteredUsers.isEmpty) {
      return _buildEmptyState();
    }

    return _buildUsersList(context);
  }

  Widget _buildNoResultsFound() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Icon(
                Icons.search_off,
                size: 64,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              );
            }
          ),
          SizedBox(height: AppSpacing.lg),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                'No se encontraron resultados',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          ),
          SizedBox(height: AppSpacing.sm),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                'Intenta con otros términos de búsqueda',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Icon(
                Icons.people_outline,
                size: 64,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              );
            }
          ),
          SizedBox(height: AppSpacing.lg),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                'No hay usuarios registrados',
                style: AppTypography.titleLarge.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  fontWeight: FontWeight.bold,
                ),
              );
            }
          ),
          SizedBox(height: AppSpacing.sm),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                'Agrega el primer usuario para comenzar',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              );
            }
          ),
          SizedBox(height: AppSpacing.xl),
          CinemaButton(
            text: 'Agregar Usuario',
            onPressed: () => _showAddEditDialog(),
            icon: Icons.person_add,
          ),
        ],
      ),
    );
  }

  Widget _buildUsersList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: AppSpacing.paddingXL,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        children: [
          // Table Header
          Container(
            padding: AppSpacing.paddingLG,
            decoration: BoxDecoration(
              gradient: isDark ? AppColors.cinemaGradient : null,
              color: isDark ? null : AppColors.lightSurfaceElevated,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(flex: 3, child: _buildHeaderCell('Usuario')),
                Expanded(flex: 2, child: _buildHeaderCell('Rol')),
                Expanded(flex: 2, child: _buildHeaderCell('Estado')),
                Expanded(flex: 2, child: _buildHeaderCell('Último Acceso')),
                Expanded(flex: 2, child: _buildHeaderCell('Acciones')),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _filteredUsers.length,
              itemBuilder: (context, index) {
                return _buildUserRow(context, _filteredUsers[index], index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
          ),
        );
      }
    );
  }

  Widget _buildUserRow(BuildContext context, User user, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Row(
        children: [
          // User Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Avatar
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    user.displayName.isNotEmpty ? user.displayName[0].toUpperCase() : 'U',
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName.isNotEmpty ? user.displayName : 'Sin nombre',
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        user.email,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'UID: ${user.uid}',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Role
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: user.isAdmin 
                    ? AppColors.warning.withOpacity(0.1)
                    : AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                user.roleDisplayName,
                style: AppTypography.bodySmall.copyWith(
                  color: user.isAdmin ? AppColors.warning : AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Status
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: user.isActiveUser
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    user.isActiveUser ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: user.isActiveUser ? AppColors.success : AppColors.error,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    user.isActiveUser ? 'Activo' : 'Deshabilitado',
                    style: AppTypography.bodySmall.copyWith(
                      color: user.isActiveUser ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Last Login
          Expanded(
            flex: 2,
            child: Text(
              user.lastLoginAt != null
                  ? _formatDate(user.lastLoginAt!)
                  : 'Nunca',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showAddEditDialog(user: user),
                  icon: Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Editar',
                ),
                IconButton(
                  onPressed: () => _toggleUserStatus(user),
                  icon: Icon(
                    user.isActiveUser ? Icons.block : Icons.check_circle,
                    color: user.isActiveUser ? AppColors.error : AppColors.success,
                  ),
                  tooltip: user.isActiveUser ? 'Deshabilitar' : 'Habilitar',
                ),
                IconButton(
                  onPressed: () => _showDeleteDialog(user),
                  icon: Icon(Icons.delete, color: AppColors.error),
                  tooltip: 'Eliminar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} días';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} semanas';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  void _showAddEditDialog({User? user}) {
    showDialog(
      context: context,
      builder: (context) => _UserDialog(
        user: user,
        onSave: (savedUser, password) {
          _saveUser(savedUser, user == null, password);
        },
      ),
    );
  }

  Future<void> _saveUser(User user, bool isNew, String? password) async {
    try {
      bool success;
      if (isNew) {
        success = await _userService.createUser(
          email: user.email,
          password: password ?? 'temporalPassword123',
          displayName: user.displayName,
          role: user.role ?? 'user',
        );
      } else {
        success = await _userService.updateUser(user);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNew ? 'Usuario creado exitosamente' : 'Usuario actualizado exitosamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      } else {
        throw Exception('Error en la operación');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleUserStatus(User user) async {
    try {
      final success = await _userService.toggleUserStatus(user.uid, !user.disabled);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActiveUser 
                  ? 'Usuario deshabilitado exitosamente' 
                  : 'Usuario habilitado exitosamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      } else {
        throw Exception('Error al cambiar el estado del usuario');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showDeleteDialog(User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Usuario'),
        content: Text('¿Estás seguro de que deseas eliminar a "${user.displayName}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUser(user);
            },
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteUser(User user) async {
    try {
      final success = await _userService.deleteUser(user.uid);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Usuario eliminado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadUsers();
      } else {
        throw Exception('Error al eliminar el usuario');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}

// Dialog for Add/Edit User
class _UserDialog extends StatefulWidget {
  final User? user;
  final Function(User, String?) onSave;

  const _UserDialog({
    this.user,
    required this.onSave,
  });

  @override
  State<_UserDialog> createState() => _UserDialogState();
}

class _UserDialogState extends State<_UserDialog> {
  final _formKey = GlobalKey<FormState>();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _selectedRole = 'user';
  bool _disabled = false;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _displayNameController.text = widget.user!.displayName;
      _emailController.text = widget.user!.email;
      _selectedRole = widget.user!.role ?? 'user';
      _disabled = widget.user!.disabled;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEdit = widget.user != null;

    return Dialog(
      child: Container(
        width: 600,
        padding: AppSpacing.paddingXL,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isEdit ? 'Editar Usuario' : 'Agregar Usuario',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              
              Row(
                children: [
                  Expanded(
                    child: CinemaTextField(
                      controller: _displayNameController,
                      label: 'Nombre completo *',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre es requerido';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedRole,
                      decoration: InputDecoration(
                        labelText: 'Rol',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        DropdownMenuItem(value: 'user', child: Text('Usuario')),
                        DropdownMenuItem(value: 'employee', child: Text('Empleado')),
                        DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedRole = value ?? 'user';
                        });
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              CinemaTextField(
                controller: _emailController,
                label: 'Correo electrónico *',
                enabled: !isEdit, // No editar email en modo edición
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El correo es requerido';
                  }
                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Ingresa un correo válido';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),

              if (!isEdit)
                CinemaTextField(
                  controller: _passwordController,
                  label: 'Contraseña *',
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'La contraseña es requerida';
                    }
                    if (value.length < 6) {
                      return 'La contraseña debe tener al menos 6 caracteres';
                    }
                    return null;
                  },
                ),
              
              if (isEdit) ...[
                SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Switch(
                      value: _disabled,
                      onChanged: (value) {
                        setState(() {
                          _disabled = value;
                        });
                      },
                      activeColor: AppColors.error,
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Text(
                      'Usuario deshabilitado',
                      style: AppTypography.bodyMedium,
                    ),
                  ],
                ),
              ],
              
              SizedBox(height: AppSpacing.xl),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancelar'),
                  ),
                  SizedBox(width: AppSpacing.md),
                  CinemaButton(
                    text: isEdit ? 'Guardar' : 'Crear',
                    onPressed: _saveUser,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveUser() {
    if (_formKey.currentState!.validate()) {
      final user = User(
        uid: widget.user?.uid ?? '',
        email: _emailController.text.trim(),
        displayName: _displayNameController.text.trim(),
        emailVerified: widget.user?.emailVerified ?? false,
        disabled: _disabled,
        role: _selectedRole,
        createdAt: widget.user?.createdAt,
        lastLoginAt: widget.user?.lastLoginAt,
      );

      widget.onSave(user, _passwordController.text.isNotEmpty ? _passwordController.text : null);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
