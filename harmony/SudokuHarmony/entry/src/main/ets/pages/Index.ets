import { SudokuDifficulty, SudokuCell, BoardSnapshot, difficultyLabel, difficultyDescription } from '../model/SudokuModels'
import { getPuzzle } from '../data/Puzzles'
import { SudokuBoard } from '../components/SudokuBoard'
import { NumberPad } from '../components/NumberPad'
import { ActionToolbar } from '../components/ActionToolbar'
import { DifficultySheet } from '../components/DifficultySheet'
import { BottomNav } from '../components/BottomNav'
import { StatsPage } from '../components/StatsPage'
import { AchievementsPage } from '../components/AchievementsPage'
import { StatsStore, StatsSummary, emptyStatsSummary } from '../model/StatsStore'
import { common } from '@kit.AbilityKit'

const APP_VERSION: string = '1.0.3'
const APP_AUTHOR: string = 'Noah.Ni'
const MAX_HISTORY: number = 80
const MAX_MISTAKES: number = 3

@Entry
@Component
struct Index {
  @State difficulty: SudokuDifficulty = SudokuDifficulty.Medium
  @State cells: SudokuCell[] = []
  @State solutionValues: number[] = []
  @State selectedIndex: number = 40
  @State mistakes: number = 0
  @State seconds: number = 0
  @State noteMode: boolean = false
  @State paused: boolean = false
  @State solved: boolean = false
  @State history: BoardSnapshot[] = []
  @State showDifficultySheet: boolean = false
  @State sheetDifficulty: SudokuDifficulty = SudokuDifficulty.Medium
  @State boardSize: number = 340
  @State screenH: number = 0
  @State contentGap: number = 16
  @State activeTab: number = 0
  @State statsSummary: StatsSummary = emptyStatsSummary()
  @State hintUsageCount: number = 0

  private timerId: number = -1
  private pageVisible: boolean = true
  private containerWidth: number = 360
  private statsStore: StatsStore = new StatsStore()

  private readonly HEADER_H: number = 92
  private readonly STATUS_H: number = 70
  private readonly TOOLBAR_H: number = 72
  private readonly NUMPAD_H: number = 52
  private readonly BOTTOM_NAV_H: number = 74
  private readonly GAP_COUNT: number = 5

  aboutToAppear(): void {
    this.loadPuzzle(this.difficulty)
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    if (context) {
      this.statsSummary = this.statsStore.init(context)
    }
    this.startTimer()
  }

  aboutToDisappear(): void {
    this.stopTimer()
  }

  onPageShow(): void {
    this.pageVisible = true
  }

  onPageHide(): void {
    this.pageVisible = false
  }

