import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/services/database_service_v2.dart';
import '../../../../core/services/language_service.dart';
import '../../../../core/presentation/components/countdown_timer_widget.dart';
import '../../../../core/presentation/components/question_voting_widget.dart';

// ---------------------------------------------------------------------------
// Modo Personalizado — Preguntas escritas manualmente
// Ruta: lib/features/custom/presentation/screens/custom_questions_screen.dart
//
// Contiene tres clases:
//   CustomQuestionsManagerScreen — lista + CRUD de preguntas
//   CustomQuestionFormScreen     — formulario crear/editar
//   CustomGameScreen             — pantalla de juego del modo
//
// Registrar DatabaseService en el Provider de main.dart antes de usar.
// Anadir boton en home_screen.dart para navegar aqui.
// ---------------------------------------------------------------------------

// ══ PANTALLA PRINCIPAL — LISTA ════════════════════════════════════════════════

class CustomQuestionsManagerScreen extends StatefulWidget {
  const CustomQuestionsManagerScreen({super.key});

  @override
  State<CustomQuestionsManagerScreen> createState() =>
      _CustomQuestionsManagerScreenState();
}

class _CustomQuestionsManagerScreenState
    extends State<CustomQuestionsManagerScreen> {
  List<CustomQuestion> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final db = context.read<DatabaseService>();
    final qs = await db.getPersonalizedQuestions();
    if (mounted) setState(() { _questions = qs; _loading = false; });
  }

  Future<void> _openForm({CustomQuestion? editing}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomQuestionFormScreen(editing: editing),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _delete(CustomQuestion q) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(Provider.of<LanguageService>(context, listen: false).translate('delete_question_title')),
        content: Text(Provider.of<LanguageService>(context, listen: false).translate(
          'delete_question_confirm',
          args: {'text': q.text.length > 50 ? '${q.text.substring(0, 50)}...' : q.text},
        )),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(Provider.of<LanguageService>(context, listen: false).translate('cancel'))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Provider.of<LanguageService>(context, listen: false).translate('delete')),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<DatabaseService>().deletePersonalizedQuestion(q.id);
      _load();
    }
  }

  void _startGame() {
    if (_questions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(Provider.of<LanguageService>(context, listen: false).translate('add_at_least_one_to_play'))),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CustomGameScreen(
          questions: List.from(_questions)..shuffle(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11072C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1B69),
        foregroundColor: Colors.white,
        title: Text(Provider.of<LanguageService>(context).translate('custom_mode_title')),
        actions: const [],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF7F5AF0)))
          : _questions.isEmpty
              ? _EmptyState(onAdd: () => _openForm())
              : Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(16, 12, 16, 6),
                      child: Row(
                        children: [
                          Text(
                            _questions.length == 1
                                ? Provider.of<LanguageService>(context).translate('questions_count_singular')
                                : Provider.of<LanguageService>(context).translate('questions_count_plural', args: {'count': _questions.length.toString()}),
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.6),
                                fontSize: 13),
                          ),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: _startGame,
                            icon: const Icon(Icons.play_arrow_rounded,
                                size: 16),
                            label: Text(Provider.of<LanguageService>(context).translate('play_now_button')),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7F5AF0),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(color: Colors.white12),
                    Expanded(
                      child: ListView.separated(
                        padding:
                            const EdgeInsets.symmetric(vertical: 6),
                        itemCount: _questions.length,
                        separatorBuilder: (_, __) =>
                            const Divider(color: Colors.white12, indent: 72),
                        itemBuilder: (_, i) => _QuestionTile(
                          question: _questions[i],
                          onEdit: () => _openForm(editing: _questions[i]),
                          onDelete: () => _delete(_questions[i]),
                        ),
                      ),
                    ),
                  ],
                ),
      floatingActionButton: _questions.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: const Color(0xFF7F5AF0),
              onPressed: () => _openForm(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class _QuestionTile extends StatelessWidget {
  final CustomQuestion question;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _QuestionTile(
      {required this.question,
      required this.onEdit,
      required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: const Color(0xFF7F5AF0).withOpacity(0.25),
        child: Text(
          '${question.drinks}',
          style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFB4A5FF),
              fontSize: 13),
        ),
      ),
      title: Text(
        question.text,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: 14, color: Colors.white),
      ),
      subtitle: question.timerSeconds != null
          ? Text('⏱ ${question.timerSeconds}s',
              style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.4)))
          : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              icon: Icon(Icons.edit_outlined,
                  size: 18, color: Colors.white.withOpacity(0.5)),
              onPressed: onEdit),
          IconButton(
              icon: const Icon(Icons.delete_outline,
                  size: 18, color: Colors.redAccent),
              onPressed: onDelete),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.edit_note_rounded,
                size: 64, color: Colors.white.withOpacity(0.2)),
            const SizedBox(height: 20),
            Text(Provider.of<LanguageService>(context).translate('no_questions_yet'),
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              Provider.of<LanguageService>(context).translate('create_your_own_hint'),
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withOpacity(0.5), fontSize: 14),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: Text(Provider.of<LanguageService>(context).translate('add_first_question')),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7F5AF0),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ══ FORMULARIO — CREAR / EDITAR ════════════════════════════════════════════════

class CustomQuestionFormScreen extends StatefulWidget {
  final CustomQuestion? editing;
  const CustomQuestionFormScreen({super.key, this.editing});

