# Конспект: віджети та компоненти Flutter

## 1. Stateless vs Stateful

| | StatelessWidget | StatefulWidget |
|---|---|---|
| Стан | немає змінного стану, все в полях `final` | стан у класі `State`, змінюється через `setState` |
| Перебудова | лише коли батько створив новий екземпляр | при `setState`, зміні `InheritedWidget`, оновленні батька |
| Приклад у проєкті | `CustomButton`, `ProfileWidget` | `AnimatedCounter`, `ProductCard`, `ProductsScreen` |
| Коли використовувати | відображення за вхідними параметрами | анімації (потрібен `Ticker`), контролери, таймери, локальний UI-стан |

Правило: стан піднімаємо якомога вище (`AppState`), локальний UI-стан (натиснуто / розгорнуто) тримаємо в `State`.

## 2. Layout-віджети

* **Container** — декор (колір, рамка, радіус, тінь), padding/margin, розмір.
* **Row / Column** — лінійна розкладка; `mainAxisAlignment` (вздовж осі), `crossAxisAlignment` (впоперек), `Expanded`/`Flexible` розподіляють вільне місце.
* **Stack + Positioned** — накладання елементів; `Positioned` задає відступи від країв `Stack`, `Align` — вирівнювання.
* Адаптивність: `LayoutBuilder` (за обмеженнями батька), `MediaQuery.sizeOf` (за розміром екрана), `Wrap`, `SliverGridDelegateWithMaxCrossAxisExtent`.

## 3. Списки

* **ListView** — прокручуваний лінійний список; `ListView.builder` будує елементи ліниво (для довгих списків).
* **GridView** — сітка; `SliverGridDelegateWithFixedCrossAxisCount` (фіксована кількість колонок) або `...WithMaxCrossAxisExtent` (максимальна ширина клітинки).
* **CustomScrollView + slivers** — комбінує різнорідні прокручувані частини в одному скролі (`SliverAppBar`, `SliverToBoxAdapter`, `SliverGrid`, `SliverList`). Використано в `ProductsScreen`.

## 4. Material Design компоненти

`Scaffold` (каркас екрана: appBar, body, bottomNavigationBar, drawer, FAB), `AppBar`, кнопки (`FilledButton`, `OutlinedButton`, `TextButton`, `IconButton`), `Card`, діалоги (`AlertDialog`, `showDialog`), `SnackBar`, `NavigationBar` / `NavigationRail`, `Badge`, `Chip`, `SegmentedButton`.

## 5. Cupertino (iOS-style)

`CupertinoButton`, `CupertinoSwitch`, `CupertinoSlider`, `CupertinoActivityIndicator`, `CupertinoAlertDialog` + `showCupertinoDialog`, `CupertinoNavigationBar`. Адаптивні варіанти (`Switch.adaptive`, `.adaptive` конструктори) обирають стиль залежно від платформи. Приклади — на екрані Showcase.

## 6. Власні (custom) віджети

1. Композиція: збираємо з наявних віджетів (краще, ніж успадкування).
2. Параметри через `final`-поля + `const`-конструктор, `required` для обов'язкових.
3. Стилізація через `Theme` / `ThemeExtension` (`AppStyle`), а не «зашиті» кольори.
4. Колбеки (`VoidCallback`, `ValueChanged<T>`) замість прямого доступу до стану батька.
5. `Key` для керування ідентичністю елементів у списках; `Semantics` для доступності.
6. Крайній варіант — `CustomPainter` / `RenderObject` (малювання власної графіки).

## 7. Lifecycle `State`

```
createState → initState → didChangeDependencies → build
                                  ↑                   │
          didUpdateWidget ← (батько оновив віджет)    │ setState
                                                      ↓
                              deactivate → dispose
```

| Метод | Коли | Типове використання |
|---|---|---|
| `initState` | 1 раз після створення | створити `AnimationController`, `TextEditingController`, таймер |
| `didChangeDependencies` | після `initState` і при зміні `InheritedWidget` | читати `Theme`/`MediaQuery`/`AppScope` |
| `didUpdateWidget(old)` | батько передав нову конфігурацію | оновити контролер, якщо змінились параметри |
| `build` | коли потрібно перемалювати | лише повертає дерево, без побічних ефектів |
| `deactivate` | State тимчасово виключено з дерева | рідко потрібен |
| `dispose` | остаточне видалення | **звільнити** контролери, таймери, підписки |

У проєкті: `AnimatedCounter` (initState/didUpdateWidget/dispose), `ProductCard` (didUpdateWidget запускає «пульс» сердечка), `ProductsScreen` (Timer у initState, cancel у dispose), демо-логер на екрані Showcase.
