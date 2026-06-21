class ScoreEntry {
  const ScoreEntry({required this.name, required this.score});

  final String name;
  final int score;

  Map<String, Object> toJson() => {'name': name, 'score': score};
}

class ScoreStore {
  final List<ScoreEntry> _scores = [];

  List<ScoreEntry> get topScores {
    final result = List<ScoreEntry>.of(_scores)
      ..sort((a, b) => b.score.compareTo(a.score));
    return result.take(10).toList(growable: false);
  }

  void add(ScoreEntry entry) => _scores.add(entry);
}
