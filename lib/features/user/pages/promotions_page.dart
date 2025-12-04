import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';

class Promotion {
  final String id;
  final String title;
  final String description;
  final String discount;
  final String code;
  final DateTime validUntil;
  final IconData icon;
  final Color color;

  Promotion({
    required this.id,
    required this.title,
    required this.description,
    required this.discount,
    required this.code,
    required this.validUntil,
    required this.icon,
    required this.color,
  });
}

class PromotionsPage extends StatelessWidget {
  const PromotionsPage({super.key});

  // Mock promotions
  List<Promotion> get _promotions => [
        Promotion(
          id: 'PROMO1',
          title: '2x1 en Boletos',
          description: '¡Compra un boleto y lleva otro gratis! Válido de lunes a jueves.',
          discount: '50% OFF',
          code: '2X1CINE',
          validUntil: DateTime.now().add(Duration(days: 15)),
          icon: Icons.local_activity,
          color: AppColors.primary,
        ),
        Promotion(
          id: 'PROMO2',
          title: 'Combo Familiar',
          description: '4 boletos + 2 combos grandes de palomitas y bebidas',
          discount: '₡5,000 OFF',
          code: 'FAMILIA',
          validUntil: DateTime.now().add(Duration(days: 30)),
          icon: Icons.family_restroom,
          color: AppColors.success,
        ),
        Promotion(
          id: 'PROMO3',
          title: 'Happy Hour',
          description: 'Funciones antes de las 5:00 PM con descuento especial',
          discount: '30% OFF',
          code: 'HAPPYHOUR',
          validUntil: DateTime.now().add(Duration(days: 60)),
          icon: Icons.access_time,
          color: AppColors.warning,
        ),
        Promotion(
          id: 'PROMO4',
          title: 'Estudiantes',
          description: 'Descuento para estudiantes presentando carné vigente',
          discount: '25% OFF',
          code: 'ESTUDIANTE',
          validUntil: DateTime.now().add(Duration(days: 90)),
          icon: Icons.school,
          color: AppColors.info,
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Promociones'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: AppSpacing.pagePadding,
        children: [
          // Header
          Text(
            '¡Aprovecha nuestras ofertas!',
            style: AppTypography.headlineMedium,
          ),
          SizedBox(height: 8),
          Text(
            'Descuentos y promociones especiales para ti',
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 24),

          // Promotions Grid
          ..._promotions.map((promo) => _buildPromotionCard(promo, isDark, context)),
        ],
      ),
    );
  }

  Widget _buildPromotionCard(Promotion promo, bool isDark, BuildContext context) {
    final daysLeft = promo.validUntil.difference(DateTime.now()).inDays;

    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showPromotionDetails(context, promo, isDark),
          borderRadius: AppSpacing.borderRadiusLG,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : AppColors.lightSurfaceElevated,
              borderRadius: AppSpacing.borderRadiusLG,
              boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
            ),
            child: Row(
              children: [
                // Color accent bar
                Container(
                  width: 6,
                  height: 140,
                  decoration: BoxDecoration(
                    color: promo.color,
                    borderRadius: BorderRadius.only(
                      topLeft: AppSpacing.borderRadiusLG.topLeft,
                      bottomLeft: AppSpacing.borderRadiusLG.bottomLeft,
                    ),
                  ),
                ),

                // Icon section
                Container(
                  width: 100,
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: promo.color.withOpacity(0.2),
                          borderRadius: AppSpacing.borderRadiusMD,
                        ),
                        child: Icon(
                          promo.icon,
                          size: 32,
                          color: promo.color,
                        ),
                      ),
                      SizedBox(height: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: promo.color,
                          borderRadius: AppSpacing.borderRadiusSM,
                        ),
                        child: Text(
                          promo.discount,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          promo.title,
                          style: AppTypography.titleLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          promo.description,
                          style: AppTypography.bodyMedium.copyWith(
                            color: isDark ? Colors.white70 : Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Icon(Icons.calendar_today, size: 14, color: isDark ? Colors.white60 : Colors.black54),
                            SizedBox(width: 4),
                            Text(
                              'Válido por $daysLeft ${daysLeft == 1 ? "día" : "días"}',
                              style: AppTypography.bodySmall.copyWith(
                                color: isDark ? Colors.white60 : Colors.black54,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Arrow
                Padding(
                  padding: EdgeInsets.only(right: 16),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showPromotionDetails(BuildContext context, Promotion promo, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppSpacing.radiusLG),
            topRight: Radius.circular(AppSpacing.radiusLG),
          ),
        ),
        padding: AppSpacing.pagePadding,
        child: Column(
          children: [
            // Handle
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

            // Icon
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [promo.color, promo.color.withOpacity(0.7)],
                ),
                borderRadius: AppSpacing.borderRadiusLG,
              ),
              child: Icon(
                promo.icon,
                size: 64,
                color: Colors.white,
              ),
            ),

            SizedBox(height: 24),

            Text(
              promo.title,
              style: AppTypography.headlineMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: promo.color.withOpacity(0.2),
                borderRadius: AppSpacing.borderRadiusLG,
                border: Border.all(
                  color: promo.color.withOpacity(0.5),
                  width: 2,
                ),
              ),
              child: Text(
                promo.discount,
                style: AppTypography.headlineLarge.copyWith(
                  fontWeight: FontWeight.bold,
                  color: promo.color,
                ),
              ),
            ),

            SizedBox(height: 24),

            Text(
              promo.description,
              style: AppTypography.bodyLarge.copyWith(
                color: isDark ? Colors.white70 : Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 32),

            // Promo Code
            Container(
              padding: AppSpacing.paddingMD,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurfaceVariant : AppColors.lightSurfaceVariant,
                borderRadius: AppSpacing.borderRadiusMD,
                border: Border.all(
                  color: promo.color.withOpacity(0.5),
                  width: 1,
                  style: BorderStyle.solid,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    'Código Promocional',
                    style: AppTypography.bodySmall.copyWith(
                      color: isDark ? Colors.white60 : Colors.black54,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        promo.code,
                        style: AppTypography.headlineSmall.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: 'monospace',
                          letterSpacing: 2,
                        ),
                      ),
                      SizedBox(width: 12),
                      IconButton(
                        icon: Icon(Icons.copy, size: 20),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Código copiado: ${promo.code}'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        tooltip: 'Copiar código',
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            Text(
              'Válido hasta ${_formatDate(promo.validUntil)}',
              style: AppTypography.bodyMedium.copyWith(
                color: isDark ? Colors.white60 : Colors.black54,
                fontWeight: FontWeight.w500,
              ),
            ),

            Spacer(),

            CinemaButton(
              text: 'Usar Promoción',
              icon: Icons.check_circle,
              isFullWidth: true,
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Promoción activada: ${promo.title}'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
