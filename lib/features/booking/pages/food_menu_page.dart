import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/food_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../providers/booking_provider.dart';
import '../widgets/food_item_card.dart';
import 'checkout_summary_page.dart';

class FoodMenuPage extends ConsumerStatefulWidget {
  const FoodMenuPage({super.key});

  @override
  ConsumerState<FoodMenuPage> createState() => _FoodMenuPageState();
}

class _FoodMenuPageState extends ConsumerState<FoodMenuPage> {
  FoodCategory _selectedCategory = FoodCategory.combo;

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final filteredItems = mockFoodItems
        .where((item) => item.category == _selectedCategory)
        .toList();

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
            child: GridView.builder(
              padding: AppSpacing.pagePadding,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: AppSpacing.md,
                mainAxisSpacing: AppSpacing.md,
              ),
              itemCount: filteredItems.length,
              itemBuilder: (context, index) {
                return FoodItemCard(
                  foodItem: filteredItems[index],
                  quantity: ref
                      .read(bookingProvider.notifier)
                      .getFoodItemQuantity(filteredItems[index].id),
                  onAdd: () {
                    ref
                        .read(bookingProvider.notifier)
                        .addFoodItem(filteredItems[index]);
                  },
                  onRemove: () {
                    ref
                        .read(bookingProvider.notifier)
                        .removeFoodItem(filteredItems[index].id);
                  },
                );
              },
            ),
          ),

          // Bottom bar
          if (bookingState.hasSelection)
            _buildBottomBar(context, bookingState),
        ],
      ),
    );
  }

  Widget _buildBottomBar(BuildContext context, BookingState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
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
                      '\$${state.totalPrice.toStringAsFixed(2)}',
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

            // Skip button
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

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
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
                  color: AppColors.surfaceVariant,
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
                color: AppColors.surfaceVariant,
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
                    '\$${state.foodTotal.toStringAsFixed(2)}',
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
    return Container(
      margin: EdgeInsets.only(bottom: AppSpacing.md),
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
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
                  '\$${cartItem.foodItem.price.toStringAsFixed(2)}',
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
            '\$${cartItem.totalPrice.toStringAsFixed(2)}',
            style: AppTypography.titleMedium.copyWith(
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}
