import { SudokuDifficulty, difficultyLabel, difficultyDescription } from '../model/SudokuModels'

@Component
export struct DifficultySheet {
  @Link sheetDifficulty: SudokuDifficulty
  onStart: () => void = () => {}
  onCancel: () => void = () => {}

  private isSelected(d: SudokuDifficulty): boolean {
    return this.sheetDifficulty === d
  }

  private optionBg(d: SudokuDifficulty): ResourceColor {
    return this.isSelected(d) ? $r('app.color.difficulty_bg_selected') : $r('app.color.difficulty_bg_unselected')
  }

  private optionBorderW(d: SudokuDifficulty): Length {
    return this.isSelected(d) ? '1.4vp' : '1vp'
  }

  private optionBorderC(d: SudokuDifficulty): ResourceColor {
    return this.isSelected(d) ? $r('app.color.difficulty_border_selected') : $r('app.color.difficulty_border_unselected')
  }

  private dotColor(i: number, d: SudokuDifficulty): ResourceColor {
    return i < (d + 1) ? $r('app.color.difficulty_dot_active') : $r('app.color.difficulty_dot_inactive')
  }

  private dotHeight(i: number): number {
    return 18 + i * 4
  }

  build() {
    Column() {
      Column() {
        Divider()
          .width(36)
          .height(4)
          .color('#33182431')
          .borderRadius(2)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Center)
      .margin({ top: 12, bottom: 18 })

      Text('选择难度')
        .fontSize($r('app.float.section_title_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor($r('app.color.text_primary'))
        .margin({ bottom: 16 })

      Column({ space: 10 }) {
        ForEach([SudokuDifficulty.Easy, SudokuDifficulty.Medium, SudokuDifficulty.Hard],
          (d: SudokuDifficulty) => {
            Row() {
              Row({ space: 3 }) {
                ForEach([0, 1, 2], (i: number) => {
                  Column()
                    .width(6)
                    .height(this.dotHeight(i))
                    .backgroundColor(this.dotColor(i, d))
                    .borderRadius(99)
                }, (i: number) => i.toString())
              }
              .alignItems(VerticalAlign.Bottom)

              Column({ space: 2 }) {
                Text(difficultyLabel(d))
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.text_primary'))
                Text(difficultyDescription(d))
                  .fontSize(12)
                  .fontColor($r('app.color.difficulty_desc'))
              }
              .margin({ left: 12 })
              .alignItems(HorizontalAlign.Start)
              .layoutWeight(1)

              if (this.isSelected(d)) {
                Text('✓')
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor($r('app.color.primary_blue'))
              }
            }
            .width('100%')
            .padding({ left: 14, right: 14, top: 12, bottom: 12 })
            .backgroundColor(this.optionBg(d))
            .borderRadius(12)
            .border({
              width: this.optionBorderW(d),
              color: this.optionBorderC(d)
            })
            .onClick(() => {
              this.sheetDifficulty = d
            })
          }, (d: SudokuDifficulty) => d.toString())
      }

      Button('开始游戏')
        .fontSize($r('app.float.button_font_size'))
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .backgroundColor($r('app.color.primary_blue'))
        .borderRadius($r('app.float.btn_border_radius'))
        .width('100%')
        .height(52)
        .margin({ top: 20 })
        .onClick(() => {
          this.onStart()
        })

      Button('取消')
        .fontSize($r('app.float.button_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.text_secondary'))
        .backgroundColor(Color.Transparent)
        .width('100%')
        .height(44)
        .onClick(() => {
          this.onCancel()
        })
    }
    .width('100%')
    .padding({ left: 20, right: 20, bottom: 20 })
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius({ topLeft: 24, topRight: 24 })
  }
}
