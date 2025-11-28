import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../../core/models/screening.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/models/theater_room.dart';
import '../../../core/models/cinema_location.dart';
import '../../../core/services/screening_service.dart';
import '../../../core/services/movies_service.dart';
import '../../../core/services/theater_room_service.dart';
import '../../../core/services/cinema_location_service.dart';

class ScreeningsManagementPage extends StatefulWidget {
  const ScreeningsManagementPage({super.key});

  @override
  State<ScreeningsManagementPage> createState() => _ScreeningsManagementPageState();
}

class _ScreeningsManagementPageState extends State<ScreeningsManagementPage> {
  List<Screening> _screenings = [];
  List<Screening> _filteredScreenings = [];
  List<MovieModel> _movies = [];
  List<TheaterRoom> _theaterRooms = [];
  List<CinemaLocation> _cinemas = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCinemaId; // Filter by cinema
  String? _error;
  final ScreeningService _screeningService = ScreeningService();
  final MoviesService _moviesService = MoviesService();
  final TheaterRoomService _theaterRoomService = TheaterRoomService();
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
      final futures = await Future.wait([
        _screeningService.getAllScreenings(),
        _moviesService.getAllMovies(),
        _theaterRoomService.getAllTheaterRooms(),
        _cinemaService.getActiveCinemas(),
      ]);

