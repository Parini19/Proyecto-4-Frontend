import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _emailNotifications = true;
  bool _pushNotifications = false;
  bool _autoBackup = true;
  bool _darkMode = false;
  int _sessionTimeout = 30;
  String _currency = 'CRC';

  final List<String> _currencies = ['CRC', 'USD', 'EUR', 'GBP', 'ARS', 'MXN'];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      body: Column(
        children: [
          _buildHeader(isDark),
          Expanded(child: _buildContent(isDark)),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          bottom: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary),
            onPressed: () => Navigator.pop(context),
            tooltip: 'Volver al panel',
          ),
          Icon(Icons.settings, color: AppColors.primary, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Configuración del Sistema', style: AppTypography.headlineSmall),
                Text(
                  'Ajustes generales y preferencias',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: _saveSettings,
            icon: const Icon(Icons.save),
            label: const Text('Guardar Cambios'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    return SingleChildScrollView(
      padding: AppSpacing.paddingLG,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSection(
            'Notificaciones',
            [
              _buildSwitchTile(
                'Notificaciones por Email',
                'Recibir alertas y actualizaciones por correo electrónico',
                _emailNotifications,
                (value) => setState(() => _emailNotifications = value),
                isDark,
              ),
              _buildSwitchTile(
                'Notificaciones Push',
                'Recibir notificaciones en el navegador',
                _pushNotifications,
                (value) => setState(() => _pushNotifications = value),
                isDark,
              ),
            ],
            isDark,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Sistema',
            [
              _buildSwitchTile(
                'Respaldo Automático',
                'Realizar respaldos automáticos de la base de datos',
                _autoBackup,
                (value) => setState(() => _autoBackup = value),
                isDark,
              ),
              _buildSwitchTile(
                'Modo Oscuro',
                'Usar tema oscuro en la interfaz',
                _darkMode,
                (value) => setState(() => _darkMode = value),
                isDark,
              ),
            ],
            isDark,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Sesión y Seguridad',
            [
              _buildSliderTile(
                'Tiempo de Expiración de Sesión',
                'Minutos de inactividad antes de cerrar sesión automáticamente',
                _sessionTimeout.toDouble(),
                10,
                120,
                (value) => setState(() => _sessionTimeout = value.toInt()),
                isDark,
              ),
            ],
            isDark,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Configuración Regional',
            [
              _buildDropdownTile(
                'Moneda',
                'Moneda predeterminada para el sistema',
                _currency,
                _currencies,
                (value) => setState(() => _currency = value!),
                isDark,
              ),
            ],
            isDark,
          ),
          const SizedBox(height: 24),
          _buildSection(
            'Avanzado',
            [
              _buildActionTile(
                'Limpiar Caché',
                'Eliminar datos temporales y archivos en caché',
                Icons.cleaning_services,
                () => _showConfirmDialog('¿Limpiar caché?', '¿Estás seguro de que deseas limpiar el caché del sistema?'),
                isDark,
              ),
              _buildActionTile(
                'Exportar Datos',
                'Descargar una copia de todos los datos del sistema',
                Icons.download,
                () => _showInfoDialog('Exportar Datos', 'Funcionalidad en desarrollo'),
                isDark,
              ),
              _buildActionTile(
                'Restablecer Configuración',
                'Volver a la configuración predeterminada',
                Icons.restore,
                () => _showConfirmDialog('¿Restablecer configuración?', '¿Estás seguro de que deseas restablecer toda la configuración?'),
                isDark,
              ),
            ],
            isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: AppSpacing.borderRadiusMD,
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
    bool isDark,
  ) {
    return ListTile(
      title: Text(title, style: AppTypography.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
    );
  }

  Widget _buildSliderTile(
    String title,
    String subtitle,
    double value,
    double min,
    double max,
    Function(double) onChanged,
    bool isDark,
  ) {
    return ListTile(
      title: Row(
        children: [
          Expanded(child: Text(title, style: AppTypography.bodyLarge)),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${value.toInt()} min',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subtitle,
            style: AppTypography.bodySmall.copyWith(
              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
            ),
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: ((max - min) / 10).toInt(),
            label: '${value.toInt()} min',
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownTile(
    String title,
    String subtitle,
    String value,
    List<String> options,
    Function(String?) onChanged,
    bool isDark,
  ) {
    return ListTile(
      title: Text(title, style: AppTypography.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
      trailing: DropdownButton<String>(
        value: value,
        onChanged: onChanged,
        items: options.map((option) {
          return DropdownMenuItem(value: option, child: Text(option));
        }).toList(),
      ),
    );
  }

  Widget _buildActionTile(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
    bool isDark,
  ) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title, style: AppTypography.bodyLarge),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        ),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _saveSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada correctamente'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showConfirmDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Acción completada')),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
