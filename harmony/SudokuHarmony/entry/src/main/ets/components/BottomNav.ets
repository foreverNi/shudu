@Component
export struct BottomNav {
  @Prop activeTab: number = 0
  onTabChange: (tab: number) => void = () => {}

  build() {
    Row() {
      this.TabItem(0, $r('app.media.icon_home'), $r('app.string.tab_game'))
      this.TabItem(1, $r('app.media.icon_stats_gray'), $r('app.string.tab_stats'))
      this.TabItem(2, $r('app.media.icon_trophy_gray'), $r('app.string.tab_achievements'))
    }
    .width('100%')
    .height($r('app.float.bottom_nav_h'))
    .backgroundColor($r('app.color.bg_card'))
    .borderRadius({ topLeft: 20, topRight: 20 })
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
    .shadow({ radius: 24, color: $r('app.color.card_shadow'), offsetY: -8 })
  }

  @Builder
  TabItem(index: number, iconRes: Resource, label: ResourceStr) {
    Column({ space: 4 }) {
      Image(iconRes)
        .width(24)
        .height(24)
        .objectFit(ImageFit.Contain)
      Text(label)
        .fontSize($r('app.float.nav_font_size'))
        .fontWeight(index === 0 ? FontWeight.Medium : FontWeight.Normal)
        .fontColor(index === 0 ? $r('app.color.nav_active') : $r('app.color.nav_default'))
    }
    .width(92)
    .height(49)
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .borderRadius(18)
    .backgroundColor(index === 0 ? $r('app.color.nav_active_bg') : Color.Transparent)
    .onClick(() => {
      this.onTabChange(index)
    })
  }
}
