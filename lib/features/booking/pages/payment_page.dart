import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/cinema_button.dart';
import '../../../core/widgets/cinema_text_field.dart';
import '../providers/booking_provider.dart';
import 'confirmation_page.dart';

class PaymentPage extends ConsumerStatefulWidget {
  const PaymentPage({super.key});

  @override
  ConsumerState<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends ConsumerState<PaymentPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _cardHolderController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvvController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isProcessing = false;
  int _selectedPaymentMethod = 0; // 0: Credit Card, 1: PayPal, 2: Apple Pay
  String _cardType = 'unknown'; // visa, mastercard, amex, etc.
  bool _isCardFlipped = false;

  late AnimationController _flipController;
  late Animation<double> _flipAnimation;

  @override
  void initState() {
    super.initState();
    _flipController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOut),
    );

    // Detect card type as user types
    _cardNumberController.addListener(() {
      _detectCardType(_cardNumberController.text);
    });
  }

  @override
  void dispose() {
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _emailController.dispose();
    _flipController.dispose();
    super.dispose();
  }

  void _detectCardType(String number) {
    final cleanNumber = number.replaceAll(' ', '');
    String newType = 'unknown';

    if (cleanNumber.startsWith('4')) {
      newType = 'visa';
    } else if (cleanNumber.startsWith(RegExp(r'5[1-5]'))) {
      newType = 'mastercard';
    } else if (cleanNumber.startsWith(RegExp(r'3[47]'))) {
      newType = 'amex';
    } else if (cleanNumber.startsWith('6')) {
      newType = 'discover';
    }

    if (newType != _cardType) {
      setState(() {
        _cardType = newType;
      });
    }
  }

  void _flipCard(bool flip) {
    if (flip && !_isCardFlipped) {
      _flipController.forward();
      setState(() => _isCardFlipped = true);
    } else if (!flip && _isCardFlipped) {
      _flipController.reverse();
      setState(() => _isCardFlipped = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          'Método de Pago',
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Total Amount Card with Gradient
                  _buildTotalCard(bookingState.totalPrice, isDark),

                  SizedBox(height: AppSpacing.xl),

                  // Payment Method Tabs
                  _buildPaymentMethodTabs(isDark),

                  SizedBox(height: AppSpacing.xl),

                  // Payment Form
                  if (_selectedPaymentMethod == 0)
                    _buildCreditCardForm(isDark)
                  else if (_selectedPaymentMethod == 1)
                    _buildPayPalForm(isDark)
                  else
                    _buildApplePayForm(isDark),
                ],
              ),
            ),
          ),

          // Bottom bar with pay button
          _buildBottomBar(bookingState.totalPrice, isDark),
        ],
      ),
    );
  }

  Widget _buildTotalCard(double total, bool isDark) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: isDark ? AppColors.glowShadow : AppColors.cardShadow,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Total a Pagar',
                style: AppTypography.titleMedium.copyWith(
                  color: Colors.white.withOpacity(0.9),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: AppTypography.displaySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.payments_outlined,
              color: Colors.white,
              size: 40,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodTabs(bool isDark) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant
            : AppColors.lightSurfaceVariant,
        borderRadius: AppSpacing.borderRadiusRound,
      ),
      child: Row(
        children: [
          _buildPaymentTab(
            icon: Icons.credit_card,
            label: 'Tarjeta',
            index: 0,
            isDark: isDark,
          ),
          _buildPaymentTab(
            icon: Icons.account_balance_wallet,
            label: 'PayPal',
            index: 1,
            isDark: isDark,
          ),
          _buildPaymentTab(
            icon: Icons.apple,
            label: 'Apple Pay',
            index: 2,
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentTab({
    required IconData icon,
    required String label,
    required int index,
    required bool isDark,
  }) {
    final isSelected = _selectedPaymentMethod == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedPaymentMethod = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(
            vertical: AppSpacing.sm,
            horizontal: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            gradient: isSelected ? AppColors.primaryGradient : null,
            color: isSelected ? null : Colors.transparent,
            borderRadius: AppSpacing.borderRadiusRound,
            boxShadow: isSelected && isDark ? AppColors.glowShadow : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                size: 20,
              ),
              SizedBox(width: AppSpacing.xs),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected
                      ? Colors.white
                      : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreditCardForm(bool isDark) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 3D Credit Card Preview
          _buildCreditCardPreview(isDark),

          SizedBox(height: AppSpacing.xl),

          // Email
          Text(
            'Email de Confirmación',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          CinemaTextField(
            label: 'Email',
            controller: _emailController,
            hint: 'correo@ejemplo.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa tu email';
              }
              if (!value.contains('@')) {
                return 'Email inválido';
              }
              return null;
            },
          ),

          SizedBox(height: AppSpacing.lg),

          // Card number
          Text(
            'Número de Tarjeta',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          CinemaTextField(
            label: 'Número de Tarjeta',
            controller: _cardNumberController,
            hint: '1234 5678 9012 3456',
            prefixIcon: Icons.credit_card,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            onTap: () => _flipCard(false),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa el número de tarjeta';
              }
              if (value.replaceAll(' ', '').length < 16) {
                return 'Número de tarjeta inválido';
              }
              return null;
            },
          ),

          SizedBox(height: AppSpacing.lg),

          // Card holder
          Text(
            'Nombre del Titular',
            style: AppTypography.titleSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          CinemaTextField(
            label: 'Nombre del Titular',
            controller: _cardHolderController,
            hint: 'JUAN PEREZ',
            prefixIcon: Icons.person_outline,
            textCapitalization: TextCapitalization.characters,
            onTap: () => _flipCard(false),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingresa el nombre del titular';
              }
              return null;
            },
          ),

          SizedBox(height: AppSpacing.lg),

          // Expiry and CVV
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Vencimiento',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    CinemaTextField(
                      label: 'Vencimiento',
                      controller: _expiryController,
                      hint: 'MM/AA',
                      prefixIcon: Icons.calendar_today,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                        _ExpiryDateFormatter(),
                      ],
                      onTap: () => _flipCard(false),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (!value.contains('/') || value.length < 5) {
                          return 'MM/AA';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CVV',
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: AppSpacing.sm),
                    CinemaTextField(
                      label: 'CVV',
                      controller: _cvvController,
                      hint: '123',
                      prefixIcon: Icons.lock_outline,
                      keyboardType: TextInputType.number,
                      obscureText: true,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      onTap: () => _flipCard(true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Requerido';
                        }
                        if (value.length < 3) {
                          return 'Inválido';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: AppSpacing.xl),

          // Security info
          _buildSecurityInfo(isDark),

          SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _buildCreditCardPreview(bool isDark) {
    return Center(
      child: AnimatedBuilder(
        animation: _flipAnimation,
        builder: (context, child) {
          final angle = _flipAnimation.value * 3.14159;
          final isFront = angle < 3.14159 / 2;

          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001)
              ..rotateY(angle),
            alignment: Alignment.center,
            child: isFront
                ? _buildCardFront(isDark)
                : Transform(
                    transform: Matrix4.identity()..rotateY(3.14159),
                    alignment: Alignment.center,
                    child: _buildCardBack(isDark),
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCardFront(bool isDark) {
    return Container(
      width: 340,
      height: 200,
      decoration: BoxDecoration(
        gradient: _getCardGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Card type logo and chip
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 50,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.sim_card, color: Colors.black87, size: 30),
                ),
                _buildCardLogo(),
              ],
            ),

            // Card number
            Text(
              _formatCardNumber(_cardNumberController.text),
              style: AppTypography.headlineSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),

            // Card holder and expiry
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TITULAR',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _cardHolderController.text.isEmpty
                          ? 'NOMBRE APELLIDO'
                          : _cardHolderController.text.toUpperCase(),
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'VENCE',
                      style: AppTypography.labelSmall.copyWith(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 10,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      _expiryController.text.isEmpty
                          ? 'MM/AA'
                          : _expiryController.text,
                      style: AppTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardBack(bool isDark) {
    return Container(
      width: 340,
      height: 200,
      decoration: BoxDecoration(
        gradient: _getCardGradient(),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(height: 30),
          // Magnetic strip
          Container(
            height: 50,
            color: Colors.black87,
          ),
          SizedBox(height: AppSpacing.lg),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerRight,
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      _cvvController.text.isEmpty
                          ? '•••'
                          : '•' * _cvvController.text.length,
                      style: AppTypography.titleMedium.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                _buildCardLogo(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardLogo() {
    IconData icon;
    Color color = Colors.white;

    switch (_cardType) {
      case 'visa':
        icon = Icons.credit_card;
        break;
      case 'mastercard':
        icon = Icons.credit_card;
        color = Colors.orange;
        break;
      case 'amex':
        icon = Icons.credit_card;
        color = Colors.blue;
        break;
      case 'discover':
        icon = Icons.credit_card;
        color = Colors.orange.shade800;
        break;
      default:
        icon = Icons.credit_card_outlined;
    }

    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 28),
    );
  }

  LinearGradient _getCardGradient() {
    switch (_cardType) {
      case 'visa':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A1F71), Color(0xFF0066B2)],
        );
      case 'mastercard':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFEB001B), Color(0xFFF79E1B)],
        );
      case 'amex':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF006FCF), Color(0xFF0099DD)],
        );
      case 'discover':
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF6000), Color(0xFFFF9500)],
        );
      default:
        return AppColors.primaryGradient;
    }
  }

  String _formatCardNumber(String number) {
    final cleaned = number.replaceAll(' ', '');
    if (cleaned.isEmpty) return '•••• •••• •••• ••••';

    String formatted = '';
    for (int i = 0; i < 16; i += 4) {
      if (i < cleaned.length) {
        final end = (i + 4 <= cleaned.length) ? i + 4 : cleaned.length;
        formatted += cleaned.substring(i, end).padRight(4, '•');
      } else {
        formatted += '••••';
      }
      if (i < 12) formatted += ' ';
    }
    return formatted;
  }

  Widget _buildPayPalForm(bool isDark) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.account_balance_wallet, size: 64, color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text(
            'Pagar con PayPal',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Serás redirigido a PayPal para completar tu pago de forma segura',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApplePayForm(bool isDark) {
    return Container(
      padding: AppSpacing.paddingLG,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceElevated
            : AppColors.lightSurfaceElevated,
        borderRadius: AppSpacing.borderRadiusLG,
        boxShadow: isDark ? AppColors.elevatedShadow : AppColors.cardShadow,
      ),
      child: Column(
        children: [
          Icon(Icons.apple, size: 64, color: AppColors.primary),
          SizedBox(height: AppSpacing.md),
          Text(
            'Pagar con Apple Pay',
            style: AppTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppSpacing.sm),
          Text(
            'Usa Touch ID o Face ID para completar tu pago de forma rápida y segura',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityInfo(bool isDark) {
    return Container(
      padding: AppSpacing.paddingMD,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurfaceVariant.withOpacity(0.5)
            : AppColors.lightSurfaceVariant.withOpacity(0.5),
        borderRadius: AppSpacing.borderRadiusMD,
        border: Border.all(
          color: AppColors.success.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.lock_outline,
              color: AppColors.success,
              size: 24,
            ),
          ),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Pago 100% Seguro',
                  style: AppTypography.titleSmall.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Tu información está encriptada y protegida',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(double total, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.darkSurface
            : AppColors.lightSurface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: AppSpacing.pagePadding,
      child: SafeArea(
        child: CinemaButton(
          text: _isProcessing
              ? 'Procesando...'
              : 'Pagar \$${total.toStringAsFixed(2)}',
          icon: _isProcessing ? null : Icons.lock_outline,
          isFullWidth: true,
          size: ButtonSize.large,
          onPressed: _isProcessing ? null : _processPayment,
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    // Only validate form for credit card payments
    if (_selectedPaymentMethod == 0) {
      if (!_formKey.currentState!.validate()) {
        return;
      }
    }

    setState(() {
      _isProcessing = true;
    });

    // Simulate payment processing
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
    });

    // Navigate to confirmation
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ConfirmationPage(
          email: _emailController.text.isEmpty
              ? 'usuario@ejemplo.com'
              : _emailController.text,
        ),
      ),
    );
  }
}

// Custom formatter for card number (adds space every 4 digits)
class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();

    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      if ((i + 1) % 4 == 0 && i + 1 != text.length) {
        buffer.write(' ');
      }
    }

    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

// Custom formatter for expiry date (adds / after 2 digits)
class _ExpiryDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll('/', '');

    if (text.length >= 2) {
      final month = text.substring(0, 2);
      final year = text.length > 2 ? text.substring(2) : '';
      final formatted = '$month/$year';

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    return newValue;
  }
}
