import 'package:flutter/material.dart';

class FloatingParticleWidget extends StatefulWidget {
  final double size;
  final double opacity;
  final Duration duration;

  const FloatingParticleWidget({
    required this.size,
    required this.opacity,
    required this.duration,
  });

  @override
  State<FloatingParticleWidget> createState() => _FloatingParticleWidgetState();
}

class _FloatingParticleWidgetState extends State<FloatingParticleWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: widget.duration, vsync: this);

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _startAnimation();
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      if (mounted) {
        _controller.reset();
        _startAnimation();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, -_animation.value * 50),
          child: Opacity(
            opacity: widget.opacity * (1 - _animation.value),
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.3),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
