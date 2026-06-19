import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/main.dart';

Future<void> pumpSudoku(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const SudokuApp());
}

void main() {
  testWidgets('shows the confirmed Sudoku game shell', (tester) async {
    await pumpSudoku(tester);

    expect(find.text('数独'), findsOneWidget);
    expect(find.text('中等'), findsOneWidget);
    expect(find.text('错误 0/3'), findsOneWidget);
    expect(find.text('候选'), findsOneWidget);
    expect(find.text('选择难度'), findsNothing);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
  });

  testWidgets('opens difficulty sheet and starts a hard game', (tester) async {
    await pumpSudoku(tester);

    await tester.tap(find.byIcon(Icons.add_rounded));
    await tester.pumpAndSettle();

    expect(find.text('选择难度'), findsOneWidget);
    expect(find.text('简单'), findsOneWidget);
    expect(find.text('困难'), findsOneWidget);
    expect(find.text('高难推理'), findsOneWidget);

    await tester.tap(find.text('困难'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始游戏'));
    await tester.pumpAndSettle();

    expect(find.text('困难'), findsOneWidget);
    expect(find.text('选择难度'), findsNothing);
  });

  testWidgets('adds and removes candidate notes in note mode', (tester) async {
    await pumpSudoku(tester);

    await tester.tap(find.byKey(const ValueKey('cell-2')));
    await tester.pump();
    await tester.tap(find.text('候选'));
    await tester.pump();
    await tester.ensureVisible(find.text('4').last);
    await tester.tap(find.text('4').last);
    await tester.pump();

    expect(find.text('4'), findsWidgets);

    await tester.ensureVisible(find.text('4').last);
    await tester.tap(find.text('4').last);
    await tester.pump();

    final noteFourWidgets = tester
        .widgetList<Text>(find.text('4'))
        .where((widget) => widget.style?.fontSize == 9);
    expect(noteFourWidgets, isEmpty);
  });
}
