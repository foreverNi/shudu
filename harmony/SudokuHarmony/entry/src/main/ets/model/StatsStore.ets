import { preferences } from '@kit.ArkData'
import { common } from '@kit.AbilityKit'
import { SudokuDifficulty } from './SudokuModels'

const STORE_NAME: string = 'sudoku_stats'
const KEY_STATS: string = 'stats_json'

export class DifficultyStats {
  count: number = 0
  totalSeconds: number = 0
  bestSeconds: number = 0
  worstSeconds: number = 0
}

export class StatsSummary {
  easy: DifficultyStats = new DifficultyStats()
  medium: DifficultyStats = new DifficultyStats()
  hard: DifficultyStats = new DifficultyStats()
}

interface StoredDifficultyStats {
  count: number
  totalSeconds: number
  bestSeconds: number
  worstSeconds: number
}

interface StoredStatsSummary {
  easy: StoredDifficultyStats
  medium: StoredDifficultyStats
  hard: StoredDifficultyStats
}

function cloneStats(stats: DifficultyStats): DifficultyStats {
  const cloned = new DifficultyStats()
  cloned.count = stats.count
  cloned.totalSeconds = stats.totalSeconds
  cloned.bestSeconds = stats.bestSeconds
  cloned.worstSeconds = stats.worstSeconds
  return cloned
}

function normalizeStats(value: StoredDifficultyStats | undefined): DifficultyStats {
  const stats = new DifficultyStats()
  if (!value) {
    return stats
  }
  stats.count = Math.max(0, Math.floor(value.count || 0))
  stats.totalSeconds = Math.max(0, Math.floor(value.totalSeconds || 0))
  stats.bestSeconds = Math.max(0, Math.floor(value.bestSeconds || 0))
  stats.worstSeconds = Math.max(0, Math.floor(value.worstSeconds || 0))
  if (stats.count === 0) {
    stats.totalSeconds = 0
    stats.bestSeconds = 0
    stats.worstSeconds = 0
  }
  return stats
}

export function emptyStatsSummary(): StatsSummary {
  return new StatsSummary()
}

export function copyStatsSummary(summary: StatsSummary): StatsSummary {
  const copy = new StatsSummary()
  copy.easy = cloneStats(summary.easy)
  copy.medium = cloneStats(summary.medium)
  copy.hard = cloneStats(summary.hard)
  return copy
}

export function totalGames(summary: StatsSummary): number {
  return summary.easy.count + summary.medium.count + summary.hard.count
}

export function totalSeconds(summary: StatsSummary): number {
  return summary.easy.totalSeconds + summary.medium.totalSeconds + summary.hard.totalSeconds
}

export function averageSeconds(stats: DifficultyStats): number {
  if (stats.count <= 0) {
    return 0
  }
  return Math.round(stats.totalSeconds / stats.count)
}

export function formatDuration(seconds: number): string {
  if (seconds <= 0) {
    return '--:--'
  }
  const minutes = Math.floor(seconds / 60).toString().padStart(2, '0')
  const secs = (seconds % 60).toString().padStart(2, '0')
  return minutes + ':' + secs
}

export class StatsStore {
  private prefs: preferences.Preferences | null = null
  private summary: StatsSummary = emptyStatsSummary()

  init(context: common.UIAbilityContext): StatsSummary {
    try {
      this.prefs = preferences.getPreferencesSync(context, { name: STORE_NAME })
      const raw = this.prefs.getSync(KEY_STATS, '') as string
      this.summary = this.parse(raw)
    } catch (err) {
      console.error('StatsStore init failed: ' + JSON.stringify(err))
      this.prefs = null
      this.summary = emptyStatsSummary()
    }
    return copyStatsSummary(this.summary)
  }

  recordGame(difficulty: SudokuDifficulty, seconds: number): StatsSummary {
    if (seconds <= 0) {
      return copyStatsSummary(this.summary)
    }
    const updated = copyStatsSummary(this.summary)
    const target = this.statsForDifficulty(updated, difficulty)
    target.count += 1
    target.totalSeconds += seconds
    target.bestSeconds = target.bestSeconds === 0 ? seconds : Math.min(target.bestSeconds, seconds)
    target.worstSeconds = Math.max(target.worstSeconds, seconds)
    this.summary = updated
    this.persist()
    return copyStatsSummary(this.summary)
  }

  private parse(raw: string): StatsSummary {
    if (raw.length === 0) {
      return emptyStatsSummary()
    }
    try {
      const stored = JSON.parse(raw) as StoredStatsSummary
      const summary = new StatsSummary()
      summary.easy = normalizeStats(stored.easy)
      summary.medium = normalizeStats(stored.medium)
      summary.hard = normalizeStats(stored.hard)
      return summary
    } catch (err) {
      console.error('StatsStore parse failed: ' + JSON.stringify(err))
      return emptyStatsSummary()
    }
  }

  private persist(): void {
    if (!this.prefs) {
      return
    }
    try {
      this.prefs.putSync(KEY_STATS, JSON.stringify(this.summary))
      this.prefs.flushSync()
    } catch (err) {
      console.error('StatsStore persist failed: ' + JSON.stringify(err))
    }
  }

  private statsForDifficulty(summary: StatsSummary, difficulty: SudokuDifficulty): DifficultyStats {
    if (difficulty === SudokuDifficulty.Easy) {
      return summary.easy
    }
    if (difficulty === SudokuDifficulty.Medium) {
      return summary.medium
    }
    return summary.hard
  }
}
