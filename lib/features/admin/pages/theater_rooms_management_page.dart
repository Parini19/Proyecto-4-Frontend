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

  void _showSeatConfigurator(TheaterRoomModel room) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => _SeatConfiguratorPage(
          room: room,
          onSave: (updatedRoom) async {
            final success = await _theaterRoomsService.updateTheaterRoom(updatedRoom);
            if (success) {
              _loadTheaterRooms();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Configuración de asientos guardada exitosamente'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error al guardar configuración de asientos'),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
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
              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
            ),
            SizedBox(height: AppSpacing.md),
            Text(
              _searchQuery.isEmpty
                  ? 'No hay salas de cine'
                  : 'No se encontraron salas',
              style: AppTypography.titleLarge.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: AppSpacing.sm),
            Text(
              _searchQuery.isEmpty
                  ? 'Agrega tu primera sala de cine'
                  : 'Intenta con otros términos de búsqueda',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
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
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'Capacidad: ${room.capacity} asientos',
                  style: AppTypography.bodyMedium.copyWith(
                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
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
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                Text(
                  'ID: ${room.id}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
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
              icon: Icon(Icons.grid_on, color: AppColors.info),
              onPressed: () => _showSeatConfigurator(room),
              tooltip: 'Configurar asientos',
            ),
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

// Seat Configurator Page
class _SeatConfiguratorPage extends StatefulWidget {
  final TheaterRoomModel room;
  final Function(TheaterRoomModel) onSave;

  const _SeatConfiguratorPage({
    required this.room,
    required this.onSave,
  });

  @override
  State<_SeatConfiguratorPage> createState() => _SeatConfiguratorPageState();
}

enum SeatType { normal, vip, empty }

class _Seat {
  final int row;
  final int col;
  SeatType type;

  _Seat({required this.row, required this.col, this.type = SeatType.normal});

  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'type': type.name,
  };

  static _Seat fromJson(Map<String, dynamic> json) => _Seat(
    row: json['row'],
    col: json['col'],
    type: SeatType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => SeatType.normal,
    ),
  );
}

class _SeatConfiguratorPageState extends State<_SeatConfiguratorPage> {
  final _rowsController = TextEditingController();
  final _colsController = TextEditingController();

  int _rows = 8;
  int _cols = 12;
  List<_Seat> _seats = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadConfiguration();
  }

  void _loadConfiguration() {
    try {
      if (widget.room.seatConfiguration != null && widget.room.seatConfiguration!.isNotEmpty) {
        final config = Map<String, dynamic>.from(
          (widget.room.seatConfiguration! as Map).cast<String, dynamic>()
        );

        _rows = config['rows'] ?? 8;
        _cols = config['columns'] ?? 12;

        if (config['seats'] != null) {
          _seats = (config['seats'] as List)
              .map((s) => _Seat.fromJson(Map<String, dynamic>.from(s)))
              .toList();
        } else {
          _generateDefaultSeats();
        }
      } else {
        _generateDefaultSeats();
      }
    } catch (e) {
      print('Error loading seat configuration: $e');
      _generateDefaultSeats();
    }

    _rowsController.text = _rows.toString();
    _colsController.text = _cols.toString();
  }

  void _generateDefaultSeats() {
    _seats = [];
    for (int r = 0; r < _rows; r++) {
      for (int c = 0; c < _cols; c++) {
        _seats.add(_Seat(row: r, col: c, type: SeatType.normal));
      }
    }
  }

  void _regenerateSeats() {
    final newRows = int.tryParse(_rowsController.text) ?? 8;
    final newCols = int.tryParse(_colsController.text) ?? 12;

    if (newRows < 1 || newRows > 20 || newCols < 1 || newCols > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Filas: 1-20, Columnas: 1-30'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _rows = newRows;
      _cols = newCols;

      // Keep existing seat types where possible
      final oldSeats = Map.fromEntries(
        _seats.map((s) => MapEntry('${s.row}-${s.col}', s.type))
      );

      _seats = [];
      for (int r = 0; r < _rows; r++) {
        for (int c = 0; c < _cols; c++) {
          final key = '$r-$c';
          _seats.add(_Seat(
            row: r,
            col: c,
            type: oldSeats[key] ?? SeatType.normal,
          ));
        }
      }
    });
  }

  void _toggleSeatType(int row, int col) {
    setState(() {
      final seat = _seats.firstWhere(
        (s) => s.row == row && s.col == col,
      );

      switch (seat.type) {
        case SeatType.normal:
          seat.type = SeatType.vip;
          break;
        case SeatType.vip:
          seat.type = SeatType.empty;
          break;
        case SeatType.empty:
          seat.type = SeatType.normal;
          break;
      }
    });
  }

  void _saveConfiguration() async {
    setState(() => _isLoading = true);

    try {
      final config = {
        'rows': _rows,
        'columns': _cols,
        'seats': _seats.map((s) => s.toJson()).toList(),
      };

      final normalSeats = _seats.where((s) => s.type != SeatType.empty).length;

      final updatedRoom = TheaterRoomModel(
        id: widget.room.id,
        cinemaId: widget.room.cinemaId,
        name: widget.room.name,
        capacity: normalSeats,
        seatConfiguration: config,
      );

      widget.onSave(updatedRoom);
      Navigator.pop(context);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final normalCount = _seats.where((s) => s.type == SeatType.normal).length;
    final vipCount = _seats.where((s) => s.type == SeatType.vip).length;
    final emptyCount = _seats.where((s) => s.type == SeatType.empty).length;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text('Configurar Asientos - ${widget.room.name}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _isLoading ? null : _saveConfiguration,
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppSpacing.pagePadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Configuration Panel
            Container(
              padding: AppSpacing.paddingLG,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                borderRadius: AppSpacing.borderRadiusLG,
                boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Configuración de la Sala',
                    style: AppTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: CinemaTextField(
                          controller: _rowsController,
                          label: 'Filas',
                          hint: '1-20',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: CinemaTextField(
                          controller: _colsController,
                          label: 'Columnas',
                          hint: '1-30',
                          keyboardType: TextInputType.number,
                          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        ),
                      ),
                      SizedBox(width: AppSpacing.md),
                      CinemaButton(
                        text: 'Aplicar',
                        icon: Icons.refresh,
                        onPressed: _regenerateSeats,
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      _buildLegendItem('Normal', AppColors.primary, normalCount, isDark),
                      _buildLegendItem('VIP', AppColors.warning, vipCount, isDark),
                      _buildLegendItem('Vacío', isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant, emptyCount, isDark),
                    ],
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Haz clic en un asiento para cambiar su tipo: Normal → VIP → Vacío',
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: AppSpacing.xl),

            // Screen indicator
            Center(
              child: Container(
                width: _cols * 40.0 * 0.8,
                height: 8,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            SizedBox(height: AppSpacing.xs),
            Center(
              child: Text(
                'PANTALLA',
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 2,
                ),
              ),
            ),
            SizedBox(height: AppSpacing.lg),

            // Seat Grid
            Center(
              child: Container(
                padding: AppSpacing.paddingLG,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                  borderRadius: AppSpacing.borderRadiusLG,
                  boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
                ),
                child: Column(
                  children: List.generate(_rows, (row) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Row label
                          SizedBox(
                            width: 32,
                            child: Text(
                              String.fromCharCode(65 + row),
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Seats
                          ...List.generate(_cols, (col) {
                            final seat = _seats.firstWhere(
                              (s) => s.row == row && s.col == col,
                            );
                            return Padding(
                              padding: EdgeInsets.only(right: AppSpacing.xs),
                              child: _buildSeat(seat, isDark),
                            );
                          }),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ),

            SizedBox(height: AppSpacing.xl),

            // Save Button
            Center(
              child: CinemaButton(
                text: 'Guardar Configuración',
                icon: Icons.save,
                isFullWidth: false,
                onPressed: _isLoading ? null : _saveConfiguration,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color, int count, bool isDark) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: AppSpacing.borderRadiusSM,
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: AppSpacing.xs),
          Text(
            '$label ($count)',
            style: AppTypography.bodySmall.copyWith(
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(_Seat seat, bool isDark) {
    Color seatColor;
    IconData icon;

    switch (seat.type) {
      case SeatType.normal:
        seatColor = AppColors.primary;
        icon = Icons.event_seat;
        break;
      case SeatType.vip:
        seatColor = AppColors.warning;
        icon = Icons.weekend;
        break;
      case SeatType.empty:
        seatColor = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
        icon = Icons.block;
        break;
    }

    return InkWell(
      onTap: () => _toggleSeatType(seat.row, seat.col),
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: seatColor.withOpacity(seat.type == SeatType.empty ? 0.3 : 0.8),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: seatColor,
            width: seat.type == SeatType.empty ? 1 : 2,
          ),
        ),
        child: Icon(
          icon,
          size: 16,
          color: seat.type == SeatType.empty
              ? seatColor.withOpacity(0.5)
              : Colors.white,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _rowsController.dispose();
    _colsController.dispose();
    super.dispose();
  }
}