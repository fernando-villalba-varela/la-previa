import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/constant_challenge.dart';
import '../../../../core/models/event.dart';
import '../../../../core/services/language_service.dart';

/// Modal que muestra los desafíos y eventos activos
class ActiveChallengesModal extends StatelessWidget {
  final bool isEndlessMode;
  final int endlessModifier;
  final List<ConstantChallenge> activeConstantChallenges;
  final List<Event> activeEvents;
  final int currentRound;

  const ActiveChallengesModal({
    super.key,
    required this.isEndlessMode,
    required this.endlessModifier,
    required this.activeConstantChallenges,
    required this.activeEvents,
    required this.currentRound,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      minChildSize: 0.4,
      maxChildSize: 0.9,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFF2A2A3E),
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(24),
            ),
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
                  Provider.of<LanguageService>(context).translate(
                    'active_challenges_title',
                  ),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    if (isEndlessMode) ...[
                      _buildSectionTitle(
                        context,
                        '🔥 ${Provider.of<LanguageService>(context).translate("endless_mode")}',
                      ),
                      _buildEndlessModeInfo(context),
                      const SizedBox(height: 16),
                    ],
                    _buildSectionTitle(
                      context,
                      Provider.of<LanguageService>(context)
                          .translate('constant_challenges_title'),
                    ),
                    if (activeConstantChallenges.isEmpty)
                      _buildEmptyState(
                        context,
                        Provider.of<LanguageService>(context)
                            .translate('empty_active_challenges'),
                      )
                    else
                      ...activeConstantChallenges
                          .map((c) => _buildActiveChallengeItem(context, c)),
                    const SizedBox(height: 16),
                    _buildSectionTitle(
                      context,
                      Provider.of<LanguageService>(context)
                          .translate('global_events_title'),
                    ),
                    if (activeEvents.isEmpty)
                      _buildEmptyState(
                        context,
                        Provider.of<LanguageService>(context)
                            .translate('empty_active_events'),
                      )
                    else
                      ...activeEvents
                          .map((e) => _buildActiveEventItem(context, e)),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEndlessModeInfo(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.local_fire_department,
            size: 24,
            color: Colors.redAccent,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${Provider.of<LanguageService>(context).translate('level')} $endlessModifier',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '+$endlessModifier ${Provider.of<LanguageService>(context).translate('drinks_per_endless')}',
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
          letterSpacing: 1,
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.center,
      child: Text(
        message,
        style: TextStyle(
          color: Colors.white.withOpacity(0.5),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildActiveChallengeItem(
    BuildContext context,
    ConstantChallenge challenge,
  ) {
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
                  Provider.of<LanguageService>(context)
                      .translate('for_player')
                      .replaceAll('{name}', challenge.targetPlayer.nombre),
                  style: const TextStyle(
                    color: Color(0xFF00FFFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  challenge.description,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  challenge.getDurationDescription(currentRound),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveEventItem(BuildContext context, Event event) {
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
                Text(
                  event.title,
                  style: const TextStyle(
                    color: Color(0xFF00FFFF),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  event.description,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  event.getDurationDescription(currentRound),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Diálogo para el checkpoint de modo endless (ronda 100)
class EndlessModeCheckpointDialog extends StatelessWidget {
  final VoidCallback onContinue;
  final VoidCallback onEnd;

  const EndlessModeCheckpointDialog({
    super.key,
    required this.onContinue,
    required this.onEnd,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2A2A3E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      title: Text(
        Provider.of<LanguageService>(context, listen: false)
            .translate('round_100_title'),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        Provider.of<LanguageService>(context, listen: false)
            .translate('round_100_content'),
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: onEnd,
          child: Text(
            Provider.of<LanguageService>(context, listen: false)
                .translate('end_here'),
            style: const TextStyle(color: Colors.redAccent),
          ),
        ),
        ElevatedButton(
          onPressed: onContinue,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00C9FF),
            foregroundColor: Colors.white,
          ),
          child: Text(
            Provider.of<LanguageService>(context, listen: false)
                .translate('continue'),
          ),
        ),
      ],
    );
  }
}
