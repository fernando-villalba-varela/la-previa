import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/services/database_service_v2.dart';

// ---------------------------------------------------------------------------
// QuestionVotingWidget
// Ruta: lib/core/presentation/components/question_voting_widget.dart
//
// Muestra botones thumbs up/down para votar un template de pregunta.
// Usa DatabaseService — no SharedPreferences.
// Se integra en GameCard cuando gameState.currentTemplateId != null.
//
// Uso desde game_card_widget.dart:
//   QuestionVotingWidget(
//     templateId: gameState.currentTemplateId!,
//     db: context.read<DatabaseService>(),
//   )
// ---------------------------------------------------------------------------

class QuestionVotingWidget extends StatefulWidget {
  final String templateId;
  final String challengeText;
  final DatabaseService db;

  const QuestionVotingWidget({
    super.key,
    required this.templateId,
    required this.challengeText,
    required this.db,
  });


  @override
  State<QuestionVotingWidget> createState() =>
      _QuestionVotingWidgetState();
}

class _QuestionVotingWidgetState extends State<QuestionVotingWidget> {
  VoteCount? _voteCount;
  bool _loading = false;
  VoteType? _localVote; // Track chosen vote for visual feedback

  @override
  void initState() {
    super.initState();
    _loadVoteCount();
  }

  @override
  void didUpdateWidget(QuestionVotingWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.templateId != widget.templateId) {
      setState(() {
        _voteCount = null;
        _localVote = null;
      });
      _loadVoteCount();
    }
  }

  Future<void> _loadVoteCount() async {
    final count = await widget.db.getVoteCount(widget.templateId);
    if (mounted) setState(() => _voteCount = count);
  }

  Future<void> _handleVote(VoteType type) async {
    if (_loading) return;
    HapticFeedback.lightImpact();

    if (_localVote == type) {
      // Mismo botón pulsado → deseleccionar (volver a gris), sin tocar la BD
      setState(() => _localVote = null);
      return;
    }

    setState(() {
      _loading = true;
      _localVote = type; // feedback visual inmediato
    });

    await widget.db.vote(widget.templateId, widget.challengeText, type);
    final updated = await widget.db.getVoteCount(widget.templateId);

    if (mounted) {
      setState(() {
        _voteCount = updated;
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '¿Buena pregunta?',
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        const SizedBox(width: 10),
        _VoteButton(
          icon: Icons.thumb_up_rounded,
          count: _voteCount?.upCount,
          activeColor: const Color(0xFF00FFFF),
          isSelected: _localVote == VoteType.up,
          onTap: () => _handleVote(VoteType.up),
        ),
        const SizedBox(width: 8),
        _VoteButton(
          icon: Icons.thumb_down_rounded,
          count: _voteCount?.downCount,
          activeColor: const Color(0xFFFF0055),
          isSelected: _localVote == VoteType.down,
          onTap: () => _handleVote(VoteType.down),
          warningThreshold: DatabaseService.suppressThreshold,
        ),
      ],
    );
  }
}


class _VoteButton extends StatelessWidget {
  final IconData icon;
  final int? count;
  final Color activeColor;
  final VoidCallback onTap;
  final int? warningThreshold;
  final bool isSelected;

  const _VoteButton({
    required this.icon,
    required this.activeColor,
    required this.onTap,
    this.isSelected = false,
    this.count,
    this.warningThreshold,
  });

  bool get _nearThreshold =>
      warningThreshold != null &&
      count != null &&
      count! >= warningThreshold! - 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withOpacity(0.2)
              : Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (_nearThreshold
                    ? Colors.redAccent.withOpacity(0.7)
                    : Colors.white.withOpacity(0.25)),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected ? [
            BoxShadow(
              color: activeColor.withOpacity(0.4),
              blurRadius: 10,
              spreadRadius: 1,
            )
          ] : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 15,
              color: isSelected
                  ? activeColor
                  : (_nearThreshold
                      ? Colors.redAccent
                      : Colors.white.withOpacity(0.7)),
            ),
            if (count != null && count! > 0) ...[
              const SizedBox(width: 4),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 11,
                  color: isSelected
                      ? activeColor
                      : (_nearThreshold
                          ? Colors.redAccent
                          : Colors.white.withOpacity(0.6)),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
