import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CountdownTimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback? onFinished;
  final double size;
  /// Si false, muestra "TOCA PARA EMPEZAR" y espera a que started cambie a true.
  final bool started;

  const CountdownTimerWidget({
    super.key,
    required this.seconds,
    this.onFinished,
    this.size = 80,
    this.started = false,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with TickerProviderStateMixin {
  late int _remaining;
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _finishedController;
  late Animation<double> _pulseScale;
  late Animation<double> _pulseGlow;
  late Animation<double> _finishedScale;
  Timer? _timer;
  bool _finished = false;
  bool _running = false;

  static const _cyan = Color(0xFF00FFFF);
  static const _crimson = Color(0xFFFF0055);
  static const _orange = Color(0xFFFF8C00);

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;

    _progressController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..repeat(reverse: true);

    _finishedController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseScale = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _pulseGlow = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _finishedScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _finishedController, curve: Curves.elasticOut),
    );

    if (widget.started) _start();
  }

  @override
  void didUpdateWidget(CountdownTimerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.started && widget.started && !_running) {
      _start();
    }
  }

  void _start() {
    _running = true;
    _pulseController.stop();
    _progressController.forward();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_remaining <= 1) {
        t.cancel();
        setState(() {
          _remaining = 0;
          _finished = true;
        });
        _onFinished();
      } else {
        setState(() => _remaining--);
        if (_remaining <= 5) {
          _pulseController
            ..stop()
            ..duration = const Duration(milliseconds: 600)
            ..repeat(reverse: true);
        }
      }
    });
  }

  void _onFinished() {
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 200), () => HapticFeedback.heavyImpact());
    Future.delayed(const Duration(milliseconds: 400), () => HapticFeedback.heavyImpact());
    _pulseController.repeat(reverse: true);
    _finishedController.forward();
    widget.onFinished?.call();
  }

  Color get _currentColor {
    if (!_running) return _cyan;
    if (_remaining <= 3) return _crimson;
    if (_remaining <= 10) {
      final t = (_remaining - 3) / 7.0;
      return Color.lerp(_crimson, _orange, t)!;
    }
    final t = ((_remaining - 10) / max(1, widget.seconds - 10)).clamp(0.0, 1.0);
    return Color.lerp(_orange, _cyan, t)!;
  }

  String _formatTime() {
    if (_remaining >= 60) {
      final m = _remaining ~/ 60;
      final s = _remaining % 60;
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
    return _remaining.toString();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _progressController.dispose();
    _pulseController.dispose();
    _finishedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_finished) return _buildFinished();
    if (!_running) return _buildWaiting();
    return _buildTimer();
  }

  // Estado: esperando primer tap
  Widget _buildWaiting() {
    final size = widget.size;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_rounded, color: _cyan, size: 13),
            const SizedBox(width: 5),
            Text(
              'TEMPORIZADOR · ${_formatTime()}s',
              style: const TextStyle(
                color: _cyan,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.8,
                shadows: [Shadow(color: _cyan, blurRadius: 6)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, _) => Transform.scale(
            scale: _pulseScale.value,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Glow exterior
                Container(
                  width: size + 16,
                  height: size + 16,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: _cyan.withOpacity(_pulseGlow.value * 0.4),
                        blurRadius: 24,
                        spreadRadius: 3,
                      ),
                    ],
                  ),
                ),
                // Fondo oscuro
                Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF0B0B1A),
                    border: Border.all(
                      color: _cyan.withOpacity(_pulseGlow.value),
                      width: 2,
                    ),
                  ),
                ),
                // Arco completo (sin contar aún)
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 5,
                    backgroundColor: Colors.transparent,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _cyan.withOpacity(_pulseGlow.value),
                    ),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                // Icono de tap
                Icon(
                  Icons.touch_app_rounded,
                  color: Colors.white.withOpacity(_pulseGlow.value),
                  size: size * 0.38,
                  shadows: [Shadow(color: _cyan, blurRadius: 10)],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedBuilder(
          animation: _pulseController,
          builder: (_, _) => Text(
            'TOCA PARA EMPEZAR',
            style: TextStyle(
              color: _cyan.withOpacity(_pulseGlow.value),
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              shadows: [Shadow(color: _cyan.withOpacity(0.5), blurRadius: 6)],
            ),
          ),
        ),
      ],
    );
  }

  // Estado: contando
  Widget _buildTimer() {
    final color = _currentColor;
    final progress = _remaining / widget.seconds;
    final isWarning = _remaining <= 5;
    final size = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_rounded, color: color, size: 13),
            const SizedBox(width: 5),
            Text(
              'TIEMPO RESTANTE',
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.8,
                shadows: [Shadow(color: color.withOpacity(0.6), blurRadius: 6)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        AnimatedBuilder(
          animation: Listenable.merge([_progressController, _pulseController]),
          builder: (_, _) {
            final scale = isWarning ? _pulseScale.value : 1.0;
            final glowOpacity = isWarning
                ? 0.5 + 0.5 * _pulseGlow.value
                : 0.25 + 0.25 * (1 - progress);
            final glowRadius = isWarning
                ? 18.0 + 14.0 * _pulseGlow.value
                : 10.0 + 8.0 * (1 - progress);

            return Transform.scale(
              scale: scale,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: size + 16,
                    height: size + 16,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(glowOpacity * 0.5),
                          blurRadius: glowRadius * 1.5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: size,
                    height: size,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0B0B1A),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(glowOpacity),
                          blurRadius: glowRadius,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: size,
                    height: size,
                    child: CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 5,
                      backgroundColor: Colors.white.withOpacity(0.08),
                      valueColor: AlwaysStoppedAnimation<Color>(color),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 150),
                    style: TextStyle(
                      fontSize: _remaining < 10 ? 32 : 24,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1,
                      shadows: [
                        Shadow(color: color, blurRadius: 14),
                        Shadow(color: color.withOpacity(0.4), blurRadius: 28),
                      ],
                    ),
                    child: Text(_formatTime()),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  // Estado: tiempo agotado
  Widget _buildFinished() {
    return AnimatedBuilder(
      animation: Listenable.merge([_finishedController, _pulseController]),
      builder: (_, _) {
        final glow = 15.0 + 20.0 * _pulseGlow.value;
        return Transform.scale(
          scale: _finishedScale.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 10),
            decoration: BoxDecoration(
              color: _crimson.withOpacity(0.12),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: _crimson, width: 2),
              boxShadow: [
                BoxShadow(
                  color: _crimson.withOpacity(0.7 * _pulseGlow.value),
                  blurRadius: glow,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.timer_off_rounded, color: Colors.white, size: 22),
                SizedBox(width: 8),
                Text(
                  '¡TIEMPO!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
