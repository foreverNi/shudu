import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shudu/main.dart';

Future<void> pumpSudoku(WidgetTester tester, {TargetPlatform? platform}) async {
  if (platform != null) {
    debugDefaultTargetPlatformOverride = platform;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
  }
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(const SudokuApp());
}

Future<void> startEasyGame(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.add_rounded));
  await tester.pumpAndSettle();
  await tester.tap(find.text('简单'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('开始游戏'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('shows the optimized Sudoku game shell', (tester) async {
    await pumpSudoku(tester);

    expect(find.text('数独'), findsOneWidget);
    expect(find.text('中等'), findsOneWidget);
    expect(find.text('错误 0/3'), findsOneWidget);
    expect(find.text('候选'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsOneWidget);
    expect(find.text('选择难度'), findsNothing);
    expect(tester.takeException(), isNull);
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

  testWidgets('shows completion feedback when the puzzle is solved', (
    tester,
  ) async {
    await pumpSudoku(tester);
    await startEasyGame(tester);

    await tester.tap(find.byKey(const ValueKey('cell-5')));
    await tester.pump();
    await tester.tap(find.text('8').last);
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('cell-11')));
    await tester.pump();
    await tester.tap(find.text('2').last);
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('cell-40')));
    await tester.pump();
    await tester.tap(find.text('5').last);
    await tester.pumpAndSettle();

    expect(find.text('恭喜完成'), findsOneWidget);
    expect(find.text('已完成'), findsOneWidget);
    expect(find.text('再来一局'), findsOneWidget);
  });

  testWidgets('shows about dialog with version and author', (tester) async {
    await pumpSudoku(tester);

    await tester.tap(find.byIcon(Icons.more_horiz_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('关于'));
    await tester.pumpAndSettle();

    expect(find.text('关于'), findsOneWidget);
    expect(find.text('版本号：$appVersion'), findsOneWidget);
    expect(find.text('作者：Noah.Ni'), findsOneWidget);
  });

  testWidgets('uses iOS controls for the Cupertino game shell', (tester) async {
    await pumpSudoku(tester, platform: TargetPlatform.iOS);

    expect(find.text('数独'), findsOneWidget);
    expect(find.text('中等'), findsOneWidget);
    expect(find.text('新游戏'), findsOneWidget);
    expect(find.text('暂停'), findsOneWidget);
    expect(find.text('更多'), findsOneWidget);
    expect(find.text('时间'), findsOneWidget);
    expect(find.byIcon(Icons.more_horiz_rounded), findsNothing);

    await tester.tap(find.text('新游戏'));
    await tester.pumpAndSettle();

    expect(
      find.byType(CupertinoSlidingSegmentedControl<SudokuDifficulty>),
      findsOneWidget,
    );
    expect(find.text('选择难度'), findsOneWidget);

    await tester.tap(find.text('困难'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('开始游戏'));
    await tester.pumpAndSettle();

    expect(find.text('困难'), findsOneWidget);
    expect(find.text('选择难度'), findsNothing);

    await tester.tap(find.text('更多'));
    await tester.pumpAndSettle();

    expect(find.text('版本号：$appVersion'), findsOneWidget);
    expect(find.text('作者：Noah.Ni'), findsOneWidget);

    debugDefaultTargetPlatformOverride = null;
  });
}
