import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/food_item.dart';
import '../../../core/models/food_combo.dart';
import '../../../core/services/food_combo_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/utils/currency_formatter.dart';
import '../providers/booking_provider.dart';
import '../widgets/food_item_card.dart';
import 'checkout_summary_page.dart';

class FoodMenuPage extends ConsumerStatefulWidget {
  const FoodMenuPage({super.key});

  @override
  ConsumerState<FoodMenuPage> createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends ConsumerState<FoodMenuPage> {
  final FoodComboService _foodComboService = FoodComboService();
  FoodCategory _selectedCategory = FoodCategory.combo;
  List<FoodItem> _allFoodItems = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadFoodItems();
  }

  Future<void> _loadFoodItems() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Get food combos from backend
      final foodCombos = await _foodComboService.getAllFoodCombos();

      // Convert FoodCombos to FoodItems
      final allItems = foodCombos
          .map((combo) => combo.toFoodItem())
          .where((item) => item.category == _selectedCategory && item.isAvailable)
          .toList();

      setState(() {
        _allFoodItems = allItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Error cargando alimentos: $e';
        _isLoading = false;
        // Fallback to empty list
        _allFoodItems = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Menú de Alimentos'),
        actions: [
          // Cart icon with badge
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart_outlined),
                onPressed: () {
                  if (bookingState.hasFoodItems) {
                    _showCartSheet(context);
                  }
                },
              ),
              if (bookingState.foodItemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    child: Text(
                      '${bookingState.foodItemCount}',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Category tabs
          Container(
            height: 60,
            padding: EdgeInsets.symmetric(vertical: AppSpacing.sm),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: AppSpacing.horizontalMD,
              itemCount: FoodCategory.values.length,
              itemBuilder: (context, index) {
                final category = FoodCategory.values[index];
                final isSelected = _selectedCategory == category;

                return Padding(
                  padding: EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(category.displayName),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                      _loadFoodItems(); // Reload items when category changes
                    },
                    backgroundColor: AppColors.surfaceVariant,
                    selectedColor: AppColors.primary,
                    labelStyle: AppTypography.labelMedium.copyWith(
                      color:
                          isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: AppSpacing.borderRadiusRound,
                    ),
                  ),
                );
              },
            ),
          ),

          // Food items grid
          Expanded(
            child: _buildFoodItemsContent(),
          ),

          // Bottom bar - Show when there are food items OR when there's a movie selection
          if (bookingState.hasFoodItems || bookingState.hasSelection)
            _buildBottomBar(context, bookingState),
        ],
      ),
    );
  }

  Widget _buildFoodItemsContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
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
            const SizedBox(height: 16),
            Text(
              _error!,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFoodItems,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_allFoodItems.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.restaurant_menu,
              size: 64,
              color: AppColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay productos disponibles\nen esta categoría',
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Responsive grid layout
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate number of columns based on screen width
        int crossAxisCount;
        double childAspectRatio;

        if (constraints.maxWidth > 1200) {
          // Desktop large
          crossAxisCount = 3;
          childAspectRatio = 3.5;
        } else if (constraints.maxWidth > 900) {
          // Desktop small / Tablet landscape
          crossAxisCount = 2;
          childAspectRatio = 3.2;
        } else if (constraints.maxWidth > 600) {
          // Tablet portrait
          crossAxisCount = 2;
          childAspectRatio = 2.8;
        } else {
          // Mobile
          crossAxisCount = 1;
          childAspectRatio = 4.5;
        }

        return GridView.builder(
          padding: AppSpacing.pagePadding,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            childAspectRatio: childAspectRatio,
            crossAxisSpacing: AppSpacing.md,
            mainAxisSpacing: AppSpacing.md,
          ),
          itemCount: _allFoodItems.length,
          itemBuilder: (context, index) {
            final foodItem = _allFoodItems[index];
            return FoodItemCard(
              foodItem: foodItem,
              quantity: ref
                  .read(bookingProvider.notifier)
                  .getFoodItemQuantity(foodItem.id),
              onAdd: () {
                ref
                    .read(bookingProvider.notifier)
                    .addFoodItem(foodItem);
              },
              onRemove: () {
                ref
                    .read(bookingProvider.notifier)
                    .removeFoodItem(foodItem.id);
              },
            );
          },
        );
      },
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingState state) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: AppSpacing.pagePadding,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Summary
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    Text(
                      CurrencyFormatter.formatCRC(state.totalPrice),
                      style: AppTypography.headlineSmall.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (state.hasFoodItems)
                  TextButton.icon(
                    onPressed: () => _showCartSheet(context),
                    icon: const Icon(Icons.shopping_cart, size: 20),
                    label: Text('${state.foodItemCount} items'),
                  ),
              ],
            ),
            SizedBox(height: AppSpacing.md),

            // Continue button
            CinemaButton(
              text: 'Continuar al Pago',
              icon: Icons.payment,
              isFullWidth: true,
              size: ButtonSize.large,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CheckoutSummaryPage(),
                  ),
                );
              },
            ),

            // Skip button - Only show when there's a movie selection (not for food-only orders)
            if (state.hasSelection)
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CheckoutSummaryPage(),
                    ),
                  );
                },
                child: const Text('Omitir alimentos'),
              ),
          ],
        ),
      ),
    );
  }

  void _showCartSheet(BuildContext context) {
    final state = ref.read(bookingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLG),
            topRight: Radius.circular(AppSpacing.radiusLG),
          ),
        ),
        padding: AppSpacing.pagePadding,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                margin: EdgeInsets.only(bottom: AppSpacing.md),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                  borderRadius: AppSpacing.borderRadiusRound,
                ),
              ),
            ),

            // Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tu Pedido',
                  style: AppTypography.headlineSmall,
                ),
                TextButton(
                  onPressed: () {
                    ref.read(bookingProvider.notifier).clearFoodCart();
                    Navigator.pop(context);
                  },
                  child: const Text('Limpiar todo'),
                ),
              ],
            ),

            SizedBox(height: AppSpacing.md),

            // Cart items
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: state.foodCart.length,
                itemBuilder: (context, index) {
                  final cartItem = state.foodCart[index];
                  return _buildCartItem(cartItem);
                },
              ),
            ),

            SizedBox(height: AppSpacing.lg),

            // Total
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                borderRadius: AppSpacing.borderRadiusMD,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Subtotal Alimentos',
                    style: AppTypography.titleMedium,
                  ),
                  Text(
                    CurrencyFormatter.formatCRC(state.foodTotal),
                    style: AppTypography.titleLarge.copyWith(
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCartItem(CartItem cartItem) {
    return Builder(
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          margin: EdgeInsets.only(bottom: AppSpacing.md),
          padding: AppSpacing.paddingMD,
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
            borderRadius: AppSpacing.borderRadiusMD,
          ),
      child: Row(
        children: [
          // Item info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cartItem.foodItem.name,
                  style: AppTypography.titleSmall,
                ),
                Text(
                  CurrencyFormatter.formatCRC(cartItem.foodItem.price),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Quantity controls
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: () {
                  ref
                      .read(bookingProvider.notifier)
                      .removeFoodItem(cartItem.foodItem.id);
                },
                color: AppColors.primary,
              ),
              Text(
                '${cartItem.quantity}',
                style: AppTypography.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  ref
                      .read(bookingProvider.notifier)
                      .addFoodItem(cartItem.foodItem);
                },
                color: AppColors.primary,
              ),
            ],
          ),

          // Item total
          Text(
            CurrencyFormatter.formatCRC(cartItem.totalPrice),
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
        );
      },
    );
  }
}
