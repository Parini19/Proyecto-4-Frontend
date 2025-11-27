import 'package:flutter/material.dart';
import '../../../core/models/food_item.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/currency_formatter.dart';

class FoodItemCard extends StatefulWidget {
  final FoodItem foodItem;
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const FoodItemCard({
    super.key,
    required this.foodItem,
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward().then((_) {
      _controller.reverse();
      if (widget.quantity == 0) {
        widget.onAdd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: widget.quantity == 0 ? _handleTap : null,
        child: Container(
          padding: EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            color: isDark
                ? AppColors.darkSurfaceElevated
                : AppColors.lightSurfaceElevated,
            borderRadius: AppSpacing.borderRadiusMD,
            boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
            border: widget.quantity > 0
                ? Border.all(
                    color: AppColors.primary.withOpacity(0.5),
                    width: 2,
                  )
                : null,
          ),
          child: Row(
            children: [
              // Image/Icon - Compact circular design
              Stack(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.primary.withOpacity(0.15),
                          AppColors.secondary.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: AppSpacing.borderRadiusMD,
                    ),
                    child: Icon(
                      _getCategoryIcon(widget.foodItem.category),
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  // Quantity badge
                  if (widget.quantity > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          boxShadow: AppColors.glowShadow,
                        ),
                        child: Text(
                          '${widget.quantity}',
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(width: AppSpacing.md),

              // Info section - Expanded to take available space
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name
                    Text(
                      widget.foodItem.name,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    // Description
                    Text(
                      widget.foodItem.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 6),
                    // Price
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColors.primary.withOpacity(0.15),
                            AppColors.secondary.withOpacity(0.1),
                          ],
                        ),
                        borderRadius: AppSpacing.borderRadiusSM,
                      ),
                      child: Text(
                        CurrencyFormatter.formatCRC(widget.foodItem.price),
                        style: AppTypography.labelMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(width: AppSpacing.sm),

              // Action buttons - Compact vertical layout
              if (widget.quantity == 0)
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: isDark ? AppColors.glowShadow : null,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.add),
                    color: Colors.white,
                    onPressed: widget.onAdd,
                    iconSize: 18,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  ),
                )
              else
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        boxShadow: isDark ? AppColors.glowShadow : null,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.add),
                        color: Colors.white,
                        onPressed: widget.onAdd,
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceVariant,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        icon: Icon(Icons.remove),
                        color: AppColors.primary,
                        onPressed: widget.onRemove,
                        iconSize: 16,
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(FoodCategory category) {
    switch (category) {
      case FoodCategory.combo:
        return Icons.restaurant_menu;
      case FoodCategory.popcorn:
        return Icons.movie;
      case FoodCategory.drink:
        return Icons.local_cafe;
      case FoodCategory.candy:
        return Icons.cake;
      case FoodCategory.snack:
        return Icons.fastfood;
    }
  }
}
