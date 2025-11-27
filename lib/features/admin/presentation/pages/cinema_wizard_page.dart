import 'package:flutter/material.dart';
import '../../../../core/models/cinema_location.dart';
import '../../../../core/models/theater_room.dart';
import '../../../../core/services/cinema_location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cinema_button.dart';
import '../../../../core/widgets/cinema_text_field.dart';

/// Wizard paso a paso para crear un cine completo
/// Paso 1: Información del cine
/// Paso 2: Crear salas
/// Paso 3: Configurar asientos
/// Paso 4: Resumen y confirmación
class CinemaWizardPage extends StatefulWidget {
  const CinemaWizardPage({super.key});

  @override
  State<CinemaWizardPage> createState() => _CinemaWizardPageState();
}

class _CinemaWizardPageState extends State<CinemaWizardPage> {
  final CinemaLocationService _cinemaService = CinemaLocationService();
  int _currentStep = 0;
  bool _isLoading = false;

  // Step 1: Cinema Info
  final _cinemaFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _imageUrlController = TextEditingController();

  // Step 2: Theater Rooms
  final List<TheaterRoomData> _rooms = [];

  // Created cinema (after step 1)
  CinemaLocation? _createdCinema;

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _createCinema() async {
    if (!_cinemaFormKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      final cinema = CinemaLocation(
        id: '',
        name: _nameController.text.trim(),
        city: _cityController.text.trim(),
        address: _addressController.text.trim(),
        phone: _phoneController.text.trim(),
        imageUrl: _imageUrlController.text.trim().isEmpty ? null : _imageUrlController.text.trim(),
        isActive: true,
      );

      final created = await _cinemaService.createCinema(cinema);
      setState(() {
        _createdCinema = created;
        _currentStep = 1;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cine creado exitosamente'),
          backgroundColor: AppColors.success,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear cine: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _addRoom() {
    setState(() {
      _rooms.add(TheaterRoomData(
        name: 'Sala ${_rooms.length + 1}',
        capacity: 100,
        type: 'standard',
      ));
    });
  }

  void _removeRoom(int index) {
    setState(() {
      _rooms.removeAt(index);
    });
  }

  void _finishWizard() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Wizard Completado'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cine creado: ${_createdCinema?.name}'),
            SizedBox(height: AppSpacing.sm),
            Text('Salas planificadas: ${_rooms.length}'),
            SizedBox(height: AppSpacing.md),
            Text(
              'Próximos pasos:\n'
              '• Ir a Gestión de Salas para crear las salas\n'
              '• Configurar los asientos de cada sala\n'
              '• Asignar películas y funciones',
              style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          CinemaButton(
            text: 'Entendido',
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            variant: ButtonVariant.primary,
            size: ButtonSize.small,
          ),
        ],
      ),
    );
  }

