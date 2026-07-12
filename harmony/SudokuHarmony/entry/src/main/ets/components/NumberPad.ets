@Component
export struct NumberPad {
  @Prop selectedNumber: number = 0
  onNumber: (num: number) => void = () => {}
  @State pressedNum: number = -1

  build() {
    Row({ space: 6 }) {
      ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9], (num: number) => {
        Column() {
          Text(num.toString())
            .fontSize($r('app.float.numpad_font_size'))
            .fontWeight(FontWeight.Medium)
            .fontColor(this.selectedNumber === num ? Color.White : $r('app.color.numpad_text'))
        }
        .width(35)
        .height(36)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
        .backgroundColor(this.selectedNumber === num ? $r('app.color.numpad_active_bg') : $r('app.color.numpad_bg'))
        .borderRadius($r('app.float.numpad_btn_radius'))
        .shadow({ radius: 16, color: $r('app.color.btn_shadow'), offsetY: 5 })
        .scale(this.pressedNum === num ? { x: 0.95, y: 0.95 } : { x: 1, y: 1 })
        .animation({ duration: 100 })
        .onClick(() => {
          this.onNumber(num)
        })
        .onTouch((event: TouchEvent) => {
          if (event.type === TouchType.Down) {
            this.pressedNum = num
          } else {
            this.pressedNum = -1
          }
        })
      }, (num: number) => num.toString())
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceBetween)
  }
}
