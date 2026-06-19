import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const SudokuApp());
}

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
  });

  final List<SudokuCell> cells;
  final int mistakes;
  final int selectedIndex;
}

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
    solution: [
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
    ],
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
    solution: [
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
    ],
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
    solution: [
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
    ],
  ),
};

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
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
  static const _success = Color(0xFFE6F5EC);
  static const _relation = Color(0xFFEFF5FF);
  static const _selected = Color(0xFFDDE8FF);
  static const _surface = Color(0xFFFFFCF8);
  static const _ink = Color(0xFF1D2530);

  SudokuDifficulty _difficulty = SudokuDifficulty.medium;
  late List<SudokuCell> _cells;
  late List<int> _solution;
  final List<BoardSnapshot> _history = [];
  int _selectedIndex = 40;
  int _mistakes = 0;
  int _seconds = 0;
  bool _noteMode = false;
  bool _paused = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadPuzzle(_difficulty);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!_paused && mounted) {
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
    _solution = puzzle.solution;
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
  }

  void _saveHistory() {
    _history.add(
      BoardSnapshot(
        cells: _cells.map((cell) => cell.copy()).toList(),
        mistakes: _mistakes,
        selectedIndex: _selectedIndex,
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
    if (cell.fixed) {
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
      if (_solution[_selectedIndex] != number) {
        _mistakes = (_mistakes + 1).clamp(0, 3);
      }
    });
  }

  void _eraseSelected() {
    final cell = _cells[_selectedIndex];
    if (cell.fixed) {
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
    });
  }

  void _hint() {
    final cell = _cells[_selectedIndex];
    if (cell.fixed) {
      return;
    }
    _saveHistory();
    setState(() {
      cell.value = _solution[_selectedIndex];
      cell.notes.clear();
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

  String get _timeLabel {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final boardSize = (constraints.maxWidth - 32).clamp(300.0, 420.0);
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 8, 18, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _TopBar(
                      difficultyLabel: _difficulty.label,
                      timeLabel: _timeLabel,
                      mistakesLabel: '错误 $_mistakes/3',
                      paused: _paused,
                      onNewGame: _showDifficultySheet,
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
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    _ActionToolbar(
                      noteMode: _noteMode,
                      onUndo: _undo,
                      onErase: _eraseSelected,
                      onHint: _hint,
                      onNoteMode: () => setState(() => _noteMode = !_noteMode),
                    ),
                    const SizedBox(height: 14),
                    _NumberPad(onNumber: _handleNumber),
                  ],
                ),
              ),
            );
          },
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
    required this.paused,
    required this.onNewGame,
    required this.onPause,
  });

  final String difficultyLabel;
  final String timeLabel;
  final String mistakesLabel;
  final bool paused;
  final VoidCallback onNewGame;
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
                fontSize: 30,
                fontWeight: FontWeight.w800,
              ),
            ),
            const Spacer(),
            _RoundIconButton(
              tooltip: '新游戏',
              icon: Icons.add_rounded,
              onTap: onNewGame,
            ),
            const SizedBox(width: 8),
            _RoundIconButton(
              tooltip: paused ? '继续' : '暂停',
              icon: paused ? Icons.play_arrow_rounded : Icons.pause_rounded,
              onTap: onPause,
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _StatusPill(
              icon: Icons.bolt_rounded,
              label: difficultyLabel,
              emphasized: true,
            ),
            _StatusPill(icon: Icons.timer_rounded, label: timeLabel),
            _StatusPill(
              icon: Icons.error_outline_rounded,
              label: mistakesLabel,
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
  });

  final List<SudokuCell> cells;
  final int selectedIndex;
  final bool Function(int index) isRelated;
  final bool Function(int row) isCompletedRow;
  final bool Function(int col) isCompletedColumn;
  final bool Function(int row, int col) isCompletedBox;
  final ValueChanged<int> onCellTap;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF566070), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x11000000),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(6),
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
                  color: const Color(0xFF9AA4B2),
                  width: col == 2 || col == 5 ? 1.6 : 0.55,
                ),
                bottom: BorderSide(
                  color: const Color(0xFF9AA4B2),
                  width: row == 2 || row == 5 ? 1.6 : 0.55,
                ),
              ),
              onTap: () => onCellTap(index),
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
  });

  final SudokuCell cell;
  final Color background;
  final Border border;
  final VoidCallback onTap;

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
                        : _SudokuPageState._accent,
                    fontSize: 22,
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
        const SizedBox(width: 10),
        _ToolButton(
          icon: Icons.backspace_outlined,
          label: '清除',
          onTap: onErase,
        ),
        const SizedBox(width: 10),
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
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 0.82,
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
            width: 42,
            height: 42,
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
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E9F0)),
            ),
            child: Icon(icon, color: const Color(0xFF526071), size: 22),
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
          height: 46,
          padding: const EdgeInsets.symmetric(horizontal: 13),
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
                size: 21,
                color: active ? Colors.white : const Color(0xFF526071),
              ),
              const SizedBox(width: 6),
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
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE1E7EF)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000),
                blurRadius: 8,
                offset: Offset(0, 4),
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
