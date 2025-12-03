import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../../core/models/screening.dart';
import '../../../core/models/movie_model.dart';
import '../../../core/models/theater_room_model.dart';
import '../../../core/models/cinema_location.dart';
import '../../../core/services/screening_service.dart';
import '../../../core/services/movies_service.dart';
import '../../../core/services/theater_rooms_service.dart';
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
  List<TheaterRoomModel> _theaterRooms = [];
  List<CinemaLocation> _cinemas = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _selectedCinemaId; // Filter by cinema
  String? _error;
  final ScreeningService _screeningService = ScreeningService();
  final MoviesService _moviesService = MoviesService();
  final TheaterRoomsService _theaterRoomService = TheaterRoomsService();
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
        _theaterRooms = futures[2] as List<TheaterRoomModel>;
        _cinemas = futures[3] as List<CinemaLocation>;

        // Debug logs
        print('📊 Datos cargados para Funciones:');
        print('   Funciones: ${_screenings.length}');
        print('   Películas: ${_movies.length}');
        print('   Salas: ${_theaterRooms.length}');
        print('   Cines: ${_cinemas.length}');
        if (_theaterRooms.isNotEmpty) {
          print('   Ejemplos de salas:');
          for (var room in _theaterRooms.take(3)) {
            print('     - ${room.name} (CinemaId: ${room.cinemaId})');
          }
        }

        _applyFilters();
        _isLoading = false;
      });
    } catch (e) {
      print('❌ Error cargando datos de funciones: $e');
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

  TheaterRoomModel? _getTheaterRoomById(String theaterRoomId) {
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Gestión de Funciones',
          style: (isMobile ? AppTypography.headlineSmall : AppTypography.headlineMedium).copyWith(
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
          if (!isMobile) SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter Bar
          Container(
            padding: isMobile ? AppSpacing.paddingSM : AppSpacing.pagePadding,
            child: Column(
              children: [
                // Search bar and button
                isMobile
                    ? Column(
                        children: [
                          TextField(
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
                              contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                            ),
                            onChanged: _filterScreenings,
                          ),
                          SizedBox(height: AppSpacing.sm),
                          SizedBox(
                            width: double.infinity,
                            child: CinemaButton(
                              text: 'Nueva Función',
                              icon: Icons.add,
                              onPressed: () => _showAddEditDialog(context, isDark),
                            ),
                          ),
                        ],
                      )
                    : Row(
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
                SizedBox(height: isMobile ? AppSpacing.xs : AppSpacing.sm),
                // Cinema Filter
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.business, size: isMobile ? 14 : 16, color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        SizedBox(width: AppSpacing.xs),
                        Text(
                          'Filtrar por cine:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: isMobile ? 12 : 14,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: AppSpacing.xs),
                    SizedBox(
                      height: isMobile ? 40 : 48,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text('Todos'),
                              selected: _selectedCinemaId == null,
                              onSelected: (_) => _filterByCinema(null),
                              visualDensity: isMobile
                                  ? VisualDensity.compact
                                  : VisualDensity.standard,
                            ),
                          ),
                          ..._cinemas.map((cinema) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: ChoiceChip(
                                  label: Text(cinema.name),
                                  selected: _selectedCinemaId == cinema.id,
                                  onSelected: (_) => _filterByCinema(cinema.id),
                                  visualDensity: isMobile
                                      ? VisualDensity.compact
                                      : VisualDensity.standard,
                                ),
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
    String? selectedCinemaIdInDialog = screening?.cinemaId; // Cinema selection for the dialog
    String? selectedTheaterRoomId = screening?.theaterRoomId;

    // Convert UTC times from backend to local time for display in pickers
    final now = DateTime.now();
    DateTime selectedStartTime = screening?.startTime ?? now;
    DateTime selectedEndTime = screening?.endTime ?? now.add(Duration(hours: 2));

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
                  // Cinema Selection
                  SearchableDropdown<CinemaLocation>(
                    label: 'Cine *',
                    hint: 'Selecciona un cine',
                    prefixIcon: Icons.business,
                    value: _cinemas.where((c) => c.id == selectedCinemaIdInDialog).firstOrNull,
                    items: _cinemas,
                    itemLabel: (cinema) => '${cinema.name} - ${cinema.address}',
                    onChanged: (cinema) {
                      setState(() {
                        selectedCinemaIdInDialog = cinema?.id;
                        // Reset theater room if it doesn't belong to the new cinema
                        if (selectedTheaterRoomId != null) {
                          final selectedRoom = _theaterRooms.where((r) => r.id == selectedTheaterRoomId).firstOrNull;
                          if (selectedRoom == null || selectedRoom.cinemaId != selectedCinemaIdInDialog) {
                            selectedTheaterRoomId = null; // Reset if room doesn't belong to new cinema
                          }
                        }
                      });
                    },
                  ),
                  SizedBox(height: AppSpacing.md),

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

                  // Theater Room Selection (filtered by cinema)
                  SearchableDropdown<TheaterRoomModel>(
                    label: 'Sala de Cine *',
                    hint: selectedCinemaIdInDialog == null
                        ? 'Primero selecciona un cine'
                        : 'Selecciona una sala',
                    prefixIcon: Icons.meeting_room,
                    value: _theaterRooms.where((r) => r.id == selectedTheaterRoomId).firstOrNull,
                    items: selectedCinemaIdInDialog == null
                        ? []
                        : _theaterRooms.where((room) => room.cinemaId == selectedCinemaIdInDialog).toList(),
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
                              'No hay salas disponibles. Por favor, crea salas desde la sección de Gestión de Salas.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[800],
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
                                // Use local time - will be converted to UTC when sending to backend
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
                                // Use local time - will be converted to UTC when sending to backend
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
                          // Use local time - will be converted to UTC when sending to backend
                          selectedEndTime = DateTime(
                            selectedStartTime.year,
                            selectedStartTime.month,
                            selectedStartTime.day,
                            time.hour,
                            time.minute,
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
                if (selectedCinemaIdInDialog == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selecciona un cine'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

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

                // Use the cinema ID selected by the user
                final cinemaId = selectedCinemaIdInDialog!;

                // Show loading indicator in the dialog
                setState(() {
                  // Optional: could add a loading state here
                });

                try {
                  // Create Screening from form data
                  // Note: selectedStartTime and selectedEndTime are in local time, will be converted to UTC in toJson()
                  final newScreening = Screening(
                    id: screening?.id ?? '', // Empty for new screenings, backend will generate
                    movieId: selectedMovieId!,
                    cinemaId: cinemaId,
                    theaterRoomId: selectedTheaterRoomId!,
                    startTime: selectedStartTime, // Local time, will be converted to UTC in toJson()
                    endTime: selectedEndTime, // Local time, will be converted to UTC in toJson()
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

                  // Close dialog AFTER operation completes
                  if (!context.mounted) return;
                  Navigator.pop(context);

                  if (success) {
                    // Reload screenings FIRST
                    await _loadData();

                    // Then show success message
                    if (!context.mounted) return;
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
                  } else {
                    if (!context.mounted) return;
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
                  // Close dialog if still open
                  if (context.mounted && Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }

                  if (!context.mounted) return;
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