  @override
  State<CustomQuestionFormScreen> createState() =>
      _CustomQuestionFormScreenState();
}

class _CustomQuestionFormScreenState
    extends State<CustomQuestionFormScreen> {
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
      backgroundColor: const Color(0xFF11072C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1B69),
        foregroundColor: Colors.white,
        title: Text(_isEditing 
            ? Provider.of<LanguageService>(context).translate('edit_question_title')
            : Provider.of<LanguageService>(context).translate('new_question_title')),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white))
                : Text(Provider.of<LanguageService>(context).translate('save_question_button'),
                    style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(Provider.of<LanguageService>(context).translate('question_or_challenge_label'),
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
                hintText: Provider.of<LanguageService>(context).translate('question_hint'),
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.08),
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
                  return Provider.of<LanguageService>(context, listen: false).translate('error_empty_question');
                if (v.trim().length < 5)
                  return Provider.of<LanguageService>(context, listen: false).translate('error_short_question');
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Tragos
            Row(
              children: [
                Text(Provider.of<LanguageService>(context).translate('drinks_label'),
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
                      Text(Provider.of<LanguageService>(context).translate('timer_label'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.white)),
                      Text(Provider.of<LanguageService>(context).translate('timer_desc'),
                          style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(0.4))),
                    ],
                  ),
                ),
                Switch(
                  value: _hasTimer,
                  onChanged: (v) => setState(() => _hasTimer = v),
                  activeColor: const Color(0xFF7F5AF0),
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
                      activeColor: const Color(0xFF7F5AF0),
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
              Text(Provider.of<LanguageService>(context).translate('preview_label'),
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
                  ? const Color(0xFF7F5AF0)
                  : Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: sel
                      ? const Color(0xFF7F5AF0)
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
                  ? Provider.of<LanguageService>(context).translate('drink_singular')
                  : Provider.of<LanguageService>(context).translate('drink_plural'),
                style: const TextStyle(
                    color: Colors.amber,
                    fontWeight: FontWeight.bold),
              ),
              if (timerSeconds != null) ...[
                const SizedBox(width: 12),
                const Icon(Icons.timer_outlined,
                    size: 16, color: Color(0xFF00D1FF)),
                const SizedBox(width: 4),
                Text('${timerSeconds}s',
                    style: const TextStyle(
                        color: Color(0xFF00D1FF),
                        fontWeight: FontWeight.bold)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// ══ PANTALLA DE JUEGO ═════════════════════════════════════════════════════════

class CustomGameScreen extends StatefulWidget {
  final List<CustomQuestion> questions;
  const CustomGameScreen({super.key, required this.questions});

  @override
  State<CustomGameScreen> createState() => _CustomGameScreenState();
}

class _CustomGameScreenState extends State<CustomGameScreen> {
  int _index = 0;

  CustomQuestion get _current => widget.questions[_index];
  bool get _isLast => _index == widget.questions.length - 1;

  void _next() {
    context.read<DatabaseService>().markPersonalizedAsUsed(_current.id);
    if (_isLast) {
      _showEndDialog();
    } else {
      setState(() => _index++);
    }
  }

  void _showEndDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(Provider.of<LanguageService>(context, listen: false).translate('end_of_questions_title')),
        content: Text(Provider.of<LanguageService>(context, listen: false).translate(
          'all_questions_played',
          args: {'count': widget.questions.length.toString()},
        )),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: Text(Provider.of<LanguageService>(context, listen: false).translate('back_to_menu')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _index = 0;
                widget.questions.shuffle();
              });
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7F5AF0)),
            child: Text(Provider.of<LanguageService>(context, listen: false).translate('repeat_button'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF11072C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D1B69),
        foregroundColor: Colors.white,
        title: Text(Provider.of<LanguageService>(context).translate('custom_mode_title')),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '${_index + 1} / ${widget.questions.length}',
                style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Progreso
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_index + 1) / widget.questions.length,
                minHeight: 5,
                backgroundColor: Colors.white.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF7F5AF0)),
              ),
            ),
            const SizedBox(height: 24),

            // Carta
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.15),
                      Colors.white.withOpacity(0.05)
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: Colors.white.withOpacity(0.2), width: 1.5),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.local_drink,
                        size: 36, color: Colors.white70),
                    const SizedBox(height: 20),
                    Text(
                      _current.text,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.local_bar,
                            color: Colors.amber, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          _current.drinks == 1
                            ? Provider.of<LanguageService>(context).translate('drink_singular')
                            : Provider.of<LanguageService>(context).translate('drink_plural'),
                          style: const TextStyle(
                              color: Colors.amber,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                      ],
                    ),
                    // Temporizador opcional
                    if (_current.timerSeconds != null) ...[
                      const SizedBox(height: 16),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 12),
                      CountdownTimerWidget(
                          seconds: _current.timerSeconds!),
                    ],
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white24),
                    const SizedBox(height: 8),
                    // Votacion — usa el id de la pregunta personalizada
                    QuestionVotingWidget(
                      templateId: _current.id,
                      db: context.read<DatabaseService>(),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Siguiente
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _next,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7F5AF0),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
                child: Text(
                  _isLast 
                    ? Provider.of<LanguageService>(context).translate('finish_button')
                    : Provider.of<LanguageService>(context).translate('next_button'),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
