import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../core/services/database_service_v2.dart';
import '../../../../../core/services/language_service.dart';
import '../../../presentation/viewmodels/league_detail_viewmodel.dart';
import 'custom_question_form_screen.dart';
import 'package:drinkaholic/core/presentation/components/drinkaholic_card.dart';

class CustomQuestionsLeagueTab extends StatefulWidget {
  const CustomQuestionsLeagueTab({super.key});

  @override
  State<CustomQuestionsLeagueTab> createState() => _CustomQuestionsLeagueTabState();
}

class _CustomQuestionsLeagueTabState extends State<CustomQuestionsLeagueTab> {
  List<CustomQuestion> _questions = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final vm = context.read<LeagueDetailViewModel>();
    final db = context.read<DatabaseService>();
    final qs = await db.getPersonalizedQuestions(vm.league.id);
    if (mounted) {
      setState(() {
        _questions = qs;
        _loading = false;
      });
    }
  }

  Future<void> _openForm({CustomQuestion? editing}) async {
    final vm = context.read<LeagueDetailViewModel>();
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomQuestionFormScreen(editing: editing, leagueId: vm.league.id),
      ),
    );
    if (result == true) _load();
  }

  Future<void> _toggleStatus(CustomQuestion q, bool isActive) async {
    await context.read<DatabaseService>().togglePersonalizedQuestionStatus(q.id, isActive);
    _load();
  }

  Future<void> _delete(CustomQuestion q) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0B0B1A),
        title: Text(Provider.of<LanguageService>(context, listen: false).translate('delete_question_title') ?? 'Eliminar pregunta', style: const TextStyle(color: Colors.white)),
        content: Text(Provider.of<LanguageService>(context, listen: false).translate(
          'delete_question_confirm',
          args: {'text': q.text.length > 50 ? '${q.text.substring(0, 50)}...' : q.text},
        ) ?? '¿Seguro que deseas eliminar esta pregunta?', style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(Provider.of<LanguageService>(context, listen: false).translate('cancel') ?? 'Cancelar', style: const TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(Provider.of<LanguageService>(context, listen: false).translate('delete') ?? 'Eliminar'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await context.read<DatabaseService>().deletePersonalizedQuestion(q.id);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF8A2BE2)));
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: _questions.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.edit_note_rounded, size: 64, color: Colors.white.withOpacity(0.5)),
                    const SizedBox(height: 20),
                    Text(Provider.of<LanguageService>(context).translate('no_questions_yet') ?? 'Aún no hay preguntas',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white)),
                    const SizedBox(height: 8),
                    Text(
                      Provider.of<LanguageService>(context).translate('create_your_own_hint') ?? 'Crea preguntas personalizadas exclusivas para esta liga.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 14),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80), // offset for FAB
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                final q = _questions[index];
                return DrinkaholicCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8A2BE2).withOpacity(0.25),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.local_bar, size: 14, color: Color(0xFFE0B3FF)),
                                const SizedBox(width: 4),
                                Text(
                                  q.drinks == 1
                                    ? '${q.drinks} ${Provider.of<LanguageService>(context).translate('drink_singular') ?? 'Trago'}'
                                    : '${q.drinks} ${Provider.of<LanguageService>(context).translate('drink_plural') ?? 'Tragos'}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE0B3FF), fontSize: 13),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              q.text,
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                          Switch(
                            value: q.isActive,
                            onChanged: (val) => _toggleStatus(q, val),
                            activeColor: const Color(0xFF8A2BE2),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          if (q.timerSeconds != null) ...[
                            Icon(Icons.timer_outlined, size: 14, color: Colors.white.withOpacity(0.5)),
                            const SizedBox(width: 4),
                            Text('${q.timerSeconds}s', style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.5))),
                            const SizedBox(width: 16),
                          ],
                          const Spacer(),
                          IconButton(
                            icon: Icon(Icons.edit_outlined, size: 20, color: Colors.white.withOpacity(0.7)),
                            onPressed: () => _openForm(editing: q),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.redAccent),
                            onPressed: () => _delete(q),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8A2BE2),
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
