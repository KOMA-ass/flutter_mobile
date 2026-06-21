import 'dart:convert';

import 'package:backend/score_store.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  return switch (context.request.method) {
    HttpMethod.get => _get(context),
    HttpMethod.post => _post(context),
    _ => Response(statusCode: 405),
  };
}

Response _get(RequestContext context) {
  final scores = context.read<ScoreStore>().topScores;
  return Response.json(body: scores.map((score) => score.toJson()).toList());
}

Future<Response> _post(RequestContext context) async {
  try {
    final data = jsonDecode(await context.request.body()) as Map<String, dynamic>;
    final name = (data['name'] as String?)?.trim();
    final score = data['score'] as int?;
    if (name == null || name.isEmpty || score == null || score < 0) {
      return Response.json(statusCode: 400, body: {'error': 'Invalid score'});
    }
    final end = name.length > 20 ? 20 : name.length;
    final entry = ScoreEntry(name: name.substring(0, end), score: score);
    context.read<ScoreStore>().add(entry);
    return Response.json(statusCode: 201, body: entry.toJson());
  } on FormatException {
    return Response.json(statusCode: 400, body: {'error': 'Invalid JSON'});
  } on TypeError {
    return Response.json(statusCode: 400, body: {'error': 'Invalid score'});
  }
}
