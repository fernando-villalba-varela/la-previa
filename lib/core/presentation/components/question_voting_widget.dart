import 'package:flutter/material.dart';
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
  final DatabaseService db;

  const QuestionVotingWidget({
    super.key,
    required this.templateId,
    required this.db,
  });

  @override
  State<QuestionVotingWidget> createState() =>
      _QuestionVotingWidgetState();
}

class _QuestionVotingWidgetState extends State<QuestionVotingWidget> {
  VoteCount? _voteCount;
  bool _justSuppressed = false;
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
    // Recargar cuando cambia el template (nuevo turno)
    if (oldWidget.templateId != widget.templateId) {
      setState(() {
        _voteCount = null;
        _justSuppressed = false;
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
    setState(() => _loading = true);

    await widget.db.vote(widget.templateId, type);
    final updated = await widget.db.getVoteCount(widget.templateId);
    final suppressed =
        await widget.db.isSuppressed(widget.templateId);

    if (mounted) {
      setState(() {
        _voteCount = updated;
        _loading = false;
        _justSuppressed = suppressed;
        _localVote = type;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_justSuppressed) {
      return _SuppressedBadge();
    }

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
          activeColor: const Color(0xFF92FE9D),
          isSelected: _localVote == VoteType.up,
          onTap: () => _handleVote(VoteType.up),
        ),
        const SizedBox(width: 8),
        _VoteButton(
          icon: Icons.thumb_down_rounded,
          count: _voteCount?.downCount,
          activeColor: const Color(0xFFFC466B),
          isSelected: _localVote == VoteType.down,
          onTap: () => _handleVote(VoteType.down),
          warningThreshold: DatabaseService.suppressThreshold,
        ),
      ],
    );
  }
}

class _SuppressedBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.withOpacity(0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.block, size: 13, color: Colors.redAccent),
          SizedBox(width: 5),
          Text(
            'No volverá a aparecer',
            style: TextStyle(fontSize: 11, color: Colors.redAccent),
          ),
        ],
      ),
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
