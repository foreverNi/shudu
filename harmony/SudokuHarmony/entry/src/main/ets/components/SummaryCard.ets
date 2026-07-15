@Component
export struct SummaryMetricItem {
  iconRes: Resource = $r('app.media.icon_target')
  valueStr: string = ''
  labelStr: ResourceStr = ''
  isError: boolean = false
  isAccent: boolean = false

  build() {
    Row({ space: 10 }) {
      Column() {
        Image(this.iconRes)
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
        Text(this.valueStr)
          .fontSize($r('app.float.metric_value_font_size'))
          .fontWeight(FontWeight.Medium)
          .fontColor(this.isError ? $r('app.color.error_red') :
            (this.isAccent ? $r('app.color.primary_blue') : $r('app.color.text_primary')))
          .maxLines(1)

        Text(this.labelStr)
          .fontSize($r('app.float.metric_label_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor($r('app.color.text_secondary'))
          .maxLines(1)
      }
      .alignItems(HorizontalAlign.Start)
    }
    .layoutWeight(1)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }
}
