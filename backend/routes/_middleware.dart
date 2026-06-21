import 'package:backend/score_store.dart';
import 'package:dart_frog/dart_frog.dart';

final _store = ScoreStore();

Handler middleware(Handler handler) {
  return handler.use(requestLogger()).use(provider<ScoreStore>((_) => _store));
}
