import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

enum DrinkaholicButtonVariant { primary, secondary, accent, outline }

typedef ButtonBuilder = Widget Function(BuildContext context, VoidCallback? onPressed);

class DrinkaholicButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final DrinkaholicButtonVariant variant;
  final bool fullWidth;
  final double height;
  final double borderRadius;

  const DrinkaholicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = DrinkaholicButtonVariant.primary,
    this.fullWidth = true,
    this.height = 60,
    this.borderRadius = 24,
  });

  @override
  State<DrinkaholicButton> createState() => _DrinkaholicButtonState();
}

class _DrinkaholicButtonState extends State<DrinkaholicButton> with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    if (widget.onPressed != null) {
      _scaleController.forward();
    }
  }

  void _handleTapUp(TapUpDetails details) {
    if (widget.onPressed != null) {
      _scaleController.reverse();
      HapticFeedback.lightImpact();
      widget.onPressed!();
    }
  }

  void _handleTapCancel() {
    if (widget.onPressed != null) {
      _scaleController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null;

    BoxDecoration decoration;
    TextStyle textStyle;
    Color? iconColor;

    switch (widget.variant) {
      case DrinkaholicButtonVariant.primary: // Magenta (Jugar)
        final colors = const [Color(0xFFFF0055), Color(0xFFFF5588)];
        decoration = BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(colors: [const Color(0xFF5A5A6E).withOpacity(0.6), const Color(0xFF7A7A8E).withOpacity(0.6)])
              : LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isDisabled
              ? []
              : [BoxShadow(color: const Color(0xFFFF0055).withOpacity(0.40), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 8))],
        );
        textStyle = GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5);
        iconColor = Colors.white;
        break;

      case DrinkaholicButtonVariant.secondary: // Cyan (Modo Liga)
        final colors = const [Color(0xFF00FFFF), Color(0xFF00B3FF)];
        decoration = BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(colors: [const Color(0xFF5A5A6E).withOpacity(0.6), const Color(0xFF7A7A8E).withOpacity(0.6)])
              : LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isDisabled
              ? []
              : [BoxShadow(color: const Color(0xFF00FFFF).withOpacity(0.40), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 8))],
        );
        // Using very dark blue/black for max contrast against Cyan
        textStyle = GoogleFonts.poppins(color: const Color(0xFF0B0B1A), fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5);
        iconColor = const Color(0xFF0B0B1A);
        break;

      case DrinkaholicButtonVariant.accent:
        final colors = const [Color(0xFF00FFFF), Color(0xFF55FFFF)];
        decoration = BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(colors: [const Color(0xFF5A5A6E).withOpacity(0.6), const Color(0xFF7A7A8E).withOpacity(0.6)])
              : LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isDisabled
              ? []
              : [BoxShadow(color: const Color(0xFF00FFFF).withOpacity(0.40), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 8))],
        );
        textStyle = GoogleFonts.poppins(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5);
        iconColor = Colors.black;
        break;

      case DrinkaholicButtonVariant.outline: // Orange (Elixirs)
        final colors = const [Color(0xFFFF8C00), Color(0xFFFFAA00)];
        decoration = BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(colors: [const Color(0xFF5A5A6E).withOpacity(0.6), const Color(0xFF7A7A8E).withOpacity(0.6)])
              : LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(widget.borderRadius),
          boxShadow: isDisabled
              ? []
              : [BoxShadow(color: const Color(0xFFFF8C00).withOpacity(0.40), blurRadius: 20, spreadRadius: 1, offset: const Offset(0, 8))],
        );
        textStyle = GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16, letterSpacing: 0.5);
        iconColor = Colors.white;
        break;
    }

    // Wrap elements to ensure perfectly centered positioning
    final bool hasArrow = widget.variant == DrinkaholicButtonVariant.primary || 
                          widget.variant == DrinkaholicButtonVariant.secondary ||
                          widget.variant == DrinkaholicButtonVariant.outline;

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(widget.icon, color: iconColor, size: 24), 
              const SizedBox(width: 16),
            ],
            Text(
              widget.label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
              style: textStyle,
            ),
          ],
        ),
        if (hasArrow)
          Icon(Icons.arrow_forward_ios, color: iconColor, size: 18),
      ],
    );

    final buttonNode = Container(
      height: widget.height,
      decoration: decoration,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24), 
          child: child,
        ),
      ),
    );

    final tapArea = GestureDetector(
      onTapDown: isDisabled ? null : _handleTapDown,
      onTapUp: isDisabled ? null : _handleTapUp,
      onTapCancel: isDisabled ? null : _handleTapCancel,
      behavior: HitTestBehavior.opaque,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: buttonNode,
      ),
    );

    if (widget.fullWidth) {
      return SizedBox(width: double.infinity, child: tapArea);
    }
    return tapArea;
  }
}
