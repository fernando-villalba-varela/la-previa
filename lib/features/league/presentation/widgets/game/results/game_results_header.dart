import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../core/services/language_service.dart';

class GameResultsHeader extends StatelessWidget {
  final double padding;
  final double iconSize;
  final double titleFontSize;

  const GameResultsHeader({
    super.key,
    this.padding = 24.0,
    this.iconSize = 32.0,
    this.titleFontSize = 24.0,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(padding),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00E5FF), Color(0xFF0088CC)],
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.emoji_events, color: Colors.white, size: iconSize),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              Provider.of<LanguageService>(context).translate('game_over_title'),
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: titleFontSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
