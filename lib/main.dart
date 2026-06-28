import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const SudokuApp());
}

const String appVersion = '1.0.3';
const String appAuthor = 'Noah.Ni';

enum SudokuDifficulty {
  easy('简单', '适合练习'),
  medium('中等', '标准挑战'),
  hard('困难', '高难推理');

  const SudokuDifficulty(this.label, this.description);

  final String label;
  final String description;
}

class SudokuPuzzle {
  const SudokuPuzzle({required this.givens, required this.solution});

  final List<int> givens;
  final List<int> solution;
}

class SudokuCell {
  SudokuCell({required this.value, required this.fixed, Set<int>? notes})
    : notes = notes ?? <int>{};

  final bool fixed;
  int value;
  Set<int> notes;

  SudokuCell copy() {
    return SudokuCell(value: value, fixed: fixed, notes: Set<int>.from(notes));
  }
}

class BoardSnapshot {
  const BoardSnapshot({
    required this.cells,
    required this.mistakes,
    required this.selectedIndex,
    required this.solved,
  });

  final List<SudokuCell> cells;
  final int mistakes;
  final int selectedIndex;
  final bool solved;
}

const List<int> _solution = [
  5,
  3,
  4,
  6,
  7,
  8,
  9,
  1,
  2,
  6,
  7,
  2,
  1,
  9,
  5,
  3,
  4,
  8,
  1,
  9,
  8,
  3,
  4,
  2,
  5,
  6,
  7,
  8,
  5,
  9,
  7,
  6,
  1,
  4,
  2,
  3,
  4,
  2,
  6,
  8,
  5,
  3,
  7,
  9,
  1,
  7,
  1,
  3,
  9,
  2,
  4,
  8,
  5,
  6,
  9,
  6,
  1,
  5,
  3,
  7,
  2,
  8,
  4,
  2,
  8,
  7,
  4,
  1,
  9,
  6,
  3,
  5,
  3,
  4,
  5,
  2,
  8,
  6,
  1,
  7,
  9,
];

const Map<SudokuDifficulty, SudokuPuzzle> puzzles = {
  SudokuDifficulty.easy: SudokuPuzzle(
    givens: [
      5,
      3,
      4,
      6,
      7,
      0,
      9,
      1,
      2,
      6,
      7,
      0,
      1,
      9,
      5,
      3,
      4,
      8,
      1,
      9,
      8,
      3,
      4,
      2,
      5,
      6,
      7,
      8,
      5,
      9,
      7,
      6,
      1,
      4,
      2,
      3,
      4,
      2,
      6,
      8,
      0,
      3,
      7,
      9,
      1,
      7,
      1,
      3,
      9,
      2,
      4,
      8,
      5,
      6,
      9,
      6,
      1,
      5,
      3,
      7,
      2,
      8,
      4,
      2,
      8,
      7,
      4,
      1,
      9,
      6,
      3,
      5,
      3,
      4,
      5,
      2,
      8,
      6,
      1,
      7,
      9,
    ],
    solution: _solution,
  ),
  SudokuDifficulty.medium: SudokuPuzzle(
    givens: [
      5,
      3,
      0,
      0,
      7,
      0,
      0,
      0,
      0,
      6,
      0,
      0,
      1,
      9,
      5,
      0,
      0,
      0,
      0,
      9,
      8,
      0,
      0,
      0,
      0,
      6,
      0,
      8,
      0,
      0,
      0,
      6,
      0,
      0,
      0,
      3,
      4,
      0,
      0,
      8,
      0,
      3,
      0,
      0,
      1,
      7,
      0,
      0,
      0,
      2,
      0,
      0,
      0,
      6,
      0,
      6,
      0,
      0,
      0,
      0,
      2,
      8,
      0,
      0,
      0,
      0,
      4,
      1,
      9,
      0,
      0,
      5,
      0,
      0,
      0,
      0,
      8,
      0,
      0,
      7,
      9,
    ],
    solution: _solution,
  ),
  SudokuDifficulty.hard: SudokuPuzzle(
    givens: [
      0,
      0,
      0,
      0,
      7,
      0,
      0,
      1,
      0,
      6,
      0,
      0,
      1,
      0,
      0,
      0,
      0,
      8,
      0,
      9,
      0,
      0,
      0,
      2,
      0,
      0,
      0,
      8,
      0,
      0,
      0,
      6,
      0,
      0,
      0,
      3,
      0,
      0,
      6,
      0,
      0,
      0,
      7,
      0,
      0,
      7,
      0,
      0,
      0,
      2,
      0,
      0,
      0,
      6,
      0,
      0,
      0,
      5,
      0,
      0,
      0,
      8,
      0,
      2,
      0,
      0,
      0,
      0,
      9,
      0,
      0,
      5,
      0,
      4,
      0,
      0,
      8,
      0,
      0,
      0,
      0,
    ],
    solution: _solution,
  ),
};

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return const CupertinoApp(
        debugShowCheckedModeBanner: false,
        title: '数独',
        theme: CupertinoThemeData(
          brightness: Brightness.light,
          primaryColor: CupertinoColors.systemBlue,
          scaffoldBackgroundColor: Color(0xFFF2F2F7),
          textTheme: CupertinoTextThemeData(
            textStyle: TextStyle(
              color: CupertinoColors.label,
              decoration: TextDecoration.none,
            ),
          ),
        ),
        home: SudokuPage(),
      );
    }
    const accent = Color(0xFF2F6BFF);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: '数独',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.light,
          surface: const Color(0xFFFFFCF8),
        ),
        scaffoldBackgroundColor: const Color(0xFFFFFCF8),
        fontFamilyFallback: const ['Noto Sans CJK SC', 'Microsoft YaHei'],
      ),
      home: const SudokuPage(),
    );
  }
}

