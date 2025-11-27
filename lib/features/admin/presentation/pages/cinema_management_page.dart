import 'package:flutter/material.dart';
import '../../../../core/models/cinema_location.dart';
import '../../../../core/services/cinema_location_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/cinema_button.dart';
import '../../../../core/widgets/cinema_card.dart';
import 'cinema_form_page.dart';

/// Página de gestión de cines/sedes
/// Permite al admin ver, crear, editar y eliminar cines
class CinemaManagementPage extends StatefulWidget {
  const CinemaManagementPage({super.key});

  @override
  State<CinemaManagementPage> createState() => _CinemaManagementPageState();
}

class _CinemaManagementPageState extends State<CinemaManagementPage> {
  final CinemaLocationService _cinemaService = CinemaLocationService();
  List<CinemaLocation> _cinemas = [];
  bool _isLoading = true;
  String? _errorMessage;
  String _searchQuery = '';
  String _filterCity = 'all';

  @override
  void initState() {
    super.initState();
    _loadCinemas();
  }

  Future<void> _loadCinemas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cinemas = await _cinemaService.getAllCinemas();
      setState(() {
        _cinemas = cinemas;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar cines: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleCinemaStatus(CinemaLocation cinema) async {
    try {
      await _cinemaService.toggleCinemaStatus(cinema.id, !cinema.isActive);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cinema.isActive ? 'Cine desactivado' : 'Cine activado',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      _loadCinemas();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _deleteCinema(CinemaLocation cinema) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: Text(
          '¿Está seguro de eliminar el cine "${cinema.name}"?\n\n'
          'IMPORTANTE: Asegúrese de que no tenga salas o funciones asociadas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          CinemaButton(
            text: 'Eliminar',
            onPressed: () => Navigator.of(context).pop(true),
            variant: ButtonVariant.secondary,
            customColor: AppColors.error,
            size: ButtonSize.small,
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _cinemaService.deleteCinema(cinema.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cine eliminado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadCinemas();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _navigateToCreateCinema() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const CinemaFormPage(),
      ),
    ).then((_) => _loadCinemas());
  }

  void _navigateToEditCinema(CinemaLocation cinema) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CinemaFormPage(cinema: cinema),
      ),
    ).then((_) => _loadCinemas());
  }

  List<CinemaLocation> get _filteredCinemas {
    return _cinemas.where((cinema) {
      final matchesSearch = cinema.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          cinema.city.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCity = _filterCity == 'all' || cinema.city == _filterCity;
      return matchesSearch && matchesCity;
    }).toList();
  }

  Set<String> get _availableCities {
    return _cinemas.map((c) => c.city).toSet();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Gestión de Cines'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadCinemas,
            tooltip: 'Recargar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView()
              : _buildCinemasList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateCinema,
        icon: const Icon(Icons.add_business),
        label: const Text('Nuevo Cine'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: AppSpacing.lg),
          Text(
            _errorMessage ?? 'Error desconocido',
            style: TextStyle(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.md),
          CinemaButton(
            text: 'Reintentar',
            onPressed: _loadCinemas,
            variant: ButtonVariant.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildCinemasList() {
    if (_cinemas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.business, size: 64, color: AppColors.textSecondary),
            SizedBox(height: AppSpacing.md),
            Text(
              'No hay cines registrados',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: AppSpacing.md),
            CinemaButton(
              text: 'Crear primer cine',
              onPressed: _navigateToCreateCinema,
              variant: ButtonVariant.primary,
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        _buildFilters(),
        Expanded(
          child: _filteredCinemas.isEmpty
              ? _buildNoResultsView()
              : _buildCinemasGrid(),
        ),
      ],
    );
  }

  Widget _buildFilters() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: AppSpacing.paddingMD,
      color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
      child: Column(
        children: [
          // Search bar
          TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o ciudad...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: AppSpacing.borderRadiusMD,
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
          SizedBox(height: AppSpacing.sm),
          // City filter
          Row(
            children: [
              const Text('Ciudad:', style: TextStyle(fontWeight: FontWeight.bold)),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('Todas'),
                      selected: _filterCity == 'all',
                      onSelected: (_) => setState(() => _filterCity = 'all'),
                    ),
                    ..._availableCities.map((city) => ChoiceChip(
                          label: Text(city),
                          selected: _filterCity == city,
                          onSelected: (_) => setState(() => _filterCity = city),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoResultsView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 64, color: AppColors.textSecondary),
          SizedBox(height: AppSpacing.md),
          Text(
            'No se encontraron resultados',
            style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildCinemasGrid() {
    return GridView.builder(
      padding: AppSpacing.paddingMD,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        childAspectRatio: 1.2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredCinemas.length,
      itemBuilder: (context, index) {
        final cinema = _filteredCinemas[index];
        return _buildCinemaCard(cinema);
      },
    );
  }

  Widget _buildCinemaCard(CinemaLocation cinema) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
      ),
      padding: AppSpacing.paddingMD,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with status
          Row(
            children: [
              Expanded(
                child: Text(
                  cinema.name,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: cinema.isActive ? AppColors.success : AppColors.error,
                  borderRadius: AppSpacing.borderRadiusSM,
                ),
                child: Text(
                  cinema.isActive ? 'Activo' : 'Inactivo',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          // City
          Row(
            children: [
              Icon(Icons.location_city, size: 16, color: AppColors.secondary),
              SizedBox(width: AppSpacing.sm),
              Text(
                cinema.city,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          // Address
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: AppColors.primary),
              SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  cinema.address,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSpacing.sm),
          // Phone
          Row(
            children: [
              Icon(Icons.phone, size: 16, color: AppColors.success),
              SizedBox(width: AppSpacing.sm),
              Text(
                cinema.phone,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const Spacer(),
          // Actions
          Row(
            children: [
              Expanded(
                child: CinemaButton(
                  text: 'Editar',
                  onPressed: () => _navigateToEditCinema(cinema),
                  variant: ButtonVariant.secondary,
                  size: ButtonSize.small,
                  icon: Icons.edit,
                ),
              ),
              SizedBox(width: AppSpacing.sm),
              IconButton(
                icon: Icon(
                  cinema.isActive ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.primary,
                ),
                onPressed: () => _toggleCinemaStatus(cinema),
                tooltip: cinema.isActive ? 'Desactivar' : 'Activar',
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: AppColors.error),
                onPressed: () => _deleteCinema(cinema),
                tooltip: 'Eliminar',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
