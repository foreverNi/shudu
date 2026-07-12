@Component
export struct ActionToolbar {
  @Prop noteMode: boolean = false
  @Prop hintCount: number = 3
  onUndo: () => void = () => {}
  onErase: () => void = () => {}
  onHint: () => void = () => {}
  onNoteMode: () => void = () => {}

  build() {
    Row({ space: 8 }) {
      this.ToolButton($r('app.media.icon_undo'), $r('app.string.undo'), () => { this.onUndo() }, 50, 50)
      this.ToolButton($r('app.media.icon_erase'), $r('app.string.erase'), () => { this.onErase() }, 50, 50)

      Stack() {
        this.ToolButton($r('app.media.icon_hint'), $r('app.string.hint'), () => { this.onHint() }, 50, 50)
        if (this.hintCount > 0) {
          Text(this.hintCount.toString())
            .fontSize($r('app.float.badge_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor($r('app.color.badge_text'))
            .backgroundColor($r('app.color.badge_bg'))
            .borderRadius(10)
            .width(20)
            .height(20)
            .textAlign(TextAlign.Center)
            .position({ x: 40, y: -8 })
        }
      }
      .width(50)
      .height(50)

      Blank()

      Button() {
        Row({ space: 8 }) {
          Image($r('app.media.icon_note_white'))
            .width(28)
            .height(28)
            .objectFit(ImageFit.Contain)
          Text($r('app.string.note'))
            .fontSize($r('app.float.candidate_font_size'))
            .fontWeight(FontWeight.Bold)
            .fontColor(Color.White)
        }
        .justifyContent(FlexAlign.Center)
        .alignItems(VerticalAlign.Center)
      }
      .width(94)
      .height(50)
      .linearGradient({
        angle: 180,
        colors: [['#2E8BFF', 0], ['#1376F8', 1]]
      })
      .borderRadius(14)
      .onClick(() => {
        this.onNoteMode()
      })
    }
    .width('100%')
    .height($r('app.float.toolbar_h'))
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius(18)
    .padding({ left: 10, right: 10 })
    .alignItems(VerticalAlign.Center)
    .shadow({ radius: 26, color: $r('app.color.card_shadow'), offsetY: 10 })
  }

  @Builder
  ToolButton(iconRes: Resource, label: ResourceStr, action: () => void, w: number, h: number) {
    Column({ space: 4 }) {
      Image(iconRes)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(label)
        .fontSize($r('app.float.tool_label_font_size'))
        .fontWeight(FontWeight.Medium)
        .fontColor($r('app.color.btn_tool_text'))
    }
    .width(w)
    .height(h)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor($r('app.color.btn_tool_bg'))
    .borderRadius(12)
    .shadow({ radius: 16, color: $r('app.color.btn_shadow'), offsetY: 5 })
    .onClick(() => {
      action()
    })
  }
}
