import 'package:flutter/material.dart';
import '../../../core/models/seat.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';

class SeatWidget extends StatefulWidget {
  final Seat seat;
  final VoidCallback onTap;
  final bool isSelected;

  const SeatWidget({
    super.key,
    required this.seat,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  State<SeatWidget> createState() => _SeatWidgetState();
}

class _SeatWidgetState extends State<SeatWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Color seatColor;
    IconData? icon;
    bool isInteractive = true;
    List<BoxShadow>? shadows;

    if (widget.isSelected) {
      seatColor = AppColors.primary;
      shadows = AppColors.glowShadow; // Neon glow effect
    } else {
      switch (widget.seat.status) {
        case SeatStatus.available:
          seatColor = _getColorForType(widget.seat.type);
          break;
        case SeatStatus.occupied:
        case SeatStatus.reserved:
          seatColor = AppColors.surfaceVariant;
          icon = Icons.close;
          isInteractive = false;
          break;
        case SeatStatus.selected:
          seatColor = AppColors.primary;
          shadows = AppColors.glowShadow;
          break;
      }
    }

    // Wheelchair icon
    if (widget.seat.type == SeatType.wheelchair &&
        widget.seat.status != SeatStatus.occupied) {
      icon = Icons.accessible;
    }

    return GestureDetector(
      onTapDown: isInteractive
          ? (_) {
              setState(() => _isPressed = true);
              _controller.forward();
            }
          : null,
      onTapUp: isInteractive
          ? (_) {
              setState(() => _isPressed = false);
              _controller.reverse();
              widget.onTap();
            }
          : null,
      onTapCancel: isInteractive
          ? () {
              setState(() => _isPressed = false);
              _controller.reverse();
            }
          : null,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 40,
          height: 40,
          margin: EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: seatColor,
            borderRadius: BorderRadius.circular(8),
            border: widget.isSelected
                ? Border.all(
                    color: Colors.white.withOpacity(0.5),
                    width: 2,
                  )
                : null,
            boxShadow: shadows,
          ),
          child: icon != null
              ? Icon(
                  icon,
                  color: Colors.white,
                  size: 22,
                )
              : null,
        ),
      ),
    );
  }

  Color _getColorForType(SeatType type) {
    switch (type) {
      case SeatType.regular:
        return AppColors.seatAvailable; // Green
      case SeatType.vip:
        return AppColors.vip; // Purple/Gold
      case SeatType.wheelchair:
        return AppColors.info; // Blue
    }
  }
}
