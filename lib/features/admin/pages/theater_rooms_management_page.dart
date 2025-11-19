import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../../../core/models/theater_room_model.dart';
import '../../../core/services/theater_rooms_service.dart';

class TheaterRoomsManagementPage extends StatefulWidget {
  const TheaterRoomsManagementPage({super.key});

  @override
  State<TheaterRoomsManagementPage> createState() => _TheaterRoomsManagementPageState();
}

class _TheaterRoomsManagementPageState extends State<TheaterRoomsManagementPage> {
  List<TheaterRoomModel> _theaterRooms = [];
  List<TheaterRoomModel> _filteredTheaterRooms = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  final TheaterRoomsService _theaterRoomsService = TheaterRoomsService();

  @override
  void initState() {
    super.initState();
    _loadTheaterRooms();
  }

  Future<void> _loadTheaterRooms() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🏛️ Cargando salas de cine desde el backend...');
      final rooms = await _theaterRoomsService.getAllTheaterRooms();
      print('🏛️ Salas de cine cargadas: ${rooms.length}');
      
      setState(() {
        _theaterRooms = rooms;
        _filteredTheaterRooms = rooms;
        _isLoading = false;
      });
      
      if (rooms.isEmpty) {
        print('⚠️ No se encontraron salas de cine en el backend');
      }
    } catch (e) {
      print('❌ Error cargando salas de cine: $e');
      setState(() {
        _error = 'Error cargando salas de cine del servidor: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testBackendConnection() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 16),
            Text('Probando conexión con el backend...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final rooms = await _theaterRoomsService.getAllTheaterRooms();
      ScaffoldMessenger.of(context).clearSnackBars();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Resultado de Conexión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Backend conectado exitosamente'),
              SizedBox(height: 8),
              Text('🏛️ Salas encontradas: ${rooms.length}'),
              if (rooms.isNotEmpty) ...[
                SizedBox(height: 8),
                Text('📋 Ejemplos:'),
                ...rooms.take(3).map((room) => Padding(
                  padding: EdgeInsets.only(left: 16, top: 4),
                  child: Text('• ${room.name} (${room.capacity} asientos)'),
                )),
              ],
              SizedBox(height: 8),
              Text('🌐 URL: https://localhost:7238/api/theaterrooms/get-all-theater-rooms'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Error de Conexión'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('❌ No se pudo conectar al backend'),
              SizedBox(height: 8),
              Text('📋 Error: $e'),
              SizedBox(height: 8),
              Text('🌐 URL: https://localhost:7238/api/theaterrooms/get-all-theater-rooms'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cerrar'),
            ),
          ],
        ),
      );
    }
  }

  void _filterTheaterRooms(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredTheaterRooms = _theaterRooms;
      } else {
        _filteredTheaterRooms = _theaterRooms.where((room) =>
          room.name.toLowerCase().contains(query.toLowerCase()) ||
          room.capacity.toString().contains(query)
        ).toList();
      }
    });
  }

  void _showAddTheaterRoomDialog() {
    showDialog(
      context: context,
      builder: (context) => _TheaterRoomFormDialog(
        onSave: (room) async {
          final success = await _theaterRoomsService.addTheaterRoom(room);
          if (success) {
            _loadTheaterRooms();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sala "${room.name}" agregada exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al agregar la sala'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _showEditTheaterRoomDialog(TheaterRoomModel room) {
    showDialog(
      context: context,
      builder: (context) => _TheaterRoomFormDialog(
        room: room,
        onSave: (updatedRoom) async {
          final success = await _theaterRoomsService.updateTheaterRoom(updatedRoom);
          if (success) {
            _loadTheaterRooms();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Sala "${updatedRoom.name}" actualizada exitosamente'),
                backgroundColor: AppColors.success,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error al actualizar la sala'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(TheaterRoomModel room) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar la sala "${room.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await _theaterRoomsService.deleteTheaterRoom(room.id);
              if (success) {
                _loadTheaterRooms();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sala "${room.name}" eliminada exitosamente'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error al eliminar la sala'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
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
        title: Text(
          'Gestión de Salas de Cine',
          style: AppTypography.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadTheaterRooms,
          ),
          IconButton(
            icon: Icon(Icons.wifi),
            onPressed: _testBackendConnection,
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Header con búsqueda y botón agregar
          Container(
            padding: AppSpacing.pagePadding,
            child: Row(
              children: [
                Expanded(
                  child: CinemaTextField(
                    label: 'Buscar salas',
                    hint: 'Buscar salas por nombre o capacidad...',
                    prefixIcon: Icons.search,
                    onChanged: _filterTheaterRooms,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                CinemaButton(
                  text: 'Agregar Sala',
                  icon: Icons.add,
                  onPressed: _showAddTheaterRoomDialog,
                ),
              ],
            ),
          ),

          // Contenido principal
          Expanded(
            child: _buildContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(bool isDark) {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: AppSpacing.md),
            Text(
              'Cargando salas de cine...',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              'Error al cargar salas',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              child: Text(
                _error!,
                textAlign: TextAlign.center,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),
            CinemaButton(
              text: 'Reintentar',
              icon: Icons.refresh,
              onPressed: _loadTheaterRooms,
            ),
          ],
        ),
      );
    }

    if (_filteredTheaterRooms.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.meeting_room_outlined : Icons.search_off,
              size: 64,
              color: AppColors.textTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              _searchQuery.isEmpty
                  ? 'No hay salas de cine'
                  : 'No se encontraron salas',
              style: AppTypography.titleLarge.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              _searchQuery.isEmpty
                  ? 'Agrega tu primera sala de cine'
                  : 'Intenta con otros términos de búsqueda',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            if (_searchQuery.isEmpty) ...[
              SizedBox(height: AppSpacing.lg),
              CinemaButton(
                text: 'Agregar Sala',
                icon: Icons.add,
                onPressed: _showAddTheaterRoomDialog,
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      itemCount: _filteredTheaterRooms.length,
      itemBuilder: (context, index) {
        final room = _filteredTheaterRooms[index];
        return _buildTheaterRoomCard(room, isDark);
      },
    );
  }

  Widget _buildTheaterRoomCard(TheaterRoomModel room, bool isDark) {
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
        boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
      ),
      child: ListTile(
        contentPadding: AppSpacing.paddingLG,
        leading: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: AppSpacing.borderRadiusMD,
            boxShadow: isDark ? AppColors.glowShadow : null,
          ),
          child: Icon(
            Icons.meeting_room,
            color: Colors.white,
            size: 28,
          ),
        ),
        title: Text(
          room.name,
          style: AppTypography.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.event_seat,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Capacidad: ${room.capacity} asientos',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.tag,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'ID: ${room.id}',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textTertiary,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.edit, color: AppColors.primary),
              onPressed: () => _showEditTheaterRoomDialog(room),
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error),
              onPressed: () => _showDeleteConfirmation(room),
            ),
          ],
        ),
      ),
    );
  }
}

class _TheaterRoomFormDialog extends StatefulWidget {
  final TheaterRoomModel? room;
  final Function(TheaterRoomModel) onSave;

  const _TheaterRoomFormDialog({
    this.room,
    required this.onSave,
  });

  @override
  State<_TheaterRoomFormDialog> createState() => _TheaterRoomFormDialogState();
}

class _TheaterRoomFormDialogState extends State<_TheaterRoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _nameController.text = widget.room!.name;
      _capacityController.text = widget.room!.capacity.toString();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  void _saveTheaterRoom() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final room = TheaterRoomModel(
        id: widget.room?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        capacity: int.parse(_capacityController.text.trim()),
      );

      widget.onSave(room);
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.room == null ? 'Agregar Sala de Cine' : 'Editar Sala de Cine',
        style: AppTypography.titleLarge.copyWith(fontWeight: FontWeight.bold),
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CinemaTextField(
              controller: _nameController,
              label: 'Nombre de la sala',
              hint: 'Ej: Sala 1, Sala VIP, etc.',
              prefixIcon: Icons.meeting_room,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El nombre es obligatorio';
                }
                if (value.trim().length < 2) {
                  return 'El nombre debe tener al menos 2 caracteres';
                }
                return null;
              },
            ),
            SizedBox(height: AppSpacing.md),
            CinemaTextField(
              controller: _capacityController,
              label: 'Capacidad',
              hint: 'Número de asientos (ej: 100)',
              prefixIcon: Icons.event_seat,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'La capacidad es obligatoria';
                }
                final capacity = int.tryParse(value.trim());
                if (capacity == null) {
                  return 'La capacidad debe ser un número válido';
                }
                if (capacity <= 0) {
                  return 'La capacidad debe ser mayor a 0';
                }
                if (capacity > 1000) {
                  return 'La capacidad no puede exceder 1000 asientos';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: Text('Cancelar'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _saveTheaterRoom,
          child: _isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(widget.room == null ? 'Agregar' : 'Guardar'),
        ),
      ],
    );
  }
}