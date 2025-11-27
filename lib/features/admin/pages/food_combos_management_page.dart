import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../../../core/models/food_combo.dart';
import '../../../core/services/food_combo_service.dart';
import '../../../core/utils/currency_formatter.dart';

class FoodCombosManagementPage extends StatefulWidget {
  const FoodCombosManagementPage({super.key});

  @override
  State<FoodCombosManagementPage> createState() => _FoodCombosManagementPageState();
}

class _FoodCombosManagementPageState extends State<FoodCombosManagementPage> {
  List<FoodCombo> _combos = [];
  List<FoodCombo> _filteredCombos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  final FoodComboService _foodComboService = FoodComboService();

  @override
  void initState() {
    super.initState();
    _loadFoodCombos();
  }

  Future<void> _loadFoodCombos() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final combos = await _foodComboService.getAllFoodCombos();
      
      setState(() {
        _combos = combos;
        _filteredCombos = combos;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error al cargar los combos de comida: $e';
        _isLoading = false;
      });
    }
  }

  void _filterCombos(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredCombos = _combos;
      } else {
        _filteredCombos = _combos.where((combo) {
          return combo.name.toLowerCase().contains(query.toLowerCase()) ||
                 combo.category.toLowerCase().contains(query.toLowerCase()) ||
                 combo.description.toLowerCase().contains(query.toLowerCase());
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
                  Icons.fastfood,
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
                      'Gestión de Combos de Comida',
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Administra los combos de comida disponibles en el cinema',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CinemaButton(
                text: 'Agregar Combo',
                onPressed: () => _showAddEditDialog(),
                icon: Icons.add,
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
                  label: 'Buscar combos...',
                  prefixIcon: Icons.search,
                  onChanged: _filterCombos,
                ),
              ),
              SizedBox(width: AppSpacing.lg),
              
              // Stats Cards
              Expanded(
                child: _buildStatCard(
                  'Total Combos',
                  _combos.length.toString(),
                  Icons.fastfood,
                  AppColors.primary,
                  isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'Disponibles',
                  _combos.where((c) => c.isAvailable).length.toString(),
                  Icons.check_circle,
                  AppColors.success,
                  isDark,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildStatCard(
                  'No Disponibles',
                  _combos.where((c) => !c.isAvailable).length.toString(),
                  Icons.cancel,
                  AppColors.error,
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
            'Cargando combos de comida...',
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
            'Error al cargar los combos',
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
            onPressed: _loadFoodCombos,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody(BuildContext context) {
    if (_filteredCombos.isEmpty && _searchQuery.isNotEmpty) {
      return _buildNoResultsFound();
    }

    if (_filteredCombos.isEmpty) {
      return _buildEmptyState();
    }

    return _buildCombosList(context);
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
                Icons.fastfood_outlined,
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
                'No hay combos de comida',
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
                'Agrega el primer combo de comida para comenzar',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
              );
            }
          ),
          SizedBox(height: AppSpacing.xl),
          CinemaButton(
            text: 'Agregar Combo',
            onPressed: () => _showAddEditDialog(),
            icon: Icons.add,
          ),
        ],
      ),
    );
  }

  Widget _buildCombosList(BuildContext context) {
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
                Expanded(flex: 3, child: _buildHeaderCell('Combo')),
                Expanded(flex: 2, child: _buildHeaderCell('Categoría')),
                Expanded(flex: 2, child: _buildHeaderCell('Precio')),
                Expanded(flex: 2, child: _buildHeaderCell('Estado')),
                Expanded(flex: 2, child: _buildHeaderCell('Acciones')),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _filteredCombos.length,
              itemBuilder: (context, index) {
                return _buildComboRow(context, _filteredCombos[index], index);
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
      },
    );
  }

  Widget _buildComboRow(BuildContext context, FoodCombo combo, int index) {
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
          // Combo Info
          Expanded(
            flex: 3,
            child: Row(
              children: [
                // Image
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: combo.imageUrl.isNotEmpty
                        ? Image.network(
                            combo.imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: AppColors.textTertiary.withOpacity(0.1),
                                child: Icon(
                                  Icons.fastfood,
                                  color: AppColors.textTertiary,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: AppColors.textTertiary.withOpacity(0.1),
                            child: Icon(
                              Icons.fastfood,
                              color: AppColors.textTertiary,
                            ),
                          ),
                  ),
                ),
                SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        combo.name,
                        style: AppTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        combo.description,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (combo.items.isNotEmpty) ...[
                        SizedBox(height: AppSpacing.xs),
                        Text(
                          'Items: ${combo.items.join(', ')}',
                          style: AppTypography.bodySmall.copyWith(
                            color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                            fontStyle: FontStyle.italic,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Category
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                combo.category.isEmpty ? 'Sin categoría' : combo.category,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Price
          Expanded(
            flex: 2,
            child: Text(
              CurrencyFormatter.formatCRC(combo.price),
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.success,
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
                color: combo.isAvailable
                    ? AppColors.success.withOpacity(0.1)
                    : AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    combo.isAvailable ? Icons.check_circle : Icons.cancel,
                    size: 16,
                    color: combo.isAvailable ? AppColors.success : AppColors.error,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    combo.isAvailable ? 'Disponible' : 'No disponible',
                    style: AppTypography.bodySmall.copyWith(
                      color: combo.isAvailable ? AppColors.success : AppColors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                IconButton(
                  onPressed: () => _showAddEditDialog(combo: combo),
                  icon: Icon(Icons.edit, color: AppColors.primary),
                  tooltip: 'Editar',
                ),
                IconButton(
                  onPressed: () => _showDeleteDialog(combo),
                  icon: Icon(Icons.delete, color: AppColors.error),
                  tooltip: 'Eliminar',
                ),
                IconButton(
                  onPressed: () => _toggleAvailability(combo),
                  icon: Icon(
                    combo.isAvailable ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.textSecondary,
                  ),
                  tooltip: combo.isAvailable ? 'Desactivar' : 'Activar',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditDialog({FoodCombo? combo}) {
    showDialog(
      context: context,
      builder: (context) => _FoodComboDialog(
        combo: combo,
        onSave: (savedCombo) {
          _saveFoodCombo(savedCombo, combo == null);
        },
      ),
    );
  }

  Future<void> _saveFoodCombo(FoodCombo combo, bool isNew) async {
    try {
      bool success;
      if (isNew) {
        success = await _foodComboService.createFoodCombo(combo);
      } else {
        success = await _foodComboService.updateFoodCombo(combo);
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isNew ? 'Combo creado exitosamente' : 'Combo actualizado exitosamente',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        _loadFoodCombos();
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

  void _showDeleteDialog(FoodCombo combo) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Eliminar Combo'),
        content: Text('¿Estás seguro de que deseas eliminar "${combo.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteFoodCombo(combo);
            },
            child: Text('Eliminar', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteFoodCombo(FoodCombo combo) async {
    try {
      final success = await _foodComboService.deleteFoodCombo(combo.id);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Combo eliminado exitosamente'),
            backgroundColor: AppColors.success,
          ),
        );
        _loadFoodCombos();
      } else {
        throw Exception('Error al eliminar el combo');
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

  Future<void> _toggleAvailability(FoodCombo combo) async {
    final updatedCombo = FoodCombo(
      id: combo.id,
      name: combo.name,
      description: combo.description,
      price: combo.price,
      items: combo.items,
      imageUrl: combo.imageUrl,
      category: combo.category,
      isAvailable: !combo.isAvailable,
    );

    await _saveFoodCombo(updatedCombo, false);
  }
}

// Dialog for Add/Edit Food Combo
class _FoodComboDialog extends StatefulWidget {
  final FoodCombo? combo;
  final Function(FoodCombo) onSave;

  const _FoodComboDialog({
    this.combo,
    required this.onSave,
  });

  @override
  State<_FoodComboDialog> createState() => _FoodComboDialogState();
}

class _FoodComboDialogState extends State<_FoodComboDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _categoryController = TextEditingController();
  final _itemsController = TextEditingController();
  bool _isAvailable = true;

  @override
  void initState() {
    super.initState();
    if (widget.combo != null) {
      _nameController.text = widget.combo!.name;
      _descriptionController.text = widget.combo!.description;
      _priceController.text = widget.combo!.price.toString();
      _imageUrlController.text = widget.combo!.imageUrl;
      _categoryController.text = widget.combo!.category;
      _itemsController.text = widget.combo!.items.join(', ');
      _isAvailable = widget.combo!.isAvailable;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
                widget.combo == null ? 'Agregar Combo' : 'Editar Combo',
                style: AppTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: AppSpacing.xl),
              
              Row(
                children: [
                  Expanded(
                    child: CinemaTextField(
                      controller: _nameController,
                      label: 'Nombre del combo *',
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
                    child: CinemaTextField(
                      controller: _categoryController,
                      label: 'Categoría',
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              CinemaTextField(
                controller: _descriptionController,
                label: 'Descripción *',
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'La descripción es requerida';
                  }
                  return null;
                },
              ),
              SizedBox(height: AppSpacing.md),

              Row(
                children: [
                  Expanded(
                    child: CinemaTextField(
                      controller: _priceController,
                      label: 'Precio *',
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El precio es requerido';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Ingresa un precio válido';
                        }
                        return null;
                      },
                    ),
                  ),
                  SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Row(
                      children: [
                        Switch(
                          value: _isAvailable,
                          onChanged: (value) {
                            setState(() {
                              _isAvailable = value;
                            });
                          },
                          activeColor: AppColors.primary,
                        ),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Disponible',
                          style: AppTypography.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: AppSpacing.md),

              CinemaTextField(
                controller: _itemsController,
                label: 'Items del combo (separados por comas)',
                maxLines: 2,
              ),
              SizedBox(height: AppSpacing.md),

              CinemaTextField(
                controller: _imageUrlController,
                label: 'URL de la imagen',
              ),
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
                    text: widget.combo == null ? 'Crear' : 'Guardar',
                    onPressed: _saveFoodCombo,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveFoodCombo() {
    if (_formKey.currentState!.validate()) {
      final items = _itemsController.text
          .split(',')
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty)
          .toList();

      final combo = FoodCombo(
        id: widget.combo?.id ?? '',
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        price: double.parse(_priceController.text),
        items: items,
        imageUrl: _imageUrlController.text.trim(),
        category: _categoryController.text.trim(),
        isAvailable: _isAvailable,
      );

      widget.onSave(combo);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _imageUrlController.dispose();
    _categoryController.dispose();
    _itemsController.dispose();
    super.dispose();
  }
}