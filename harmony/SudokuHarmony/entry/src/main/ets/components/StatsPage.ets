import { DifficultyStats, StatsSummary, averageSeconds, formatDuration, totalGames } from '../model/StatsStore'

@Component
export struct StatsPage {
  @Prop summary: StatsSummary = new StatsSummary()
  @Prop contentWidth: number = 340

  private maxDifficultyCount(): number {
    const maxCount = Math.max(this.summary.easy.count, this.summary.medium.count, this.summary.hard.count)
    return maxCount <= 0 ? 1 : maxCount
  }

  build() {
    Scroll() {
      Column({ space: 14 }) {
        this.DistributionCard()
        this.TimeCard()
      }
      .width(this.contentWidth)
      .padding({ bottom: 18 })
    }
    .width('100%')
    .layoutWeight(1)
    .scrollBar(BarState.Off)
  }

  @Builder
  DistributionCard() {
    Column({ space: 12 }) {
      this.SectionHeader('难度局数分布', '按已完成棋局统计')

      Row({ space: 18 }) {
        Stack() {
          Circle()
            .width(108)
            .height(108)
            .fill('#EAF2FF')
          Circle()
            .width(76)
            .height(76)
            .fill($r('app.color.bg_card'))
          Column({ space: 2 }) {
            Text(totalGames(this.summary).toString())
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .fontColor($r('app.color.text_primary'))
            Text('局')
              .fontSize(11)
              .fontColor($r('app.color.text_secondary'))
          }
          .alignItems(HorizontalAlign.Center)
        }
        .width(108)
        .height(108)

        Column({ space: 12 }) {
          this.DistributionRow('简单', this.summary.easy.count, '#1F7CFF')
          this.DistributionRow('中等', this.summary.medium.count, '#74A6FF')
          this.DistributionRow('困难', this.summary.hard.count, '#3BAE5B')
        }
        .layoutWeight(1)
      }
      .width('100%')
      .alignItems(VerticalAlign.Center)
    }
    .width('100%')
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius($r('app.float.card_border_radius'))
    .padding({ left: 20, right: 20, top: 18, bottom: 18 })
    .shadow({ radius: 26, color: $r('app.color.card_shadow'), offsetY: 9 })
  }

  @Builder
  DistributionRow(label: string, count: number, color: string) {
    Column({ space: 6 }) {
      Row() {
        Circle()
          .width(8)
          .height(8)
          .fill(color)
        Text(label)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
          .margin({ left: 10 })
        Blank()
        Text(count.toString() + '局')
          .fontSize(14)
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
          .width((count / this.maxDifficultyCount() * 100).toString() + '%')
          .backgroundColor(color)
          .borderRadius(4)
      }
      .width('100%')
      .height(7)
    }
    .width('100%')
  }

  @Builder
  TimeCard() {
    Column({ space: 12 }) {
      this.SectionHeader('各难度用时', '平均、最快和最长完成时间')

      Row() {
        this.TableHeaderCell('难度', 1.15)
        this.TableHeaderCell('平均', 1)
        this.TableHeaderCell('最快', 1)
        this.TableHeaderCell('最长', 1)
      }
      .width('100%')

      Column({ space: 6 }) {
        this.TimeRow('简单', this.summary.easy, '#1F7CFF', true)
        this.TimeRow('中等', this.summary.medium, '#74A6FF', false)
        this.TimeRow('困难', this.summary.hard, '#3BAE5B', true)
      }
      .width('100%')
    }
    .width('100%')
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius($r('app.float.card_border_radius'))
    .padding({ left: 20, right: 20, top: 18, bottom: 18 })
    .shadow({ radius: 26, color: $r('app.color.card_shadow'), offsetY: 9 })
  }

  @Builder
  SectionHeader(title: string, subtitle: string) {
    Column({ space: 4 }) {
      Text(title)
        .fontSize(19)
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_primary'))
      Text(subtitle)
        .fontSize(11)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  TableHeaderCell(label: string, weight: number) {
    Text(label)
      .layoutWeight(weight)
      .fontSize(12)
      .fontWeight(FontWeight.Medium)
      .fontColor($r('app.color.text_secondary'))
  }

  @Builder
  TimeRow(label: string, stats: DifficultyStats, color: string, shaded: boolean) {
    Row() {
      Row({ space: 9 }) {
        Circle()
          .width(8)
          .height(8)
          .fill(color)
        Text(label)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .fontColor($r('app.color.text_primary'))
      }
      .layoutWeight(1.15)
      .alignItems(VerticalAlign.Center)

      Text(formatDuration(averageSeconds(stats)))
        .layoutWeight(1)
        .fontSize(14)
        .fontColor($r('app.color.text_primary'))
      Text(formatDuration(stats.bestSeconds))
        .layoutWeight(1)
        .fontSize(14)
        .fontColor($r('app.color.success_green'))
      Text(formatDuration(stats.worstSeconds))
        .layoutWeight(1)
        .fontSize(14)
        .fontColor($r('app.color.text_secondary'))
    }
    .width('100%')
    .height(34)
    .padding({ left: 10, right: 10 })
    .backgroundColor(shaded ? '#F8FBFF' : Color.Transparent)
    .borderRadius(10)
    .alignItems(VerticalAlign.Center)
  }
}
