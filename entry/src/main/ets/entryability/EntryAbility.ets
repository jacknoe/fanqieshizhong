import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { TimerService } from '../services/TimerService';
import { PersistenceService } from '../services/PersistenceService';

const DOMAIN = 0x0000;

export default class EntryAbility extends UIAbility {
  private timerService: TimerService = TimerService.getInstance();
  private persistence: PersistenceService = PersistenceService.getInstance();

  async onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): Promise<void> {
    this.timerService.init();
    this.timerService.setPersistence(this.persistence);
    await this.persistence.init(this.context);
    await this.persistence.loadAll();
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');

    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    this.timerService.handleAppForeground();
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    this.timerService.handleAppBackground();
    this.persistence.saveAll();
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
