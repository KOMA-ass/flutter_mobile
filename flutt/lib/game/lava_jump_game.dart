import 'dart:math';

import 'package:flutter/material.dart';

class LavaJumpGame extends StatefulWidget {
  const LavaJumpGame({super.key});

  @override
  State<LavaJumpGame> createState() => _LavaJumpGameState();
}

class _LavaJumpGameState extends State<LavaJumpGame>
    with SingleTickerProviderStateMixin {
  late final AnimationController _clock;
  final Random _random = Random(7);
  final List<Spike> _spikes = [];

  Size _size = Size.zero;
  Offset _player = Offset.zero;
  Offset _velocity = Offset.zero;
  double _lavaY = 0;
  double _lastTime = 0;
  int _score = 0;
  int _bestScore = 0;
  bool _started = false;
  bool _gameOver = false;
  bool _onLeftWall = true;
  bool _onRightWall = false;
  bool _airTurnAvailable = false;

  static const double _wallWidth = 34;
  static const double _playerRadius = 13;

  @override
  void initState() {
    super.initState();
    _clock = AnimationController.unbounded(vsync: this)
      ..addListener(_tick)
      ..repeat(
        min: 0,
        max: 100000,
        period: const Duration(seconds: 100000),
      );
  }

  @override
  void dispose() {
    _clock.dispose();
    super.dispose();
  }

  void _reset(Size size) {
    _size = size;
    _player = Offset(_wallWidth + _playerRadius, size.height * 0.57);
    _velocity = Offset.zero;
    _lavaY = size.height * 0.9;
    _score = 0;
    _started = false;
    _gameOver = false;
    _onLeftWall = true;
    _onRightWall = false;
    _airTurnAvailable = false;
    _lastTime = _clock.value;
    _spikes
      ..clear()
      ..addAll(_makeSpikes(size));
  }

  List<Spike> _makeSpikes(Size size) {
    return List.generate(9, (index) {
      final side = index.isEven ? WallSide.right : WallSide.left;
      return Spike(
        side: side,
        y: size.height - 210 - index * 125,
        height: 34 + _random.nextDouble() * 16,
      );
    });
  }

  void _tap() {
    if (_size == Size.zero) return;
    if (_gameOver) {
      setState(() => _reset(_size));
      return;
    }

    if (!_started) _started = true;
    if (_onLeftWall) {
      _velocity = const Offset(265, -450);
      _onLeftWall = false;
      _airTurnAvailable = true;
    } else if (_onRightWall) {
      _velocity = const Offset(-265, -450);
      _onRightWall = false;
      _airTurnAvailable = true;
    } else if (_airTurnAvailable) {
      final direction = _velocity.dx >= 0 ? -1.0 : 1.0;
      _velocity = Offset(245 * direction, min(_velocity.dy, -300));
      _airTurnAvailable = false;
    } else {
      return;
    }
    _score++;
    setState(() {});
  }

  void _tick() {
    if (!mounted || _size == Size.zero) return;
    final now = _clock.value;
    final dt = (now - _lastTime).clamp(0.0, 0.032).toDouble();
    _lastTime = now;
    if (!_started || _gameOver || dt == 0) return;

    const gravity = 980.0;
    _velocity = Offset(_velocity.dx, _velocity.dy + gravity * dt);
    _player += _velocity * dt;
    final lavaSpeed = (18 + _score * 0.12).clamp(18, 38).toDouble();
    _lavaY -= lavaSpeed * dt;

    _resolveWalls();
    _moveCamera();
    _recycleSpikes();

    if (_hitsSpike() || _player.dy + _playerRadius >= _lavaY) {
      _gameOver = true;
      _bestScore = max(_bestScore, _score);
      _velocity = Offset.zero;
    }
    setState(() {});
  }

  void _resolveWalls() {
    final left = _wallWidth + _playerRadius;
    final right = _size.width - _wallWidth - _playerRadius;
    if (_player.dx <= left) {
      _player = Offset(left, _player.dy);
      _velocity = Offset(0, min(_velocity.dy, 125));
      _onLeftWall = true;
      _onRightWall = false;
      _airTurnAvailable = false;
    } else if (_player.dx >= right) {
      _player = Offset(right, _player.dy);
      _velocity = Offset(0, min(_velocity.dy, 125));
      _onRightWall = true;
      _onLeftWall = false;
      _airTurnAvailable = false;
    }
  }

  void _moveCamera() {
    final cameraLine = _size.height * 0.34;
    if (_player.dy >= cameraLine) return;
    final shift = cameraLine - _player.dy;
    _player = Offset(_player.dx, cameraLine);
    _lavaY += shift;
    for (final spike in _spikes) {
      spike.y += shift;
    }
  }

  void _recycleSpikes() {
    final top = _spikes.map((spike) => spike.y).reduce(min);
    for (final spike in _spikes) {
      if (spike.y > _size.height + 70) {
        spike
          ..y = top - 110 - _random.nextDouble() * 80
          ..side = _random.nextBool() ? WallSide.left : WallSide.right
          ..height = 34 + _random.nextDouble() * 16;
      }
    }
  }

  bool _hitsSpike() {
    final playerRect = Rect.fromCircle(center: _player, radius: _playerRadius - 2);
    for (final spike in _spikes) {
      final width = spike.height;
      final rect = spike.side == WallSide.left
          ? Rect.fromLTWH(_wallWidth - 2, spike.y, width, 30)
          : Rect.fromLTWH(
              _size.width - _wallWidth - width + 2,
              spike.y,
              width,
              30,
            );
      if (playerRect.overlaps(rect)) return true;
    }
    return _player.dy > _size.height + _playerRadius;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final size = Size(constraints.maxWidth, constraints.maxHeight);
          if (_size != size && size.width > 0 && size.height > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _reset(size));
            });
          }
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _tap,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CustomPaint(
                  painter: GamePainter(
                    player: _player,
                    lavaY: _lavaY,
                    spikes: _spikes,
                    wallWidth: _wallWidth,
                    playerRadius: _playerRadius,
                  ),
                ),
                SafeArea(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: ScoreBoard(score: _score, best: _bestScore),
                  ),
                ),
                if (!_started && !_gameOver)
                  const GameMessage(
                    title: 'LAVA JUMP',
                    subtitle: 'Коснись экрана, чтобы прыгнуть',
                  ),
                if (_gameOver)
                  GameMessage(
                    title: 'ИГРА ОКОНЧЕНА',
                    subtitle:
                        'Счёт: $_score\nКоснись, чтобы начать заново',
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

enum WallSide { left, right }

class Spike {
  Spike({required this.side, required this.y, required this.height});

  WallSide side;
  double y;
  double height;
}

class ScoreBoard extends StatelessWidget {
  const ScoreBoard({required this.score, required this.best, super.key});

  final int score;
  final int best;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 9),
      decoration: BoxDecoration(
        color: const Color(0xCC121824),
        border: Border.all(color: const Color(0x66FFFFFF)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$score   ЛУЧШИЙ: $best',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
    );
  }
}

