import { SudokuCell } from '../model/SudokuModels'

@Component
export struct SudokuBoard {
  @Link cells: SudokuCell[]
  @Prop selectedIndex: number = 0
  @Prop paused: boolean = false
  @Prop mistakes: number = 0
  onCellTap: (index: number) => void = () => {}

  private isRelated(index: number): boolean {
    const sr: number = Math.floor(this.selectedIndex / 9)
    const sc: number = this.selectedIndex % 9
    const row: number = Math.floor(index / 9)
    const col: number = index % 9
    return row === sr || col === sc ||
      (Math.floor(row / 3) === Math.floor(sr / 3) && Math.floor(col / 3) === Math.floor(sc / 3))
  }

  private isSameNumber(index: number): boolean {
    const sv: number = this.cells[this.selectedIndex].value
    return sv !== 0 && this.cells[index].value === sv
  }

  private isErrorCell(index: number): boolean {
    const cell: SudokuCell = this.cells[index]
    return !cell.fixed && cell.value !== 0 && this.mistakes > 0
  }

  private cellBg(index: number): ResourceColor {
    if (index === this.selectedIndex) {
      return $r('app.color.cell_selected')
    }
    if (this.isErrorCell(index)) {
      return $r('app.color.cell_error_bg')
    }
    if (this.isSameNumber(index)) {
      return $r('app.color.cell_same_number')
    }
    if (this.isRelated(index)) {
      return $r('app.color.cell_related')
    }
    return $r('app.color.bg_card')
  }

  private rightBorderW(col: number): Length {
    if (col === 2 || col === 5) { return '2vp' }
    if (col === 8) { return 0 }
    return '1vp'
  }

  private bottomBorderW(row: number): Length {
    if (row === 2 || row === 5) { return '2vp' }
    if (row === 8) { return 0 }
    return '1vp'
  }

  private borderC(row: number, col: number): ResourceColor {
    if (row === 2 || row === 5 || col === 2 || col === 5) {
      return $r('app.color.board_line_thick')
    }
    return $r('app.color.board_line_thin')
  }

  private cellTextColor(index: number): ResourceColor {
    const cell: SudokuCell = this.cells[index]
    if (this.isErrorCell(index)) {
      return $r('app.color.cell_error_text')
    }
    if (cell.fixed) {
      return $r('app.color.cell_fixed_text')
    }
    return $r('app.color.cell_filled_text')
  }

  build() {
    Column() {
      Grid() {
        ForEach(this.cells, (cell: SudokuCell, index: number) => {
          GridItem() {
            this.CellBuilder(index)
          }
        }, (cell: SudokuCell, index: number) => index.toString() + '_' + cell.value.toString() + '_' + cell.noteFlags.join(''))
      }
      .columnsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .rowsTemplate('1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr 1fr')
      .width('100%')
      .height('100%')
    }
    .backgroundColor('#FCFEFF')
    .borderRadius($r('app.float.board_border_radius'))
    .border({ width: 1.2, color: $r('app.color.board_border'), radius: $r('app.float.board_border_radius') })
    .shadow({ radius: 16, color: '#14396518', offsetY: 8 })
  }

  @Builder
  CellBuilder(index: number) {
    Column() {
      if (this.paused) {
        Text('')
          .fontSize(0)
      } else if (this.cells[index].value !== 0) {
        Text(this.cells[index].value.toString())
          .fontSize($r('app.float.cell_digit_font_size'))
          .fontWeight(FontWeight.Normal)
          .fontColor(this.cellTextColor(index))
      } else {
        Grid() {
          ForEach([1, 2, 3, 4, 5, 6, 7, 8, 9], (num: number) => {
            GridItem() {
              Text(this.cells[index].hasNote(num) ? num.toString() : '')
                .fontSize($r('app.float.note_digit_font_size'))
                .fontWeight(FontWeight.Medium)
                .fontColor($r('app.color.cell_note_text'))
                .textAlign(TextAlign.Center)
            }
          }, (num: number) => num.toString())
        }
        .columnsTemplate('1fr 1fr 1fr')
        .rowsTemplate('1fr 1fr 1fr')
        .width('100%')
        .height('100%')
        .padding(2)
      }
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor(this.cellBg(index))
    .border({
      width: index === this.selectedIndex
        ? { right: this.rightBorderW(index % 9), bottom: this.bottomBorderW(Math.floor(index / 9)), left: '1.2vp', top: '1.2vp' }
        : { right: this.rightBorderW(index % 9), bottom: this.bottomBorderW(Math.floor(index / 9)) },
      color: index === this.selectedIndex
        ? { right: this.borderC(Math.floor(index / 9), index % 9), bottom: this.borderC(Math.floor(index / 9), index % 9), left: $r('app.color.cell_selected_border'), top: $r('app.color.cell_selected_border') }
        : { right: this.borderC(Math.floor(index / 9), index % 9), bottom: this.borderC(Math.floor(index / 9), index % 9) }
    })
    .onClick(() => {
      this.onCellTap(index)
    })
  }
}
