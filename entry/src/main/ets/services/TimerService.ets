import { DEFAULT_FOCUS_MINUTES, DEFAULT_SHORT_BREAK_MINUTES, DEFAULT_LONG_BREAK_MINUTES,
  POMODOROS_BEFORE_LONG_BREAK, TimerState, AppStorageKeys } from '../utils/Constants';

export class TimerService {
  private static instance: TimerService;
  private timerId: number = -1;
  private updateIntervalId: number = -1;
  private onFocusComplete: (() => void) | null = null;

  static getInstance(): TimerService {
    if (TimerService.instance === undefined) {
      TimerService.instance = new TimerService();
    }
    return TimerService.instance;
  }

  setOnFocusComplete(callback: () => void): void {
    this.onFocusComplete = callback;
  }

  init(): void {
    AppStorage.setOrCreate(AppStorageKeys.TIMER_STATE, TimerState.IDLE);
    AppStorage.setOrCreate(AppStorageKeys.REMAINING_SECONDS, DEFAULT_FOCUS_MINUTES * 60);
    AppStorage.setOrCreate(AppStorageKeys.TOTAL_SECONDS, DEFAULT_FOCUS_MINUTES * 60);
    AppStorage.setOrCreate(AppStorageKeys.COMPLETED_POMODOROS, 0);
    AppStorage.setOrCreate(AppStorageKeys.SESSION_POMODOROS, 0);
    AppStorage.setOrCreate(AppStorageKeys.FOCUS_MINUTES, DEFAULT_FOCUS_MINUTES);
    AppStorage.setOrCreate(AppStorageKeys.SHORT_BREAK_MINUTES, DEFAULT_SHORT_BREAK_MINUTES);
    AppStorage.setOrCreate(AppStorageKeys.LONG_BREAK_MINUTES, DEFAULT_LONG_BREAK_MINUTES);
    AppStorage.setOrCreate(AppStorageKeys.DAILY_GOAL, 8);
    AppStorage.setOrCreate(AppStorageKeys.LONG_BREAK_INTERVAL, POMODOROS_BEFORE_LONG_BREAK);
    AppStorage.setOrCreate(AppStorageKeys.END_TIMESTAMP, 0);
    AppStorage.setOrCreate(AppStorageKeys.TODAY_COMPLETED, 0);
    AppStorage.setOrCreate(AppStorageKeys.TODAY_FOCUS_MINUTES, 0);
    AppStorage.setOrCreate(AppStorageKeys.CURRENT_TAB, 0);
  }

  getState(): string {
    return AppStorage.get(AppStorageKeys.TIMER_STATE) as string;
  }

  startFocus(): void {
    const focusMinutes = AppStorage.get(AppStorageKeys.FOCUS_MINUTES) as number;
    const totalSec = focusMinutes * 60;
    AppStorage.setOrCreate(AppStorageKeys.TOTAL_SECONDS, totalSec);
    AppStorage.setOrCreate(AppStorageKeys.REMAINING_SECONDS, totalSec);
    AppStorage.setOrCreate(AppStorageKeys.TIMER_STATE, TimerState.FOCUSING);
    this.startTicking(totalSec);
  }

  startShortBreak(): void {
    const breakMinutes = AppStorage.get(AppStorageKeys.SHORT_BREAK_MINUTES) as number;
    const totalSec = breakMinutes * 60;
    AppStorage.setOrCreate(AppStorageKeys.TOTAL_SECONDS, totalSec);
    AppStorage.setOrCreate(AppStorageKeys.REMAINING_SECONDS, totalSec);
    AppStorage.setOrCreate(AppStorageKeys.TIMER_STATE, TimerState.SHORT_BREAK);
    this.startTicking(totalSec);
  }

  startLongBreak(): void {
    const breakMinutes = AppStorage.get(AppStorageKeys.LONG_BREAK_MINUTES) as number;
    const totalSec = breakMinutes * 60;
    AppStorage.setOrCreate(AppStorageKeys.TOTAL_SECONDS, totalSec);
    AppStorage.setOrCreate(AppStorageKeys.REMAINING_SECONDS, totalSec);
    AppStorage.setOrCreate(AppStorageKeys.TIMER_STATE, TimerState.LONG_BREAK);
    this.startTicking(totalSec);
  }

  pause(): void {
    const state = this.getState();
    let newState = state;
    if (state === TimerState.FOCUSING) {
      newState = TimerState.FOCUS_PAUSED;
    } else if (state === TimerState.SHORT_BREAK) {
      newState = TimerState.SHORT_BREAK_PAUSED;
    } else if (state === TimerState.LONG_BREAK) {
      newState = TimerState.LONG_BREAK_PAUSED;
    }
    AppStorage.setOrCreate(AppStorageKeys.TIMER_STATE, newState);
    AppStorage.setOrCreate(AppStorageKeys.END_TIMESTAMP, 0);
    this.stopTicking();
  }

  resume(): void {
    const state = this.getState();
    const remaining = AppStorage.get(AppStorageKeys.REMAINING_SECONDS) as number;
    let newState = state;
    if (state === TimerState.FOCUS_PAUSED) {
      newState = TimerState.FOCUSING;
    } else if (state === TimerState.SHORT_BREAK_PAUSED) {
      newState = TimerState.SHORT_BREAK;
    } else if (state === TimerState.LONG_BREAK_PAUSED) {
      newState = TimerState.LONG_BREAK;
    }
    AppStorage.setOrCreate(AppStorageKeys.TIMER_STATE, newState);
    this.startTicking(remaining);
  }

