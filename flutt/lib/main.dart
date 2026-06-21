import 'package:flutter/material.dart';

import 'game/lava_jump_game.dart';

void main() {
  runApp(const LavaJumpApp());
}

class LavaJumpApp extends StatelessWidget {
  const LavaJumpApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lava Jump',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFFFCA3A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const LavaJumpGame(),
    );
  }
}
