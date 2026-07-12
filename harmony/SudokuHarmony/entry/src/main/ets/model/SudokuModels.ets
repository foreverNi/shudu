export enum SudokuDifficulty {
  Easy = 0,
  Medium = 1,
  Hard = 2
}

export function difficultyLabel(d: SudokuDifficulty): string {
  if (d === SudokuDifficulty.Easy) {
    return '简单'
  }
  if (d === SudokuDifficulty.Medium) {
    return '中等'
  }
  return '困难'
}

export function difficultyDescription(d: SudokuDifficulty): string {
  if (d === SudokuDifficulty.Easy) {
    return '适合练习'
  }
  if (d === SudokuDifficulty.Medium) {
    return '标准挑战'
  }
  return '高难推理'
}

@Observed
export class SudokuCell {
  value: number = 0
  fixed: boolean = false
  noteFlags: boolean[] = [false, false, false, false, false, false, false, false, false]

  hasNote(num: number): boolean {
    return this.noteFlags[num - 1]
  }

  toggleNote(num: number): void {
    this.noteFlags[num - 1] = !this.noteFlags[num - 1]
  }

  copy(): SudokuCell {
    const c = new SudokuCell()
    c.value = this.value
    c.fixed = this.fixed
    c.noteFlags = [...this.noteFlags]
    return c
  }
}

export class BoardSnapshot {
  cells: SudokuCell[] = []
  mistakes: number = 0
  selectedIndex: number = 0
  solved: boolean = false
}

export class SudokuPuzzle {
  givens: number[] = []
  solution: number[] = []
}
