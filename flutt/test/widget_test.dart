import 'package:flutter_test/flutter_test.dart';
import 'package:lava_jump/main.dart';

void main() {
  testWidgets('game starts and counts the first jump', (tester) async {
    await tester.pumpWidget(const LavaJumpApp());
    await tester.pump();

    expect(find.text('LAVA JUMP'), findsOneWidget);
    await tester.tap(find.text('LAVA JUMP'));
    await tester.pump();

    expect(find.textContaining('1   ЛУЧШИЙ:'), findsOneWidget);
  });
}
