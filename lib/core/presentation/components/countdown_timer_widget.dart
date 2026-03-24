import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Widget de cuenta atrás para retos con temporizador.
/// Añade el campo opcional "timer_seconds" al modelo de pregunta/reto
/// y pasa el valor a este widget cuando sea distinto de null.
///
/// Uso:
///   if (question.timerSeconds != null)
///     CountdownTimerWidget(seconds: question.timerSeconds!)
class CountdownTimerWidget extends StatefulWidget {
  final int seconds;
  final VoidCallback? onFinished;
  final Color? activeColor;
  final Color? warningColor;  // < 30% tiempo restante
  final Color? dangerColor;   // < 10% tiempo restante

  const CountdownTimerWidget({
    super.key,
    required this.seconds,
    this.onFinished,
    this.activeColor,
    this.warningColor,
    this.dangerColor,
  });

  @override
  State<CountdownTimerWidget> createState() => _CountdownTimerWidgetState();
}

class _CountdownTimerWidgetState extends State<CountdownTimerWidget>
    with SingleTickerProviderStateMixin {
  late int _remaining;
  late AnimationController _animController;
  Timer? _timer;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    _remaining = widget.seconds;

    _animController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.seconds),
    )..forward();

    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remaining <= 1) {
        timer.cancel();
        setState(() {
          _remaining = 0;
          _finished = true;
        });
        _onFinished();
      } else {
        setState(() => _remaining--);
      }
    });
  }

  void _onFinished() {
    // Vibración al terminar
    HapticFeedback.heavyImpact();
    Future.delayed(const Duration(milliseconds: 300), () {
      HapticFeedback.heavyImpact();
    });
    widget.onFinished?.call();
  }

  Color _currentColor() {
    if (_remaining <= 3) return const Color(0xFFFF0055); // Crimson Fiesta
    // Linear transition to cyan
    return Color.lerp(const Color(0xFFFF0055), const Color(0xFF00FFFF), _remaining / widget.seconds) ?? const Color(0xFF00FFFF);
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
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = _currentColor();
    final progress = _remaining / widget.seconds;
    final isHeartbeat = _remaining <= 3 && _remaining > 0;
    
    // Scale animation that pulses every second
    final scale = isHeartbeat ? 1.0 + 0.15 * (0.5 - (_animController.value * widget.seconds % 1).abs()).abs() : 1.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Transform.scale(
          scale: scale,
          child: Stack(
            alignment: Alignment.center,
            children: [
            SizedBox(
              width: 80,
              height: 80,
              child: AnimatedBuilder(
                animation: _animController,
                builder: (_, __) => CircularProgressIndicator(
                  value: 1.0 - _animController.value,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.shade200,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              style: TextStyle(
                fontSize: _remaining < 10 ? 28 : 22,
                fontWeight: FontWeight.bold,
                color: _finished ? Colors.red.shade600 : color,
              ),
              child: Text(_finished ? '¡Ya!' : _formatTime()),
            ),
          ],
        ),
      ),
        if (_finished) ...[
          const SizedBox(height: 8),
          Text(
            '¡Tiempo agotado!',
            style: TextStyle(
              color: Colors.red.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// MODELO — añadir campo timerSeconds al modelo de pregunta existente
// ---------------------------------------------------------------------------

/// Ejemplo de cómo extender el modelo de pregunta para soportar el temporizador.
/// Adapta esto a tu clase de modelo actual.
class Question {
  final String id;
  final String type;      // "pregunta", "reto", "evento"
  final String category;
  final String text;
  final int drinks;
  final int? timerSeconds; // null = sin temporizador

  const Question({
    required this.id,
    required this.type,
    required this.category,
    required this.text,
    required this.drinks,
    this.timerSeconds,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id:           json['id'] as String,
    type:         json['type'] as String,
    category:     json['category'] as String,
    text:         json['text'] as String,
    drinks:       json['drinks'] as int,
    timerSeconds: json['timer_seconds'] as int?,
  );

  Map<String, dynamic> toJson() => {
    'id':       id,
    'type':     type,
    'category': category,
    'text':     text,
    'drinks':   drinks,
    if (timerSeconds != null) 'timer_seconds': timerSeconds,
  };
}

// ---------------------------------------------------------------------------
// EJEMPLO DE USO en la pantalla de juego
// ---------------------------------------------------------------------------

/// Muestra cómo integrar el temporizador en la carta de pregunta/reto.
class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              question.text,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
            if (question.timerSeconds != null) ...[
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              const Text(
                'Tiempo para completar el reto:',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 12),
              CountdownTimerWidget(
                seconds: question.timerSeconds!,
                onFinished: () {
                  // Aquí puedes disparar una lógica adicional:
                  // vibración extra, mostrar dialog de penalización, etc.
                },
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.local_bar, size: 16, color: Colors.amber),
                const SizedBox(width: 4),
                Text(
                  '${question.drinks} ${question.drinks == 1 ? "trago" : "tragos"}',
                  style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
