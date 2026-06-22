import { AppStorageKeys } from '../utils/Constants';

@Component
export struct StatisticsPage {
  @StorageLink(AppStorageKeys.TODAY_COMPLETED) todayCompleted: number = 0;
  @StorageLink(AppStorageKeys.TODAY_FOCUS_MINUTES) todayFocusMinutes: number = 0;
  @StorageLink(AppStorageKeys.COMPLETED_POMODOROS) totalCompleted: number = 0;
  @StorageLink(AppStorageKeys.DAILY_GOAL) dailyGoal: number = 8;

  private settings: CanvasRenderingContext2D = new CanvasRenderingContext2D();
  private chartWidth: number = 360;

  get goalProgress(): number {
    if (this.dailyGoal <= 0) return 0;
    return Math.min(1, this.todayCompleted / this.dailyGoal);
  }

  build() {
    Column() {
      Scroll() {
        Column() {
          this.createTodayCard()

          this.createStatsGrid()

          this.createGoalCard()

          this.createWeekChart()
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
  createTodayCard() {
    Column() {
      Text('今日概览')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)
        .fontColor('#FFFFFF')
      Row() {
        StatItem({ label: '完成番茄', value: `${this.todayCompleted}`, color: '#FF6B6B' })
        StatItem({ label: '专注时长', value: `${this.todayFocusMinutes}分钟`, color: '#4ECB71' })
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceAround)
      .margin({ top: 16 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#16213E')
    .borderRadius(16)
  }

  @Builder
  createStatsGrid() {
    Row() {
      StatItem({ label: '累计番茄', value: `${this.totalCompleted}`, color: '#FFA500' })
    }
    .width('100%')
    .justifyContent(FlexAlign.SpaceAround)
    .margin({ top: 16 })
    .padding(20)
    .backgroundColor('#16213E')
    .borderRadius(16)
  }

  @Builder
  createGoalCard() {
    Column() {
      Row() {
        Text('每日目标')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#FFFFFF')
        Text(`${this.todayCompleted} / ${this.dailyGoal} 个番茄`)
          .fontSize(14)
          .fontColor('#AAAAAA')
      }
      .width('100%')
      .justifyContent(FlexAlign.SpaceBetween)

      Progress({ value: this.goalProgress, total: 1, type: ProgressType.Ring })
        .width(80)
        .height(80)
        .style({ strokeWidth: 8 })
        .color('#FF6B6B')
        .backgroundColor('#2A2A4A')
        .margin({ top: 12 })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#16213E')
    .borderRadius(16)
    .margin({ top: 16 })
  }

  @Builder
  createWeekChart() {
    Column() {
      Text('本周趋势')
        .fontSize(16)
        .fontWeight(FontWeight.Medium)
        .fontColor('#FFFFFF')

      Canvas(this.settings)
        .width('100%')
        .height(180)
        .backgroundColor('#0D1117')
        .borderRadius(12)
        .margin({ top: 12 })
        .onReady(() => {
          this.drawWeekChart();
        })
    }
    .width('100%')
    .padding(20)
    .backgroundColor('#16213E')
    .borderRadius(16)
    .margin({ top: 16 })
  }

  drawWeekChart(): void {
    const ctx = this.settings;
    const width = this.chartWidth;
    const height = 160;
    const pad = 30;
    const chartW = width - pad * 2;
    const chartH = height - pad * 2;
    const barCount = 7;
    const barW = chartW / barCount - 8;

    ctx.clearRect(0, 0, width, height);

    const days = ['一', '二', '三', '四', '五', '六', '日'];
    const values = this.getWeekData();

    let maxVal = 1;
    for (let i = 0; i < values.length; i++) {
      if (values[i] > maxVal) maxVal = values[i];
    }

    for (let i = 0; i < barCount; i++) {
      const x = pad + i * (chartW / barCount) + 4;
      const barH = (values[i] / maxVal) * chartH;
      const y = pad + chartH - barH;

      ctx.beginPath();
      ctx.roundRect(x, y, barW, barH, 4);
      ctx.fillStyle = '#FF6B6B';
      ctx.fill();

      ctx.beginPath();
      ctx.textAlign = 'center';
      ctx.font = '12px sans-serif';
      ctx.fillStyle = '#888888';
      ctx.fillText(days[i], x + barW / 2, pad + chartH + 16);

      if (values[i] > 0) {
        ctx.fillStyle = '#FFFFFF';
        ctx.font = '10px sans-serif';
        ctx.fillText(`${values[i]}`, x + barW / 2, y - 6);
      }
    }
  }

  getWeekData(): number[] {
    const data: number[] = [];
    const today = new Date();
    const dayOfWeek = today.getDay();
    const mondayOffset = dayOfWeek === 0 ? -6 : 1 - dayOfWeek;
    for (let i = 0; i < 7; i++) {
      const d = new Date(today);
      d.setDate(today.getDate() + mondayOffset + i);
      const dateStr = `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')}`;
      if (dateStr === this.getTodayDateStr()) {
        data.push(this.todayCompleted);
      } else {
        data.push(0);
      }
    }
    return data;
  }

  getTodayDateStr(): string {
    const d = new Date();
    return `${d.getFullYear()}-${(d.getMonth() + 1).toString().padStart(2, '0')}-${d.getDate().toString().padStart(2, '0')}`;
  }
}

@Component
export struct StatItem {
  @Prop label: string = '';
  @Prop value: string = '';
  @Prop color: ResourceColor = '#FFFFFF';

  build() {
    Column() {
      Text(this.value)
        .fontSize(32)
        .fontWeight(FontWeight.Bold)
        .fontColor(this.color)
      Text(this.label)
        .fontSize(13)
        .fontColor('#AAAAAA')
        .margin({ top: 4 })
    }
  }
}
