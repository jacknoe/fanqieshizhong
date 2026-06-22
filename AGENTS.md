# ArkTS 规则备忘录

ArkTS 比 TypeScript 严格，以下写法一律禁止：

- `as const` → 用 `enum`
- `AppStorage.get<T>()` / `.set<T>()` → 去掉泛型，用 `as` 断言
- `type T = { ... }` 和匿名对象 `{ ... }` → 用 `class` + `new`
- `interface` → 用 `class`
- `@Builder` 方法不能传 `() => void` 参数 → 拆成多个无参 builder
- 组件传参用 `Comp({ prop: val })` 对象语法，不用位置参数
- 子组件属性用 `@Prop` 而非 `private`
- 数组 spread `...arr` 禁止 → 改用 `for` 循环
