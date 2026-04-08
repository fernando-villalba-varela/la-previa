import 'league.dart';
import 'custom_question.dart';

class LeagueExportData {
  final League league;
  final List<CustomQuestion> customQuestions;

  LeagueExportData({
    required this.league,
    required this.customQuestions,
  });

  Map<String, dynamic> toJson() => {
    'league': league.toJson(),
    'customQuestions': customQuestions.map((q) => q.toJson()).toList(),
    'exportedAt': DateTime.now().toIso8601String(),
    'version': 1,
  };

  factory LeagueExportData.fromJson(Map<String, dynamic> j) => LeagueExportData(
    league: League.fromJson(j['league']),
    customQuestions: (j['customQuestions'] as List)
        .map((e) => CustomQuestion.fromJson(e))
        .toList(),
  );
}
