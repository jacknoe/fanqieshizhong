# ArkTS 避坑规则

## 1. 不要用 `as const`
```ts
// ❌
const State = { IDLE: 'IDLE' } as const;
// ✅
enum State { IDLE = 'IDLE' }
```

## 2. 不要写泛型 `AppStorage.get<T>()`
```ts
// ❌
AppStorage.get<number>('key');
AppStorage.set<string>('key', 'val');
// ✅
AppStorage.get('key') as number;
AppStorage.set('key', 'val'); // 类型靠参数推断
```

## 3. 不要用对象字面量和 type 声明类型
```ts
// ❌
type Foo = { a: number; b: string };
const x: Foo = { a: 1, b: '' };
// ✅
class Foo { a: number = 0; b: string = ''; constructor(a: number, b: string) { this.a = a; this.b = b; } }
const x = new Foo(1, '');
```

## 4. `@Builder` 不能传函数参数
```ts
// ❌
@Builder foo(cb: () => void) { ... }
this.foo(() => {});
// ✅
// 拆成多个无参 @Builder，直接访问 this.xxx
@Builder focusBtn() { Button().onClick(() => { this.timerService.startFocus(); }) }
```

## 5. 组件传参用对象语法
```ts
// ❌
StatItem('label', 'value', '#c');
// ✅
StatItem({ label: 'label', value: 'value', color: '#c' });
```

## 6. 子组件属性用 `@Prop`
```ts
// ❌
@Component struct Child { private value: string = ''; }
// ✅
@Component struct Child { @Prop value: string = ''; }
```

## 7. 不要用 `interface`
```ts
// ❌
interface Foo { a: number; }
// ✅ 用 class 代替
class Foo { a: number = 0; constructor(a: number) { this.a = a; } }
```

## 8. 不要用 spread 运算符
```ts
// ❌
Math.max(...arr);
// ✅
let m = 0; for (let i = 0; i < arr.length; i++) { if (arr[i] > m) m = arr[i]; }
```
