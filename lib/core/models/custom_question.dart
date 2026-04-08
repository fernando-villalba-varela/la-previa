class CustomQuestion {
  final String id;
  final String text;
  final int drinks;
  final int? timerSeconds;
  final String? leagueId;
  final bool isActive;

  const CustomQuestion({
    required this.id,
    required this.text,
    required this.drinks,
    this.timerSeconds,
    this.leagueId,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'text': text,
    'drinks': drinks,
    'timer_seconds': timerSeconds,
    'league_id': leagueId,
    'is_active': isActive ? 1 : 0,
  };

  factory CustomQuestion.fromJson(Map<String, dynamic> j) => CustomQuestion(
    id: j['id'],
    text: j['text'],
    drinks: j['drinks'],
    timerSeconds: j['timer_seconds'],
    leagueId: j['league_id'],
    isActive: (j['is_active'] ?? 1) == 1,
  );

  factory CustomQuestion.fromRow(Map<String, dynamic> row) => CustomQuestion(
    id: row['id'] as String,
    text: row['text'] as String,
    drinks: row['drinks'] as int,
    timerSeconds: row['timer_seconds'] as int?,
    leagueId: row['league_id'] as String?,
    isActive: (row['is_active'] as int? ?? 1) == 1,
  );
}
