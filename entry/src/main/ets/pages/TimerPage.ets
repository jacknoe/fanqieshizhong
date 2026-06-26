import { TimerState, AppStorageKeys, formatTime } from '../utils/Constants';
import { TimerService } from '../services/TimerService';

@Component
export struct TimerPage {
  @StorageLink(AppStorageKeys.TIMER_STATE) state: string = TimerState.IDLE;
  @StorageLink(AppStorageKeys.REMAINING_SECONDS) remainingSeconds: number = 0;
  @StorageLink(AppStorageKeys.TOTAL_SECONDS) totalSeconds: number = 0;
  @StorageLink(AppStorageKeys.COMPLETED_POMODOROS) completedPomodoros: number = 0;
  @StorageLink(AppStorageKeys.SESSION_POMODOROS) sessionPomodoros: number = 0;

  private timerService: TimerService = TimerService.getInstance();

  get stateLabel(): string {
    if (this.state === TimerState.FOCUSING || this.state === TimerState.FOCUS_PAUSED) {
      return '专注中';
    } else if (this.state === TimerState.SHORT_BREAK || this.state === TimerState.SHORT_BREAK_PAUSED) {
      return '短休息';
    } else if (this.state === TimerState.LONG_BREAK || this.state === TimerState.LONG_BREAK_PAUSED) {
      return '长休息';
    }
    return '准备开始';
  }

  get timerColor(): ResourceColor {
    if (this.state === TimerState.FOCUSING || this.state === TimerState.FOCUS_PAUSED) {
      return '#FF6B6B';
    } else if (this.state === TimerState.SHORT_BREAK || this.state === TimerState.SHORT_BREAK_PAUSED ||
      this.state === TimerState.LONG_BREAK || this.state === TimerState.LONG_BREAK_PAUSED) {
      return '#4ECB71';
    }
    return '#FF6B6B';
  }

  build() {
    Column() {
      Stack() {
        Progress({ value: this.totalSeconds <= 0 ? 0 : (this.totalSeconds - this.remainingSeconds) / this.totalSeconds, total: 1, type: ProgressType.Ring })
          .width(280)
          .height(280)
          .style({ strokeWidth: 14 })
          .color(this.timerColor)
          .backgroundColor('#E8E8E8')

        Column() {
          Text(formatTime(this.remainingSeconds))
            .fontSize(64)
            .fontWeight(FontWeight.Bold)
            .fontColor('#333333')
          Text(this.stateLabel)
            .fontSize(18)
            .fontColor('#666666')
            .margin({ top: 8 })
        }
        .alignItems(HorizontalAlign.Center)
      }
      .width(280)
      .height(280)

      Row() {
        if (this.state === TimerState.IDLE) {
          Button('开始')
            .width(120)
            .height(48)
            .backgroundColor('#FF6B6B')
            .borderRadius(24)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.timerService.startFocus();
            })
        } else if (this.state === TimerState.FOCUSING || this.state === TimerState.SHORT_BREAK ||
          this.state === TimerState.LONG_BREAK) {
          Button('暂停')
            .width(120)
            .height(48)
            .backgroundColor('#FFA500')
            .borderRadius(24)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.timerService.pause();
            })
        } else if (this.state === TimerState.FOCUS_PAUSED || this.state === TimerState.SHORT_BREAK_PAUSED ||
          this.state === TimerState.LONG_BREAK_PAUSED) {
          Button('继续')
            .width(120)
            .height(48)
            .backgroundColor('#4ECB71')
            .borderRadius(24)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.timerService.resume();
            })
        }

        if (this.state !== TimerState.IDLE) {
          Blank()
            .width(24)
          Button('重置')
            .width(120)
            .height(48)
            .backgroundColor('#999999')
            .borderRadius(24)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor('#FFFFFF')
            .onClick(() => {
              this.timerService.reset();
            })
        }
      }
      .margin({ top: 40 })
      .justifyContent(FlexAlign.Center)

      this.createProgressDots()

      Text(`${this.completedPomodoros} 个番茄已完成`)
        .fontSize(14)
        .fontColor('#999999')
        .margin({ top: 24 })
    }
    .width('100%')
    .height('100%')
    .padding({ top: 40 })
    .backgroundColor('#F0F2F5')
  }

  @Builder
  createProgressDots() {
    Row() {
      ForEach(this.dotItems, (dot: DotItem) => {
        Circle()
          .width(12)
          .height(12)
          .fill(dot.filled ? '#FF6B6B' : '#D0D0D0')
          .margin({ left: 6, right: 6 })
      }, (dot: DotItem) => dot.index.toString())
    }
    .margin({ top: 32 })
  }

  get dotItems(): DotItem[] {
    const interval = AppStorage.get(AppStorageKeys.LONG_BREAK_INTERVAL) as number || 4;
    const items: DotItem[] = [];
    for (let i = 0; i < interval; i++) {
      items.push(new DotItem(i < this.sessionPomodoros, i));
    }
    return items;
  }
}

class DotItem {
  filled: boolean;
  index: number;

  constructor(filled: boolean, index: number) {
    this.filled = filled;
    this.index = index;
  }
}
