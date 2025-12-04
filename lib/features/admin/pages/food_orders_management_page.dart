import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../../../core/widgets/searchable_dropdown.dart';
import '../../../core/models/food_order.dart';
import '../../../core/models/food_combo.dart';
import '../../../core/services/food_order_service.dart';
import '../../../core/services/food_combo_service.dart';
import '../../../core/services/user_service.dart';
import '../../../core/entities/user.dart';
import '../../../core/utils/currency_formatter.dart';


class FoodOrdersManagementPage extends StatefulWidget {
  const FoodOrdersManagementPage({super.key});

  @override
  State<FoodOrdersManagementPage> createState() => _FoodOrdersManagementPageState();
}

class _FoodOrdersManagementPageState extends State<FoodOrdersManagementPage> {
  List<FoodOrder> _orders = [];
  List<FoodOrder> _filteredOrders = [];
  List<User> _users = [];
  List<FoodCombo> _foodCombos = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String? _error;
  final FoodOrderService _foodOrderService = FoodOrderService();
  final FoodComboService _foodComboService = FoodComboService();
  final UserService _userService = UserService();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadFoodOrders(),
      _loadUsers(),
      _loadFoodCombos(),
    ]);
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

  Future<void> _loadUsers() async {
    try {
      final users = await _userService.getAllUsers();
      setState(() {
        _users = users;
      });
    } catch (e) {
      // If users fail to load, we just continue without them
      // This prevents the food orders page from breaking
      print('Warning: Failed to load users: $e');
    }
  }

  Future<void> _loadFoodCombos() async {
    try {
      final combos = await _foodComboService.getAllFoodCombos();
      setState(() {
        _foodCombos = combos.where((combo) => combo.isAvailable).toList();
      });
    } catch (e) {
      // If food combos fail to load, we just continue without them
      print('Warning: Failed to load food combos: $e');
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
    // Optimistic update - immediately update the UI
    final orderIndex = _orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final updatedOrder = _orders[orderIndex].copyWith(
        status: newStatus,
        updatedAt: DateTime.now(),
      );
      
      setState(() {
        _orders[orderIndex] = updatedOrder;
        _filterOrders(); // Update filtered list
      });
    }

    try {
      final success = await _foodOrderService.updateOrderStatus(orderId, newStatus);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Estado actualizado correctamente'),
            backgroundColor: AppColors.success,
          ),
        );
        // No need to reload - already updated optimistically
      } else {
        // Revert the optimistic update on failure
        await _loadFoodOrders();
        _showErrorSnackBar('Error al actualizar el estado');
      }
    } catch (e) {
      // Revert the optimistic update on error
      await _loadFoodOrders();
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingXL,
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
          // Title and Add Button
          if (isMobile)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_long,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Órdenes de Comida',
                        style: AppTypography.titleLarge.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.sm),
                SizedBox(
                  width: double.infinity,
                  child: CinemaButton(
                    text: 'Nueva Orden',
                    onPressed: () => _showAddEditOrderDialog(),
                    icon: Icons.add,
                    size: ButtonSize.small,
                  ),
                ),
              ],
            )
          else
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
          SizedBox(height: isMobile ? AppSpacing.sm : AppSpacing.xl),

          // Search Bar
          CinemaTextField(
            label: 'Buscar órdenes...',
            prefixIcon: Icons.search,
            onChanged: _onSearchChanged,
          ),
          SizedBox(height: isMobile ? AppSpacing.sm : AppSpacing.md),

          // Stats Cards
          if (_orders.isNotEmpty) _buildStatsRow(),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    final totalOrders = _orders.length;
    final pendingOrders = _orders.where((o) => o.status == FoodOrder.statusPending).length;
    final readyOrders = _orders.where((o) => o.status == FoodOrder.statusReady).length;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            isMobile ? 'Total' : 'Total',
            '$totalOrders',
            Icons.receipt_long,
            AppColors.primary,
          ),
        ),
        SizedBox(width: isMobile ? AppSpacing.xs : AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            isMobile ? 'Pend.' : 'Pendientes',
            '$pendingOrders',
            Icons.pending,
            const Color(0xFFF59E0B),
          ),
        ),
        SizedBox(width: isMobile ? AppSpacing.xs : AppSpacing.md),
        Expanded(
          child: _buildStatCard(
            isMobile ? 'Listos' : 'Listos',
            '$readyOrders',
            Icons.check_circle,
            AppColors.success,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      padding: isMobile ? AppSpacing.paddingSM : AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(isMobile ? 8 : 12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: isMobile ? 14 : 20),
              SizedBox(width: isMobile ? 4 : AppSpacing.xs),
              Flexible(
                child: Text(
                  title,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: isMobile ? 10 : null,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: isMobile ? 2 : AppSpacing.xs),
          Text(
            value,
            style: (isMobile ? AppTypography.titleLarge : AppTypography.headlineMedium).copyWith(
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
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    if (isMobile) {
      // Mobile: Card layout
      return ListView.builder(
        padding: AppSpacing.paddingSM,
        itemCount: _filteredOrders.length,
        itemBuilder: (context, index) {
          return _buildOrderCard(context, _filteredOrders[index]);
        },
      );
    }

    // Desktop: Table layout
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
                Expanded(flex: 2, child: _buildHeaderCell('Fecha ordenado')),
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

  Widget _buildOrderCard(BuildContext context, FoodOrder order) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with order ID and status
          Padding(
            padding: AppSpacing.paddingSM,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Order ID and items count
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '#${order.id.length > 8 ? order.id.substring(0, 8) : order.id}',
                        style: AppTypography.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        '${order.foodComboIds.length} items',
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                // Status badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: FoodOrder.getStatusColor(order.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: FoodOrder.getStatusColor(order.status).withOpacity(0.3),
                    ),
                  ),
                  child: Text(
                    order.statusDisplayName,
                    style: AppTypography.bodySmall.copyWith(
                      color: FoodOrder.getStatusColor(order.status),
                      fontWeight: FontWeight.w600,
                      fontSize: 10,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1),
          // Order details
          Padding(
            padding: AppSpacing.paddingSM,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User ID
                Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 14,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                    SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        order.userId.length > 20 ? '${order.userId.substring(0, 20)}...' : order.userId,
                        style: AppTypography.bodySmall.copyWith(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppSpacing.xs),
                // Date
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 14,
                      color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      order.createdAt != null
                          ? '${order.createdAt!.day}/${order.createdAt!.month}/${order.createdAt!.year}'
                          : 'N/A',
                      style: AppTypography.bodySmall.copyWith(
                        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Divider(height: 1),
          // Price and actions
          Padding(
            padding: AppSpacing.paddingSM,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  CurrencyFormatter.formatCRC(order.totalPrice),
                  style: AppTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.success,
                  ),
                ),
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, size: 20),
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: FoodOrder.statusPending,
                      child: Row(
                        children: [
                          Icon(Icons.pending, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusPending)),
                          SizedBox(width: 8),
                          Text('Pendiente', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: FoodOrder.statusPreparing,
                      child: Row(
                        children: [
                          Icon(Icons.kitchen, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusPreparing)),
                          SizedBox(width: 8),
                          Text('Preparando', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: FoodOrder.statusReady,
                      child: Row(
                        children: [
                          Icon(Icons.check_circle, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusReady)),
                          SizedBox(width: 8),
                          Text('Listo', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: FoodOrder.statusDelivered,
                      child: Row(
                        children: [
                          Icon(Icons.local_shipping, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusDelivered)),
                          SizedBox(width: 8),
                          Text('Entregado', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: FoodOrder.statusDone,
                      child: Row(
                        children: [
                          Icon(Icons.done_all, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusDone)),
                          SizedBox(width: 8),
                          Text('Completado', style: TextStyle(fontSize: 12)),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: FoodOrder.statusCancelled,
                      child: Row(
                        children: [
                          Icon(Icons.cancel, size: 16, color: FoodOrder.getStatusColor(FoodOrder.statusCancelled)),
                          SizedBox(width: 8),
                          Text('Cancelado', style: TextStyle(fontSize: 12)),
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
                          Text('Eliminar', style: TextStyle(color: AppColors.error, fontSize: 12)),
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddEditOrderDialog({FoodOrder? order}) {
    String? selectedUserId = order?.userId;
    final totalPriceController = TextEditingController(
      text: order?.totalPrice.toString() ?? '',
    );
    
    // Initialize selected combos with quantities
    Map<String, int> selectedCombos = {};
    if (order != null && order.foodComboIds.isNotEmpty) {
      for (String comboId in order.foodComboIds) {
        selectedCombos[comboId] = (selectedCombos[comboId] ?? 0) + 1;
      }
    }
    
    String selectedStatus = order?.status ?? FoodOrder.statusPending;
    
    // Function to calculate total price
    void calculateTotalPrice() {
      double total = 0.0;
      selectedCombos.forEach((comboId, quantity) {
        final combo = _foodCombos.firstWhere((c) => c.id == comboId, orElse: () => FoodCombo(id: '', name: '', description: '', price: 0, items: [], imageUrl: '', category: ''));
        total += combo.price * quantity;
      });
      totalPriceController.text = total.toStringAsFixed(2);
    }

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
                  // User Selection
                  SearchableDropdown<User>(
                    label: 'Usuario *',
                    hint: 'Selecciona un usuario',
                    prefixIcon: Icons.person,
                    value: _users.where((u) => u.uid == selectedUserId).firstOrNull,
                    items: _users,
                    itemLabel: (user) => '${user.displayName} (${user.email})',
                    onChanged: (user) {
                      setState(() {
                        selectedUserId = user?.uid;
                      });
                    },
                  ),
                  
                  // Warning message if no users available
                  if (_users.isEmpty)
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
                              'No hay usuarios disponibles. Asegúrate de que existan usuarios registrados en el sistema.',
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
                  
                  // Food Combos Multi-Select Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header
                        Padding(
                          padding: EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            children: [
                              Icon(Icons.fastfood, color: AppColors.primary, size: 20),
                              SizedBox(width: AppSpacing.xs),
                              Text(
                                'Combos de Comida *',
                                style: AppTypography.labelLarge.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Available Combos List
                        if (_foodCombos.isEmpty)
                          Container(
                            padding: EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                Icon(Icons.warning, color: Colors.orange, size: 16),
                                SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    'No hay combos de comida disponibles. Crea combos primero.',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.orange[800],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Container(
                            constraints: BoxConstraints(maxHeight: 300),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _foodCombos.length,
                              itemBuilder: (context, index) {
                                final combo = _foodCombos[index];
                                final quantity = selectedCombos[combo.id] ?? 0;
                                final isSelected = quantity > 0;
                                
                                return Container(
                                  margin: EdgeInsets.symmetric(
                                    horizontal: AppSpacing.sm,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected 
                                        ? AppColors.primary.withOpacity(0.1)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: isSelected
                                        ? Border.all(color: AppColors.primary.withOpacity(0.3))
                                        : null,
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    leading: Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: AppColors.primary.withOpacity(0.1),
                                      ),
                                      child: combo.imageUrl.isNotEmpty
                                          ? ClipRRect(
                                              borderRadius: BorderRadius.circular(8),
                                              child: Image.network(
                                                combo.imageUrl,
                                                fit: BoxFit.cover,
                                                errorBuilder: (_, __, ___) => Icon(
                                                  Icons.fastfood,
                                                  color: AppColors.primary,
                                                  size: 20,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.fastfood,
                                              color: AppColors.primary,
                                              size: 20,
                                            ),
                                    ),
                                    title: Text(
                                      combo.name,
                                      style: AppTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    subtitle: Text(
                                      '${CurrencyFormatter.formatCRC(combo.price)} - ${combo.description}',
                                      style: AppTypography.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    trailing: isSelected
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.remove_circle, color: AppColors.error),
                                                iconSize: 20,
                                                onPressed: () {
                                                  setState(() {
                                                    if (quantity > 1) {
                                                      selectedCombos[combo.id] = quantity - 1;
                                                    } else {
                                                      selectedCombos.remove(combo.id);
                                                    }
                                                    calculateTotalPrice();
                                                  });
                                                },
                                              ),
                                              Container(
                                                padding: EdgeInsets.symmetric(
                                                  horizontal: AppSpacing.xs,
                                                  vertical: 4,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: AppColors.primary,
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Text(
                                                  quantity.toString(),
                                                  style: AppTypography.bodySmall.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(Icons.add_circle, color: AppColors.success),
                                                iconSize: 20,
                                                onPressed: () {
                                                  setState(() {
                                                    selectedCombos[combo.id] = quantity + 1;
                                                    calculateTotalPrice();
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        : IconButton(
                                            icon: Icon(Icons.add_circle_outline, color: AppColors.primary),
                                            onPressed: () {
                                              setState(() {
                                                selectedCombos[combo.id] = 1;
                                                calculateTotalPrice();
                                              });
                                            },
                                          ),
                                  ),
                                );
                              },
                            ),
                          ),
                        
                        // Selected Combos Summary
                        if (selectedCombos.isNotEmpty)
                          Container(
                            margin: EdgeInsets.all(AppSpacing.sm),
                            padding: EdgeInsets.all(AppSpacing.sm),
                            decoration: BoxDecoration(
                              color: AppColors.success.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.success.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Combos Seleccionados:',
                                  style: AppTypography.labelMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.success,
                                  ),
                                ),
                                SizedBox(height: AppSpacing.xs),
                                ...selectedCombos.entries.map((entry) {
                                  final combo = _foodCombos.firstWhere(
                                    (c) => c.id == entry.key,
                                    orElse: () => FoodCombo(
                                      id: entry.key,
                                      name: 'Combo no encontrado',
                                      description: '',
                                      price: 0,
                                      items: [],
                                      imageUrl: '',
                                      category: '',
                                    ),
                                  );
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 4),
                                    child: Text(
                                      '• ${combo.name} x${entry.value} = ${CurrencyFormatter.formatCRC(combo.price * entry.value)}',
                                      style: AppTypography.bodySmall.copyWith(
                                        color: AppColors.success,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        
                        SizedBox(height: AppSpacing.sm),
                      ],
                    ),
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
                if (selectedUserId == null || selectedUserId!.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selecciona un usuario'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }

                if (selectedCombos.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Selecciona al menos un combo de comida'),
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
                  // Create food combo IDs list based on selected combos with quantities
                  final List<String> foodComboIds = [];
                  selectedCombos.forEach((comboId, quantity) {
                    for (int i = 0; i < quantity; i++) {
                      foodComboIds.add(comboId);
                    }
                  });

                  // Parse total price
                  final totalPrice = double.tryParse(totalPriceController.text.trim()) ?? 0.0;

                  // Create FoodOrder from form data
                  final newOrder = FoodOrder(
                    id: order?.id ?? '', // Empty for new orders, backend will generate
                    userId: selectedUserId!,
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

                    if (order == null) {
                      // For new orders: Add optimistically to the list
                      setState(() {
                        _orders.insert(0, newOrder); // Add at the beginning (newest first)
                        _filterOrders(); // Update filtered list
                      });
                    } else {
                      // For updates: Find and replace the order
                      final orderIndex = _orders.indexWhere((o) => o.id == order.id);
                      if (orderIndex != -1) {
                        setState(() {
                          _orders[orderIndex] = newOrder;
                          _filterOrders(); // Update filtered list
                        });
                      }
                    }
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