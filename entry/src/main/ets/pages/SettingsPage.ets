 import { DEFAULT_FOCUS_MINUTES, DEFAULT_SHORT_BREAK_MINUTES, DEFAULT_LONG_BREAK_MINUTES,
  POMODOROS_BEFORE_LONG_BREAK, AppStorageKeys } from '../utils/Constants';
import { TimerService } from '../services/TimerService';

@Component
export struct SettingsPage {
  @StorageLink(AppStorageKeys.FOCUS_MINUTES) focusMinutes: number = DEFAULT_FOCUS_MINUTES;
  @StorageLink(AppStorageKeys.SHORT_BREAK_MINUTES) shortBreakMinutes: number = DEFAULT_SHORT_BREAK_MINUTES;
  @StorageLink(AppStorageKeys.LONG_BREAK_MINUTES) longBreakMinutes: number = DEFAULT_LONG_BREAK_MINUTES;
  @StorageLink(AppStorageKeys.LONG_BREAK_INTERVAL) longBreakInterval: number = POMODOROS_BEFORE_LONG_BREAK;
  @StorageLink(AppStorageKeys.DAILY_GOAL) dailyGoal: number = 8;

  private timerService: TimerService = TimerService.getInstance();

  build() {
    Column() {
      Scroll() {
        Column() {
          this.focusCard()
          this.shortBreakCard()
          this.longBreakCard()
          this.intervalCard()
          this.goalCard()
          this.resetCard()
        }
        .width('100%')
        .padding(16)
      }
      .height('100%')
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  focusCard() {
    Column() {
      Row() {
        Text('专注时长')
          .fontSize(16)
          .fontColor('#FFFFFF')
        Text(`${this.focusMinutes} 分钟`)
          .fontSize(16)
          .fontColor('#FF6B6B')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Slider({ value: this.focusMinutes, min: 5, max: 60, step: 1, style: SliderStyle.OutSet })
        .width('100%')
        .blockColor('#FF6B6B')
        .trackColor('#2A2A4A')
        .selectedColor('#FF6B6B')
        .showSteps(true)
        .onChange((v: number) => { this.focusMinutes = v; })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#16213E')
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  @Builder
  shortBreakCard() {
    Column() {
      Row() {
        Text('短休息时长')
          .fontSize(16)
          .fontColor('#FFFFFF')
        Text(`${this.shortBreakMinutes} 分钟`)
          .fontSize(16)
          .fontColor('#4ECB71')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Slider({ value: this.shortBreakMinutes, min: 1, max: 30, step: 1, style: SliderStyle.OutSet })
        .width('100%')
        .blockColor('#4ECB71')
        .trackColor('#2A2A4A')
        .selectedColor('#4ECB71')
        .showSteps(true)
        .onChange((v: number) => { this.shortBreakMinutes = v; })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#16213E')
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  @Builder
  longBreakCard() {
    Column() {
      Row() {
        Text('长休息时长')
          .fontSize(16)
          .fontColor('#FFFFFF')
        Text(`${this.longBreakMinutes} 分钟`)
          .fontSize(16)
          .fontColor('#4ECB71')
          .fontWeight(FontWeight.Medium)
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Slider({ value: this.longBreakMinutes, min: 5, max: 60, step: 1, style: SliderStyle.OutSet })
        .width('100%')
        .blockColor('#4ECB71')
        .trackColor('#2A2A4A')
        .selectedColor('#4ECB71')
        .showSteps(true)
        .onChange((v: number) => { this.longBreakMinutes = v; })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#16213E')
    .borderRadius(16)
    .margin({ bottom: 12 })
  }

  @Builder
  intervalCard() {
    Column() {
      Row() {
        Text('长休息间隔')
          .fontSize(16)
          .fontColor('#FFFFFF')
        Text(`每 ${this.longBreakInterval} 个番茄`)
          .fontSize(14)
          .fontColor('#888888')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 })

      Row() {
        Button('-')
          .width(44)
          .height(44)
          .backgroundColor(this.longBreakInterval > 2 ? '#3A3A5A' : '#2A2A3A')
          .borderRadius(22)
          .fontSize(24)
          .fontColor(this.longBreakInterval > 2 ? '#FFFFFF' : '#555555')
          .enabled(this.longBreakInterval > 2)
          .onClick(() => { if (this.longBreakInterval > 2) this.longBreakInterval--; })

        Text(`${this.longBreakInterval}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(60)
          .textAlign(TextAlign.Center)

        Button('+')
          .width(44)
          .height(44)
          .backgroundColor(this.longBreakInterval < 8 ? '#3A3A5A' : '#2A2A3A')
          .borderRadius(22)
          .fontSize(24)
          .fontColor(this.longBreakInterval < 8 ? '#FFFFFF' : '#555555')
          .enabled(this.longBreakInterval < 8)
          .onClick(() => { if (this.longBreakInterval < 8) this.longBreakInterval++; })
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#16213E')
    .borderRadius(16)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  goalCard() {
    Column() {
      Row() {
        Text('每日目标')
          .fontSize(16)
          .fontColor('#FFFFFF')
        Text(`${this.dailyGoal} 个番茄`)
          .fontSize(14)
          .fontColor('#888888')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)
      .margin({ bottom: 12 })

      Row() {
        Button('-')
          .width(44)
          .height(44)
          .backgroundColor(this.dailyGoal > 2 ? '#3A3A5A' : '#2A2A3A')
          .borderRadius(22)
          .fontSize(24)
          .fontColor(this.dailyGoal > 2 ? '#FFFFFF' : '#555555')
          .enabled(this.dailyGoal > 2)
          .onClick(() => { if (this.dailyGoal > 2) this.dailyGoal--; })

        Text(`${this.dailyGoal}`)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#FFFFFF')
          .width(60)
          .textAlign(TextAlign.Center)

        Button('+')
          .width(44)
          .height(44)
          .backgroundColor(this.dailyGoal < 20 ? '#3A3A5A' : '#2A2A3A')
          .borderRadius(22)
          .fontSize(24)
          .fontColor(this.dailyGoal < 20 ? '#FFFFFF' : '#555555')
          .enabled(this.dailyGoal < 20)
          .onClick(() => { if (this.dailyGoal < 20) this.dailyGoal++; })
      }
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#16213E')
    .borderRadius(16)
    .margin({ bottom: 12 })
    .alignItems(HorizontalAlign.Center)
  }

  @Builder
  resetCard() {
    Button('重置统计数据')
      .width('100%')
      .height(48)
      .backgroundColor('#FF4444')
      .borderRadius(24)
      .fontSize(16)
      .fontColor('#FFFFFF')
      .margin({ top: 20, bottom: 40 })
      .onClick(() => {
        AlertDialog.show({
          title: '确认重置',
          message: '将清除所有统计数据，确定继续？',
          primaryButton: {
            value: '取消',
            action: () => {}
          },
          secondaryButton: {
            value: '确认',
            action: () => {
              this.timerService.resetDailyStats();
            }
          }
        });
      })
  }
}