  private startTimer(): void {
    if (this.timerId !== -1) {
      return
    }
    this.timerId = setInterval(() => {
      if (this.pageVisible && !this.paused && !this.solved) {
        this.seconds += 1
      }
    }, 1000)
  }

  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId)
      this.timerId = -1
    }
  }

  private loadPuzzle(d: SudokuDifficulty): void {
    const puzzle = getPuzzle(d)
    this.difficulty = d
    this.solutionValues = puzzle.solution
    const newCells: SudokuCell[] = []
    for (let i = 0; i < puzzle.givens.length; i++) {
      const c = new SudokuCell()
      c.value = puzzle.givens[i]
      c.fixed = puzzle.givens[i] !== 0
      newCells.push(c)
    }
    this.cells = newCells
    let firstEmpty: number = -1
    for (let i = 0; i < puzzle.givens.length; i++) {
      if (puzzle.givens[i] === 0) {
        firstEmpty = i
        break
      }
    }
    this.selectedIndex = firstEmpty >= 0 ? firstEmpty : 0
    this.mistakes = 0
    this.seconds = 0
    this.history = []
    this.noteMode = false
    this.hintUsageCount = 0
    this.paused = false
    this.solved = false
  }

  private saveHistory(): void {
    const snap = new BoardSnapshot()
    snap.cells = this.cells.map((c: SudokuCell) => c.copy())
    snap.mistakes = this.mistakes
    snap.selectedIndex = this.selectedIndex
    snap.solved = this.solved
    const newHistory: BoardSnapshot[] = [...this.history, snap]
    if (newHistory.length > MAX_HISTORY) {
      newHistory.splice(0, newHistory.length - MAX_HISTORY)
    }
    this.history = newHistory
  }

  private handleNumber(num: number): void {
    if (this.selectedIndex < 0 || this.selectedIndex >= this.cells.length) {
      return
    }
    const cell: SudokuCell = this.cells[this.selectedIndex]
    if (cell.fixed || this.solved) {
      return
    }
    this.saveHistory()
    if (this.noteMode) {
      if (cell.value === 0) {
        const newCells: SudokuCell[] = [...this.cells]
        const nc: SudokuCell = newCells[this.selectedIndex].copy()
        nc.toggleNote(num)
        newCells[this.selectedIndex] = nc
        this.cells = newCells
      }
      return
    }
    const newCells: SudokuCell[] = [...this.cells]
    const nc: SudokuCell = newCells[this.selectedIndex].copy()
    nc.noteFlags = [false, false, false, false, false, false, false, false, false]
    nc.value = num
    newCells[this.selectedIndex] = nc
    if (this.solutionValues[this.selectedIndex] !== num) {
      this.mistakes = Math.min(MAX_MISTAKES, this.mistakes + 1)
    }
    this.cells = newCells
    this.checkCompletion()
  }

  private eraseSelected(): void {
    if (this.selectedIndex < 0 || this.selectedIndex >= this.cells.length) {
      return
    }
    const cell: SudokuCell = this.cells[this.selectedIndex]
    if (cell.fixed || this.solved) {
      return
    }
    this.saveHistory()
    const newCells: SudokuCell[] = [...this.cells]
    const nc: SudokuCell = newCells[this.selectedIndex].copy()
    nc.value = 0
    nc.noteFlags = [false, false, false, false, false, false, false, false, false]
    newCells[this.selectedIndex] = nc
    this.cells = newCells
  }

  private undo(): void {
    if (this.history.length === 0) {
      return
    }
    const newHistory: BoardSnapshot[] = [...this.history]
    const snap: BoardSnapshot = newHistory.pop()!
    this.history = newHistory
    this.cells = snap.cells
    this.mistakes = snap.mistakes
    this.selectedIndex = snap.selectedIndex
    this.solved = snap.solved
  }

  private hint(): void {
    if (this.selectedIndex < 0 || this.selectedIndex >= this.cells.length) {
      return
    }
    const cell: SudokuCell = this.cells[this.selectedIndex]
    if (cell.fixed || this.solved) {
      return
    }
    this.saveHistory()
    const newCells: SudokuCell[] = [...this.cells]
    const nc: SudokuCell = newCells[this.selectedIndex].copy()
    nc.value = this.solutionValues[this.selectedIndex]
    nc.noteFlags = [false, false, false, false, false, false, false, false, false]
    newCells[this.selectedIndex] = nc
    this.cells = newCells
    this.hintUsageCount += 1
    this.checkCompletion()
  }

  private isSolved(): boolean {
    for (let i = 0; i < this.cells.length; i++) {
      if (this.cells[i].value !== this.solutionValues[i]) {
        return false
      }
    }
    return true
  }

  private checkCompletion(): void {
    if (this.solved || !this.isSolved()) {
      return
    }
    this.solved = true
    const diffLabel: string = difficultyLabel(this.difficulty)
    const timeStr: string = this.timeLabel
    const mistakesStr: string = this.mistakes.toString()
    this.statsSummary = this.statsStore.recordGame(this.difficulty, this.seconds)
    this.getUIContext().showAlertDialog({
      title: '恭喜完成',
      message: '你已正确完成' + diffLabel + '数独。\n用时 ' + timeStr + '，错误 ' + mistakesStr + '/3。',
      primaryButton: {
        value: '再来一局',
        action: () => {
          this.sheetDifficulty = this.difficulty
          this.showDifficultySheet = true
        }
      },
      secondaryButton: {
        value: '继续查看',
        action: () => {}
      }
    })
  }

  private showAboutDialog(): void {
    this.getUIContext().showAlertDialog({
      title: '关于',
      message: '数独\n\n版本号：' + APP_VERSION + '\n作者：' + APP_AUTHOR,
      primaryButton: {
        value: '关闭',
        action: () => {}
      }
    })
  }

  private get timeLabel(): string {
    const minutes: string = Math.floor(this.seconds / 60).toString().padStart(2, '0')
    const secs: string = (this.seconds % 60).toString().padStart(2, '0')
    return minutes + ':' + secs
  }

  private togglePause(): void {
    this.paused = !this.paused
  }

  private selectedCellValue(): number {
    if (this.selectedIndex >= 0 && this.selectedIndex < this.cells.length) {
      return this.cells[this.selectedIndex].value
    }
    return 0
  }

  private hintCount(): number {
    return this.hintUsageCount
  }

  private calcBoardSize(): number {
    const padding: number = this.containerWidth < 360 ? 24 : 44
    const available: number = this.containerWidth - padding
    let size: number = available
    if (size > 384) {
      size = 384
    }
    if (size < 292) {
      size = 292
    }
    return size
  }

  private recalcLayout(): void {
    this.boardSize = this.calcBoardSize()
    if (this.screenH <= 0) {
      this.contentGap = 16
      return
    }
    const fixedH: number = this.HEADER_H + this.STATUS_H + this.boardSize + this.TOOLBAR_H + this.NUMPAD_H + this.BOTTOM_NAV_H
    const remaining: number = this.screenH - fixedH
    if (remaining <= 0) {
      this.contentGap = 4
      return
    }
    const gap: number = Math.floor(remaining / this.GAP_COUNT)
    this.contentGap = gap < 4 ? 4 : (gap > 18 ? 18 : gap)
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          angle: 180,
          colors: [['#FFFFFF', 0], ['#F7FAFF', 0.55], ['#F3F8FF', 1]]
        })

      Column() {
        this.HeaderBar()

        if (this.activeTab === 0) {
          this.GameContent()
        } else if (this.activeTab === 1) {
          this.StatsContent()
        } else {
          this.AchievementsContent()
        }

        BottomNav({
          activeTab: this.activeTab,
          onTabChange: (tab: number) => { this.activeTab = tab }
        })
      }
      .width('100%')
      .height('100%')
    }
    .width('100%')
    .height('100%')
    .onAreaChange((_old: Area, newArea: Area) => {
      const w: number = Number(newArea.width)
      const h: number = Number(newArea.height)
      if (w > 0 && h > 0) {
        this.containerWidth = w
        this.screenH = h
        this.recalcLayout()
      }
    })
    .bindSheet(this.showDifficultySheet, this.DifficultySheetBuilder(), {
      detents: [SheetSize.LARGE],
      dragBar: true,
      backgroundColor: Color.Transparent,
      onDisappear: () => {
        this.showDifficultySheet = false
      }
    })
  }

  @Builder
  GameContent() {
    Column() {
      Column() {
        this.StatusCard()
      }
      .width(this.boardSize)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: this.contentGap })

      Column() {
        this.BoardArea()
      }
      .margin({ top: this.contentGap })

      Column() {
        ActionToolbar({
          noteMode: this.noteMode,
          hintCount: this.hintCount(),
          onUndo: () => { this.undo() },
          onErase: () => { this.eraseSelected() },
          onHint: () => { this.hint() },
          onNoteMode: () => { this.noteMode = !this.noteMode }
        })
      }
      .width(this.boardSize)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: this.contentGap })

      Column() {
        NumberPad({
          selectedNumber: this.selectedCellValue(),
          onNumber: (num: number) => { this.handleNumber(num) }
        })
      }
      .width(this.boardSize)
      .alignItems(HorizontalAlign.Center)
      .margin({ top: this.contentGap })

      Blank()
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  StatsContent() {
    Column() {
      StatsPage({
        summary: this.statsSummary,
        contentWidth: this.boardSize
      })
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .margin({ top: this.contentGap })
  }

  @Builder
  AchievementsContent() {
    Column() {
      AchievementsPage({
        summary: this.statsSummary,
        contentWidth: this.boardSize
      })
    }
    .width('100%')
    .layoutWeight(1)
    .alignItems(HorizontalAlign.Center)
    .margin({ top: this.contentGap })
  }

  @Builder
  HeaderBar() {
    Row() {
      Column({ space: 4 }) {
        Image($r('app.media.title_sudoku'))
          .width(154)
          .height(58)
          .objectFit(ImageFit.Contain)
        Text(this.activeTab === 1 ? '沉淀每一局的思考节奏' : (this.activeTab === 2 ? '记录每一次突破与坚持' : $r('app.string.subtitle')))
          .fontSize($r('app.float.subtitle_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.text_subtitle'))
      }
      .alignItems(HorizontalAlign.Start)

      Blank()

      Button({ type: ButtonType.Normal }) {
        Image($r('app.media.icon_more'))
          .width(28)
          .height(28)
          .objectFit(ImageFit.Contain)
      }
      .width(58)
      .height(58)
      .backgroundColor('#FDFEFF')
      .borderRadius(29)
      .shadow({ radius: 24, color: $r('app.color.header_btn_shadow'), offsetY: 8 })
      .bindMenu([
        {
          value: '新游戏',
          action: () => {
            this.sheetDifficulty = this.difficulty
            this.showDifficultySheet = true
          }
        },
        {
          value: this.paused ? '继续' : '暂停',
          action: () => {
            this.togglePause()
          }
        },
        {
          value: '关于',
          action: () => {
            this.showAboutDialog()
          }
        }
      ])
    }
    .width('100%')
    .height(this.HEADER_H)
    .padding({ left: 27, right: 30, top: 0 })
    .alignItems(VerticalAlign.Top)
  }

  @Builder
  MetricItem(iconRes: Resource, valueStr: string, labelStr: ResourceStr, isError: boolean) {
    Row({ space: 10 }) {
      Column() {
        Image(iconRes)
          .width(24)
          .height(24)
          .objectFit(ImageFit.Contain)
      }
      .width($r('app.float.icon_circle_size'))
      .height($r('app.float.icon_circle_size'))
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius(14)
      .backgroundColor($r('app.color.bg_icon_circle'))
      .shadow({ radius: 18, color: $r('app.color.btn_shadow'), offsetY: 6 })

      Column({ space: 4 }) {
        Text(valueStr)
          .fontSize($r('app.float.metric_value_font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor(isError ? $r('app.color.error_red') : $r('app.color.text_primary'))

        Text(labelStr)
          .fontSize($r('app.float.metric_label_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.text_secondary'))
      }
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  StatusCard() {
    Row() {
      this.MetricItem($r('app.media.icon_difficulty'), this.solved ? '已完成' : difficultyLabel(this.difficulty), $r('app.string.difficulty'), false)

      Divider()
        .vertical(true)
        .height(48)
        .color($r('app.color.divider'))

      this.MetricItem($r('app.media.icon_clock'), Math.floor(this.seconds / 60).toString().padStart(2, '0') + ':' + (this.seconds % 60).toString().padStart(2, '0'), $r('app.string.time'), false)

      Divider()
        .vertical(true)
        .height(48)
        .color($r('app.color.divider'))

      this.MetricItem($r('app.media.icon_target'), this.mistakes.toString() + '/3', $r('app.string.mistakes'), this.mistakes > 0)
    }
    .width('100%')
    .height($r('app.float.status_card_h'))
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius($r('app.float.card_border_radius'))
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
    .shadow({ radius: 28, color: $r('app.color.card_shadow'), offsetY: 10 })
  }

  @Builder
  BoardArea() {
    Column() {
      SudokuBoard({
        cells: this.cells,
        selectedIndex: this.selectedIndex,
        paused: this.paused,
        mistakes: this.mistakes,
        onCellTap: (index: number) => {
          this.selectedIndex = index
        }
      })
    }
    .width(this.boardSize)
    .height(this.boardSize)
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  DifficultySheetBuilder() {
    DifficultySheet({
      sheetDifficulty: this.sheetDifficulty,
      onStart: () => {
        this.showDifficultySheet = false
        this.loadPuzzle(this.sheetDifficulty)
      },
      onCancel: () => {
        this.showDifficultySheet = false
      }
    })
  }
}