class SudokuPage extends StatefulWidget {
  const SudokuPage({super.key});

  @override
  State<SudokuPage> createState() => _SudokuPageState();
}

class _SudokuPageState extends State<SudokuPage> {
  static const _accent = Color(0xFF2F6BFF);
  static const _iosBlue = CupertinoColors.systemBlue;
  static const _iosBackground = Color(0xFFF2F2F7);
  static const _iosSeparator = Color(0xFFD1D1D6);
  static const _success = Color(0xFFE6F5EC);
  static const _relation = Color(0xFFEFF5FF);
  static const _selected = Color(0xFFDDE8FF);
  static const _surface = Color(0xFFFFFCF8);
  static const _ink = Color(0xFF1D2530);

  SudokuDifficulty _difficulty = SudokuDifficulty.medium;
  late List<SudokuCell> _cells;
  late List<int> _solutionValues;
  final List<BoardSnapshot> _history = [];
  int _selectedIndex = 40;
  int _mistakes = 0;
  int _seconds = 0;
  bool _noteMode = false;
  bool _paused = false;
  bool _solved = false;
  Timer? _timer;

  bool get _isIosStyle => defaultTargetPlatform == TargetPlatform.iOS;

  @override
  void initState() {
    super.initState();
    _loadPuzzle(_difficulty);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && !_solved && mounted) {
        setState(() => _seconds++);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadPuzzle(SudokuDifficulty difficulty) {
    final puzzle = puzzles[difficulty]!;
    _difficulty = difficulty;
    _solutionValues = puzzle.solution;
    _cells = [
      for (final value in puzzle.givens)
        SudokuCell(value: value, fixed: value != 0),
    ];
    _selectedIndex = puzzle.givens.indexWhere((value) => value == 0);
    if (_selectedIndex == -1) {
      _selectedIndex = 0;
    }
    _mistakes = 0;
    _seconds = 0;
    _history.clear();
    _noteMode = false;
    _paused = false;
    _solved = false;
  }

  void _saveHistory() {
    _history.add(
      BoardSnapshot(
        cells: _cells.map((cell) => cell.copy()).toList(),
        mistakes: _mistakes,
        selectedIndex: _selectedIndex,
        solved: _solved,
      ),
    );
    if (_history.length > 80) {
      _history.removeAt(0);
    }
  }

  void _selectCell(int index) {
    setState(() => _selectedIndex = index);
  }

  void _handleNumber(int number) {
    final cell = _cells[_selectedIndex];
    if (cell.fixed || _solved) {
      return;
    }
    _saveHistory();
    setState(() {
      if (_noteMode) {
        if (cell.value == 0) {
          cell.notes.contains(number)
              ? cell.notes.remove(number)
              : cell.notes.add(number);
        }
        return;
      }
      cell.notes.clear();
      cell.value = number;
      if (_solutionValues[_selectedIndex] != number) {
        _mistakes = (_mistakes + 1).clamp(0, 3);
      }
    });
    if (!_noteMode) {
      _maybeShowCompletionDialog();
    }
  }

  void _eraseSelected() {
    final cell = _cells[_selectedIndex];
    if (cell.fixed || _solved) {
      return;
    }
    _saveHistory();
    setState(() {
      cell.value = 0;
      cell.notes.clear();
    });
  }

  void _undo() {
    if (_history.isEmpty) {
      return;
    }
    final snapshot = _history.removeLast();
    setState(() {
      _cells = snapshot.cells.map((cell) => cell.copy()).toList();
      _mistakes = snapshot.mistakes;
      _selectedIndex = snapshot.selectedIndex;
      _solved = snapshot.solved;
    });
  }

  void _hint() {
    final cell = _cells[_selectedIndex];
    if (cell.fixed || _solved) {
      return;
    }
    _saveHistory();
    setState(() {
      cell.value = _solutionValues[_selectedIndex];
      cell.notes.clear();
    });
    _maybeShowCompletionDialog();
  }

  bool get _isSolved {
    for (var index = 0; index < _cells.length; index++) {
      if (_cells[index].value != _solutionValues[index]) {
        return false;
      }
    }
    return true;
  }

  void _maybeShowCompletionDialog() {
    if (_solved || !_isSolved) {
      return;
    }
    setState(() => _solved = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      if (_isIosStyle) {
        showCupertinoDialog<void>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return CupertinoAlertDialog(
              title: const Text('恭喜完成'),
              content: Text(
                '你已正确完成${_difficulty.label}数独。\n用时 $_timeLabel，错误 $_mistakes/3。',
              ),
              actions: [
                CupertinoDialogAction(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('继续查看'),
                ),
                CupertinoDialogAction(
                  isDefaultAction: true,
                  onPressed: () {
                    Navigator.of(context).pop();
                    _showDifficultySheet();
                  },
                  child: const Text('再来一局'),
                ),
              ],
            );
          },
        );
        return;
      }
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return AlertDialog(
            title: const Text('恭喜完成'),
            content: Text(
              '你已正确完成${_difficulty.label}数独。\n用时 $_timeLabel，错误 $_mistakes/3。',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('继续查看'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _showDifficultySheet();
                },
                child: const Text('再来一局'),
              ),
            ],
          );
        },
      );
    });
  }

  bool _isCompletedUnit(List<int> indexes) {
    final values = indexes.map((index) => _cells[index].value).toList();
    if (values.any((value) => value == 0)) {
      return false;
    }
    return values.toSet().length == 9;
  }

  bool _isCompletedRow(int row) {
    return _isCompletedUnit([for (var col = 0; col < 9; col++) row * 9 + col]);
  }

  bool _isCompletedColumn(int col) {
    return _isCompletedUnit([for (var row = 0; row < 9; row++) row * 9 + col]);
  }

  bool _isCompletedBox(int row, int col) {
    final boxRow = row ~/ 3 * 3;
    final boxCol = col ~/ 3 * 3;
    return _isCompletedUnit([
      for (var r = boxRow; r < boxRow + 3; r++)
        for (var c = boxCol; c < boxCol + 3; c++) r * 9 + c,
    ]);
  }

  bool _isRelated(int index) {
    final selectedRow = _selectedIndex ~/ 9;
    final selectedCol = _selectedIndex % 9;
    final row = index ~/ 9;
    final col = index % 9;
    return row == selectedRow ||
        col == selectedCol ||
        (row ~/ 3 == selectedRow ~/ 3 && col ~/ 3 == selectedCol ~/ 3);
  }

  void _showDifficultySheet() {
    if (_isIosStyle) {
      showCupertinoModalPopup<void>(
        context: context,
        builder: (context) {
          var selected = _difficulty;
          return StatefulBuilder(
            builder: (context, setSheetState) {
              return CupertinoPopupSurface(
                isSurfacePainted: true,
                child: SafeArea(
                  top: false,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Container(
                            width: 38,
                            height: 5,
                            decoration: BoxDecoration(
                              color: const Color(0x33000000),
                              borderRadius: BorderRadius.circular(999),
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Text(
                          '选择难度',
                          style: TextStyle(
                            color: CupertinoColors.label,
                            fontSize: 21,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 16),
                        CupertinoSlidingSegmentedControl<SudokuDifficulty>(
                          groupValue: selected,
                          thumbColor: CupertinoColors.white,
                          backgroundColor: CupertinoColors.systemGrey5,
                          children: {
                            for (final difficulty in SudokuDifficulty.values)
                              difficulty: Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 8,
                                ),
                                child: Text(difficulty.label),
                              ),
                          },
                          onValueChanged: (value) {
                            if (value != null) {
                              setSheetState(() => selected = value);
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          selected.description,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: CupertinoColors.secondaryLabel,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 18),
                        CupertinoButton.filled(
                          borderRadius: BorderRadius.circular(12),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() => _loadPuzzle(selected));
                          },
                          child: const Text(
                            '开始游戏',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        const SizedBox(height: 8),
                        CupertinoButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: const Text('取消'),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      );
      return;
    }
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        var selected = _difficulty;
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(context).height * 0.86,
              ),
              child: Container(
                decoration: const BoxDecoration(
                  color: _surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0x22000000),
                      blurRadius: 28,
                      offset: Offset(0, -8),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    20,
                    14,
                    20,
                    20 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 36,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE1E5EC),
                            borderRadius: BorderRadius.circular(999),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      const Text(
                        '选择难度',
                        style: TextStyle(
                          color: _ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 14),
                      for (final difficulty in SudokuDifficulty.values) ...[
                        _DifficultyOption(
                          difficulty: difficulty,
                          selected: selected == difficulty,
                          onTap: () =>
                              setSheetState(() => selected = difficulty),
                        ),
                        const SizedBox(height: 10),
                      ],
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: _accent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            setState(() => _loadPuzzle(selected));
                          },
                          child: const Text(
                            '开始游戏',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAboutDialog() {
    if (_isIosStyle) {
      showCupertinoDialog<void>(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: const Text('关于'),
            content: const Column(
              children: [
                SizedBox(height: 8),
                Text('数独'),
                SizedBox(height: 8),
                Text('版本号：$appVersion'),
                SizedBox(height: 4),
                Text('作者：$appAuthor'),
              ],
            ),
            actions: [
              CupertinoDialogAction(
                isDefaultAction: true,
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('关闭'),
              ),
            ],
          );
        },
      );
      return;
    }
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('关于'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('数独'),
              SizedBox(height: 10),
              Text('版本号：$appVersion'),
              SizedBox(height: 6),
              Text('作者：$appAuthor'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('关闭'),
            ),
          ],
        );
      },
    );
  }

  String get _timeLabel {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    if (_isIosStyle) {
      return _buildIosLayout(context);
    }
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 360 ? 12.0 : 16.0;
            final availableWidth = constraints.maxWidth - horizontalPadding * 2;
            final availableHeight = constraints.maxHeight - 20;
            final boardSize = math
                .min(availableWidth, availableHeight * 0.52)
                .clamp(292.0, 420.0);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                6,
                horizontalPadding,
                14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _TopBar(
                    difficultyLabel: _difficulty.label,
                    timeLabel: _timeLabel,
                    mistakesLabel: '错误 $_mistakes/3',
                    solved: _solved,
                    paused: _paused,
                    onNewGame: _showDifficultySheet,
                    onAbout: _showAboutDialog,
                    onPause: () => setState(() => _paused = !_paused),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: SizedBox.square(
                      dimension: boardSize,
                      child: _SudokuBoard(
                        cells: _cells,
                        selectedIndex: _selectedIndex,
                        isRelated: _isRelated,
                        isCompletedRow: _isCompletedRow,
                        isCompletedColumn: _isCompletedColumn,
                        isCompletedBox: _isCompletedBox,
                        onCellTap: _selectCell,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _ActionToolbar(
                    noteMode: _noteMode,
                    onUndo: _undo,
                    onErase: _eraseSelected,
                    onHint: _hint,
                    onNoteMode: () => setState(() => _noteMode = !_noteMode),
                  ),
                  const SizedBox(height: 10),
                  _NumberPad(onNumber: _handleNumber),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIosLayout(BuildContext context) {
    return CupertinoPageScaffold(
      backgroundColor: _iosBackground,
      navigationBar: CupertinoNavigationBar(
        leading: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: _showDifficultySheet,
          child: const Text(
            '新游戏',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
        ),
        middle: const Text('数独'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CupertinoButton(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              onPressed: () => setState(() => _paused = !_paused),
              child: Text(
                _paused ? '继续' : '暂停',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
            CupertinoButton(
              padding: const EdgeInsets.only(left: 8),
              onPressed: _showAboutDialog,
              child: const Text(
                '更多',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final horizontalPadding = constraints.maxWidth < 360 ? 12.0 : 18.0;
            final availableWidth = constraints.maxWidth - horizontalPadding * 2;
            final boardSize = math
                .min(availableWidth - 16, constraints.maxHeight * 0.44)
                .clamp(292.0, 384.0);

            return SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                10,
                horizontalPadding,
                18,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _IosStatusHeader(
                    difficultyLabel: _difficulty.label,
                    timeLabel: _timeLabel,
                    mistakesLabel: '错误 $_mistakes/3',
                    solved: _solved,
                    paused: _paused,
                    onPause: () => setState(() => _paused = !_paused),
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: SizedBox.square(
                      dimension: boardSize,
                      child: _SudokuBoard(
                        cells: _cells,
                        selectedIndex: _selectedIndex,
                        isRelated: _isRelated,
                        isCompletedRow: _isCompletedRow,
                        isCompletedColumn: _isCompletedColumn,
                        isCompletedBox: _isCompletedBox,
                        onCellTap: _selectCell,
                        iosStyle: true,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  _IosActionToolbar(
                    noteMode: _noteMode,
                    onUndo: _undo,
                    onErase: _eraseSelected,
                    onHint: _hint,
                    onNoteMode: () => setState(() => _noteMode = !_noteMode),
                  ),
                  const SizedBox(height: 12),
                  _IosNumberPad(
                    selectedNumber: _cells[_selectedIndex].value == 0
                        ? null
                        : _cells[_selectedIndex].value,
                    onNumber: _handleNumber,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _IosStatusHeader extends StatelessWidget {
  const _IosStatusHeader({
    required this.difficultyLabel,
    required this.timeLabel,
    required this.mistakesLabel,
    required this.solved,
    required this.paused,
    required this.onPause,
  });

  final String difficultyLabel;
  final String timeLabel;
  final String mistakesLabel;
  final bool solved;
  final bool paused;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Text(
                solved ? '已完成' : difficultyLabel,
                style: const TextStyle(
                  color: CupertinoColors.label,
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            _IosMetric(labelPrefix: '时间', label: timeLabel),
            const SizedBox(width: 7),
            _IosMetric(
              labelPrefix: '错误',
              label: mistakesLabel.replaceFirst('错误 ', ''),
            ),
            const SizedBox(width: 7),
            _IosStatusButton(
              label: paused ? '继续' : '进行中',
              emphasized: paused,
              onTap: onPause,
            ),
          ],
        ),
      ),
    );
  }
}

class _IosMetric extends StatelessWidget {
  const _IosMetric({required this.labelPrefix, required this.label});

  final String labelPrefix;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 8),
      decoration: BoxDecoration(
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            labelPrefix,
            style: const TextStyle(
              color: CupertinoColors.secondaryLabel,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF7C8595),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _IosStatusButton extends StatelessWidget {
  const _IosStatusButton({
    required this.label,
    required this.emphasized,
    required this.onTap,
  });

  final String label;
  final bool emphasized;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minimumSize: const Size(66, 42),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: emphasized ? _SudokuPageState._iosBlue : null,
      borderRadius: BorderRadius.circular(14),
      onPressed: onTap,
      child: Text(
        label,
        style: TextStyle(
          color: emphasized ? CupertinoColors.white : _SudokuPageState._iosBlue,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _IosActionToolbar extends StatelessWidget {
  const _IosActionToolbar({
    required this.noteMode,
    required this.onUndo,
    required this.onErase,
    required this.onHint,
    required this.onNoteMode,
  });

  final bool noteMode;
  final VoidCallback onUndo;
  final VoidCallback onErase;
  final VoidCallback onHint;
  final VoidCallback onNoteMode;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: CupertinoColors.systemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            _IosIconButton(
              label: '撤销',
              icon: CupertinoIcons.arrow_counterclockwise,
              onTap: onUndo,
            ),
            const SizedBox(width: 8),
            _IosIconButton(
              label: '清除',
              icon: CupertinoIcons.delete_left,
              onTap: onErase,
            ),
            const SizedBox(width: 8),
            _IosIconButton(
              label: '提示',
              icon: CupertinoIcons.lightbulb,
              onTap: onHint,
            ),
            const Spacer(),
            CupertinoButton(
              minimumSize: const Size(84, 48),
              padding: const EdgeInsets.symmetric(horizontal: 18),
              color: noteMode
                  ? _SudokuPageState._iosBlue.withValues(alpha: 0.14)
                  : CupertinoColors.secondarySystemBackground.resolveFrom(
                      context,
                    ),
              borderRadius: BorderRadius.circular(16),
              onPressed: onNoteMode,
              child: Text(
                '候选',
                style: TextStyle(
                  color: _SudokuPageState._iosBlue,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosIconButton extends StatelessWidget {
  const _IosIconButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: CupertinoButton(
        minimumSize: const Size(48, 48),
        padding: EdgeInsets.zero,
        color: CupertinoColors.secondarySystemBackground.resolveFrom(context),
        borderRadius: BorderRadius.circular(14),
        onPressed: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 19),
            const SizedBox(height: 2),
            Text(
              label,
              style: const TextStyle(
                color: CupertinoColors.secondaryLabel,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _IosNumberPad extends StatelessWidget {
  const _IosNumberPad({required this.selectedNumber, required this.onNumber});

  final int? selectedNumber;
  final ValueChanged<int> onNumber;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 2.35,
      children: [
        for (var number = 1; number <= 9; number++)
          _IosNumberButton(
            number: number,
            selected: selectedNumber == number,
            onTap: () => onNumber(number),
          ),
      ],
    );
  }
}

class _IosNumberButton extends StatelessWidget {
  const _IosNumberButton({
    required this.number,
    required this.selected,
    required this.onTap,
  });

  final int number;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      color: selected
          ? _SudokuPageState._iosBlue
          : CupertinoColors.systemBackground.resolveFrom(context),
      borderRadius: BorderRadius.circular(14),
      onPressed: onTap,
      child: Text(
        '$number',
        style: TextStyle(
          color: selected ? CupertinoColors.white : _SudokuPageState._iosBlue,
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.difficultyLabel,
    required this.timeLabel,
    required this.mistakesLabel,
    required this.solved,
    required this.paused,
    required this.onNewGame,
    required this.onAbout,
    required this.onPause,
  });

  final String difficultyLabel;
  final String timeLabel;
  final String mistakesLabel;
  final bool solved;
  final bool paused;
  final VoidCallback onNewGame;
  final VoidCallback onAbout;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              '数独',
              style: TextStyle(
                color: _SudokuPageState._ink,
                fontSize: 28,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 10),
            _StatusPill(
              icon: solved ? Icons.check_circle_rounded : Icons.bolt_rounded,
              label: solved ? '已完成' : difficultyLabel,
              emphasized: true,
            ),
            const Spacer(),
            _RoundIconButton(
              tooltip: '新游戏',
              icon: Icons.add_rounded,
              onTap: onNewGame,
            ),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              tooltip: '菜单',
              icon: const Icon(Icons.more_horiz_rounded),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              onSelected: (value) {
                if (value == 'about') {
                  onAbout();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'about',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline_rounded, size: 20),
                      SizedBox(width: 10),
                      Text('关于'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _StatusPill(icon: Icons.timer_rounded, label: timeLabel),
            const SizedBox(width: 8),
            _StatusPill(
              icon: Icons.error_outline_rounded,
              label: mistakesLabel,
            ),
            const Spacer(),
            _RoundIconButton(
              tooltip: paused ? '继续' : '暂停',
              icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              onTap: onPause,
            ),
          ],
        ),
      ],
    );
  }
}

class _SudokuBoard extends StatelessWidget {
  const _SudokuBoard({
    required this.cells,
    required this.selectedIndex,
    required this.isRelated,
    required this.isCompletedRow,
    required this.isCompletedColumn,
    required this.isCompletedBox,
    required this.onCellTap,
    this.iosStyle = false,
  });

  final List<SudokuCell> cells;
  final int selectedIndex;
  final bool Function(int index) isRelated;
  final bool Function(int row) isCompletedRow;
  final bool Function(int col) isCompletedColumn;
  final bool Function(int row, int col) isCompletedBox;
  final ValueChanged<int> onCellTap;
  final bool iosStyle;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(iosStyle ? 12 : 8),
        border: Border.all(
          color: iosStyle
              ? _SudokuPageState._iosSeparator
              : const Color(0xFF566070),
          width: iosStyle ? 1 : 2,
        ),
        boxShadow: iosStyle
            ? const []
            : const [
                BoxShadow(
                  color: Color(0x10000000),
                  blurRadius: 14,
                  offset: Offset(0, 7),
                ),
              ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(iosStyle ? 11 : 6),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          itemCount: 81,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 9,
          ),
          itemBuilder: (context, index) {
            final row = index ~/ 9;
            final col = index % 9;
            final completed =
                isCompletedRow(row) ||
                isCompletedColumn(col) ||
                isCompletedBox(row, col);
            Color background = Colors.white;
            if (completed) {
              background = _SudokuPageState._success;
            }
            if (isRelated(index)) {
              background = Color.alphaBlend(
                _SudokuPageState._relation.withValues(alpha: 0.72),
                background,
              );
            }
            if (index == selectedIndex) {
              background = _SudokuPageState._selected;
            }
            return _SudokuCellTile(
              key: ValueKey('cell-$index'),
              cell: cells[index],
              background: background,
              border: Border(
                right: BorderSide(
                  color: iosStyle
                      ? _SudokuPageState._iosSeparator
                      : const Color(0xFF9AA4B2),
                  width: col == 2 || col == 5
                      ? (iosStyle ? 1.25 : 1.6)
                      : (iosStyle ? 0.45 : 0.55),
                ),
                bottom: BorderSide(
                  color: iosStyle
                      ? _SudokuPageState._iosSeparator
                      : const Color(0xFF9AA4B2),
                  width: row == 2 || row == 5
                      ? (iosStyle ? 1.25 : 1.6)
                      : (iosStyle ? 0.45 : 0.55),
                ),
              ),
              onTap: () => onCellTap(index),
              iosStyle: iosStyle,
            );
          },
        ),
      ),
    );
  }
}

class _SudokuCellTile extends StatelessWidget {
  const _SudokuCellTile({
    super.key,
    required this.cell,
    required this.background,
    required this.border,
    required this.onTap,
    this.iosStyle = false,
  });

  final SudokuCell cell;
  final Color background;
  final Border border;
  final VoidCallback onTap;
  final bool iosStyle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(border: border),
          alignment: Alignment.center,
          child: cell.value == 0
              ? _NotesGrid(notes: cell.notes)
              : Text(
                  '${cell.value}',
                  style: TextStyle(
                    color: cell.fixed
                        ? _SudokuPageState._ink
                        : (iosStyle
                              ? _SudokuPageState._iosBlue
                              : _SudokuPageState._accent),
                    fontSize: iosStyle ? 24 : 22,
                    fontWeight: cell.fixed ? FontWeight.w700 : FontWeight.w600,
                  ),
                ),
        ),
      ),
    );
  }
}

class _NotesGrid extends StatelessWidget {
  const _NotesGrid({required this.notes});

  final Set<int> notes;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      padding: const EdgeInsets.all(3),
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      children: [
        for (var number = 1; number <= 9; number++)
          Center(
            child: Text(
              notes.contains(number) ? '$number' : '',
              style: const TextStyle(
                color: Color(0xFF6F7B8C),
                fontSize: 9,
                fontWeight: FontWeight.w600,
                height: 1,
              ),
            ),
          ),
      ],
    );
  }
}

class _ActionToolbar extends StatelessWidget {
  const _ActionToolbar({
    required this.noteMode,
    required this.onUndo,
    required this.onErase,
    required this.onHint,
    required this.onNoteMode,
  });

  final bool noteMode;
  final VoidCallback onUndo;
  final VoidCallback onErase;
  final VoidCallback onHint;
  final VoidCallback onNoteMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ToolButton(icon: Icons.undo_rounded, label: '撤销', onTap: onUndo),
        const SizedBox(width: 8),
        _ToolButton(
          icon: Icons.backspace_outlined,
          label: '清除',
          onTap: onErase,
        ),
        const SizedBox(width: 8),
        _ToolButton(icon: Icons.lightbulb_outline, label: '提示', onTap: onHint),
        const Spacer(),
        _NoteToggle(active: noteMode, onTap: onNoteMode),
      ],
    );
  }
}

class _NumberPad extends StatelessWidget {
  const _NumberPad({required this.onNumber});

  final ValueChanged<int> onNumber;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 9,
      mainAxisSpacing: 6,
      crossAxisSpacing: 6,
      childAspectRatio: 0.95,
      children: [
        for (var number = 1; number <= 9; number++)
          _NumberButton(number: number, onTap: () => onNumber(number)),
      ],
    );
  }
}

class _DifficultyOption extends StatelessWidget {
  const _DifficultyOption({
    required this.difficulty,
    required this.selected,
    required this.onTap,
  });

  final SudokuDifficulty difficulty;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFEFF5FF) : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? _SudokuPageState._accent
                  : const Color(0xFFE1E5EC),
              width: selected ? 1.4 : 1,
            ),
          ),
          child: Row(
            children: [
              _DifficultyDots(level: difficulty.index + 1),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      difficulty.label,
                      style: const TextStyle(
                        color: _SudokuPageState._ink,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      difficulty.description,
                      style: const TextStyle(
                        color: Color(0xFF788394),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: _SudokuPageState._accent,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DifficultyDots extends StatelessWidget {
  const _DifficultyDots({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < 3; index++)
          Container(
            width: 6,
            height: 18.0 + index * 4,
            margin: const EdgeInsets.only(right: 3),
            decoration: BoxDecoration(
              color: index < level
                  ? _SudokuPageState._accent
                  : const Color(0xFFDCE2EA),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: emphasized ? const Color(0xFFEFF5FF) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: emphasized ? const Color(0xFFCFE0FF) : const Color(0xFFE5E9F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 15,
            color: emphasized
                ? _SudokuPageState._accent
                : const Color(0xFF6F7B8C),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: emphasized
                  ? _SudokuPageState._accent
                  : const Color(0xFF526071),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Color(0xFFE5E9F0)),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Icon(icon, color: _SudokuPageState._ink, size: 22),
          ),
        ),
      ),
    );
  }
}

class _ToolButton extends StatelessWidget {
  const _ToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E9F0)),
            ),
            child: Icon(icon, color: const Color(0xFF526071), size: 21),
          ),
        ),
      ),
    );
  }
}

class _NoteToggle extends StatelessWidget {
  const _NoteToggle({required this.active, required this.onTap});

  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? _SudokuPageState._accent : Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active
                  ? _SudokuPageState._accent
                  : const Color(0xFFE5E9F0),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.edit_note_rounded,
                size: 20,
                color: active ? Colors.white : const Color(0xFF526071),
              ),
              const SizedBox(width: 5),
              Text(
                '候选',
                style: TextStyle(
                  color: active ? Colors.white : const Color(0xFF526071),
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  const _NumberButton({required this.number, required this.onTap});

  final int number;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E7EF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '$number',
            style: const TextStyle(
              color: _SudokuPageState._accent,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
