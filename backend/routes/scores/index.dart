import 'dart:convert';

import 'package:backend/score_store.dart';
import 'package:dart_frog/dart_frog.dart';

Future<Response> onRequest(RequestContext context) async {
  if (context.request.method == HttpMethod.get) {
    return _get(context);
  }

  if (context.request.method == HttpMethod.post) {
    return await _post(context);
  }

  return Response(statusCode: 405);
}

Response _get(RequestContext context) {
  final scores = context.read<ScoreStore>().topScores;

  return Response.json(
    body: scores.map((score) => score.toJson()).toList(),
  );
}

Future<Response> _post(RequestContext context) async {
  try {
    final body = await context.request.body();
    final data = jsonDecode(body) as Map<String, dynamic>;

    final name = (data['name'] as String?)?.trim();
    final score = data['score'] as int?;

    if (name == null || name.isEmpty || score == null || score < 0) {
      return Response.json(
        statusCode: 400,
        body: {'error': 'Invalid score'},
      );
    }

    final end = name.length > 20 ? 20 : name.length;
    final entry = ScoreEntry(
      name: name.substring(0, end),
      score: score,
    );

    context.read<ScoreStore>().add(entry);

    return Response.json(
      statusCode: 201,
      body: entry.toJson(),
    );
  } on FormatException {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid JSON'},
    );
  } on TypeError {
    return Response.json(
      statusCode: 400,
      body: {'error': 'Invalid score'},
    );
  }
}
