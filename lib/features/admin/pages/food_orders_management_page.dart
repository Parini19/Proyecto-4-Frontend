import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../../../core/models/food_order.dart';
import '../../../core/services/food_order_service.dart';
import '../../../core/utils/currency_formatter.dart';


class FoodOrdersManagementPage extends StatefulWidget {
  const FoodOrdersManagementPage({super.key});

  @override
  State<FoodOrdersManagementPage> createState() => _FoodOrdersManagementPageState();
}

class _FoodOrdersManagementPageState extends State<FoodOrdersManagementPage> {
  List<FoodOrder> _orders = [];
  List<FoodOrder> _filteredOrders = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  final FoodOrderService _foodOrderService = FoodOrderService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadFoodOrders();
  }

  Future<void> _loadFoodOrders() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final orders = await _foodOrderService.getAllFoodOrders();
      setState(() {
        _orders = orders;
        _filterOrders();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando órdenes: $e';
        _isLoading = false;
      });
    }
  }



  void _filterOrders() {
    if (_searchQuery.isEmpty) {
      _filteredOrders = List.from(_orders);
    } else {
      _filteredOrders = _orders.where((order) {
        return order.userId.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.status.toLowerCase().contains(_searchQuery.toLowerCase()) ||
               order.id.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    // Sort by creation date (newest first)
    _filteredOrders.sort((a, b) {
      final aDate = a.createdAt ?? DateTime.now();
      final bDate = b.createdAt ?? DateTime.now();
      return bDate.compareTo(aDate);
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _filterOrders();
    });
  }

  Future<void> _updateOrderStatus(String orderId, String newStatus) async {
    try {
      final success = await _foodOrderService.updateOrderStatus(orderId, newStatus);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        await _loadFoodOrders();
      } else {
        _showErrorSnackBar('Error al actualizar el estado');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    }
  }

  Future<void> _deleteOrder(String orderId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirmar eliminación'),
        content: Text('¿Estás seguro de que deseas eliminar esta orden?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        final success = await _foodOrderService.deleteFoodOrder(orderId);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Orden eliminada correctamente'),
              backgroundColor: AppColors.success,
            ),
          );
          await _loadFoodOrders();
        } else {
          _showErrorSnackBar('Error al eliminar la orden');
        }
      } catch (e) {
        _showErrorSnackBar('Error: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
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
                  Icons.receipt_long,
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
                      'Gestión de Órdenes de Comida',
                      style: AppTypography.displaySmall.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Administra las órdenes de comida del cinema',
                      style: AppTypography.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              CinemaButton(
                text: 'Nueva Orden',
                onPressed: () => _showAddEditOrderDialog(),
                icon: Icons.add,
              ),
            ],
          ),
          
          SizedBox(height: AppSpacing.lg),
          
          // Search and Stats
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'Buscar órdenes...',
                    prefixIcon: Icon(Icons.search),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.darkSurfaceVariant
                        : AppColors.lightSurfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md,
                    ),
                  ),
                  onChanged: _onSearchChanged,
                ),
              ),
              SizedBox(width: AppSpacing.md),
              _buildRefreshButton(),
            ],
          ),

          SizedBox(height: AppSpacing.lg),

          // Stats Row
          if (_orders.isNotEmpty) _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildRefreshButton() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        onPressed: _loadData,
        icon: Icon(Icons.refresh, color: Colors.white),
        tooltip: 'Actualizar',
      ),
    );
  }

  Widget _buildStatsRow() {
    final totalOrders = _orders.length;
    final pendingOrders = _orders.where((o) => o.status == FoodOrder.statusPending).length;
    final preparingOrders = _orders.where((o) => o.status == FoodOrder.statusPreparing).length;
    final readyOrders = _orders.where((o) => o.status == FoodOrder.statusReady).length;
    final doneOrders = _orders.where((o) => o.status == FoodOrder.statusDone).length;

    return Row(
      children: [
        Expanded(child: _buildStatCard('Total', '$totalOrders', Icons.receipt_long, AppColors.primary)),
        SizedBox(width: AppSpacing.md),
        Expanded(child: _buildStatCard('Pendientes', '$pendingOrders', Icons.pending, const Color(0xFFF59E0B))),
        SizedBox(width: AppSpacing.md),
        Expanded(child: _buildStatCard('Preparando', '$preparingOrders', Icons.kitchen, const Color(0xFF3B82F6))),
        SizedBox(width: AppSpacing.md),
        Expanded(child: _buildStatCard('Listos', '$readyOrders', Icons.check_circle, AppColors.success)),
        SizedBox(width: AppSpacing.md),
        Expanded(child: _buildStatCard('Completados', '$doneOrders', Icons.done_all, const Color(0xFF059669))),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                title,
                style: AppTypography.bodySmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              );
            }
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
            'Cargando órdenes...',
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
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          SizedBox(height: AppSpacing.md),
          Text(
            _error ?? 'Error desconocido',
            style: AppTypography.bodyLarge.copyWith(color: AppColors.error),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: AppSpacing.lg),
          CinemaButton(
            text: 'Reintentar',
            onPressed: _loadData,
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildContentBody(BuildContext context) {
    if (_filteredOrders.isEmpty) {
      return _buildEmptyState();
    }

    return _buildOrdersList();
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
                Icons.receipt_long_outlined,
                size: 80,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
              );
            }
          ),
          SizedBox(height: AppSpacing.md),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                'No hay órdenes registradas',
                style: AppTypography.headlineSmall.copyWith(
                  color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                ),
              );
            }
          ),
          SizedBox(height: AppSpacing.sm),
          Builder(
            builder: (context) {
              final isDark = Theme.of(context).brightness == Brightness.dark;
              return Text(
                _searchQuery.isNotEmpty
                    ? 'No se encontraron órdenes con los criterios de búsqueda'
                    : 'Las órdenes de comida aparecerán aquí cuando los usuarios las realicen',
                style: AppTypography.bodyMedium.copyWith(
                  color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                ),
                textAlign: TextAlign.center,
              );
            }
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList() {
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
                Expanded(flex: 2, child: _buildHeaderCell('Orden')),
                Expanded(flex: 2, child: _buildHeaderCell('Usuario')),
                Expanded(flex: 2, child: _buildHeaderCell('Total')),
                Expanded(flex: 2, child: _buildHeaderCell('Estado')),
                Expanded(flex: 2, child: _buildHeaderCell('Fecha')),
                Expanded(flex: 2, child: _buildHeaderCell('Acciones')),
              ],
            ),
          ),

          // Table Body
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: _filteredOrders.length,
              itemBuilder: (context, index) {
                return _buildOrderRow(context, _filteredOrders[index], index);
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
          style: AppTypography.labelMedium.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          ),
        );
      }
    );
  }

  Widget _buildOrderRow(BuildContext context, FoodOrder order, int index) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isEven = index % 2 == 0;

    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: isEven
            ? (isDark ? AppColors.darkSurfaceVariant.withOpacity(0.3) : AppColors.lightSurfaceVariant.withOpacity(0.5))
            : Colors.transparent,
      ),
      child: Row(
        children: [
          // Order ID
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${order.foodComboIds.length} items',
                  style: AppTypography.bodySmall.copyWith(
                    color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                  ),
                ),
              ],
            ),
          ),

          // User ID
          Expanded(
            flex: 2,
            child: Text(
              order.userId.length > 15 ? '${order.userId.substring(0, 15)}...' : order.userId,
              style: AppTypography.bodyMedium,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Total Price
          Expanded(
            flex: 2,
            child: Text(
              CurrencyFormatter.formatCRC(order.totalPrice),
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
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
                color: FoodOrder.getStatusColor(order.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: FoodOrder.getStatusColor(order.status).withOpacity(0.3),
                ),
              ),
              child: Text(
                order.statusDisplayName,
                style: AppTypography.labelSmall.copyWith(
                  color: FoodOrder.getStatusColor(order.status),
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // Date
          Expanded(
            flex: 2,
            child: Text(
              order.createdAt != null
                  ? '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'
                  : 'N/A',
              style: AppTypography.bodySmall.copyWith(
                color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
              ),
            ),
          ),

          // Actions
          Expanded(
            flex: 2,
            child: Row(
              children: [
                // Status update dropdown
                Expanded(
                  child: PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 20),
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: FoodOrder.statusPending,
                        child: Row(
                          children: [
                            Icon(Icons.pending, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusPending)),
                            SizedBox(width: 8),
                            Text('Pendiente'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: FoodOrder.statusPreparing,
                        child: Row(
                          children: [
                            Icon(Icons.kitchen, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusPreparing)),
                            SizedBox(width: 8),
                            Text('Preparando'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: FoodOrder.statusReady,
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusReady)),
                            SizedBox(width: 8),
                            Text('Listo'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: FoodOrder.statusDelivered,
                        child: Row(
                          children: [
                            Icon(Icons.local_shipping, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusDelivered)),
                            SizedBox(width: 8),
                            Text('Entregado'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: FoodOrder.statusDone,
                        child: Row(
                          children: [
                            Icon(Icons.done_all, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusDone)),
                            SizedBox(width: 8),
                            Text('Completado'),
                          ],
                        ),
                      ),
                      PopupMenuItem(
                        value: FoodOrder.statusCancelled,
                        child: Row(
                          children: [
                            Icon(Icons.cancel, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusCancelled)),
                            SizedBox(width: 8),
                            Text('Cancelado'),
                          ],
                        ),
                      ),
                      PopupMenuDivider(),
                      PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: AppColors.error),
                            SizedBox(width: 8),
                            Text('Eliminar', style: TextStyle(color: AppColors.error)),
                          ],
                        ),
                      ),
                    ],
                    onSelected: (value) {
                      if (value == 'delete') {
                        _deleteOrder(order.id);
                      } else {
                        _updateOrderStatus(order.id, value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditOrderDialog({FoodOrder? order}) {
    final userIdController = TextEditingController(text: order?.userId ?? '');
    final totalPriceController = TextEditingController(
      text: order?.totalPrice.toString() ?? '',
    );
    final foodComboIdsController = TextEditingController(
      text: order?.foodComboIds.join(', ') ?? '',
    );
    String selectedStatus = order?.status ?? FoodOrder.statusPending;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            order == null ? 'Nueva Orden' : 'Editar Orden',
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
                  CinemaTextField(
                    label: 'ID de Usuario *',
                    controller: userIdController,
                    hint: 'ID del usuario que realizó la orden',
                    prefixIcon: Icons.person,
                  ),
                  SizedBox(height: AppSpacing.md),
                  CinemaTextField(
                    label: 'IDs de Combos de Comida *',
                    controller: foodComboIdsController,
                    hint: 'Separados por comas (ej: 1, 2, 3)',
                    prefixIcon: Icons.fastfood,
                    maxLines: 2,
                  ),
                  SizedBox(height: AppSpacing.md),
                  CinemaTextField(
                    label: 'Precio Total *',
                    controller: totalPriceController,
                    hint: '0.00',
                    prefixIcon: Icons.account_balance_wallet,
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                  ),
                  SizedBox(height: AppSpacing.md),
                  
                  // Status Dropdown
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedStatus,
                      decoration: InputDecoration(
                        labelText: 'Estado',
                        prefixIcon: Icon(Icons.flag, color: AppColors.primary),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: AppSpacing.lg,
                          vertical: AppSpacing.md,
                        ),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: FoodOrder.statusPending,
                          child: Row(
                            children: [
                              Icon(Icons.pending, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusPending)),
                              SizedBox(width: 8),
                              Text('Pendiente'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: FoodOrder.statusPreparing,
                          child: Row(
                            children: [
                              Icon(Icons.kitchen, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusPreparing)),
                              SizedBox(width: 8),
                              Text('Preparando'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: FoodOrder.statusReady,
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusReady)),
                              SizedBox(width: 8),
                              Text('Listo'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: FoodOrder.statusDelivered,
                          child: Row(
                            children: [
                              Icon(Icons.local_shipping, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusDelivered)),
                              SizedBox(width: 8),
                              Text('Entregado'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: FoodOrder.statusDone,
                          child: Row(
                            children: [
                              Icon(Icons.done_all, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusDone)),
                              SizedBox(width: 8),
                              Text('Completado'),
                            ],
                          ),
                        ),
                        DropdownMenuItem(
                          value: FoodOrder.statusCancelled,
                          child: Row(
                            children: [
                              Icon(Icons.cancel, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusCancelled)),
                              SizedBox(width: 8),
                              Text('Cancelado'),
                            ],
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedStatus = value;
                          });
                        }
                      },
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
              text: order == null ? 'Crear' : 'Guardar',
              onPressed: () async {
                // Validate required fields
                if (userIdController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('El ID de usuario es requerido'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (foodComboIdsController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Los IDs de combos son requeridos'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (totalPriceController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('El precio total es requerido'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

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
                        Text(order == null ? 'Creando orden...' : 'Actualizando orden...'),
                      ],
                    ),
                    duration: Duration(seconds: 30),
                  ),
                );

                try {
                  // Parse food combo IDs
                  final foodComboIds = foodComboIdsController.text
                      .split(',')
                      .map((id) => id.trim())
                      .where((id) => id.isNotEmpty)
                      .toList();

                  // Parse total price
                  final totalPrice = double.tryParse(totalPriceController.text.trim()) ?? 0.0;

                  // Create FoodOrder from form data
                  final newOrder = FoodOrder(
                    id: order?.id ?? '', // Empty for new orders, backend will generate
                    userId: userIdController.text.trim(),
                    foodComboIds: foodComboIds,
                    totalPrice: totalPrice,
                    status: selectedStatus,
                    createdAt: order?.createdAt ?? DateTime.now(),
                    updatedAt: DateTime.now(),
                  );

                  bool success;
                  if (order == null) {
                    // Create new order
                    success = await _foodOrderService.createFoodOrder(newOrder);
                  } else {
                    // Update existing order
                    success = await _foodOrderService.updateFoodOrder(newOrder);
                  }

                  // Clear loading snackbar
                  ScaffoldMessenger.of(context).clearSnackBars();

                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          order == null
                              ? 'Orden creada exitosamente'
                              : 'Orden actualizada exitosamente',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );

                    // Reload orders
                    await _loadData();
                  } else {
                    _showErrorSnackBar(
                      order == null
                          ? 'Error al crear la orden'
                          : 'Error al actualizar la orden',
                    );
                  }
                } catch (e) {
                  // Clear loading snackbar
                  ScaffoldMessenger.of(context).clearSnackBars();
                  _showErrorSnackBar('Error: $e');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}