  reset(): void {
    this.stopTicking();
    const focusMinutes = AppStorage.get(AppStorageKeys.FOCUS_MINUTES) as number;
    AppStorage.setOrCreate(AppStorageKeys.TIMER_STATE, TimerState.IDLE);
    AppStorage.setOrCreate(AppStorageKeys.REMAINING_SECONDS, focusMinutes * 60);
    AppStorage.setOrCreate(AppStorageKeys.TOTAL_SECONDS, focusMinutes * 60);
    AppStorage.setOrCreate(AppStorageKeys.END_TIMESTAMP, 0);
  }

  handleAppForeground(): void {
    const state = this.getState();
    const endTs = AppStorage.get(AppStorageKeys.END_TIMESTAMP) as number;
    const running = state === TimerState.FOCUSING || state === TimerState.SHORT_BREAK || state === TimerState.LONG_BREAK;
    if (running && endTs > 0) {
      const remaining = Math.max(0, Math.ceil((endTs - Date.now()) / 1000));
      AppStorage.setOrCreate(AppStorageKeys.REMAINING_SECONDS, remaining);
      if (remaining <= 0) {
        this.handleTimerComplete();
      } else {
        this.startTicking(remaining);
      }
    } else if (running) {
      const remaining = AppStorage.get(AppStorageKeys.REMAINING_SECONDS) as number;
      if (remaining > 0) {
        this.startTicking(remaining);
      }
    }
  }

  handleAppBackground(): void {
    const state = this.getState();
    const running = state === TimerState.FOCUSING || state === TimerState.SHORT_BREAK || state === TimerState.LONG_BREAK;
    if (running) {
      const remaining = AppStorage.get(AppStorageKeys.REMAINING_SECONDS) as number;
      AppStorage.setOrCreate(AppStorageKeys.END_TIMESTAMP, Date.now() + remaining * 1000);
    }
    this.stopTicking();
  }

  private startTicking(seconds: number): void {
    this.stopTicking();
    let remaining = seconds;
    this.timerId = setInterval(() => {
      remaining--;
      AppStorage.setOrCreate(AppStorageKeys.REMAINING_SECONDS, remaining);
      if (remaining <= 0) {
        this.stopTicking();
        this.handleTimerComplete();
      }
    }, 1000);
  }

  private stopTicking(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
    if (this.updateIntervalId !== -1) {
      clearInterval(this.updateIntervalId);
      this.updateIntervalId = -1;
    }
  }

  private handleTimerComplete(): void {
    const state = this.getState();
    AppStorage.setOrCreate(AppStorageKeys.REMAINING_SECONDS, 0);
    AppStorage.setOrCreate(AppStorageKeys.END_TIMESTAMP, 0);

    if (state === TimerState.FOCUSING) {
      let completed = AppStorage.get(AppStorageKeys.COMPLETED_POMODOROS) as number;
      let session = AppStorage.get(AppStorageKeys.SESSION_POMODOROS) as number;
      completed++;
      session++;
      AppStorage.setOrCreate(AppStorageKeys.COMPLETED_POMODOROS, completed);
      AppStorage.setOrCreate(AppStorageKeys.SESSION_POMODOROS, session);
      this.updateTodayStats();
      if (this.onFocusComplete !== null) {
        this.onFocusComplete();
      }
    } else {
      AppStorage.setOrCreate(AppStorageKeys.TIMER_STATE, TimerState.IDLE);
      const focusMinutes = AppStorage.get(AppStorageKeys.FOCUS_MINUTES) as number;
      AppStorage.setOrCreate(AppStorageKeys.REMAINING_SECONDS, focusMinutes * 60);
      AppStorage.setOrCreate(AppStorageKeys.TOTAL_SECONDS, focusMinutes * 60);
    }
  }

  private updateTodayStats(): void {
    let todayCompleted = AppStorage.get(AppStorageKeys.TODAY_COMPLETED) as number;
    let todayMinutes = AppStorage.get(AppStorageKeys.TODAY_FOCUS_MINUTES) as number;
    todayCompleted++;
    const focusMinutes = AppStorage.get(AppStorageKeys.FOCUS_MINUTES) as number;
    todayMinutes += focusMinutes;
    AppStorage.setOrCreate(AppStorageKeys.TODAY_COMPLETED, todayCompleted);
    AppStorage.setOrCreate(AppStorageKeys.TODAY_FOCUS_MINUTES, todayMinutes);
  }

  getTodayCompleted(): number {
    return AppStorage.get(AppStorageKeys.TODAY_COMPLETED) as number;
  }

  getSessionCount(): number {
    return AppStorage.get(AppStorageKeys.SESSION_POMODOROS) as number;
  }

  resetDailyStats(): void {
    AppStorage.setOrCreate(AppStorageKeys.TODAY_COMPLETED, 0);
    AppStorage.setOrCreate(AppStorageKeys.TODAY_FOCUS_MINUTES, 0);
    AppStorage.setOrCreate(AppStorageKeys.COMPLETED_POMODOROS, 0);
    AppStorage.setOrCreate(AppStorageKeys.SESSION_POMODOROS, 0);
  }
}