  @override

  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Wizard de Creación de Cine'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildStepper(),
                Expanded(child: _buildStepContent()),
                _buildNavigationButtons(),
              ],
            ),
    );}

  Widget _buildStepper() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
      padding: AppSpacing.paddingMD,
      child: Row(
        children: [
          _buildStepIndicator(0, 'Información del Cine'),
          _buildStepConnector(0),
          _buildStepIndicator(1, 'Planificar Salas'),
          _buildStepConnector(1),
          _buildStepIndicator(2, 'Resumen'),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    final isActive = _currentStep == step;
    final isCompleted = _currentStep > step;

    return Expanded(
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.success
                  : isActive
                      ? AppColors.primary
                      : AppColors.textSecondary.withOpacity(0.3),
            ),
            child: Center(
              child: isCompleted
                  ? Icon(Icons.check, color: Colors.white, size: 20)
                  : Text(
                      '${step + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : AppColors.textSecondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(int step) {
    final isCompleted = _currentStep > step;
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 40),
        color: isCompleted ? AppColors.success : AppColors.textSecondary.withOpacity(0.3),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildCinemaInfoStep();
      case 1:
        return _buildRoomsStep();
      case 2:
        return _buildSummaryStep();
      default:
        return SizedBox();
    }
  }

  Widget _buildCinemaInfoStep() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Form(
        key: _cinemaFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paso 1: Información del Cine',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              'Ingrese la información básica del nuevo cine. Después podrá crear las salas.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
            SizedBox(height: AppSpacing.md),
            CinemaTextField(
              controller: _nameController,
              label: 'Nombre del Cine',
              hint: 'Ej: Cine Premium Escazú',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es requerido';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.sm),
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

  Widget _buildRoomsStep() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso 2: Planificar Salas',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Cine creado: ${_createdCinema?.name ?? "N/A"}',
            style: const TextStyle(
              color: AppColors.success,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Defina cuántas salas tendrá este cine. Podrá configurar los asientos en Gestión de Salas.',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          SizedBox(height: AppSpacing.md),
          CinemaButton(
            text: 'Agregar Sala',
            onPressed: _addRoom,
            variant: ButtonVariant.primary,
            icon: Icons.add,
          ),
          SizedBox(height: AppSpacing.md),
          if (_rooms.isEmpty)
            Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: Text(
                  'No hay salas planificadas.\nPresione "Agregar Sala" para comenzar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
            )
          else
            ..._rooms.asMap().entries.map((entry) {
              final index = entry.key;
              final room = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: Icon(Icons.meeting_room, color: AppColors.primary),
                  title: Text(room.name),
                  subtitle: Text('${room.capacity} asientos - ${room.type}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: AppColors.error),
                    onPressed: () => _removeRoom(index),
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildSummaryStep() {
    return SingleChildScrollView(
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paso 3: Resumen',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Información del Cine',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  _buildInfoRow('Nombre:', _createdCinema?.name ?? 'N/A'),
                  _buildInfoRow('Ciudad:', _createdCinema?.city ?? 'N/A'),
                  _buildInfoRow('Dirección:', _createdCinema?.address ?? 'N/A'),
                  _buildInfoRow('Teléfono:', _createdCinema?.phone ?? 'N/A'),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Card(
            child: Padding(
              padding: AppSpacing.paddingMD,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Salas Planificadas',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: AppSpacing.sm),
                  if (_rooms.isEmpty)
                    Text(
                      'No hay salas planificadas',
                      style: TextStyle(color: AppColors.warning),
                    )
                  else
                    ..._rooms.map((room) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: AppColors.success, size: 20),
                              SizedBox(width: AppSpacing.sm),
                              Text('${room.name} (${room.capacity} asientos)'),
                            ],
                          ),
                        )),
                ],
              ),
            ),
          ),
          SizedBox(height: AppSpacing.md),
          Container(
            padding: AppSpacing.paddingMD,
            decoration: BoxDecoration(
              color: AppColors.info.withOpacity(0.1),
              borderRadius: AppSpacing.borderRadiusMD,
              border: Border.all(color: AppColors.info),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.info),
                    SizedBox(width: 8),
                    Text(
                      'Próximos Pasos',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                Text(
                  '1. Vaya a "Gestión de Salas" para crear las salas\n'
                  '2. Configure los asientos de cada sala\n'
                  '3. Vaya a "Funciones" para asignar películas',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: CinemaButton(
                text: 'Anterior',
                onPressed: () {
                  setState(() {
                    _currentStep--;
                  });
                },
                variant: ButtonVariant.secondary,
                icon: Icons.arrow_back,
              ),
            ),
          if (_currentStep > 0) SizedBox(width: AppSpacing.md),
          Expanded(
            child: CinemaButton(
              text: _currentStep == 0
                  ? 'Crear Cine'
                  : _currentStep == 2
                      ? 'Finalizar'
                      : 'Siguiente',
              onPressed: () {
                if (_currentStep == 0) {
                  _createCinema();
                } else if (_currentStep == 2) {
                  _finishWizard();
                } else {
                  setState(() {
                    _currentStep++;
                  });
                }
              },
              variant: ButtonVariant.primary,
              icon: _currentStep == 2 ? Icons.check : Icons.arrow_forward,
            ),
          ),
        ],
      ),
    );
  }
}

/// Clase auxiliar para almacenar datos de sala durante el wizard
class TheaterRoomData {
  String name;
  int capacity;
  String type;

  TheaterRoomData({
    required this.name,
    required this.capacity,
    required this.type,
  });
}