class GameMessage extends StatelessWidget {
  const GameMessage({required this.title, required this.subtitle, super.key});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 42),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: const Color(0xE6181E2B),
          border: Border.all(color: const Color(0xFFFFCA3A), width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFFFFCA3A),
                fontSize: 27,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(subtitle, textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

class GamePainter extends CustomPainter {
  GamePainter({
    required this.player,
    required this.lavaY,
    required this.spikes,
    required this.wallWidth,
    required this.playerRadius,
  });

  final Offset player;
  final double lavaY;
  final List<Spike> spikes;
  final double wallWidth;
  final double playerRadius;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = const Color(0xFF101620));
    _paintBackground(canvas, size);
    final wallPaint = Paint()..color = const Color(0xFF394457);
    canvas.drawRect(Rect.fromLTWH(0, 0, wallWidth, size.height), wallPaint);
    canvas.drawRect(
      Rect.fromLTWH(size.width - wallWidth, 0, wallWidth, size.height),
      wallPaint,
    );
    _paintSpikes(canvas, size);
    _paintLava(canvas, size);
    _paintStickman(canvas);
  }

  void _paintBackground(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0x1817C3B2)
      ..strokeWidth = 1;
    for (double y = 0; y < size.height; y += 64) {
      canvas.drawLine(Offset(wallWidth, y), Offset(size.width - wallWidth, y), paint);
    }
  }

  void _paintSpikes(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFFE8EDF4);
    for (final spike in spikes) {
      final path = Path();
      if (spike.side == WallSide.left) {
        path
          ..moveTo(wallWidth - 1, spike.y)
          ..lineTo(wallWidth + spike.height, spike.y + 15)
          ..lineTo(wallWidth - 1, spike.y + 30);
      } else {
        path
          ..moveTo(size.width - wallWidth + 1, spike.y)
          ..lineTo(size.width - wallWidth - spike.height, spike.y + 15)
          ..lineTo(size.width - wallWidth + 1, spike.y + 30);
      }
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _paintLava(Canvas canvas, Size size) {
    final lavaPaint = Paint()..color = const Color(0xFFFF3B30);
    final glowPaint = Paint()..color = const Color(0xFFFFCA3A);
    final wave = Path()..moveTo(0, lavaY);
    for (double x = 0; x <= size.width; x += 20) {
      wave.lineTo(x, lavaY + sin(x / 20) * 6);
    }
    wave
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
    canvas.drawPath(wave, lavaPaint);
    canvas.drawLine(
      Offset(0, lavaY),
      Offset(size.width, lavaY),
      glowPaint..strokeWidth = 4,
    );
  }

  void _paintStickman(Canvas canvas) {
    final paint = Paint()
      ..color = const Color(0xFFFFCA3A)
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    canvas.drawCircle(player - const Offset(0, 8), 6, paint);
    canvas.drawLine(player - const Offset(0, 2), player + const Offset(0, 10), paint);
    canvas.drawLine(player, player + const Offset(-8, 5), paint);
    canvas.drawLine(player, player + const Offset(8, 5), paint);
    canvas.drawLine(player + const Offset(0, 10), player + const Offset(-7, 18), paint);
    canvas.drawLine(player + const Offset(0, 10), player + const Offset(7, 18), paint);
  }

  @override
  bool shouldRepaint(covariant GamePainter oldDelegate) => true;
}
