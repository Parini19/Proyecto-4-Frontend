import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../../core/models/theater_room_model.dart';
import '../../../core/models/cinema_location.dart';
import '../../../core/services/theater_rooms_service.dart';
import '../../../core/services/cinema_location_service.dart';

class TheaterRoomsManagementPage extends StatefulWidget {
  const TheaterRoomsManagementPage({super.key});

  @override
  State<TheaterRoomsManagementPage> createState() => _TheaterRoomsManagementPageState();
}

class _TheaterRoomsManagementPageState extends State<TheaterRoomsManagementPage> {
  List<TheaterRoomModel> _theaterRooms = [];
  List<TheaterRoomModel> _filteredTheaterRooms = [];
  List<CinemaLocation> _cinemas = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  final TheaterRoomsService _theaterRoomsService = TheaterRoomsService();
  final CinemaLocationService _cinemaService = CinemaLocationService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      print('🏛️ Cargando salas y cines desde el backend...');
      final results = await Future.wait([
        _theaterRoomsService.getAllTheaterRooms(),
        _cinemaService.getActiveCinemas(),
      ]);

      final rooms = results[0] as List<TheaterRoomModel>;
      final cinemas = results[1] as List<CinemaLocation>;

      print('🏛️ Salas cargadas: ${rooms.length}, Cines cargados: ${cinemas.length}');

      setState(() {
        _theaterRooms = rooms;
        _filteredTheaterRooms = rooms;
        _cinemas = cinemas;
        _isLoading = false;
      });

