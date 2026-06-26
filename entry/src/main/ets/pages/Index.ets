import { AppStorageKeys, TimerState } from '../utils/Constants';
import { TimerService } from '../services/TimerService';
import { TimerPage } from './TimerPage';
import { StatisticsPage } from './StatisticsPage';
import { SettingsPage } from './SettingsPage';

@Entry
@Component
struct Index {
  @StorageLink(AppStorageKeys.CURRENT_TAB) currentTab: number = 0;
  @StorageLink(AppStorageKeys.TIMER_STATE) timerState: string = TimerState.IDLE;

  private tabsController: TabsController = new TabsController();
  private timerService: TimerService = TimerService.getInstance();

  aboutToAppear(): void {
    this.timerService.init();

    //调用 TimerService 的 setOnFocusComplete 方法，把箭头函数传进去，TimerService 内部用 = 把收到的箭头函数存到自己的 onFocusComplete 属性里。
    //***遇到自己不清楚的，一定要花时间搞清楚，不能模棱两可，之前一直不知道这种写法干了什么事，今天才知道
    //不会立即执行onFocusComplete方法，意识到这个很重要，也很基础
    this.timerService.setOnFocusComplete(() => {
      this.onFocusComplete();
    });
  }

  onFocusComplete(): void {
    const interval = AppStorage.get(AppStorageKeys.LONG_BREAK_INTERVAL) as number || 4;
    const session = AppStorage.get(AppStorageKeys.SESSION_POMODOROS) as number;
    AlertDialog.show({
      title: '专注完成！',
      message: session >= interval ? '该进行长休息了' : '该进行短休息了',
      autoCancel: false,
      primaryButton: {
        value: '短休息',
        action: () => {
          this.timerService.startShortBreak();
        }
      },
      secondaryButton: {
        value: session >= interval ? '长休息' : '继续专注',
        action: () => {
          if (session >= interval) {
            this.timerService.startLongBreak();
          } else {
            this.timerService.startFocus();
          }
        }
      }
    });
  }

  build() {
    Column() {
      Tabs({
        barPosition: BarPosition.End,
        index: this.currentTab,
        controller: this.tabsController
      }) {
        TabContent() {
          TimerPage()
        }
        .tabBar(this.createTabItem('专注', 0))

        TabContent() {
          StatisticsPage()
        }
        .tabBar(this.createTabItem('统计', 1))

        TabContent() {
          SettingsPage()
        }
        .tabBar(this.createTabItem('设置', 2))
      }
      .width('100%')
      .height('100%')
      .onChange((index: number) => {
        this.currentTab = index;
      })
    }
    .width('100%')
    .height('100%')
    .backgroundColor('#F0F2F5')
  }

  @Builder
  createTabItem(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(14)
        .fontColor(this.currentTab === index ? '#FF6B6B' : '#999999')
        .fontWeight(this.currentTab === index ? FontWeight.Medium : FontWeight.Regular)
    }
    .padding({ top: 8, bottom: 12 })
    .width('100%')
  }
}
