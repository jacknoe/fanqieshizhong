export const DEFAULT_FOCUS_MINUTES = 25;
export const DEFAULT_SHORT_BREAK_MINUTES = 5;
export const DEFAULT_LONG_BREAK_MINUTES = 15;
export const POMODOROS_BEFORE_LONG_BREAK = 4;

export enum TimerState {
  IDLE = 'IDLE',
  FOCUSING = 'FOCUSING',
  FOCUS_PAUSED = 'FOCUS_PAUSED',
  SHORT_BREAK = 'SHORT_BREAK',
  SHORT_BREAK_PAUSED = 'SHORT_BREAK_PAUSED',
  LONG_BREAK = 'LONG_BREAK',
  LONG_BREAK_PAUSED = 'LONG_BREAK_PAUSED',
}

export class AppStorageKeys {
  static readonly TIMER_STATE: string = 'timer_state';
  static readonly REMAINING_SECONDS: string = 'remaining_seconds';
  static readonly TOTAL_SECONDS: string = 'total_seconds';
  static readonly COMPLETED_POMODOROS: string = 'completed_pomodoros';
  static readonly SESSION_POMODOROS: string = 'session_pomodoros';
  static readonly FOCUS_MINUTES: string = 'focus_minutes';
  static readonly SHORT_BREAK_MINUTES: string = 'short_break_minutes';
  static readonly LONG_BREAK_MINUTES: string = 'long_break_minutes';
  static readonly DAILY_GOAL: string = 'daily_goal';
  static readonly LONG_BREAK_INTERVAL: string = 'long_break_interval';
  static readonly END_TIMESTAMP: string = 'end_timestamp';
  static readonly TODAY_COMPLETED: string = 'today_completed';
  static readonly TODAY_FOCUS_MINUTES: string = 'today_focus_minutes';
  static readonly CURRENT_TAB: string = 'current_tab';
}

export function formatTime(seconds: number): string {
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return `${m.toString().padStart(2, '0')}:${s.toString().padStart(2, '0')}`;
}

export function getTodayDate(): string {
  const d = new Date();
  return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')}`;
}
