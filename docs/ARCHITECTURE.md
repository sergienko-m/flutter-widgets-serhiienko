# Архітектура застосунку

> Діаграми написано в Mermaid. Для draw.io: **Arrange → Insert → Advanced → Mermaid**
> (вставте код блоку). Для Miro: додаток *Mermaid* / *Diagramming*. Також Mermaid
> рендериться безпосередньо на GitHub.

## 1. Шари

```mermaid
flowchart TD
    UI["UI: screens/ + widgets/"] -->|"читає AppScope.of(context)"| STATE["State: utils/app_state.dart<br/>AppState (ChangeNotifier) + AppScope (InheritedNotifier)"]
    UI -->|викликає методи| STATE
    STATE --> MODELS["models/: User, Product (immutable)"]
    UI --> THEME["utils/themes.dart: AppThemes + AppStyle (ThemeExtension)"]
    STATE --> DATA["utils/constants.dart: mock-дані"]
```

Принципи: єдине джерело правди (`AppState`), імутабельні оновлення колекцій, віджети не зберігають
бізнес-стан, а лише локальний UI-стан (анімації, натискання). Валідація — в моделі/стані, помилки — через `lastError`.

## 2. Дерево віджетів

```mermaid
flowchart TD
    MyApp --> AppScope --> ListenableBuilder --> MaterialApp --> HomeScreen
    HomeScreen --> AppBar
    HomeScreen --> NavRail["NavigationRail / NavigationBar"]
    HomeScreen --> IndexedStack
    IndexedStack --> ShowcaseScreen
    IndexedStack --> ProductsScreen
    IndexedStack --> ProfileScreen
    ShowcaseScreen --> CustomButton
    ShowcaseScreen --> ProfileWidget
    ShowcaseScreen --> AnimatedCounter
    ShowcaseScreen --> LifecycleProbe
    ProductsScreen --> CustomScrollView --> SliverGrid_SliverList
    SliverGrid_SliverList --> ProductCard
    ProductCard --> Dismissible
    ProductCard --> BounceTap
    ProductCard --> ProductArt --> ShimmerBox
    ProfileScreen --> ProfileWidget
    ProfileScreen --> CustomButton
    AnimatedCounter --> BounceTap
```

## 3. Потік стану: додати товар у кошик

```mermaid
sequenceDiagram
    actor U as Користувач
    participant C as ProductCard
    participant P as ProductsScreen
    participant S as AppState
    participant H as HomeScreen (Badge)
    U->>C: tap "У кошик"
    C->>P: onAddToCart()
    P->>S: addToCart(product)
    alt кількість > ліміту або <= 0
        S-->>P: false + lastError
        P->>U: SnackBar з помилкою
    else успіх
        S->>S: _cart = {..._cart, product: qty+1}
        S-->>H: notifyListeners() → InheritedNotifier
        H->>U: Badge оновлено
        P->>U: SnackBar "додано"
    end
```

## 4. Потік стану: обране (swipe)

```mermaid
flowchart LR
    A["Swipe / tap ♡ на ProductCard"] --> B["confirmDismiss → onFavoriteToggle()"]
    B --> C["AppState.toggleFavorite(product)"]
    C --> D["нова копія _favoriteProducts"]
    D --> E["notifyListeners()"]
    E --> F["ProductsScreen / ProfileScreen перебудовуються"]
    F --> G["ProductCard.didUpdateWidget → пульс сердечка"]
```

## 5. API contract (mock)

Дані зараз беруться з `kMockProducts`. Контракт, під який легко замінити джерело на REST:

| Метод | Шлях | Опис | Відповідь |
|---|---|---|---|
| GET | `/api/products?category=` | список товарів | `200 [Product]` |
| GET | `/api/products/{id}` | один товар | `200 Product` / `404` |
| GET | `/api/me` | поточний користувач | `200 User` |
| PUT | `/api/me` | оновити профіль (`name`, `email`) | `200 User` / `422 {error}` |
| POST | `/api/cart/items` | `{productId, quantity}` | `200 Cart` / `422 {error}` |
| DELETE | `/api/cart/items/{productId}` | прибрати з кошика | `204` |
| PUT/DELETE | `/api/favorites/{productId}` | додати/прибрати з обраного | `204` |

```json
// Product
{ "id": "p1", "title": "Бездротові навушники", "description": "…",
  "price": 1899.0, "category": "Електроніка", "emoji": "🎧",
  "colorValue": 4282431989, "imageUrl": null }
// User
{ "id": "u1", "name": "Олександр Шевченко", "email": "oleksandr@example.com", "avatarUrl": null }
```
