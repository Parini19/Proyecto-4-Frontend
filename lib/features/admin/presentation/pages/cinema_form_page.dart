import 'package:flutter/material.dart';
import '../../../../core/models/cinema_location.dart';
import '../../../../core/services/cinema_location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cinema_button.dart';
import '../../../../core/widgets/cinema_text_field.dart';

/// Formulario para crear o editar un cine
class CinemaFormPage extends StatefulWidget {
  final CinemaLocation? cinema;

  const CinemaFormPage({super.key, this.cinema});

  @override
  State<CinemaFormPage> createState() => _CinemaFormPageState();
}

class _CinemaFormPageState extends State<CinemaFormPage> {
  final _formKey = GlobalKey<FormState>();
  final CinemaLocationService _cinemaService = CinemaLocationService();

  late TextEditingController _nameController;
  late TextEditingController _cityController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _imageUrlController;
  bool _isActive = true;
  bool _isLoading = false;

  bool get _isEditing => widget.cinema != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.cinema?.name ?? '');
    _cityController = TextEditingController(text: widget.cinema?.city ?? '');
    _addressController = TextEditingController(text: widget.cinema?.address ?? '');
    _phoneController = TextEditingController(text: widget.cinema?.phone ?? '');
    _imageUrlController = TextEditingController(text: widget.cinema?.imageUrl ?? '');
    _isActive = widget.cinema?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveCinema() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cinema = CinemaLocation(
        id: widget.cinema?.id ?? '',
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        isActive: _isActive,
        createdAt: widget.cinema?.createdAt,
        updatedAt: widget.cinema?.updatedAt,
      );

      if (_isEditing) {
        await _cinemaService.updateCinema(cinema);
      } else {
        await _cinemaService.createCinema(cinema);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'Cine actualizado exitosamente' : 'Cine creado exitosamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(_isEditing ? 'Editar Cine' : 'Nuevo Cine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildInfoCard(),
                    SizedBox(height: AppSpacing.md),
                    _buildLocationCard(),
                    SizedBox(height: AppSpacing.md),
                    _buildStatusCard(),
                    SizedBox(height: AppSpacing.lg),
                    _buildActionButtons(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Básica',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            CinemaTextField(
              controller: _nameController,
              label: 'Nombre del Cine',
              hint: 'Ej: Cine Premium San José',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                if (value.trim().length < 3) {
                  return 'El nombre debe tener al menos 3 caracteres';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.sm),
            CinemaTextField(
              controller: _imageUrlController,
              label: 'URL de Imagen (opcional)',
              hint: 'https://ejemplo.com/imagen.jpg',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ubicación',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            CinemaTextField(
              controller: _cityController,
              label: 'Ciudad',
              hint: 'Ej: San José',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La ciudad es requerida';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.sm),
            CinemaTextField(
              controller: _addressController,
              label: 'Dirección',
              hint: 'Ej: Avenida Central, Calle 5',
              maxLines: 2,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La dirección es requerida';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.sm),
            CinemaTextField(
              controller: _phoneController,
              label: 'Teléfono',
              hint: 'Ej: 2222-3333',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El teléfono es requerido';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: AppSpacing.paddingMD,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estado',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            SwitchListTile(
              title: const Text('Cine Activo'),
              subtitle: Text(
                _isActive
                    ? 'El cine está visible y disponible para usuarios'
                    : 'El cine está oculto y no disponible para usuarios',
              ),
              value: _isActive,
              onChanged: (value) {
                setState(() {
                  _isActive = value;
                });
              },
              activeColor: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: CinemaButton(
            text: 'Cancelar',
            onPressed: () => Navigator.of(context).pop(),
            variant: ButtonVariant.secondary,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: CinemaButton(
            text: _isEditing ? 'Guardar Cambios' : 'Crear Cine',
            onPressed: _saveCinema,
            variant: ButtonVariant.primary,
            icon: _isEditing ? Icons.save : Icons.add_business,
          ),
        ),
      ],
    );
  }
}