      if (rooms.isEmpty) {
        print('⚠️ No se encontraron salas de cine en el backend');
      }
    } catch (e) {
      print('❌ Error cargando datos: $e');
      setState(() {
        _error = 'Error cargando datos del servidor: $e';
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
        cinemas: _cinemas,
        onSave: (room) async {
          final success = await _theaterRoomsService.addTheaterRoom(room);
          if (success) {
            _loadData();
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
        cinemas: _cinemas,
        room: room,
        onSave: (updatedRoom) async {
          final success = await _theaterRoomsService.updateTheaterRoom(updatedRoom);
          if (success) {
            _loadData();
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
                _loadData();
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
            onPressed: _loadData,
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
              onPressed: _loadData,
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      margin: EdgeInsets.only(bottom: isMobile ? AppSpacing.sm : AppSpacing.md),
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
        contentPadding: isMobile
            ? EdgeInsets.all(AppSpacing.sm)
            : AppSpacing.paddingLG,
        leading: isMobile
            ? null
            : Container(
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
          style: (isMobile ? AppTypography.titleSmall : AppTypography.titleMedium).copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.event_seat,
                  size: isMobile ? 14 : 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    'Capacidad: ${room.capacity} asientos',
                    style: (isMobile ? AppTypography.bodySmall : AppTypography.bodyMedium).copyWith(
                      color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.tag,
                  size: isMobile ? 14 : 16,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
                SizedBox(width: AppSpacing.xs),
                Flexible(
                  child: Text(
                    'ID: ${room.id}',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                      fontFamily: 'monospace',
                      fontSize: isMobile ? 10 : 12,
                    ),
                    overflow: TextOverflow.ellipsis,
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
              icon: Icon(Icons.edit, color: AppColors.primary, size: isMobile ? 20 : 24),
              onPressed: () => _showEditTheaterRoomDialog(room),
              tooltip: 'Editar sala',
              padding: isMobile ? EdgeInsets.all(8) : null,
              constraints: isMobile ? BoxConstraints() : null,
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppColors.error, size: isMobile ? 20 : 24),
              onPressed: () => _showDeleteConfirmation(room),
              tooltip: 'Eliminar sala',
              padding: isMobile ? EdgeInsets.all(8) : null,
              constraints: isMobile ? BoxConstraints() : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _TheaterRoomFormDialog extends StatefulWidget {
  final List<CinemaLocation> cinemas;
  final TheaterRoomModel? room;
  final Function(TheaterRoomModel) onSave;

  const _TheaterRoomFormDialog({
    required this.cinemas,
    this.room,
    required this.onSave,
  });

  @override
  State<_TheaterRoomFormDialog> createState() => _TheaterRoomFormDialogState();
}

enum SeatType { normal, vip, wheelchair, disabled, empty }

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

class _TheaterRoomFormDialogState extends State<_TheaterRoomFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _rowsController = TextEditingController(text: '8');
  final _colsController = TextEditingController(text: '12');

  String? _selectedCinemaId;
  bool _isLoading = false;
  bool _seatsGenerated = false;

  int _rows = 8;
  int _cols = 12;
  List<_Seat> _seats = [];

  @override
  void initState() {
    super.initState();
    if (widget.room != null) {
      _nameController.text = widget.room!.name;
      _capacityController.text = widget.room!.capacity.toString();
      _selectedCinemaId = widget.room!.cinemaId;
      _loadExistingSeatConfiguration();
    }
  }

  void _loadExistingSeatConfiguration() {
    try {
      if (widget.room?.seatConfiguration != null && widget.room!.seatConfiguration!.isNotEmpty) {
        // Parse the JSON string or object
        Map<String, dynamic> config;

        if (widget.room!.seatConfiguration is String) {
          // If it's a string, parse it
          config = Map<String, dynamic>.from(
            jsonDecode(widget.room!.seatConfiguration as String)
          );
        } else {
          // If it's already an object, use it directly
          config = Map<String, dynamic>.from(
            (widget.room!.seatConfiguration! as Map).cast<String, dynamic>()
          );
        }

        _rows = config['rows'] ?? 8;
        _cols = config['columns'] ?? 12;

        if (config['seats'] != null) {
          _seats = (config['seats'] as List)
              .map((s) => _Seat.fromJson(Map<String, dynamic>.from(s)))
              .toList();
          _seatsGenerated = true;
        }

        _rowsController.text = _rows.toString();
        _colsController.text = _cols.toString();

        setState(() {}); // Trigger rebuild to show seats
      }
    } catch (e) {
      print('Error loading seat configuration: $e');
    }
  }

  void _generateSeats() {
    final rows = int.tryParse(_rowsController.text);
    final cols = int.tryParse(_colsController.text);

    if (rows == null || cols == null || rows < 1 || rows > 20 || cols < 1 || cols > 30) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Filas: 1-20, Columnas: 1-30'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _rows = rows;
      _cols = cols;
      _seats = [];
      for (int r = 0; r < _rows; r++) {
        for (int c = 0; c < _cols; c++) {
          _seats.add(_Seat(row: r, col: c, type: SeatType.normal));
        }
      }
      _seatsGenerated = true;

      // Auto-update capacity based on seats
      final normalSeats = _seats.where((s) => s.type != SeatType.empty).length;
      _capacityController.text = normalSeats.toString();
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
          seat.type = SeatType.wheelchair;
          break;
        case SeatType.wheelchair:
          seat.type = SeatType.disabled;
          break;
        case SeatType.disabled:
          seat.type = SeatType.empty;
          break;
        case SeatType.empty:
          seat.type = SeatType.normal;
          break;
      }

      // Update capacity based on non-empty seats
      final normalSeats = _seats.where((s) => s.type != SeatType.empty).length;
      _capacityController.text = normalSeats.toString();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _capacityController.dispose();
    _rowsController.dispose();
    _colsController.dispose();
    super.dispose();
  }

  void _saveTheaterRoom() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate cinema selection
    if (_selectedCinemaId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Selecciona un cine'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    // Validate seats are generated
    if (!_seatsGenerated || _seats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Genera la configuración de asientos primero'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final config = {
        'rows': _rows,
        'columns': _cols,
        'seats': _seats.map((s) => s.toJson()).toList(),
      };

      final normalSeats = _seats.where((s) => s.type != SeatType.empty).length;

      final room = TheaterRoomModel(
        id: widget.room?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        cinemaId: _selectedCinemaId,
        name: _nameController.text.trim(),
        capacity: normalSeats,
        seatConfiguration: config,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;
    final normalCount = _seats.where((s) => s.type == SeatType.normal).length;
    final vipCount = _seats.where((s) => s.type == SeatType.vip).length;
    final emptyCount = _seats.where((s) => s.type == SeatType.empty).length;
    final wheelchairCount = _seats.where((s) => s.type == SeatType.wheelchair).length;
    final disabledCount = _seats.where((s) => s.type == SeatType.disabled).length;

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * (isMobile ? 0.95 : 0.9),
        height: MediaQuery.of(context).size.height * 0.9,
        padding: isMobile ? AppSpacing.paddingMD : AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.room == null ? 'Agregar Sala de Cine' : 'Editar Sala de Cine',
                    style: AppTypography.headlineMedium.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Divider(),
            SizedBox(height: AppSpacing.md),

            // Content
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Cinema Selection
                      SearchableDropdown<CinemaLocation>(
                        label: 'Cine *',
                        hint: 'Selecciona un cine',
                        prefixIcon: Icons.business,
                        value: widget.cinemas.where((c) => c.id == _selectedCinemaId).firstOrNull,
                        items: widget.cinemas,
                        itemLabel: (cinema) => '${cinema.name} - ${cinema.address}',
                        onChanged: (cinema) {
                          setState(() {
                            _selectedCinemaId = cinema?.id;
                          });
                        },
                      ),
                      SizedBox(height: AppSpacing.md),

                      // Name Field
                      CinemaTextField(
                        controller: _nameController,
                        label: 'Nombre de la sala *',
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

                      // Capacity Field (read-only, auto-calculated)
                      CinemaTextField(
                        controller: _capacityController,
                        label: 'Capacidad (auto-calculada)',
                        hint: 'Se calcula según configuración de asientos',
                        prefixIcon: Icons.event_seat,
                        enabled: false,
                      ),
                      SizedBox(height: AppSpacing.lg),

                      // Seat Configuration Section
                      Container(
                        padding: AppSpacing.paddingMD,
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
                          borderRadius: AppSpacing.borderRadiusLG,
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Configuración de Asientos',
                                    style: AppTypography.titleMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (widget.room != null && _seatsGenerated)
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppSpacing.sm,
                                      vertical: AppSpacing.xs,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.info.withOpacity(0.1),
                                      borderRadius: AppSpacing.borderRadiusSM,
                                      border: Border.all(color: AppColors.info.withOpacity(0.3)),
                                    ),
                                    child: Text(
                                      'Editando: ${_rows}x${_cols}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.info,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: AppSpacing.md),

                            // Only show configuration fields if creating OR if editing and seats not yet generated
                            if (widget.room == null || !_seatsGenerated) ...[
                              // Rows and Columns
                              if (isMobile)
                                Column(
                                  children: [
                                    CinemaTextField(
                                      controller: _rowsController,
                                      label: 'Filas',
                                      hint: '1-20',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    CinemaTextField(
                                      controller: _colsController,
                                      label: 'Columnas',
                                      hint: '1-30',
                                      keyboardType: TextInputType.number,
                                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    ),
                                    SizedBox(height: AppSpacing.sm),
                                    SizedBox(
                                      width: double.infinity,
                                      child: CinemaButton(
                                        text: 'Generar',
                                        icon: Icons.grid_on,
                                        onPressed: _generateSeats,
                                        size: ButtonSize.small,
                                      ),
                                    ),
                                  ],
                                )
                              else
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
                                      text: 'Generar',
                                      icon: Icons.grid_on,
                                      onPressed: _generateSeats,
                                    ),
                                  ],
                                ),
                            ],

                            if (_seatsGenerated) ...[
                              SizedBox(height: AppSpacing.md),
                              // Legend
                              Wrap(
                                spacing: AppSpacing.sm,
                                runSpacing: AppSpacing.xs,
                                children: [
                                  _buildLegendChip('Normal', AppColors.primary, normalCount, isDark),
                                  _buildLegendChip('VIP', AppColors.warning, vipCount, isDark),
                                  _buildLegendChip('Discapacitados', AppColors.error, wheelchairCount, isDark),
                                  _buildLegendChip('Deshabilitado', AppColors.textSecondary, disabledCount, isDark),
                                  _buildLegendChip('Vacío', isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant, emptyCount, isDark),
                                ],
                              ),
                              SizedBox(height: AppSpacing.xs),
                              Text(
                                'Haz clic en un asiento para cambiar su tipo',
                                style: AppTypography.bodySmall.copyWith(
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),

                              // Screen indicator
                              Center(
                                child: Column(
                                  children: [
                                    Container(
                                      width: _cols * 32.0 * 0.8,
                                      height: 6,
                                      decoration: BoxDecoration(
                                        gradient: AppColors.primaryGradient,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                    SizedBox(height: AppSpacing.xs),
                                    Text(
                                      'PANTALLA',
                                      style: AppTypography.labelSmall.copyWith(
                                        color: AppColors.textSecondary,
                                        letterSpacing: 2,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: AppSpacing.md),

                              // Seat Grid
                              Center(
                                child: SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: Column(
                                    children: List.generate(_rows, (row) {
                                      return Padding(
                                        padding: EdgeInsets.only(bottom: AppSpacing.xs),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            // Row label
                                            SizedBox(
                                              width: 24,
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
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            SizedBox(height: AppSpacing.md),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: _isLoading ? null : () => Navigator.pop(context),
                  style: isMobile
                      ? TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                          textStyle: TextStyle(fontSize: 12),
                        )
                      : null,
                  child: Text('Cancelar'),
                ),
                SizedBox(width: AppSpacing.sm),
                CinemaButton(
                  text: widget.room == null ? 'Crear Sala' : 'Guardar Cambios',
                  icon: Icons.save,
                  isFullWidth: false,
                  size: isMobile ? ButtonSize.small : ButtonSize.medium,
                  onPressed: _isLoading ? null : _saveTheaterRoom,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendChip(String label, Color color, int count, bool isDark) {
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
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
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
    late Color seatColor;
    late IconData icon;

    switch (seat.type) {
      case SeatType.normal:
        seatColor = AppColors.primary;
        icon = Icons.event_seat;
        break;
      case SeatType.vip:
        seatColor = AppColors.warning;
        icon = Icons.weekend;
        break;
      case SeatType.wheelchair:
        seatColor = AppColors.error;
        icon = Icons.accessible;
        break;
      case SeatType.disabled:
        seatColor = AppColors.textSecondary;
        icon = Icons.not_accessible;
        break;
      case SeatType.empty:
        seatColor = isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant;
        icon = Icons.block;
        break;
    }

    return InkWell(
      onTap: () => _toggleSeatType(seat.row, seat.col),
      borderRadius: BorderRadius.circular(4),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: seatColor.withOpacity(seat.type == SeatType.empty ? 0.3 : 0.8),
          borderRadius: BorderRadius.circular(4),
          border: Border.all(
            color: seatColor,
            width: seat.type == SeatType.empty ? 1 : 2,
          ),
        ),
        child: Icon(
          icon,
          size: 14,
          color: seat.type == SeatType.empty
              ? seatColor.withOpacity(0.5)
              : Colors.white,
        ),
      ),
    );
  }
}
