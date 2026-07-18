import { SudokuDifficulty, SudokuCell, BoardSnapshot, difficultyLabel, difficultyDescription } from '../model/SudokuModels'
import { getPuzzle } from '../data/Puzzles'
import { SudokuBoard } from '../components/SudokuBoard'
import { NumberPad } from '../components/NumberPad'
import { ActionToolbar } from '../components/ActionToolbar'
import { DifficultySheet } from '../components/DifficultySheet'
import { BottomNav } from '../components/BottomNav'
import { StatsPage } from '../components/StatsPage'
import { AchievementsPage } from '../components/AchievementsPage'
import { SummaryMetricItem } from '../components/SummaryCard'
import { StatsStore, StatsSummary, emptyStatsSummary, formatDuration, totalGames, totalSeconds } from '../model/StatsStore'
import { HuaweiGameServiceState } from '../model/HuaweiGameServiceState'
import { common } from '@kit.AbilityKit'
import { BusinessError } from '@kit.BasicServicesKit'
import { gamePlayer } from '@kit.GameServiceKit'
import { deviceInfo } from '@kit.BasicServicesKit'
import { hilog } from '@kit.PerformanceAnalysisKit'

const APP_VERSION: string = '1.0.7'
const APP_AUTHOR: string = '倪国瑜'
const MAX_HISTORY: number = 80
const MAX_MISTAKES: number = 3
const LOG_DOMAIN: number = 0x0000
const LOG_TAG: string = 'SudokuGameService'
const ACHIEVEMENT_TOTAL: number = 7

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
  @State gameServiceReady: boolean = false
  @State gameServiceMessage: string = '正在进行华为账号合规校验...'

  private textTimerController: TextTimerController = new TextTimerController()
  private containerWidth: number = 360
  private statsStore: StatsStore = new StatsStore()
  private gameServiceStarted: boolean = false

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
    this.startHuaweiGameService(false)
    this.startTimer()
  }

  aboutToDisappear(): void {
    this.stopTimer()
  }

  onPageShow(): void {
    this.startTimer()
  }

  onPageHide(): void {
    this.stopTimer()
  }

  private startTimer(): void {
    if (this.gameServiceReady && !this.paused && !this.solved) {
      this.textTimerController.start()
    }
  }

  private stopTimer(): void {
    this.textTimerController.pause()
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
    this.textTimerController.reset()
    this.startTimer()
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
    this.stopTimer()
    const diffLabel: string = difficultyLabel(this.difficulty)
    const elapsedSeconds: number = this.elapsedSeconds()
    const timeStr: string = this.formatElapsedTime(elapsedSeconds)
    const mistakesStr: string = this.mistakes.toString()
    this.statsSummary = this.statsStore.recordGame(this.difficulty, elapsedSeconds)
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
    return this.formatElapsedTime(this.elapsedSeconds())
  }

  private elapsedSeconds(): number {
    const seconds: number = Math.floor(this.seconds || 0)
    if (seconds <= 0) {
      return 0
    }
    return seconds
  }

  private formatElapsedTime(seconds: number): string {
    const safeSeconds: number = Math.max(0, Math.floor(seconds || 0))
    const minutes: string = Math.floor(safeSeconds / 60).toString().padStart(2, '0')
    const secs: string = (safeSeconds % 60).toString().padStart(2, '0')
    return minutes + ':' + secs
  }

  private togglePause(): void {
    this.paused = !this.paused
    if (this.paused) {
      this.stopTimer()
    } else {
      this.startTimer()
    }
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

  private statsAverageSeconds(): number {
    const games = totalGames(this.statsSummary)
    if (games <= 0) {
      return 0
    }
    return Math.round(totalSeconds(this.statsSummary) / games)
  }

  private completionRateLabel(): string {
    const games = totalGames(this.statsSummary)
    return games > 0 ? '100%' : '0%'
  }

  private totalCount(): number {
    return totalGames(this.statsSummary)
  }

  private hasMediumWin(): boolean {
    return this.statsSummary.medium.count > 0
  }

  private hasHardWin(): boolean {
    return this.statsSummary.hard.count > 0
  }

  private hasMediumFastWin(): boolean {
    return this.statsSummary.medium.bestSeconds > 0 && this.statsSummary.medium.bestSeconds <= 600
  }

  private hasHardFastWin(): boolean {
    return this.statsSummary.hard.bestSeconds > 0 && this.statsSummary.hard.bestSeconds <= 900
  }

  private unlockedCount(): number {
    let count = 0
    count += this.hasMediumWin() ? 1 : 0
    count += this.hasHardWin() ? 1 : 0
    count += this.hasMediumFastWin() ? 1 : 0
    count += this.hasHardFastWin() ? 1 : 0
    count += this.totalCount() >= 10 ? 1 : 0
    count += this.totalCount() >= 20 ? 1 : 0
    count += this.totalCount() >= 30 ? 1 : 0
    return count
  }

  private unlockPercent(): number {
    return Math.round(this.unlockedCount() / ACHIEVEMENT_TOTAL * 100)
  }

  private nextTargetLabel(): string {
    if (!this.hasMediumWin()) {
      return '首胜中等'
    }
    if (!this.hasHardWin()) {
      return '首胜困难'
    }
    if (!this.hasMediumFastWin()) {
      return '十分钟中等'
    }
    if (!this.hasHardFastWin()) {
      return '十五分钟困难'
    }
    if (this.totalCount() < 10) {
      return '完成10局'
    }
    if (this.totalCount() < 20) {
      return '完成20局'
    }
    if (this.totalCount() < 30) {
      return '完成30局'
    }
    return '全部达成'
  }

  private startHuaweiGameService(showLoginDialog: boolean): void {
    if (this.gameServiceStarted && !showLoginDialog) {
      return
    }
    this.gameServiceStarted = true
    if (deviceInfo.productModel === 'emulator') {
      this.gameServiceReady = true
      this.gameServiceMessage = ''
      this.startTimer()
      return
    }
    this.gameServiceReady = false
    this.gameServiceMessage = showLoginDialog ? '正在重新拉起华为账号登录...' : '正在进行华为账号合规校验...'
    this.loginAndVerifyHuaweiPlayer(showLoginDialog)
  }

  private async loginAndVerifyHuaweiPlayer(showLoginDialog: boolean): Promise<void> {
    const context = this.getUIContext().getHostContext() as common.UIAbilityContext
    if (!context) {
      this.handleGameServiceFailure('未获取到应用上下文，无法进行华为账号合规校验。')
      return
    }

    try {
      await HuaweiGameServiceState.waitInitialized()
      this.registerHuaweiPlayerChangedListener()

      const loginParam: gamePlayer.UnionLoginParam = {
        thirdAccountInfos: [],
        showLoginDialog: showLoginDialog
      }
      const loginResult: gamePlayer.UnionLoginResult = await gamePlayer.unionLogin(context, loginParam)
      hilog.info(LOG_DOMAIN, LOG_TAG, 'Game Service union login succeeded. account=%{public}s',
        loginResult.accountIdentifier ? loginResult.accountIdentifier : loginResult.accountName)

      const thirdUserInfo: gamePlayer.ThirdUserInfo = {
        thirdOpenId: ''
      }
      await gamePlayer.verifyLocalPlayer(context, thirdUserInfo)
      hilog.info(LOG_DOMAIN, LOG_TAG, 'Game Service local player verification succeeded.')
      await this.saveHuaweiDefaultRole(context, loginResult)

      this.gameServiceReady = true
      this.gameServiceMessage = ''
      this.startTimer()
    } catch (error) {
      const err = error as BusinessError
      const code = err && err.code !== undefined ? err.code.toString() : 'unknown'
      const message = err && err.message ? err.message : JSON.stringify(error)
      hilog.error(LOG_DOMAIN, LOG_TAG, 'Game Service login or verification failed. code=%{public}s message=%{public}s',
        code, message)
      this.handleGameServiceFailure('华为游戏服务登录或合规校验失败，请重新登录后再进入游戏。错误码：' + code)
    }
  }

  private registerHuaweiPlayerChangedListener(): void {
    try {
      gamePlayer.off('playerChanged')
      gamePlayer.on('playerChanged', (result: gamePlayer.PlayerChangedResult): void => {
        hilog.warn(LOG_DOMAIN, LOG_TAG, 'Game Service player changed. event=%{public}d', result.event)
        this.gameServiceReady = false
        this.stopTimer()
        this.startHuaweiGameService(true)
      })
    } catch (error) {
      const err = error as BusinessError
      hilog.error(LOG_DOMAIN, LOG_TAG, 'Failed to register playerChanged listener. code=%{public}d message=%{public}s',
        err.code, err.message)
    }
  }

  private async saveHuaweiDefaultRole(context: common.UIAbilityContext,
    loginResult: gamePlayer.UnionLoginResult): Promise<void> {
    const localPlayer: gamePlayer.GSKLocalPlayer = loginResult.localPlayer
    if (!localPlayer || !localPlayer.gamePlayerId) {
      return
    }
    const role: gamePlayer.GSKPlayerRole = {
      roleId: '0',
      roleName: 'default',
      gamePlayerId: localPlayer.gamePlayerId
    }
    try {
      await gamePlayer.savePlayerRole(context, role)
      hilog.info(LOG_DOMAIN, LOG_TAG, 'Game Service default role saved.')
    } catch (error) {
      const err = error as BusinessError
      hilog.warn(LOG_DOMAIN, LOG_TAG, 'Game Service default role save failed. code=%{public}d message=%{public}s',
        err.code, err.message)
    }
  }

  private handleGameServiceFailure(message: string): void {
    this.stopTimer()
    this.gameServiceReady = false
    this.gameServiceMessage = message
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
        this.TopSummary()

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
        this.BoardArea()
      }

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
    .margin({ bottom: this.contentGap })
  }

  @Builder
  TopSummary() {
    Column() {
      if (this.activeTab === 0) {
        this.StatusCard()
      } else if (this.activeTab === 1) {
        this.StatsSummaryCard()
      } else {
        this.AchievementsSummaryCard()
      }
    }
    .width(this.boardSize)
    .alignItems(HorizontalAlign.Center)
    .margin({ bottom: this.contentGap })
  }

  @Builder
  MetricItem(iconRes: Resource, valueStr: string, labelStr: ResourceStr, isError: boolean) {
    SummaryMetricItem({
      iconRes: iconRes,
      valueStr: valueStr,
      labelStr: labelStr,
      isError: isError
    })
  }

  @Builder
  TimerMetricItem() {
    Row({ space: 10 }) {
      Column() {
        Image($r('app.media.icon_clock'))
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
        TextTimer({ isCountDown: false, controller: this.textTimerController })
          .format('mm:ss')
          .fontSize($r('app.float.metric_value_font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .onTimer((_utc: number, elapsedTime: number) => {
            this.seconds = Math.max(0, Math.floor(elapsedTime || 0))
          })
          .onAppear(() => {
            this.startTimer()
          })

        Text($r('app.string.time'))
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

      this.TimerMetricItem()

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
  StatsSummaryCard() {
    Row() {
      this.MetricItem($r('app.media.icon_trophy'), totalGames(this.statsSummary).toString(), '总局数', false)

      Divider()
        .vertical(true)
        .height(48)
        .color($r('app.color.divider'))

      this.MetricItem($r('app.media.icon_clock'), formatDuration(this.statsAverageSeconds()), '平均用时', false)

      Divider()
        .vertical(true)
        .height(48)
        .color($r('app.color.divider'))

      this.MetricItem($r('app.media.icon_target'), this.completionRateLabel(), '完成率', false)
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
  AchievementsSummaryCard() {
    Row() {
      SummaryMetricItem({
        iconRes: $r('app.media.icon_trophy'),
        valueStr: this.unlockedCount().toString() + ' / ' + ACHIEVEMENT_TOTAL.toString(),
        labelStr: '已解锁成就'
      })

      Divider()
        .vertical(true)
        .height(48)
        .color($r('app.color.divider'))

      SummaryMetricItem({
        iconRes: $r('app.media.icon_clock'),
        valueStr: this.unlockPercent().toString() + '%',
        labelStr: '解锁率',
        isAccent: true
      })

      Divider()
        .vertical(true)
        .height(48)
        .color($r('app.color.divider'))

      SummaryMetricItem({
        iconRes: $r('app.media.icon_target'),
        valueStr: this.nextTargetLabel(),
        labelStr: '下一目标'
      })
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
        paused: this.paused || !this.gameServiceReady,
        mistakes: this.mistakes,
        onCellTap: (index: number) => {
          if (this.gameServiceReady) {
            this.selectedIndex = index
          }
        }
      })

      if (!this.gameServiceReady) {
        Column({ space: 12 }) {
          Text(this.gameServiceMessage)
            .fontSize(14)
            .fontWeight(FontWeight.Medium)
            .fontColor($r('app.color.text_primary'))
            .textAlign(TextAlign.Center)

          Button('重新登录')
            .fontSize(13)
            .fontColor(Color.White)
            .backgroundColor($r('app.color.primary_blue'))
            .borderRadius(18)
            .height(36)
            .padding({ left: 18, right: 18 })
            .onClick(() => {
              this.startHuaweiGameService(true)
            })
        }
        .width(this.boardSize)
        .height(this.boardSize)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor('#EAF2FFEE')
        .borderRadius($r('app.float.card_border_radius'))
        .position({ x: 0, y: 0 })
      }
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
