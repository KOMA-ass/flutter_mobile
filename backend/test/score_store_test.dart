import 'package:backend/score_store.dart';
import 'package:test/test.dart';

void main() {
  test('returns scores from highest to lowest', () {
    final store = ScoreStore()
      ..add(const ScoreEntry(name: 'One', score: 2))
      ..add(const ScoreEntry(name: 'Two', score: 8));

    expect(store.topScores.map((entry) => entry.score), [8, 2]);
  });
}
