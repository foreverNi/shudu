import { SudokuDifficulty, SudokuPuzzle } from '../model/SudokuModels'

const SOLUTION: number[] = [
  5, 3, 4, 6, 7, 8, 9, 1, 2,
  6, 7, 2, 1, 9, 5, 3, 4, 8,
  1, 9, 8, 3, 4, 2, 5, 6, 7,
  8, 5, 9, 7, 6, 1, 4, 2, 3,
  4, 2, 6, 8, 5, 3, 7, 9, 1,
  7, 1, 3, 9, 2, 4, 8, 5, 6,
  9, 6, 1, 5, 3, 7, 2, 8, 4,
  2, 8, 7, 4, 1, 9, 6, 3, 5,
  3, 4, 5, 2, 8, 6, 1, 7, 9
]

const ORDER_PERMUTATIONS: number[][] = [
  [0, 1, 2],
  [0, 2, 1],
  [1, 0, 2],
  [1, 2, 0],
  [2, 0, 1],
  [2, 1, 0]
]

const DIGIT_VARIANTS: number = 18
const PUZZLE_VARIANTS: number = ORDER_PERMUTATIONS.length * ORDER_PERMUTATIONS.length *
ORDER_PERMUTATIONS.length * ORDER_PERMUTATIONS.length * DIGIT_VARIANTS
let lastEasyVariant: number = -1
let lastMediumVariant: number = -1
let lastHardVariant: number = -1

function buildPuzzle(givens: number[], solution: number[] = SOLUTION): SudokuPuzzle {
  const p = new SudokuPuzzle()
  p.givens = givens
  p.solution = solution
  return p
}

function lastVariantForDifficulty(d: SudokuDifficulty): number {
  if (d === SudokuDifficulty.Easy) {
    return lastEasyVariant
  }
  if (d === SudokuDifficulty.Medium) {
    return lastMediumVariant
  }
  return lastHardVariant
}

function setLastVariantForDifficulty(d: SudokuDifficulty, variant: number): void {
  if (d === SudokuDifficulty.Easy) {
    lastEasyVariant = variant
  } else if (d === SudokuDifficulty.Medium) {
    lastMediumVariant = variant
  } else {
    lastHardVariant = variant
  }
}

function randomVariant(d: SudokuDifficulty): number {
  let variant: number = Math.floor(Math.random() * PUZZLE_VARIANTS)
  const lastVariant: number = lastVariantForDifficulty(d)
  if (variant === lastVariant) {
    variant = (variant + 1) % PUZZLE_VARIANTS
  }
  setLastVariantForDifficulty(d, variant)
  return variant
}

function expandOrder(majorPermutation: number[], innerPermutation: number[]): number[] {
  const order: number[] = []
  for (let majorIndex = 0; majorIndex < majorPermutation.length; majorIndex++) {
    const major: number = majorPermutation[majorIndex]
    for (let innerIndex = 0; innerIndex < innerPermutation.length; innerIndex++) {
      order.push(major * 3 + innerPermutation[innerIndex])
    }
  }
  return order
}

function remapDigit(value: number, shift: number, reversed: boolean): number {
  if (value === 0) {
    return 0
  }
  const shifted: number = ((value + shift - 1) % 9) + 1
  return reversed ? 10 - shifted : shifted
}

function transformGrid(grid: number[], rowOrder: number[], columnOrder: number[],
  digitShift: number, digitReversed: boolean): number[] {
  const transformed: number[] = []
  for (let row = 0; row < 9; row++) {
    for (let column = 0; column < 9; column++) {
      const sourceIndex: number = rowOrder[row] * 9 + columnOrder[column]
      transformed.push(remapDigit(grid[sourceIndex], digitShift, digitReversed))
    }
  }
  return transformed
}

function transformPuzzle(givens: number[], variant: number): SudokuPuzzle {
  let seed: number = variant
  const bandOrder: number[] = ORDER_PERMUTATIONS[seed % ORDER_PERMUTATIONS.length]
  seed = Math.floor(seed / ORDER_PERMUTATIONS.length)
  const stackOrder: number[] = ORDER_PERMUTATIONS[seed % ORDER_PERMUTATIONS.length]
  seed = Math.floor(seed / ORDER_PERMUTATIONS.length)
  const rowInnerOrder: number[] = ORDER_PERMUTATIONS[seed % ORDER_PERMUTATIONS.length]
  seed = Math.floor(seed / ORDER_PERMUTATIONS.length)
  const columnInnerOrder: number[] = ORDER_PERMUTATIONS[seed % ORDER_PERMUTATIONS.length]
  seed = Math.floor(seed / ORDER_PERMUTATIONS.length)
  const digitShift: number = seed % 9
  const digitReversed: boolean = Math.floor(seed / 9) % 2 === 1
  const rowOrder: number[] = expandOrder(bandOrder, rowInnerOrder)
  const columnOrder: number[] = expandOrder(stackOrder, columnInnerOrder)
  return buildPuzzle(
    transformGrid(givens, rowOrder, columnOrder, digitShift, digitReversed),
    transformGrid(SOLUTION, rowOrder, columnOrder, digitShift, digitReversed)
  )
}

const EASY_GIVENS: number[] = [
  5, 3, 4, 6, 7, 0, 9, 1, 2,
  6, 7, 0, 1, 9, 5, 3, 4, 8,
  1, 9, 8, 3, 4, 2, 5, 6, 7,
  8, 5, 9, 7, 6, 1, 4, 2, 3,
  4, 2, 6, 8, 0, 3, 7, 9, 1,
  7, 1, 3, 9, 2, 4, 8, 5, 6,
  9, 6, 1, 5, 3, 7, 2, 8, 4,
  2, 8, 7, 4, 1, 9, 6, 3, 5,
  3, 4, 5, 2, 8, 6, 1, 7, 9
]

const MEDIUM_GIVENS: number[] = [
  5, 3, 0, 0, 7, 0, 0, 0, 0,
  6, 0, 0, 1, 9, 5, 0, 0, 0,
  0, 9, 8, 0, 0, 0, 0, 6, 0,
  8, 0, 0, 0, 6, 0, 0, 0, 3,
  4, 0, 0, 8, 0, 3, 0, 0, 1,
  7, 0, 0, 0, 2, 0, 0, 0, 6,
  0, 6, 0, 0, 0, 0, 2, 8, 0,
  0, 0, 0, 4, 1, 9, 0, 0, 5,
  0, 0, 0, 0, 8, 0, 0, 7, 9
]

const HARD_GIVENS: number[] = [
  0, 0, 0, 0, 7, 0, 0, 1, 0,
  6, 0, 0, 1, 0, 0, 0, 0, 8,
  0, 9, 0, 0, 0, 2, 0, 0, 0,
  8, 0, 0, 0, 6, 0, 0, 0, 3,
  0, 0, 6, 0, 0, 0, 7, 0, 0,
  7, 0, 0, 0, 2, 0, 0, 0, 6,
  0, 0, 0, 5, 0, 0, 8, 0, 2,
  0, 0, 0, 0, 9, 0, 0, 5, 0,
  4, 0, 8, 0, 0, 0, 0, 0, 0
]

export function getPuzzle(d: SudokuDifficulty): SudokuPuzzle {
  const variant: number = randomVariant(d)
  if (d === SudokuDifficulty.Easy) {
    return transformPuzzle(EASY_GIVENS, variant)
  }
  if (d === SudokuDifficulty.Medium) {
    return transformPuzzle(MEDIUM_GIVENS, variant)
  }
  return transformPuzzle(HARD_GIVENS, variant)
}

export function getSolution(): number[] {
  return SOLUTION
}