      setState(() {
        _screenings = futures[0] as List<Screening>;
        _movies = futures[1] as List<MovieModel>;
        _theaterRooms = futures[2] as List<TheaterRoom>;
        _cinemas = futures[3] as List<CinemaLocation>;
        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando datos: $e';
        _isLoading = false;
      });
    }
  }

  void _filterScreenings(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _filterByCinema(String? cinemaId) {
    setState(() {
      _selectedCinemaId = cinemaId;
      _applyFilters();
    });
  }

  void _applyFilters() {
    _filteredScreenings = _screenings.where((screening) {
      // Search filter
      final matchesSearch = _searchQuery.isEmpty || () {
        final movie = _getMovieById(screening.movieId);
        final theaterRoom = _getTheaterRoomById(screening.theaterRoomId);
        return movie?.title.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
               theaterRoom?.name.toLowerCase().contains(_searchQuery.toLowerCase()) == true ||
               screening.formattedDate.contains(_searchQuery) ||
               screening.formattedStartTime.contains(_searchQuery);
      }();

      // Cinema filter
      final matchesCinema = _selectedCinemaId == null || screening.cinemaId == _selectedCinemaId;

      return matchesSearch && matchesCinema;
    }).toList();
  }

  MovieModel? _getMovieById(String movieId) {
    try {
      return _movies.firstWhere((movie) => movie.id == movieId);
    } catch (e) {
      return null;
    }
  }

  TheaterRoom? _getTheaterRoomById(String theaterRoomId) {
    try {
      return _theaterRooms.firstWhere((room) => room.id == theaterRoomId);
    } catch (e) {
      return null;
    }
  }

  CinemaLocation? _getCinemaById(String cinemaId) {
    try {
      return _cinemas.firstWhere((cinema) => cinema.id == cinemaId);
    } catch (e) {
      return null;
    }
  }

  Future<void> _initializeDefaultRooms() async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
            SizedBox(width: 16),
            Text('Inicializando salas por defecto...'),
          ],
        ),
        duration: Duration(seconds: 30),
      ),
    );

    try {
      final success = await _theaterRoomService.initializeDefaultRooms();
      ScaffoldMessenger.of(context).clearSnackBars();
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 16),
                Text('Salas inicializadas correctamente'),
              ],
            ),
            backgroundColor: AppColors.success,
          ),
        );
        
        // Reload data to refresh the theater rooms
        await _loadData();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 16),
                Text('Error al inicializar salas. Verifique la conexión.'),
              ],
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).clearSnackBars();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 16),
              Text('Error: $e'),
            ],
          ),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Gestión de Funciones',
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
            tooltip: 'Actualizar',
          ),
          SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: AppSpacing.pagePadding,
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar funciones...',
                          prefixIcon: Icon(Icons.search),
                          filled: true,
                          fillColor: isDark
                              ? AppColors.darkSurfaceVariant
                              : AppColors.lightSurfaceVariant,
                          border: OutlineInputBorder(
                            borderRadius: AppSpacing.borderRadiusMD,
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: _filterScreenings,
                      ),
                    ),
                    SizedBox(width: AppSpacing.md),
                    CinemaButton(
                      text: 'Nueva Función',
                      icon: Icons.add,
                      onPressed: () => _showAddEditDialog(context, isDark),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                // Cinema Filter
                Row(
                  children: [
                    Icon(Icons.business, size: 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                    SizedBox(width: AppSpacing.xs),
                    Text(
                      'Filtrar por cine:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: Text('Todos'),
                            selected: _selectedCinemaId == null,
                            onSelected: (_) => _filterByCinema(null),
                          ),
                          ..._cinemas.map((cinema) => ChoiceChip(
                                label: Text(cinema.name),
                                selected: _selectedCinemaId == cinema.id,
                                onSelected: (_) => _filterByCinema(cinema.id),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Screenings List
          Expanded(
            child: _buildScreeningsContent(isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildScreeningsContent(bool isDark) {
    if (_isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadData,
              child: Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_filteredScreenings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event, size: 64, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
            SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No hay funciones programadas'
                  : 'No se encontraron funciones\nque coincidan con "$_searchQuery"',
              style: AppTypography.bodyLarge.copyWith(color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty) ...[
              SizedBox(height: 16),
              TextButton(
                onPressed: () => _filterScreenings(''),
                child: Text('Ver todas las funciones'),
              ),
            ],
          ],
        ),
      );
    }

    return ListView.builder(
      padding: AppSpacing.pagePadding,
      itemCount: _filteredScreenings.length,
      itemBuilder: (context, index) {
        final screening = _filteredScreenings[index];
        return _buildScreeningCard(screening, isDark);
      },
    );
  }

  Widget _buildScreeningCard(Screening screening, bool isDark) {
    final movie = _getMovieById(screening.movieId);
    final theaterRoom = _getTheaterRoomById(screening.theaterRoomId);
    final cinema = _getCinemaById(screening.cinemaId);

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
      ),
      child: Padding(
        padding: AppSpacing.paddingLG,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie?.title ?? 'Película no encontrada',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(Icons.business, size: 14, color: AppColors.secondary),
                          SizedBox(width: 4),
                          Text(
                            cinema?.name ?? 'Cine no encontrado',
                            style: AppTypography.bodySmall.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 2),
                      Text(
                        theaterRoom?.name ?? 'Sala no encontrada',
                        style: AppTypography.bodyMedium.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: screening.isFuture 
                        ? AppColors.success.withOpacity(0.1)
                        : screening.isActive
                            ? AppColors.warning.withOpacity(0.1)
                            : AppColors.textSecondary.withOpacity(0.1),
                    borderRadius: AppSpacing.borderRadiusRound,
                  ),
                  child: Text(
                    screening.isFuture 
                        ? 'Programada'
                        : screening.isActive
                            ? 'En Curso'
                            : 'Finalizada',
                    style: AppTypography.labelSmall.copyWith(
                      color: screening.isFuture 
                          ? AppColors.success
                          : screening.isActive
                              ? AppColors.warning
                              : AppColors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Icon(Icons.calendar_today, size: 16, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  screening.formattedDate,
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Icon(Icons.access_time, size: 16, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '${screening.formattedStartTime} - ${screening.formattedEndTime}',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Icon(Icons.timer, size: 16, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '${screening.durationMinutes} min',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(Icons.account_balance_wallet, size: 16, color: AppColors.success),
                SizedBox(width: AppSpacing.xs),
                Text(
                  '₡${screening.price.toStringAsFixed(0)}',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showAddEditDialog(context, isDark, screening: screening),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
                    ),
                    child: Text('Editar'),
                  ),
                ),
                SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: Icon(Icons.delete, color: AppColors.error),
                  onPressed: () => _showDeleteDialog(context, screening),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAddEditDialog(BuildContext context, bool isDark, {Screening? screening}) {
    String? selectedMovieId = screening?.movieId;
    String? selectedTheaterRoomId = screening?.theaterRoomId;
    DateTime selectedStartTime = screening?.startTime ?? DateTime.now().toUtc();
    DateTime selectedEndTime = screening?.endTime ?? DateTime.now().toUtc().add(Duration(hours: 2));
    TextEditingController priceController = TextEditingController(text: screening?.price.toString() ?? '4500');

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            screening == null ? 'Nueva Función' : 'Editar Función',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 500,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Movie Selection
                  SearchableDropdown<MovieModel>(
                    label: 'Película *',
                    hint: 'Selecciona una película',
                    prefixIcon: Icons.movie,
                    value: _movies.where((m) => m.id == selectedMovieId).firstOrNull,
                    items: _movies,
                    itemLabel: (movie) => movie.title,
                    onChanged: (movie) {
                      setState(() {
                        selectedMovieId = movie?.id;
                      });
                    },
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Theater Room Selection
                  SearchableDropdown<TheaterRoom>(
                    label: 'Sala de Cine *',
                    hint: 'Selecciona una sala',
                    prefixIcon: Icons.meeting_room,
                    value: _theaterRooms.where((r) => r.id == selectedTheaterRoomId).firstOrNull,
                    items: _theaterRooms,
                    itemLabel: (room) => '${room.name} (${room.capacity} asientos)',
                    onChanged: (room) {
                      setState(() {
                        selectedTheaterRoomId = room?.id;
                      });
                    },
                  ),
                  
                  // Mensaje de ayuda cuando no hay salas disponibles
                  if (_theaterRooms.isEmpty)
                    Container(
                      margin: EdgeInsets.only(top: AppSpacing.xs),
                      padding: EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.warning, color: Colors.orange, size: 16),
                          SizedBox(width: AppSpacing.xs),
                          Expanded(
                            child: Text(
                              'No hay salas disponibles desde Firestore.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[800],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () => _initializeDefaultRooms(),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              minimumSize: Size(0, 0),
                            ),
                            child: Text(
                              'Inicializar',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  SizedBox(height: AppSpacing.md),

                  // Price Field
                  TextField(
                    controller: priceController,
                    decoration: InputDecoration(
                      labelText: 'Precio (₡) *',
                      hintText: 'Ej: 4500',
                      prefixIcon: Icon(Icons.account_balance_wallet),
                      filled: true,
                      fillColor: isDark
                          ? AppColors.darkSurfaceVariant
                          : AppColors.lightSurfaceVariant,
                      border: OutlineInputBorder(
                        borderRadius: AppSpacing.borderRadiusMD,
                        borderSide: BorderSide.none,
                      ),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                  SizedBox(height: AppSpacing.md),

                  // Start Date & Time
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: selectedStartTime,
                              firstDate: DateTime.now(),
                              lastDate: DateTime.now().add(Duration(days: 365)),
                            );
                            if (date != null) {
                              setState(() {
                                selectedStartTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  selectedStartTime.hour,
                                  selectedStartTime.minute,
                                );
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.calendar_today, color: AppColors.primary),
                                SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Fecha',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      Text(
                                        '${selectedStartTime.day}/${selectedStartTime.month}/${selectedStartTime.year}',
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final time = await showTimePicker(
                              context: context,
                              initialTime: TimeOfDay.fromDateTime(selectedStartTime),
                            );
                            if (time != null) {
                              setState(() {
                                selectedStartTime = DateTime(
                                  selectedStartTime.year,
                                  selectedStartTime.month,
                                  selectedStartTime.day,
                                  time.hour,
                                  time.minute,
                                );
                                // Auto-calculate end time (2 hours later)
                                selectedEndTime = selectedStartTime.add(Duration(hours: 2));
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            decoration: BoxDecoration(
                              border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.access_time, color: AppColors.primary),
                                SizedBox(width: AppSpacing.sm),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Hora Inicio',
                                        style: AppTypography.labelSmall.copyWith(
                                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                        ),
                                      ),
                                      Text(
                                        '${selectedStartTime.hour.toString().padLeft(2, '0')}:${selectedStartTime.minute.toString().padLeft(2, '0')}',
                                        style: AppTypography.bodyMedium,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSpacing.md),

                  // End Time (Auto-calculated, but editable)
                  InkWell(
                    onTap: () async {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(selectedEndTime),
                      );
                      if (time != null) {
                        setState(() {
                          selectedEndTime = DateTime(
                            selectedStartTime.year,
                            selectedStartTime.month,
                            selectedStartTime.day,
                            time.hour,
                            time.minute,
                          ); // Will be converted to UTC when creating Screening object
                        });
                      }
                    },
                    child: Container(
                      padding: EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.access_time_filled, color: AppColors.secondary),
                          SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hora Fin',
                                  style: AppTypography.labelSmall.copyWith(
                                    color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                                  ),
                                ),
                                Text(
                                  '${selectedEndTime.hour.toString().padLeft(2, '0')}:${selectedEndTime.minute.toString().padLeft(2, '0')}',
                                  style: AppTypography.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                          Text(
                            'Duración: ${selectedEndTime.difference(selectedStartTime).inMinutes} min',
                            style: AppTypography.labelSmall.copyWith(
                              color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancelar'),
            ),
            CinemaButton(
              text: screening == null ? 'Crear' : 'Guardar',
              onPressed: () async {
                // Validate required fields
                if (selectedMovieId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selecciona una película'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (selectedTheaterRoomId == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selecciona una sala de cine'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (selectedEndTime.isBefore(selectedStartTime)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('La hora de fin debe ser posterior a la hora de inicio'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Validate price
                final priceText = priceController.text.trim();
                if (priceText.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('El precio es requerido'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                final price = double.tryParse(priceText);
                if (price == null || price <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('El precio debe ser un número válido mayor a 0'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                // Get cinema ID from the selected theater room
                final selectedRoom = _theaterRooms.firstWhere((r) => r.id == selectedTheaterRoomId);
                final cinemaId = selectedRoom.cinemaId;

                Navigator.pop(context); // Close dialog first

                // Show loading
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 16),
                        Text(screening == null ? 'Creando función...' : 'Actualizando función...'),
                      ],
                    ),
                    duration: Duration(seconds: 30),
                  ),
                );

                try {
                  // Create Screening from form data
                  final newScreening = Screening(
                    id: screening?.id ?? '', // Empty for new screenings, backend will generate
                    movieId: selectedMovieId!,
                    cinemaId: cinemaId,
                    theaterRoomId: selectedTheaterRoomId!,
                    startTime: selectedStartTime.toUtc(),
                    endTime: selectedEndTime.toUtc(),
                    price: price,
                  );

                  bool success;
                  if (screening == null) {
                    // Create new screening
                    success = await _screeningService.createScreening(newScreening);
                  } else {
                    // Update existing screening
                    success = await _screeningService.updateScreening(newScreening);
                  }

                  // Clear loading snackbar
                  ScaffoldMessenger.of(context).clearSnackBars();

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          screening == null
                              ? 'Función creada exitosamente'
                              : 'Función actualizada exitosamente',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );

                    // Reload screenings
                    await _loadData();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          screening == null
                              ? 'Error al crear la función'
                              : 'Error al actualizar la función',
                        ),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                } catch (e) {
                  // Clear loading snackbar
                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Screening screening) {
    final movie = _getMovieById(screening.movieId);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Función'),
        content: Text('¿Estás seguro que deseas eliminar la función de "${movie?.title ?? 'Película desconocida'}" del ${screening.formattedDate} a las ${screening.formattedStartTime}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Row(
                    children: [
                      SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                      SizedBox(width: 16),
                      Text('Eliminando función...'),
                    ],
                  ),
                  duration: Duration(seconds: 30),
                ),
              );

              try {
                final success = await _screeningService.deleteScreening(screening.id);
                ScaffoldMessenger.of(context).clearSnackBars();
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Función eliminada exitosamente'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                  _loadData();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error al eliminar la función'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              } catch (e) {
                ScaffoldMessenger.of(context).clearSnackBars();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );
  }
}
