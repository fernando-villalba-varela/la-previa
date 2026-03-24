import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/database_service_v2.dart';
import '../../../../../core/services/language_service.dart';

class CustomQuestionFormScreen extends StatefulWidget {
  final CustomQuestion? editing;
  final String? leagueId;

  const CustomQuestionFormScreen({super.key, this.editing, this.leagueId});

  @override
  State<CustomQuestionFormScreen> createState() => _CustomQuestionFormScreenState();
}

class _CustomQuestionFormScreenState extends State<CustomQuestionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _textCtrl = TextEditingController();
  int _drinks = 1;
  bool _hasTimer = false;
  int _timerSecs = 30;
  bool _saving = false;

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _textCtrl.text = widget.editing!.text;
      _drinks       = widget.editing!.drinks;
      _hasTimer     = widget.editing!.timerSeconds != null;
      _timerSecs    = widget.editing!.timerSeconds ?? 30;
    }
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final q = CustomQuestion(
      id:           _isEditing
          ? widget.editing!.id
          : 'custom_${DateTime.now().millisecondsSinceEpoch}',
      text:         _textCtrl.text.trim(),
      drinks:       _drinks,
      timerSeconds: _hasTimer ? _timerSecs : null,
      leagueId:     _isEditing ? widget.editing!.leagueId : widget.leagueId,
      isActive:     _isEditing ? widget.editing!.isActive : true,
    );

    final db = context.read<DatabaseService>();
    if (_isEditing) {
      await db.updatePersonalizedQuestion(q);
    } else {
      await db.savePersonalizedQuestion(q);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0B1A), // Deep Night
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0B1A),
        foregroundColor: Colors.white,
        title: Text(_isEditing 
            ? Provider.of<LanguageService>(context).translate('edit_question_title') ?? 'Editar'
            : Provider.of<LanguageService>(context).translate('new_question_title') ?? 'Nueva Pregunta'),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(Provider.of<LanguageService>(context).translate('save_question_button') ?? 'Guardar',
                    style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(Provider.of<LanguageService>(context).translate('question_or_challenge_label') ?? 'Pregunta o Reto',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, color: Colors.white)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _textCtrl,
              maxLines: 4,
              maxLength: 300,
              textCapitalization: TextCapitalization.sentences,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: Provider.of<LanguageService>(context).translate('question_hint') ?? 'Escribe tu reto aquí...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                      color: Colors.white.withOpacity(0.2)),
                ),
                counterStyle: TextStyle(
                    color: Colors.white.withOpacity(0.4)),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty)
                  return Provider.of<LanguageService>(context, listen: false).translate('error_empty_question') ?? 'No puede estar vacío';
                if (v.trim().length < 5)
                  return Provider.of<LanguageService>(context, listen: false).translate('error_short_question') ?? 'Demasiado corto';
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Tragos
            Row(
              children: [
                Text(Provider.of<LanguageService>(context).translate('drinks_label') ?? 'Tragos',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.white)),
                const Spacer(),
                _DrinksSelector(
                    value: _drinks,
                    onChanged: (v) => setState(() => _drinks = v)),
              ],
            ),
            const SizedBox(height: 24),

            // Temporizador
            const Divider(color: Colors.white24),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(Provider.of<LanguageService>(context).translate('timer_label') ?? 'Temporizador',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      Text(Provider.of<LanguageService>(context).translate('timer_desc') ?? 'Añadir límite de tiempo',
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4))),
                    ],
                  ),
                ),
                Switch(
                  value: _hasTimer,
                  onChanged: (v) => setState(() => _hasTimer = v),
                  activeColor: const Color(0xFF8A2BE2),
                ),
              ],
            ),
            if (_hasTimer) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Text('${_timerSecs}s',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)),
                  Expanded(
                    child: Slider(
                      value: _timerSecs.toDouble(),
                      min: 10,
                      max: 120,
                      divisions: 11,
                      activeColor: const Color(0xFF8A2BE2),
                      onChanged: (v) =>
                          setState(() => _timerSecs = v.round()),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 32),

            // Preview
            if (_textCtrl.text.isNotEmpty) ...[
              Text(Provider.of<LanguageService>(context).translate('preview_label') ?? 'Vista Previa',
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 13)),
              const SizedBox(height: 8),
              _PreviewCard(
                text: _textCtrl.text.trim(),
                drinks: _drinks,
                timerSeconds: _hasTimer ? _timerSecs : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DrinksSelector extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const _DrinksSelector(
      {required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final n = i + 1;
        final sel = n == value;
        return GestureDetector(
          onTap: () => onChanged(n),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: sel
                  ? const Color(0xFF8A2BE2)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: sel
                      ? const Color(0xFF8A2BE2)
                      : Colors.white.withOpacity(0.2)),
            ),
            child: Center(
              child: Text('$n',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: sel
                          ? Colors.white
                          : Colors.white.withOpacity(0.5))),
            ),
          ),
        );
      }),
    );
  }
}

class _PreviewCard extends StatelessWidget {
  final String text;
  final int drinks;
  final int? timerSeconds;

  const _PreviewCard(
      {required this.text,
      required this.drinks,
      this.timerSeconds});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Column(
        children: [
          Text(text,
              textAlign: TextAlign.center,
              style:
                  const TextStyle(fontSize: 15, color: Colors.white)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.local_bar,
                  size: 16, color: Colors.amber),
              const SizedBox(width: 4),
              Text(
                drinks == 1 
                  ? '$drinks ${Provider.of<LanguageService>(context).translate('drink_singular') ?? 'Trago'}'
                  : '$drinks ${Provider.of<LanguageService>(context).translate('drink_plural') ?? 'Tragos'}',
                style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
              if (timerSeconds != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.timer_outlined,
                    size: 16, color: Color(0xFF00FFFF)),
                const SizedBox(width: 4),
                Text('${timerSeconds}s',
                    style: const TextStyle(
                        color: Color(0xFF00FFFF),
                        fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
