import { StatsSummary, formatDuration, totalGames } from '../model/StatsStore'

@Component
export struct AchievementsPage {
  @Prop summary: StatsSummary = new StatsSummary()
  @Prop contentWidth: number = 340

  private totalCount(): number {
    return totalGames(this.summary)
  }

  private hasMediumWin(): boolean {
    return this.summary.medium.count > 0
  }

  private hasHardWin(): boolean {
    return this.summary.hard.count > 0
  }

  private hasMediumFastWin(): boolean {
    return this.summary.medium.bestSeconds > 0 && this.summary.medium.bestSeconds <= 600
  }

  private hasHardFastWin(): boolean {
    return this.summary.hard.bestSeconds > 0 && this.summary.hard.bestSeconds <= 900
  }

  private clampedProgress(target: number): number {
    const progress = this.totalCount() / target * 100
    if (progress <= 0) {
      return 0
    }
    if (progress >= 100) {
      return 100
    }
    return progress
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.KeyAchievementsCard()
        this.MilestoneCard()
      }
      .width(this.contentWidth)
      .padding({ bottom: 18 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  KeyAchievementsCard() {
    Column({ space: 9 }) {
      this.SectionHeader('关键成就', '难度突破与限时挑战')

      Column({ space: 3 }) {
        this.AchievementRow('首胜中等', '首次挑战中难度成功', this.hasMediumWin(), this.hasMediumWin() ? '已完成' : '未解锁', this.hasMediumWin() ? '#1F7CFF' : '#A9B5C5', this.hasMediumWin() ? '已' : '锁', true)
        this.AchievementRow('首胜困难', '首次挑战困难难度成功', this.hasHardWin(), this.hasHardWin() ? '已完成' : '未解锁', this.hasHardWin() ? '#1F7CFF' : '#A9B5C5', this.hasHardWin() ? '已' : '锁', false)
        this.AchievementRow('十分钟中等', '中难度完成时间10分钟内', this.hasMediumFastWin(), this.hasMediumFastWin() ? formatDuration(this.summary.medium.bestSeconds) : '未解锁', this.hasMediumFastWin() ? '#3BAE5B' : '#A9B5C5', this.hasMediumFastWin() ? '快' : '锁', true)
        this.AchievementRow('十五分钟困难', '困难难度完成时间15分钟内', this.hasHardFastWin(), this.hasHardFastWin() ? formatDuration(this.summary.hard.bestSeconds) : '未解锁', this.hasHardFastWin() ? '#3BAE5B' : '#A9B5C5', this.hasHardFastWin() ? '快' : '锁', false)
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius($r('app.float.card_border_radius'))
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .shadow({ radius: 26, color: $r('app.color.card_shadow'), offsetY: 9 })
  }

  @Builder
  AchievementRow(title: string, description: string, unlocked: boolean, status: string, color: string, mark: string, shaded: boolean) {
    Row({ space: 13 }) {
      Column() {
        Text(mark)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor(color)
      }
      .width(32)
      .height(32)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .borderRadius(16)
      .backgroundColor(unlocked ? $r('app.color.bg_icon_circle') : '#F4F7FB')

      Column({ space: 4 }) {
        Text(title)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .maxLines(1)
        Text(description)
          .fontSize(10)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)

      Text(status)
        .fontSize(11)
        .fontWeight(unlocked ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(color)
        .width(58)
        .textAlign(TextAlign.End)
        .maxLines(1)
    }
    .width('100%')
    .height(48)
    .padding({ left: 8, right: 8 })
    .backgroundColor(shaded ? '#F8FBFF' : Color.Transparent)
    .borderRadius(12)
    .alignItems(VerticalAlign.Center)
  }

  @Builder
  MilestoneCard() {
    Column({ space: 11 }) {
      this.SectionHeader('局数阶梯挑战', '每完成10局解锁一个新挑战')

      this.MilestoneRow('完成10局', 10, '#1F7CFF')
      this.MilestoneRow('完成20局', 20, '#74A6FF')
      this.MilestoneRow('完成30局', 30, '#3BAE5B')
    }
    .width('100%')
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius($r('app.float.card_border_radius'))
    .padding({ left: 20, right: 20, top: 16, bottom: 16 })
    .shadow({ radius: 26, color: $r('app.color.card_shadow'), offsetY: 9 })
  }

  @Builder
  MilestoneRow(label: string, target: number, color: string) {
    Column({ space: 8 }) {
      Row() {
        Text(label)
          .fontSize(13)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
        Blank()
        Text(Math.min(this.totalCount(), target).toString() + '/' + target.toString())
          .fontSize(12)
          .fontColor($r('app.color.text_secondary'))
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)

      Stack({ alignContent: Alignment.Start }) {
        Column()
          .height(7)
          .width('100%')
          .backgroundColor('#EEF3FA')
          .borderRadius(4)
        Column()
          .height(7)
          .width(this.clampedProgress(target).toString() + '%')
          .backgroundColor(color)
          .borderRadius(4)
      }
      .width('100%')
      .height(7)
    }
    .width('100%')
  }

  @Builder
  SectionHeader(title: string, subtitle: string) {
    Column({ space: 3 }) {
      Text(title)
        .fontSize(18)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
      Text(subtitle)
        .fontSize(10)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }
}
