import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../../core/models/constant_challenge.dart';
import '../../../../../../../core/models/event.dart';
import '../../../../../../../core/services/language_service.dart';

class ChallengesModalContent extends StatelessWidget {
  final List<ConstantChallenge> constantChallenges;
  final List<Event> events;
  final int currentRound;
  final ScrollController scrollController;

  const ChallengesModalContent({
    super.key,
    required this.constantChallenges,
    required this.events,
    required this.currentRound,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.read<LanguageService>();
    final activeChallenges =
        constantChallenges.where((c) => c.status == ConstantChallengeStatus.active).toList();
    final activeEvents =
        events.where((e) => e.status == EventStatus.active).toList();

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A3E),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Text(
              lang.translate('active_challenges_title'),
              style: const TextStyle(
                  color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _sectionTitle(lang.translate('constant_challenges_title')),
                if (activeChallenges.isEmpty)
                  _emptyState(lang.translate('empty_active_challenges'))
                else
                  ...activeChallenges.map((c) => _challengeItem(c)),
                _sectionTitle(lang.translate('global_events_title')),
                if (activeEvents.isEmpty)
                  _emptyState(lang.translate('empty_active_events'))
                else
                  ...activeEvents.map((e) => _eventItem(e)),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 1),
      ),
    );
  }

  Widget _emptyState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(
            color: Colors.white.withOpacity(0.5), fontStyle: FontStyle.italic),
      ),
    );
  }

  Widget _challengeItem(ConstantChallenge challenge) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(challenge.typeIcon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Para: ${challenge.targetPlayer.nombre}',
                  style: const TextStyle(
                      color: Color(0xFF00C9FF), fontWeight: FontWeight.bold),
                ),
                Text(challenge.description,
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  challenge.getDurationDescription(currentRound),
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _eventItem(Event event) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Text(event.typeIcon, style: const TextStyle(fontSize: 24)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title,
                    style: const TextStyle(
                        color: Color(0xFF92FE9D),
                        fontWeight: FontWeight.bold)),
                Text(event.description,
                    style: const TextStyle(color: Colors.white)),
                const SizedBox(height: 4),
                Text(
                  event.getDurationDescription(currentRound),
                  style: TextStyle(
                      color: Colors.white.withOpacity(0.5), fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
