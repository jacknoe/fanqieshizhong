import { preferences } from '@kit.ArkData';
import { Context } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { AppStorageKeys } from '../utils/Constants';

const STORE_NAME = 'pomodoro_prefs';
const DOMAIN = 0x0000;

const SAVE_KEYS: string[] = [
  AppStorageKeys.COMPLETED_POMODOROS,
  AppStorageKeys.SESSION_POMODOROS,
  AppStorageKeys.TODAY_COMPLETED,
  AppStorageKeys.TODAY_FOCUS_MINUTES,
  AppStorageKeys.FOCUS_MINUTES,
  AppStorageKeys.SHORT_BREAK_MINUTES,
  AppStorageKeys.LONG_BREAK_MINUTES,
  AppStorageKeys.LONG_BREAK_INTERVAL,
  AppStorageKeys.DAILY_GOAL,
];

export class PersistenceService {
  private static instance: PersistenceService;
  private dataStore: preferences.Preferences | null = null;
  private ready: boolean = false;

  static getInstance(): PersistenceService {
    if (PersistenceService.instance === undefined) {
      PersistenceService.instance = new PersistenceService();
    }
    return PersistenceService.instance;
  }

  async init(context: Context): Promise<void> {
    if (this.ready) {
      return;
    }
    try {
      this.dataStore = await preferences.getPreferences(context, STORE_NAME);
      this.ready = true;
      hilog.info(DOMAIN, 'Persistence', 'Preferences initialized');
    } catch (e) {
      hilog.error(DOMAIN, 'Persistence', 'Failed to init: %{public}s', JSON.stringify(e));
    }
  }

  async loadAll(): Promise<void> {
    if (!this.ready || this.dataStore === null) {
      return;
    }
    for (let i = 0; i < SAVE_KEYS.length; i++) {
      const key = SAVE_KEYS[i];
      try {
        const saved = await this.dataStore.get(key, -1);
        if (saved !== -1) {
          AppStorage.setOrCreate(key, saved);
        }
      } catch (e) {
        hilog.error(DOMAIN, 'Persistence', 'Failed to load key %{public}s: %{public}s', key, JSON.stringify(e));
      }
    }
    hilog.info(DOMAIN, 'Persistence', 'Data loaded');
  }

  async saveAll(): Promise<void> {
    if (!this.ready || this.dataStore === null) {
      return;
    }
    for (let i = 0; i < SAVE_KEYS.length; i++) {
      const key = SAVE_KEYS[i];
      try {
        const val = AppStorage.get(key) as number;
        this.dataStore.put(key, val);
      } catch (e) {
        hilog.error(DOMAIN, 'Persistence', 'Failed to save key %{public}s: %{public}s', key, JSON.stringify(e));
      }
    }
    try {
      await this.dataStore.flush();
    } catch (e) {
      hilog.error(DOMAIN, 'Persistence', 'Failed to flush: %{public}s', JSON.stringify(e));
    }
    hilog.info(DOMAIN, 'Persistence', 'Data saved');
  }
}
